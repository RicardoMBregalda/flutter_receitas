import 'dart:isolate';

/// Modelo para passar dados entre isolates durante operações de backup
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

/// Modelo para representar o resultado de uma operação de backup
class BackupResult {
  /// Indica se a operação foi bem-sucedida
  final bool success;
  
  /// Mensagem descritiva do resultado
  final String message;
  
  /// Dados adicionais retornados pela operação (opcional)
  final Map<String, dynamic>? data;

  BackupResult({
    required this.success,
    required this.message,
    this.data,
  });
}