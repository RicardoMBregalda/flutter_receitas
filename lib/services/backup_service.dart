import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
import 'package:receitas_trabalho_2/services/auth_service.dart';
import 'package:logger/logger.dart';

class BackupService {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Logger configurado
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  // Método para obter o userId do provider
  String? _getUserId(BuildContext context) {
    try {
      return Provider.of<AuthService>(context, listen: false).userId;
    } catch (e) {
      _logger.e('Erro ao obter userId do provider', error: e);
      return null;
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

  Future<String> exportRecipesToJson(BuildContext context) async {
    try {
      final String? userId = _getUserId(context);

      if (userId == null) {
        return "Erro: Usuário não identificado. Faça login novamente.";
      }

      final List<Receita> recipes = await _receitaRepository
          .listarReceitasPorUsuario(userId);

      if (recipes.isEmpty) {
        return "Nenhuma receita encontrada para exportar.";
      }

      final List<Map<String, dynamic>> jsonRecipes =
          recipes.map((recipe) => recipe.toMapCompleto()).toList();

      final Map<String, dynamic> backupData = {
        'metadata': {
          'userId': userId,
          'backupDate': DateTime.now().toIso8601String(),
          'totalRecipes': recipes.length,
          'version': '1.0',
        },
        'recipes': jsonRecipes,
      };

      final String jsonString = JsonEncoder.withIndent(
        '  ',
      ).convert(backupData);

      try {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Selecione onde salvar o backup:',
          fileName:
              'receitas_backup_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: utf8.encode(jsonString),
        );

        if (outputFile != null) {
          _logger.i(
            'Backup local criado com sucesso via FilePicker',
            error: {
              'outputFile': outputFile,
              'size': '${(jsonString.length / 1024).toStringAsFixed(1)} KB',
              'recipesCount': recipes.length,
            },
          );
          return "Backup local criado com sucesso!\n📍 Local: $outputFile\nTamanho: ${(jsonString.length / 1024).toStringAsFixed(1)} KB\n${recipes.length} receitas exportadas";
        }
      } catch (e) {
        _logger.w(
          'FilePicker saveFile falhou, tentando método alternativo',
          error: e,
        );
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'receitas_backup_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString, encoding: utf8);

      if (await file.exists()) {
        final fileSize = await file.length();
        _logger.i(
          'Backup local criado com sucesso no diretório de documentos',
          error: {
            'filePath': file.path,
            'size': '${(fileSize / 1024).toStringAsFixed(1)} KB',
            'recipesCount': recipes.length,
          },
        );
        return "Backup local criado com sucesso!\nLocal: ${file.path}\nTamanho: ${(fileSize / 1024).toStringAsFixed(1)} KB\n${recipes.length} receitas exportadas\n\nNota: Arquivo salvo na pasta de documentos do app.";
      } else {
        return "Erro: Arquivo não foi criado corretamente.";
      }
    } catch (e) {
      _logger.e('Erro no exportRecipesToJson', error: e);
      return "Erro ao criar backup local: ${e.toString()}";
    }
  }

  Future<String> exportAndShareJson(BuildContext context) async {
    try {
      final String? userId = _getUserId(context);

      if (userId == null) {
        return "Erro: Usuário não identificado. Faça login novamente.";
      }

      final List<Receita> recipes = await _receitaRepository
          .listarReceitasPorUsuario(userId);

      if (recipes.isEmpty) {
        return "Nenhuma receita encontrada para exportar.";
      }

      final List<Map<String, dynamic>> jsonRecipes =
          recipes.map((recipe) => recipe.toMapCompleto()).toList();

      final Map<String, dynamic> backupData = {
        'metadata': {
          'userId': userId,
          'backupDate': DateTime.now().toIso8601String(),
          'totalRecipes': recipes.length,
          'version': '1.0',
        },
        'recipes': jsonRecipes,
      };

      final String jsonString = JsonEncoder.withIndent(
        '  ',
      ).convert(backupData);

      final directory = await getTemporaryDirectory();
      final fileName =
          'receitas_backup_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString, encoding: utf8);

      _logger.i(
        'Backup criado para compartilhamento',
        error: {
          'filePath': file.path,
          'size': '${(jsonString.length / 1024).toStringAsFixed(1)} KB',
          'recipesCount': recipes.length,
        },
      );

      return "Backup criado e pronto para compartilhar!\nArquivo temporário: ${file.path}\nTamanho: ${(jsonString.length / 1024).toStringAsFixed(1)} KB\n${recipes.length} receitas exportadas\n\nUse o compartilhamento para salvar onde desejar.";
    } catch (e) {
      _logger.e('Erro no exportAndShareJson', error: e);
      return "Erro ao criar backup: ${e.toString()}";
    }
  }

  Future<String> importRecipesFromJson(BuildContext context) async {
    try {
      final String? userId = _getUserId(context);

      if (userId == null) {
        return "Erro: Usuário não identificado. Faça login novamente.";
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecione o arquivo de backup',
      );

      if (result == null || result.files.isEmpty) {
        return "Nenhum arquivo selecionado.";
      }

      String jsonString;

      if (result.files.single.bytes != null) {
        jsonString = utf8.decode(result.files.single.bytes!);
      } else if (result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (!await file.exists()) {
          return "Arquivo não encontrado.";
        }
        jsonString = await file.readAsString(encoding: utf8);
      } else {
        return "Não foi possível ler o arquivo.";
      }

      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      if (!backupData.containsKey('recipes')) {
        return "Formato de backup inválido.";
      }

      final List<dynamic> recipesData = backupData['recipes'];
      if (recipesData.isEmpty) {
        return "Nenhuma receita encontrada no arquivo.";
      }

      int importedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      for (final recipeData in recipesData) {
        try {
          final receita = Receita.fromMap(recipeData as Map<String, dynamic>);

          // Atualiza o userId da receita para o usuário atual
          receita.userId = userId;

          if (receita.ingredientes.isEmpty && receita.instrucoes.isEmpty) {
            _logger.d(
              'Receita ${receita.nome} não tem ingredientes nem instruções, pulando...',
            );
            skippedCount++;
            continue;
          }

          bool success = await _receitaRepository.adicionarComBackup(receita);

          if (success) {
            importedCount++;
            _logger.d(
              'Receita ${receita.nome} importada',
              error: {
                'ingredientesCount': receita.ingredientes.length,
                'instrucoesCount': receita.instrucoes.length,
              },
            );
          } else {
            errorCount++;
          }
        } catch (e) {
          _logger.e('Erro ao importar receita individual', error: e);
          errorCount++;
        }
      }

      _logger.i(
        'Importação de receitas concluída',
        error: {
          'imported': importedCount,
          'skipped': skippedCount,
          'errors': errorCount,
        },
      );

      String resultado = "Importação concluída!\n";
      resultado += "$importedCount receitas importadas com sucesso\n";

      if (skippedCount > 0) {
        resultado += "$skippedCount receitas puladas (sem dados)\n";
      }

      if (errorCount > 0) {
        resultado += "$errorCount receitas com erro\n";
      }

      return resultado;
    } catch (e) {
      _logger.e('Erro no importRecipesFromJson', error: e);
      return "Erro ao importar receitas: ${e.toString()}";
    }
  }

  Future<String> restoreFromFirestore(
    BuildContext context,
    String backupId,
  ) async {
    try {
      final String? userId = _getUserId(context);

      if (userId == null) {
        return "Erro: Usuário não identificado. Faça login novamente.";
      }

      final DocumentSnapshot doc =
          await _firestore
              .collection('backups')
              .doc(userId)
              .collection('user_backups')
              .doc(backupId)
              .get();

      if (!doc.exists) {
        return "Backup não encontrado.";
      }

      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> recipesData = data['recipes'] ?? [];

      if (recipesData.isEmpty) {
        return "Nenhuma receita encontrada no backup.";
      }

      int restoredCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      for (final recipeData in recipesData) {
        try {
          final receita = Receita.fromMap(recipeData as Map<String, dynamic>);

          // Atualiza o userId da receita para o usuário atual
          receita.userId = userId;

          if (receita.ingredientes.isEmpty && receita.instrucoes.isEmpty) {
            _logger.d(
              'Receita ${receita.nome} não tem ingredientes nem instruções, pulando...',
            );
            skippedCount++;
            continue;
          }

          bool success = await _receitaRepository.adicionarComBackup(receita);

          if (success) {
            restoredCount++;
            _logger.d(
              'Receita ${receita.nome} restaurada',
              error: {
                'ingredientesCount': receita.ingredientes.length,
                'instrucoesCount': receita.instrucoes.length,
              },
            );
          } else {
            errorCount++;
          }
        } catch (e) {
          _logger.e('Erro ao restaurar receita individual', error: e);
          errorCount++;
        }
      }

      _logger.i(
        'Restauração de backup concluída',
        error: {
          'backupId': backupId,
          'restored': restoredCount,
          'skipped': skippedCount,
          'errors': errorCount,
        },
      );

      String resultado = "Backup restaurado com sucesso!\n";
      resultado += "$restoredCount receitas restauradas\n";

      if (skippedCount > 0) {
        resultado += "$skippedCount receitas puladas (sem dados)\n";
      }

      if (errorCount > 0) {
        resultado += "$errorCount receitas com erro\n";
      }

      return resultado;
    } catch (e) {
      _logger.e('Erro no restoreFromFirestore', error: e);
      return "Erro ao restaurar backup: ${e.toString()}";
    }
  }

  Future<String> backupRecipesToFirestore(BuildContext context) async {
    try {
      final String? userId = _getUserId(context);

      if (userId == null) {
        return "Erro: Usuário não identificado. Faça login novamente.";
      }

      final List<Receita> recipes = await _receitaRepository
          .listarReceitasPorUsuario(userId);

      if (recipes.isEmpty) {
        return "Nenhuma receita encontrada para backup.";
      }

      final String backupId = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());

      final backupData = {
        'metadata': {
          'userId': userId,
          'backupId': backupId,
          'criadoEm': FieldValue.serverTimestamp(),
          'totalReceitas': recipes.length,
          'versao': '1.0',
        },
        'recipes': recipes.map((recipe) => recipe.toMapCompleto()).toList(),
      };

      await _firestore
          .collection('backups')
          .doc(userId)
          .collection('user_backups')
          .doc(backupId)
          .set(backupData);

      _logger.i(
        'Backup na nuvem criado com sucesso',
        error: {
          'backupId': backupId,
          'recipesCount': recipes.length,
          'userId': userId,
        },
      );

      return "Backup na nuvem criado com sucesso!\nBackup ID: $backupId\n${recipes.length} receitas salvas";
    } catch (e) {
      _logger.e('Erro no backupRecipesToFirestore', error: e);
      return "Erro ao fazer backup no Firestore: ${e.toString()}";
    }
  }

  Future<List<Map<String, dynamic>>> listFirestoreBackups(
    BuildContext context,
  ) async {
    try {
      final String? userId = _getUserId(context);

      if (userId == null) {
        _logger.e('Usuário não identificado para listar backups');
        return [];
      }

      final QuerySnapshot snapshot =
          await _firestore
              .collection('backups')
              .doc(userId)
              .collection('user_backups')
              .orderBy('metadata.criadoEm', descending: true)
              .get();

      _logger.i(
        'Backups listados com sucesso',
        error: {'userId': userId, 'backupsCount': snapshot.docs.length},
      );

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'metadata': data['metadata'] ?? {},
          'totalReceitas': data['metadata']?['totalReceitas'] ?? 0,
        };
      }).toList();
    } catch (e) {
      _logger.e('Erro ao listar backups', error: e);
      return [];
    }
  }

  Future<String> deleteFirestoreBackup(
    BuildContext context,
    String backupId,
  ) async {
    try {
      final String? userId = _getUserId(context);

      if (userId == null) {
        return "Erro: Usuário não identificado. Faça login novamente.";
      }

      await _firestore
          .collection('backups')
          .doc(userId)
          .collection('user_backups')
          .doc(backupId)
          .delete();

      _logger.i(
        'Backup deletado com sucesso',
        error: {'backupId': backupId, 'userId': userId},
      );

      return "Backup deletado com sucesso!";
    } catch (e) {
      _logger.e('Erro ao deletar backup', error: e);
      return "Erro ao deletar backup: ${e.toString()}";
    }
  }
}
