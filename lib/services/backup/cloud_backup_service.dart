import 'dart:isolate';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:receitas_trabalho_2/models/backup.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
import 'package:receitas_trabalho_2/services/backup/isolate_handlers.dart';

/// Serviço responsável por operações de backup e restauração na nuvem (Firestore)
class CloudBackupService {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger(printer: PrettyPrinter());

  /// Cria um backup das receitas do usuário no Firestore
  /// Utiliza Isolate para preparar os dados sem bloquear a UI
  Future<BackupResult> backupRecipesToFirestoreAsync({
    required String userId,
  }) async {
    try {
      // Busca as receitas do usuário no banco local
      final List<Receita> recipes = await _receitaRepository.listarReceitasPorUsuario(userId);

      if (recipes.isEmpty) {
        return BackupResult(success: false, message: "Nenhuma receita encontrada para backup.");
      }

      final receivePort = ReceivePort();

      // Isolate para preparar os dados do backup
      await Isolate.spawn(
        IsolateHandlers.prepareFirestoreBackupIsolate,
        {
          'userId': userId,
          'recipes': recipes.map((r) => r.toMapCompleto()).toList(),
          'sendPort': receivePort.sendPort,
        },
      );

      // Recebe os dados preparados do isolate
      final result = await receivePort.first;

      if (result is Map<String, dynamic> && result.containsKey('error')) {
        return BackupResult(success: false, message: "Erro no Isolate: ${result['error']}");
      }
      
      final preparedData = result as Map<String, dynamic>;
      final String backupId = preparedData['backupId'];
      final Map<String, dynamic> backupData = preparedData['backupData'];

      // Adiciona timestamp do servidor (deve ser feito no isolate principal)
      backupData['metadata']['criadoEm'] = FieldValue.serverTimestamp();

      // Salva no Firestore
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

  /// Restaura receitas de um backup específico do Firestore
  /// O isolate prepara os dados e a inserção no banco ocorre no isolate principal
  Future<BackupResult> restoreFromFirestoreAsync({
    required String userId,
    required String backupId,
  }) async {
    try {
      // Busca o backup no Firestore
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

      // Isolate para preparar os objetos Receita
      await Isolate.spawn(
        IsolateHandlers.prepareRestoreDataIsolate,
        {
          'userId': userId,
          'recipesData': recipesData,
          'sendPort': receivePort.sendPort,
        },
      );

      // Recebe as receitas preparadas do isolate
      final dynamic isolateResult = await receivePort.first;

      if (isolateResult is BackupResult && !isolateResult.success) {
        return isolateResult;
      }

      final List<Receita> recipesToRestore = isolateResult as List<Receita>;
      int restoredCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      // Insere as receitas no banco de dados (isolate principal)
      for (final receita in recipesToRestore) {
        try {
          bool success = await _receitaRepository.adicionarComBackup(receita);
          if (success) {
            restoredCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          errorCount++;
          _logger.e('Erro ao restaurar receita: ${receita.nome}', error: e);
        }
      }

      // Monta mensagem de resultado
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

  /// Lista todos os backups disponíveis no Firestore para o usuário
  /// Retorna uma lista com metadados de cada backup
  Future<List<Map<String, dynamic>>> listFirestoreBackups({
    required String userId,
  }) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('backups')
          .doc(userId)
          .collection('user_backups')
          .orderBy('metadata.criadoEm', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final metadata = data['metadata'] ?? {};
        
        // Converte timestamp para string se necessário
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

  /// Deleta um backup específico do Firestore
  Future<String> deleteFirestoreBackup({
    required String userId,
    required String backupId,
  }) async {
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
}