import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:receitas_trabalho_2/services/auth_service.dart';
import 'package:receitas_trabalho_2/services/backup_service.dart';
import 'package:receitas_trabalho_2/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart'; // Adicione esta dependência no pubspec.yaml

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    // Para Android 11+ (API 30+), não precisamos de permissão para Downloads
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 30) {
      return true;
    }
    // Para versões anteriores
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
  String _currentOperation = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadCloudBackups();
  }

  Future<void> _initializeServices() async {
    try {
      await _notificationService.init();
    } catch (e) {
      debugPrint('Erro ao inicializar serviços: $e');
    }
  }

  String? get _userId =>
      Provider.of<AuthService>(context, listen: false).userId;

  void _setLoading(bool loading, [String operation = '']) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        _currentOperation = operation;
      });
    }
  }

  Future<void> _loadCloudBackups() async {
    if (_userId == null) return;

    _setLoading(true, 'Carregando backups...');
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

  // --- Operações Assíncronas com Isolates ---

  Future<void> _performCloudBackup() async {
    if (_userId == null) {
      _showMessage('Usuário não autenticado', isError: true);
      return;
    }

    _showMessage('Backup na nuvem iniciado em segundo plano...');

    // Executa em background sem bloquear a UI
    _backupService.backupRecipesToFirestoreAsync(userId: _userId!).then((result) {
      if (result.success) {
        _notificationService.showSuccessNotification(
          operation: 'Backup na Nuvem',
          details: result.message,
        );
        if (mounted) {
          _showMessage(result.message);
          _loadCloudBackups(); // Recarrega a lista
        }
      } else {
        _notificationService.showErrorNotification(
          operation: 'Backup na Nuvem',
          error: result.message,
        );
        if (mounted) {
          _showMessage(result.message, isError: true);
        }
      }
    }).catchError((e) {
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

    _showMessage('Restauração iniciada em segundo plano...');

    // Executa em background sem bloquear a UI
    _backupService.restoreFromFirestoreAsync(
      userId: _userId!,
      backupId: backupId,
    ).then((result) {
      if (result.success) {
        _notificationService.showSuccessNotification(
          operation: 'Restauração da Nuvem',
          details: result.message,
        );
        if (mounted) {
          _showMessage(result.message);
        }
      } else {
        _notificationService.showErrorNotification(
          operation: 'Restauração da Nuvem',
          error: result.message,
        );
        if (mounted) {
          _showMessage(result.message, isError: true);
        }
      }
    }).catchError((e) {
      final errorMessage = 'Erro ao restaurar backup: $e';
      _notificationService.showErrorNotification(
        operation: 'Restauração da Nuvem',
        error: errorMessage,
      );
      if (mounted) {
        _showMessage(errorMessage, isError: true);
      }
    });
  }

  Future<void> _performExportToJson() async {
    if (_userId == null) {
      _showMessage('Usuário não autenticado', isError: true);
      return;
    }

    _showMessage('Exportação iniciada em segundo plano...');

    try {
      // Opção 1: Usar um diretório temporário primeiro
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'backup_receitas_${DateTime.now().millisecondsSinceEpoch}.json';
      final String tempPath = p.join(tempDir.path, fileName);

      // Executa o backup para arquivo temporário
      final result = await _backupService.exportRecipesToJsonAsync(
        userId: _userId!,
        outputPath: tempPath,
      );

      if (result.success) {

        // Notifica sucesso
        _notificationService.showSuccessNotification(
          operation: 'Exportação JSON',
          details: 'Backup criado com sucesso!',
        );

        // Mostra diálogo com opções
        if (mounted) {
          _showExportOptionsDialog(tempPath, fileName);
        }
      } else {
        _notificationService.showErrorNotification(
          operation: 'Exportação JSON',
          error: result.message,
        );
        if (mounted) {
          _showMessage(result.message, isError: true);
        }
      }
    } catch (e) {
      final errorMessage = 'Erro ao exportar para JSON: $e';
      _notificationService.showErrorNotification(
        operation: 'Exportação JSON',
        error: errorMessage,
      );
      if (mounted) {
        _showMessage(errorMessage, isError: true);
      }
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
                await _shareFile(filePath, fileName);
              },
              icon: const Icon(Icons.share),
              label: const Text('Compartilhar'),
            ),
            if (Platform.isAndroid)
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _saveToDownloads(filePath, fileName);
                },
                icon: const Icon(Icons.download),
                label: const Text('Salvar em Downloads'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _shareFile(String filePath, String fileName) async {
    try {
      final XFile file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Backup de Receitas - $fileName',
      );
    } catch (e) {
      _showMessage('Erro ao compartilhar arquivo: $e', isError: true);
    }
  }

  Future<void> _saveToDownloads(String sourcePath, String fileName) async {
    try {
      // Solicita permissão se necessário
      bool hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        _showMessage('Permissão de armazenamento negada', isError: true);
        return;
      }

      // Obtém o diretório de Downloads público
      final Directory? downloadsDir = Directory('/storage/emulated/0/Download');
      
      if (downloadsDir != null && await downloadsDir.exists()) {
        final String destinationPath = p.join(downloadsDir.path, fileName);
        
        // Copia o arquivo para Downloads
        final File sourceFile = File(sourcePath);
        final File destinationFile = await sourceFile.copy(destinationPath);
        
        if (await destinationFile.exists()) {
          _showMessage(
            'Arquivo salvo em: Downloads/$fileName',
          );
          
          // Abre o diretório de Downloads (opcional)
          _showOpenDownloadsOption(fileName);
        }
      } else {
        _showMessage('Não foi possível acessar a pasta Downloads', isError: true);
      }
    } catch (e) {
      _showMessage('Erro ao salvar em Downloads: $e', isError: true);
    }
  }

  void _showOpenDownloadsOption(String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Arquivo Salvo!'),
          content: Text('O arquivo "$fileName" foi salvo na pasta Downloads.'),
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
      // Configura o FilePicker para buscar em Downloads também
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecione o arquivo de backup',
        initialDirectory: '/storage/emulated/0/Download', // Diretório inicial em Downloads
      );

      if (result == null || result.files.isEmpty) {
        _showMessage('Nenhum arquivo selecionado');
        return;
      }

      _showMessage('Importação iniciada em segundo plano...');

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

      // Executa em background sem bloquear a UI
      _backupService.importRecipesFromJsonAsync(
        userId: _userId!,
        jsonString: jsonString,
      ).then((importResult) {
        if (importResult.success) {
          _notificationService.showSuccessNotification(
            operation: 'Importação JSON',
            details: importResult.message,
          );
          if (mounted) {
            _showMessage(importResult.message);
          }
        } else {
          _notificationService.showErrorNotification(
            operation: 'Importação JSON',
            error: importResult.message,
          );
          if (mounted) {
            _showMessage(importResult.message, isError: true);
          }
        }
      }).catchError((e) {
        final errorMessage = 'Erro ao importar de JSON: $e';
        _notificationService.showErrorNotification(
          operation: 'Importação JSON',
          error: errorMessage,
        );
        if (mounted) {
          _showMessage(errorMessage, isError: true);
        }
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

    _setLoading(true, 'Excluindo backup...');

    try {
      final result = await _backupService.deleteFirestoreBackup(
        userId: _userId!,
        backupId: backupId,
      );

      _notificationService.showSuccessNotification(
        operation: 'Exclusão de Backup',
        details: result,
      );
      _showMessage(result);
      await _loadCloudBackups(); // Recarrega a lista
    } catch (e) {
      final errorMessage = 'Erro ao excluir backup: $e';
      _notificationService.showErrorNotification(
        operation: 'Exclusão de Backup',
        error: errorMessage,
      );
      _showMessage(errorMessage, isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // --- Build Method e Widgets ---

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
            // Indicador de operação atual
            if (_isLoading && _currentOperation.isNotEmpty)
              Card(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _currentOperation,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_isLoading && _currentOperation.isNotEmpty)
              const SizedBox(height: 16),

            // Card de Backup/Exportação
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

            // Card de Restauração/Importação
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

            // Card da lista de backups na nuvem
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
                    if (_isLoading && _currentOperation.contains('Carregando'))
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
                                itemBuilder: (context) => [
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
      final DateTime date = (timestamp is Timestamp)
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
      builder: (context) => AlertDialog(
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