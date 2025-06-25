import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:receitas_trabalho_2/services/auth_service.dart';
import 'package:receitas_trabalho_2/services/backup/backup_service.dart';
import 'package:receitas_trabalho_2/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 30) {
      return true;
    }
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  return true;
}

class BackupScreen extends StatefulWidget {
  static const routeName = '/backup_screen';

  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _cloudBackups = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadCloudBackups();
  }

  Future<void> _initializeServices() async {
    try {
      await _notificationService.init();
      final hasPermission =
          await _notificationService.hasNotificationPermission();
      if (!hasPermission) {
        await _notificationService.requestNotificationPermission();
      }
    } catch (e) {
      debugPrint('Erro ao inicializar serviços: $e');
    }
  }

  String? get _userId =>
      Provider.of<AuthService>(context, listen: false).userId;

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  Future<void> _loadCloudBackups() async {
    if (_userId == null) return;

    _setLoading(true);
    try {
      final backups = await _backupService.listFirestoreBackups(
        userId: _userId!,
      );
      if (mounted) {
        setState(() => _cloudBackups = backups);
      }
    } catch (e) {
      _showMessage('Erro ao carregar backups: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          backgroundColor: isError ? Colors.red[600] : null,
        ),
      );
    }
  }
  Future<void> _performCloudBackup() async {
    if (_userId == null) {
      _showMessage('Usuário não autenticado', isError: true);
      return;
    }
    _backupService
        .backupRecipesToFirestoreAsync(userId: _userId!)
        .then((result) {
          if (result.success) {
            _notificationService.showSuccessNotification(
              operation: 'Backup na Nuvem',
              details: result.message,
            );
            if (mounted) {
              _loadCloudBackups(); 
            }
          } else {
            _notificationService.showErrorNotification(
              operation: 'Backup na Nuvem',
              error: result.message,
            );
          }
        })
        .catchError((e) {
          final errorMessage = 'Erro ao fazer backup na nuvem: $e';
          _notificationService.showErrorNotification(
            operation: 'Backup na Nuvem',
            error: errorMessage,
          );
          if (mounted) {
            _showMessage(errorMessage, isError: true);
          }
        });
  }

  Future<void> _performCloudRestore(String backupId) async {
    if (_userId == null) {
      _showMessage('Usuário não autenticado', isError: true);
      return;
    }
    _backupService
        .restoreFromFirestoreAsync(userId: _userId!, backupId: backupId)
        .then((result) {
          if (result.success) {
            _notificationService.showSuccessNotification(
              operation: 'Restauração da Nuvem',
              details: "Restauração concluída com sucesso!",
            );
  
          } else {
            _notificationService.showErrorNotification(
              operation: 'Restauração da Nuvem',
              error: result.message,
            );
          }
        })
        .catchError((e) {
          final errorMessage = 'Erro ao restaurar backup: $e';
          _notificationService.showErrorNotification(
            operation: 'Restauração da Nuvem',
            error: errorMessage,
          );
        });
  }

  Future<void> _performExportToJson() async {
    if (_userId == null) {
      _showMessage('Usuário não autenticado', isError: true);
      return;
    }
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'backup_receitas_${DateTime.now().millisecondsSinceEpoch}.json';
      final String tempPath = p.join(tempDir.path, fileName);

      final result = await _backupService.exportRecipesToJsonAsync(
        userId: _userId!,
        outputPath: tempPath,
      );

      if (result.success) {
        _notificationService.showSuccessNotification(
          operation: 'Exportação JSON',
          details: 'Backup criado com sucesso!',
        );

        if (mounted) {
          _showExportOptionsDialog(tempPath, fileName);
        }
      } else {
        _notificationService.showErrorNotification(
          operation: 'Exportação JSON',
          error: result.message,
        );
      }
    } catch (e) {
      final errorMessage = 'Erro ao exportar para JSON: $e';
      _notificationService.showErrorNotification(
        operation: 'Exportação JSON',
        error: errorMessage,
      );
    }
  }

  void _showExportOptionsDialog(String filePath, String fileName) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Backup Exportado com Sucesso!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arquivo: $fileName'),
            const SizedBox(height: 16),
            const Text(
              'O que você deseja fazer com o backup?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _saveToCustomDirectory(filePath, fileName);
            },
            icon: const Icon(Icons.folder),
            label: const Text('Escolher Local'),
          ),
        ],
      );
    },
  );
}

