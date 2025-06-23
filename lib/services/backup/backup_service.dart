import 'package:receitas_trabalho_2/models/backup.dart';
import 'package:receitas_trabalho_2/services/backup/local_backup_service.dart';
import 'package:receitas_trabalho_2/services/backup/cloud_backup_service.dart';

/// Serviço principal de backup que coordena operações locais e na nuvem
class BackupService {
  final LocalBackupService _localBackupService = LocalBackupService();
  final CloudBackupService _cloudBackupService = CloudBackupService();

  // ==================== OPERAÇÕES LOCAIS ====================
  
  /// Exporta receitas para um arquivo JSON local
  Future<BackupResult> exportRecipesToJsonAsync({
    required String userId,
    required String outputPath,
  }) async {
    return await _localBackupService.exportRecipesToJsonAsync(
      userId: userId,
      outputPath: outputPath,
    );
  }

  /// Importa receitas de um arquivo JSON local
  Future<BackupResult> importRecipesFromJsonAsync({
    required String userId,
    required String jsonString,
  }) async {
    return await _localBackupService.importRecipesFromJsonAsync(
      userId: userId,
      jsonString: jsonString,
    );
  }

  /// Solicita permissão de armazenamento no dispositivo
  Future<bool> solicitarPermissaoArmazenamento() async {
    return await _localBackupService.solicitarPermissaoArmazenamento();
  }

  // ==================== OPERAÇÕES NA NUVEM ====================
  
  /// Cria um backup das receitas no Firestore
  Future<BackupResult> backupRecipesToFirestoreAsync({
    required String userId,
  }) async {
    return await _cloudBackupService.backupRecipesToFirestoreAsync(
      userId: userId,
    );
  }

  /// Restaura receitas de um backup específico do Firestore
  Future<BackupResult> restoreFromFirestoreAsync({
    required String userId,
    required String backupId,
  }) async {
    return await _cloudBackupService.restoreFromFirestoreAsync(
      userId: userId,
      backupId: backupId,
    );
  }

  /// Lista todos os backups disponíveis no Firestore para o usuário
  Future<List<Map<String, dynamic>>> listFirestoreBackups({
    required String userId,
  }) async {
    return await _cloudBackupService.listFirestoreBackups(userId: userId);
  }

  /// Deleta um backup específico do Firestore
  Future<String> deleteFirestoreBackup({
    required String userId,
    required String backupId,
  }) async {
    return await _cloudBackupService.deleteFirestoreBackup(
      userId: userId,
      backupId: backupId,
    );
  }
}