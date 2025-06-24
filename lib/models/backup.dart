import 'dart:isolate';

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