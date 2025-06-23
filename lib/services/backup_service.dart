import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
import 'package:logger/logger.dart';

// Classe para passar dados entre isolates (mantida para consistência)
class BackupIsolateData {
  final String userId;
  final String? outputPath;
  final String? jsonString;
  final String? backupId;
  final SendPort sendPort;

  BackupIsolateData({
    required this.userId,
    this.outputPath,
    this.jsonString,
    this.backupId,
    required this.sendPort,
  });
}

// Resultado das operações de backup
class BackupResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  BackupResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class BackupService {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger(printer: PrettyPrinter());

  // ==================== OPERAÇÕES DE ARQUIVO LOCAL (sem alterações) ====================

  Future<BackupResult> exportRecipesToJsonAsync({
    required String userId,
    required String outputPath,
  }) async {
    try {
      _logger.i("Iniciando exportação para o caminho: $outputPath");
      final List<Receita> recipes = await _receitaRepository.listarReceitasPorUsuario(userId);
      if (recipes.isEmpty) {
        return BackupResult(success: false, message: "Nenhuma receita encontrada para exportar.");
      }

      final receivePort = ReceivePort();
      await Isolate.spawn(
        _exportRecipesToJsonIsolate,
        {
          'userId': userId,
          'outputPath': outputPath,
          'recipes': recipes.map((r) => r.toMapCompleto()).toList(),
          'sendPort': receivePort.sendPort,
        },
      );

      final result = await receivePort.first as BackupResult;
      return result;
    } catch (e, stackTrace) {
      _logger.e('Erro ao iniciar isolate de exportação', error: e, stackTrace: stackTrace);
      return BackupResult(success: false, message: 'Erro ao exportar: ${e.toString()}');
    }
  }

  Future<BackupResult> importRecipesFromJsonAsync({
    required String userId,
    required String jsonString,
  }) async {
    // >> CORREÇÃO IMPORTANTE <<
    // A restauração a partir de um JSON também não pode ocorrer no Isolate secundário
    // porque ele precisa acessar o `ReceitaRepository` (SQLite).
    // O Isolate deve apenas preparar os dados.
    try {
      final receivePort = ReceivePort();

      await Isolate.spawn(
        _prepareRecipesFromJsonIsolate, // Função renomeada para clareza
        BackupIsolateData(
          userId: userId,
          jsonString: jsonString,
          sendPort: receivePort.sendPort,
        ),
      );

      // O Isolate retorna uma lista de objetos Receita prontos para serem inseridos
      final dynamic isolateResult = await receivePort.first;

      if (isolateResult is BackupResult && !isolateResult.success) {
        return isolateResult; // Retorna o erro vindo do Isolate
      }

      final List<Receita> recipesToImport = isolateResult as List<Receita>;
      int importedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      // A inserção no banco de dados ocorre no Isolate principal
      for (final receita in recipesToImport) {
        try {
           bool success = await _receitaRepository.adicionarComBackup(receita);
           if (success) {
             importedCount++;
           } else {
             errorCount++;
           }
        } catch (e) {
            errorCount++;
        }
      }

      String resultado = "Importação concluída!\n";
      resultado += "$importedCount receitas importadas com sucesso\n";
      if (skippedCount > 0) resultado += "$skippedCount receitas puladas\n";
      if (errorCount > 0) resultado += "$errorCount receitas com erro\n";

      return BackupResult(
        success: true,
        message: resultado,
        data: {'imported': importedCount, 'skipped': skippedCount, 'errors': errorCount},
      );
    } catch (e) {
      _logger.e('Erro ao importar de JSON', error: e);
      return BackupResult(success: false, message: 'Erro ao importar: ${e.toString()}');
    }
  }


  // ==================== OPERAÇÕES COM FIREBASE (COM CORREÇÕES) ====================

  /// Faz backup para Firestore de forma assíncrona
  Future<BackupResult> backupRecipesToFirestoreAsync({
    required String userId,
  }) async {
    try {
      // 1. Obter dados do SQLite no Isolate principal (Correto)
      final List<Receita> recipes = await _receitaRepository.listarReceitasPorUsuario(userId);

      if (recipes.isEmpty) {
        return BackupResult(success: false, message: "Nenhuma receita encontrada para backup.");
      }

      final receivePort = ReceivePort();

      // 2. Enviar dados para o Isolate secundário apenas para preparação do JSON
      await Isolate.spawn(
        _prepareFirestoreBackupIsolate, // Função renomeada e corrigida
        {
          'userId': userId,
          'recipes': recipes.map((r) => r.toMapCompleto()).toList(),
          'sendPort': receivePort.sendPort,
        },
      );

      // 3. Receber o mapa de dados preparado do Isolate
      final result = await receivePort.first;

      if (result is Map<String, dynamic> && result.containsKey('error')) {
         return BackupResult(success: false, message: "Erro no Isolate: ${result['error']}");
      }
      
      final preparedData = result as Map<String, dynamic>;
      final String backupId = preparedData['backupId'];
      final Map<String, dynamic> backupData = preparedData['backupData'];

      // 4. >> CORREÇÃO << Adicionar o FieldValue.serverTimestamp() no Isolate principal
      backupData['metadata']['criadoEm'] = FieldValue.serverTimestamp();

      // 5. Salvar no Firestore a partir do Isolate principal (Correto)
      await _firestore
          .collection('backups')
          .doc(userId)
          .collection('user_backups')
          .doc(backupId)
          .set(backupData);

      return BackupResult(
        success: true,
        message: "Backup na nuvem criado com sucesso!\nBackup ID: $backupId\n${recipes.length} receitas salvas",
        data: {'backupId': backupId},
      );
    } catch (e) {
      _logger.e('Erro no backup assíncrono para Firestore', error: e);
      return BackupResult(success: false, message: 'Erro ao fazer backup: ${e.toString()}');
    }
  }