Future<void> _saveToCustomDirectory(String sourcePath, String fileName) async {
  try {
    bool hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      _showMessage('Permissão de armazenamento negada', isError: true);
      return;
    }
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    
    if (selectedDirectory == null) {
      return;
    }
    final String destinationPath = p.join(selectedDirectory, fileName);

    final File sourceFile = File(sourcePath);
    final File destinationFile = await sourceFile.copy(destinationPath);

    if (await destinationFile.exists()) {
      _showOpenCustomLocationOption(fileName, selectedDirectory);
    } else {
      _showMessage('Erro: Arquivo não foi salvo corretamente', isError: true);
    }
  } catch (e) {
    _showMessage('Erro ao salvar arquivo: $e', isError: true);
  }
}

void _showOpenCustomLocationOption(String fileName, String directory) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Arquivo Salvo!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('O arquivo "$fileName" foi salvo com sucesso!'),
            const SizedBox(height: 8),
            Text(
              'Local: $directory',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  Future<void> _performImportFromJson() async {
    if (_userId == null) {
      _showMessage('Usuário não autenticado', isError: true);
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecione o arquivo de backup',
      );

      if (result == null || result.files.isEmpty) {
        _showMessage('Nenhum arquivo selecionado');
        return;
      }

      String jsonString;

      if (result.files.single.bytes != null) {
        jsonString = String.fromCharCodes(result.files.single.bytes!);
      } else if (result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (!await file.exists()) {
          _showMessage('Arquivo não encontrado', isError: true);
          return;
        }
        jsonString = await file.readAsString();
      } else {
        _showMessage('Não foi possível ler o arquivo', isError: true);
        return;
      }

      _backupService
          .importRecipesFromJsonAsync(userId: _userId!, jsonString: jsonString)
          .then((importResult) {
            if (importResult.success) {
              _notificationService.showSuccessNotification(
                operation: 'Importação JSON',
                details: "Importação concluída com sucesso!",
              );
            } else {
              _notificationService.showErrorNotification(
                operation: 'Importação JSON',
                error: importResult.message,
              );
            }
          })
          .catchError((e) {
            final errorMessage = 'Erro ao importar de JSON: $e';
            _notificationService.showErrorNotification(
              operation: 'Importação JSON',
              error: errorMessage,
            );
          });
    } catch (e) {
      final errorMessage = 'Erro ao importar de JSON: $e';
      _showMessage(errorMessage, isError: true);
    }
  }

  Future<void> _performDeleteFromFirestore(String backupId) async {
    if (_userId == null) {
      _showMessage('Usuário não autenticado', isError: true);
      return;
    }

    _setLoading(true);

    try {
      final result = await _backupService.deleteFirestoreBackup(
        userId: _userId!,
        backupId: backupId,
      );

      _notificationService.showSuccessNotification(
        operation: 'Exclusão de Backup',
        details: result,
      );
      await _loadCloudBackups(); 
    } catch (e) {
      final errorMessage = 'Erro ao excluir backup: $e';
      _notificationService.showErrorNotification(
        operation: 'Exclusão de Backup',
        error: errorMessage,
      );
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup e Restauração'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Criar e Exportar Backup',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _performExportToJson,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Exportar para Arquivo JSON'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Após exportar, você poderá compartilhar ou salvar em Downloads',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _performCloudBackup,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Salvar Backup na Nuvem'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restaurar e Importar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _performImportFromJson,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Importar de Arquivo JSON'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecione um arquivo de backup salvo anteriormente',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Backups na Nuvem',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _isLoading ? null : _loadCloudBackups,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Atualizar lista',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_cloudBackups.isEmpty)
                      const Center(
                        child: Text(
                          'Nenhum backup encontrado na nuvem.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cloudBackups.length,
                        itemBuilder: (context, index) {
                          final backup = _cloudBackups[index];
                          final metadata =
                              backup['metadata'] as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.cloud_circle_outlined),
                              title: Text(
                                'Backup de ${_formatDate(metadata['criadoEm'])}',
                              ),
                              subtitle: Text(
                                '${backup['totalReceitas']} receitas',
                              ),
                              trailing: PopupMenuButton(
                                onSelected: (value) {
                                  if (value == 'restore') {
                                    _performCloudRestore(backup['id']);
                                  } else if (value == 'delete') {
                                    _confirmDelete(backup['id']);
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'restore',
                                        child: Row(
                                          children: [
                                            Icon(Icons.restore),
                                            SizedBox(width: 8),
                                            Text('Restaurar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Excluir'),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Data desconhecida';
    try {
      final DateTime date =
          (timestamp is Timestamp)
              ? timestamp.toDate()
              : DateTime.parse(timestamp as String);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  void _confirmDelete(String backupId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text(
              'Tem certeza que deseja deletar este backup? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performDeleteFromFirestore(backupId);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }
}
