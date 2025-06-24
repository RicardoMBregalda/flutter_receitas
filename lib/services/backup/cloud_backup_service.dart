import 'dart:isolate';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:receitas_trabalho_2/models/backup.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
import 'package:receitas_trabalho_2/services/backup/isolate_handlers.dart';

class CloudBackupService {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger(printer: PrettyPrinter());

  Future<BackupResult> backupRecipesToFirestoreAsync({
    required String userId,
  }) async {
    try {
      final List<Receita> recipes = await _receitaRepository.listarReceitasPorUsuario(userId);

      if (recipes.isEmpty) {
        return BackupResult(success: false, message: "Nenhuma receita encontrada para backup.");
      }

      final receivePort = ReceivePort();

      await Isolate.spawn(
        IsolateHandlers.prepareFirestoreBackupIsolate,
        {
          'userId': userId,
          'recipes': recipes.map((r) => r.toMapCompleto()).toList(),
          'sendPort': receivePort.sendPort,
        },
      );

      final result = await receivePort.first;

      if (result is Map<String, dynamic> && result.containsKey('error')) {
        return BackupResult(success: false, message: "Erro no Isolate: ${result['error']}");
      }
      
      final preparedData = result as Map<String, dynamic>;
      final String backupId = preparedData['backupId'];
      final Map<String, dynamic> backupData = preparedData['backupData'];

      backupData['metadata']['criadoEm'] = FieldValue.serverTimestamp();

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


  Future<BackupResult> restoreFromFirestoreAsync({
    required String userId,
    required String backupId,
  }) async {
    try {
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

      await Isolate.spawn(
        IsolateHandlers.prepareRestoreDataIsolate,
        {
          'userId': userId,
          'recipesData': recipesData,
          'sendPort': receivePort.sendPort,
        },
      );

      final dynamic isolateResult = await receivePort.first;

      if (isolateResult is BackupResult && !isolateResult.success) {
        return isolateResult;
      }

      final List<Receita> recipesToRestore = isolateResult as List<Receita>;
      int restoredCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

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