  /// Restaura backup do Firestore de forma assíncrona
  Future<BackupResult> restoreFromFirestoreAsync({
    required String userId,
    required String backupId,
  }) async {
    try {
      // 1. Obter dados do Firestore no Isolate principal (Correto)
      final DocumentSnapshot doc = await _firestore
          .collection('backups')
          .doc(userId)
          .collection('user_backups')
          .doc(backupId)
          .get();

      if (!doc.exists) {
        return BackupResult(success: false, message: "Backup não encontrado.");
      }

      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> recipesData = data['recipes'] ?? [];

      if (recipesData.isEmpty) {
        return BackupResult(success: false, message: "Nenhuma receita encontrada no backup.");
      }

      final receivePort = ReceivePort();

      // 2. >> CORREÇÃO << Enviar os dados brutos para o Isolate apenas para desserializar
      await Isolate.spawn(
        _prepareRestoreDataIsolate, // Função renomeada e corrigida
        {
          'userId': userId,
          'recipesData': recipesData,
          'sendPort': receivePort.sendPort,
        },
      );

      // 3. Receber a lista de objetos `Receita` prontos do Isolate
      final dynamic isolateResult = await receivePort.first;

      if (isolateResult is BackupResult && !isolateResult.success) {
        return isolateResult; // Retorna o erro vindo do Isolate
      }

      final List<Receita> recipesToRestore = isolateResult as List<Receita>;
      int restoredCount = 0;
      int skippedCount = 0; // Você pode implementar a lógica de pular se quiser
      int errorCount = 0;

      // 4. >> CORREÇÃO << Iterar e salvar no banco de dados (SQLite) no Isolate principal
      for (final receita in recipesToRestore) {
        try {
          // A lógica de pular receitas vazias já foi feita no Isolate
          bool success = await _receitaRepository.adicionarComBackup(receita);
          if (success) {
            restoredCount++;
          } else {
            errorCount++;
          }
        } catch(e) {
          errorCount++;
        }
      }

      String resultado = "Backup restaurado com sucesso!\n";
      resultado += "$restoredCount receitas restauradas\n";
      if (skippedCount > 0) resultado += "$skippedCount receitas puladas\n";
      if (errorCount > 0) resultado += "$errorCount receitas com erro\n";

      return BackupResult(
          success: true,
          message: resultado,
          data: {'restored': restoredCount, 'skipped': skippedCount, 'errors': errorCount},
        );

    } catch (e) {
      _logger.e('Erro na restauração assíncrona do Firestore', error: e);
      return BackupResult(success: false, message: 'Erro ao restaurar: ${e.toString()}');
    }
  }


  // ==================== ISOLATE FUNCTIONS (CORRIGIDAS) ====================

  static void _exportRecipesToJsonIsolate(Map<String, dynamic> data) async {
    final sendPort = data['sendPort'] as SendPort;
    try {
      final userId = data['userId'] as String;
      final outputPath = data['outputPath'] as String;
      final List<dynamic> recipes = data['recipes'];

      final Map<String, dynamic> backupData = {
        'metadata': {
          'userId': userId,
          'backupDate': DateTime.now().toIso8601String(),
          'totalRecipes': recipes.length,
          'version': '1.0',
        },
        'recipes': recipes,
      };

      final String jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      final file = File(outputPath);
      await file.writeAsString(jsonString, encoding: utf8);
      final fileSize = await file.length();

      sendPort.send(BackupResult(
        success: true,
        message: "Backup criado com sucesso!\nLocal: $outputPath\nTamanho: ${(fileSize / 1024).toStringAsFixed(1)} KB\n${recipes.length} receitas exportadas",
        data: {'filePath': outputPath, 'recipesCount': recipes.length},
      ));
    } catch (e) {
      // Logger não está disponível aqui, então enviamos o erro de volta
      sendPort.send(BackupResult(success: false, message: "Erro ao criar backup no isolate: ${e.toString()}"));
    }
  }

