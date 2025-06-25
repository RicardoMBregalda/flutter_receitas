import 'dart:isolate';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import '/models/backup.dart';
import '/models/receita.dart';
import '/repositories/receita_repository.dart';
import '/services/backup/isolate_handlers.dart';

class LocalBackupService {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final Logger _logger = Logger(printer: PrettyPrinter());

  Future<BackupResult> exportRecipesToJsonAsync({
    required String userId,
    required String outputPath,
  }) async {
    try {
      _logger.i("Iniciando exportação para o caminho: $outputPath");

      final List<Receita> recipes = await _receitaRepository
          .listarReceitasPorUsuario(userId);

      if (recipes.isEmpty) {
        return BackupResult(
          success: false,
          message: "Nenhuma receita encontrada para exportar.",
        );
      }

      final receivePort = ReceivePort();
      await Isolate.spawn(IsolateHandlers.exportRecipesToJsonIsolate, {
        'userId': userId,
        'outputPath': outputPath,
        'recipes': recipes.map((r) => r.toMapCompleto()).toList(),
        'sendPort': receivePort.sendPort,
      });

      final result = await receivePort.first as BackupResult;
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Erro ao iniciar isolate de exportação',
        error: e,
        stackTrace: stackTrace,
      );
      return BackupResult(
        success: false,
        message: 'Erro ao exportar: ${e.toString()}',
      );
    }
  }

  Future<BackupResult> importRecipesFromJsonAsync({
    required String userId,
    required String jsonString,
  }) async {
    try {
      final receivePort = ReceivePort();

      await Isolate.spawn(
        IsolateHandlers.prepareRecipesFromJsonIsolate,
        BackupIsolateData(
          userId: userId,
          jsonString: jsonString,
          sendPort: receivePort.sendPort,
        ),
      );

      final dynamic isolateResult = await receivePort.first;

      if (isolateResult is BackupResult && !isolateResult.success) {
        return isolateResult;
      }

      final List<Receita> recipesToImport = isolateResult as List<Receita>;
      int importedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      for (final receita in recipesToImport) {
        try {
          bool success = await _receitaRepository.adicionarComBackup(receita);
          if (success) {
            importedCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          errorCount++;
          _logger.e('Erro ao importar receita: ${receita.nome}', error: e);
        }
      }

      String resultado = "Importação concluída!\n";
      resultado += "$importedCount receitas importadas com sucesso\n";
      if (skippedCount > 0) resultado += "$skippedCount receitas puladas\n";
      if (errorCount > 0) resultado += "$errorCount receitas com erro\n";

      return BackupResult(
        success: true,
        message: resultado,
        data: {
          'imported': importedCount,
          'skipped': skippedCount,
          'errors': errorCount,
        },
      );
    } catch (e) {
      _logger.e('Erro ao importar de JSON', error: e);
      return BackupResult(
        success: false,
        message: 'Erro ao importar: ${e.toString()}',
      );
    }
  }

  Future<bool> solicitarPermissaoArmazenamento() async {
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
    return true;
  }

  Future<int> _getAndroidVersion() async {
    try {
      return 30;
    } catch (e) {
      return 30;
    }
  }
}
