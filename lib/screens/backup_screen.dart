import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  final String userId;

  const BackupScreen({super.key, required this.userId});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _cloudBackups = [];

  @override
  void initState() {
    super.initState();
    _loadCloudBackups();
  }

  Future<void> _loadCloudBackups() async {
    setState(() => _isLoading = true);
    try {
      final backups = await _backupService.listFirestoreBackups(widget.userId);
      setState(() => _cloudBackups = backups);
    } catch (e) {
      _showMessage('Erro ao carregar backups: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _showLoadingDialog(
    Future<String> operation,
    String title,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Processando...'),
              ],
            ),
          ),
    );

    try {
      final result = await operation;
      Navigator.of(context).pop(); // Fecha o dialog de loading
      _showMessage(result);
      if (result.contains('sucesso')) {
        _loadCloudBackups(); // Recarrega a lista se foi bem-sucedido
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showMessage('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup de Receitas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de Backup
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Criar Backup',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      _showLoadingDialog(
                                        _backupService.exportRecipesToJson(
                                          widget.userId,
                                        ),
                                        'Criando Backup Local',
                                      );
                                    },
                            icon: const Icon(Icons.save_alt),
                            label: const Text('Backup Local'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      _showLoadingDialog(
                                        _backupService.backupRecipesToFirestore(
                                          widget.userId,
                                        ),
                                        'Criando Backup na Nuvem',
                                      );
                                    },
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Backup Nuvem'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Seção de Restauração
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restaurar Backup',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  _showLoadingDialog(
                                    _backupService.importRecipesFromJson(),
                                    'Importando Receitas',
                                  );
                                },
                        icon: const Icon(Icons.file_upload),
                        label: const Text('Importar de Arquivo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Seção de Backups na Nuvem
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
                          onPressed: _loadCloudBackups,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_cloudBackups.isEmpty)
                      const Text(
                        'Nenhum backup encontrado na nuvem.',
                        style: TextStyle(color: Colors.grey),
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
                              leading: const Icon(Icons.cloud),
                              title: Text('Backup ${backup['id']}'),
                              subtitle: Text(
                                '${backup['totalReceitas']} receitas\n'
                                'Criado em: ${_formatDate(metadata['criadoEm'])}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton(
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'restore',
                                        child: const Row(
                                          children: [
                                            Icon(Icons.restore),
                                            SizedBox(width: 8),
                                            Text('Restaurar'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete),
                                            SizedBox(width: 8),
                                            Text('Excluir'),
                                          ],
                                        ),
                                      ),
                                    ],
                                onSelected: (value) {
                                  if (value == 'restore') {
                                    _showLoadingDialog(
                                      _backupService.restoreFromFirestore(
                                        widget.userId,
                                        backup['id'],
                                      ),
                                      'Restaurando Backup',
                                    );
                                  } else if (value == 'delete') {
                                    _confirmDelete(backup['id']);
                                  }
                                },
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
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Data inválida';
      }

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} às '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
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
              'Tem certeza que deseja deletar este backup? '
              'Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                child: Text('Cancelar'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showLoadingDialog(
                    _backupService.deleteFirestoreBackup(
                      widget.userId,
                      backupId,
                    ),
                    'Excluindo Backup',
                  );
                },
                child: Text('Excluir'),
              ),
            ],
          ),
    );
  }
}