  // >> NOVA FUNÇÃO DE ISOLATE <<
  // Apenas prepara a lista de Receitas, não acessa o banco de dados.
  static void _prepareRecipesFromJsonIsolate(BackupIsolateData data) {
    try {
      final Map<String, dynamic> backupData = jsonDecode(data.jsonString!);
      if (!backupData.containsKey('recipes')) {
        data.sendPort.send(BackupResult(success: false, message: "Formato de backup inválido."));
        return;
      }

      final List<dynamic> recipesData = backupData['recipes'];
      final List<Receita> recipesToImport = [];

      for (final recipeData in recipesData) {
        final receita = Receita.fromMap(recipeData as Map<String, dynamic>);
        receita.userId = data.userId; // Atribui o userId
        
        if (receita.ingredientes.isNotEmpty || receita.instrucoes.isNotEmpty) {
           recipesToImport.add(receita);
        }
      }

      // Envia a lista de objetos prontos de volta para o Isolate principal
      data.sendPort.send(recipesToImport);

    } catch (e) {
      data.sendPort.send(BackupResult(success: false, message: "Erro ao processar o arquivo JSON: ${e.toString()}"));
    }
  }

  // >> FUNÇÃO DE ISOLATE CORRIGIDA <<
  // Apenas prepara o mapa de dados. Não usa FieldValue.
  static void _prepareFirestoreBackupIsolate(Map<String, dynamic> data) {
    final sendPort = data['sendPort'] as SendPort;
    try {
      final String backupId = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final recipes = data['recipes'] as List<dynamic>;

      // O timestamp será adicionado no Isolate principal
      final backupData = {
        'metadata': {
          'userId': data['userId'],
          'backupId': backupId,
          // 'criadoEm' foi removido daqui
          'totalReceitas': recipes.length,
          'versao': '1.0',
        },
        'recipes': recipes,
      };

      sendPort.send({
        'backupId': backupId,
        'backupData': backupData,
      });
    } catch (e) {
      sendPort.send({'error': e.toString()});
    }
  }
  
  // >> FUNÇÃO DE ISOLATE CORRIGIDA <<
  // Apenas desserializa os dados para objetos `Receita`. Não acessa o SQLite.
  static void _prepareRestoreDataIsolate(Map<String, dynamic> data) {
    final sendPort = data['sendPort'] as SendPort;
    try {
      final recipesData = data['recipesData'] as List<dynamic>;
      final userId = data['userId'] as String;
      final List<Receita> restoredRecipes = [];

      for (final recipeData in recipesData) {
        final receita = Receita.fromMap(recipeData as Map<String, dynamic>);
        receita.userId = userId;

        if (receita.ingredientes.isNotEmpty || receita.instrucoes.isNotEmpty) {
          restoredRecipes.add(receita);
        }
      }
      
      // Envia a lista de objetos `Receita` prontos de volta para o Isolate principal
      sendPort.send(restoredRecipes);

    } catch (e) {
      sendPort.send(BackupResult(success: false, message: "Erro ao preparar dados para restauração: ${e.toString()}"));
    }
  }


  // ==================== MÉTODOS SÍNCRONOS (mantidos) ====================
  
  Future<List<Map<String, dynamic>>> listFirestoreBackups({required String userId}) async {
    // ... seu código original aqui ...
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('backups')
          .doc(userId)
          .collection('user_backups')
          .orderBy('metadata.criadoEm', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Garante que o timestamp seja convertido para String para evitar erros
        final metadata = data['metadata'] ?? {};
        if (metadata['criadoEm'] is Timestamp) {
            metadata['criadoEm'] = (metadata['criadoEm'] as Timestamp).toDate().toIso8601String();
        }
        return {
          'id': doc.id,
          'metadata': metadata,
          'totalReceitas': data['metadata']?['totalReceitas'] ?? 0,
        };
      }).toList();
    } catch (e) {
      _logger.e('Erro ao listar backups', error: e);
      return [];
    }
  }

  Future<String> deleteFirestoreBackup({required String userId, required String backupId}) async {
    // ... seu código original aqui ...
    try {
      await _firestore
          .collection('backups')
          .doc(userId)
          .collection('user_backups')
          .doc(backupId)
          .delete();
      _logger.i('Backup deletado com sucesso', error: {'backupId': backupId, 'userId': userId});
      return "Backup deletado com sucesso!";
    } catch (e) {
      _logger.e('Erro ao deletar backup', error: e);
      return "Erro ao deletar backup: ${e.toString()}";
    }
  }

  Future<bool> solicitarPermissaoArmazenamento() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 30) {
        return true;
      } else {
        final status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        }

        if (status.isDenied) {
          final novoStatus = await Permission.storage.request();
          return novoStatus.isGranted;
        }

        if (status.isPermanentlyDenied) {
          _logger.w(
            "Permissão de armazenamento permanentemente negada. Abrindo configurações.",
          );
          await openAppSettings();
          return false;
        }
      }
    }

    return true;
  }

  Future<int> _getAndroidVersion() async {
    try {
      return 30;
    } catch (e) {
      return 30;
    }
  }
}