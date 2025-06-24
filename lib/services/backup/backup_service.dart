import 'package:receitas_trabalho_2/models/backup.dart';
import 'package:receitas_trabalho_2/services/backup/local_backup_service.dart';
import 'package:receitas_trabalho_2/services/backup/cloud_backup_service.dart';

class BackupService {
  final LocalBackupService _localBackupService = LocalBackupService();
  final CloudBackupService _cloudBackupService = CloudBackupService();
  
  Future<BackupResult> exportRecipesToJsonAsync({
    required String userId,
    required String outputPath,
  }) async {
    return await _localBackupService.exportRecipesToJsonAsync(
      userId: userId,
      outputPath: outputPath,
    );
  }

  Future<BackupResult> importRecipesFromJsonAsync({
    required String userId,
    required String jsonString,
  }) async {
    return await _localBackupService.importRecipesFromJsonAsync(
      userId: userId,
      jsonString: jsonString,
    );
  }

  Future<bool> solicitarPermissaoArmazenamento() async {
    return await _localBackupService.solicitarPermissaoArmazenamento();
  }

  Future<BackupResult> backupRecipesToFirestoreAsync({
    required String userId,
  }) async {
    return await _cloudBackupService.backupRecipesToFirestoreAsync(
      userId: userId,
    );
  }

  Future<BackupResult> restoreFromFirestoreAsync({
    required String userId,
    required String backupId,
  }) async {
    return await _cloudBackupService.restoreFromFirestoreAsync(
      userId: userId,
      backupId: backupId,
    );
  }

  Future<List<Map<String, dynamic>>> listFirestoreBackups({
    required String userId,
  }) async {
    return await _cloudBackupService.listFirestoreBackups(userId: userId);
  }

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