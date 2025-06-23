import 'dart:io';
import 'dart:isolate';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receitas_trabalho_2/models/backup.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
import 'package:receitas_trabalho_2/services/backup/isolate_handlers.dart';

/// Serviço responsável por operações de backup e restauração local (arquivos JSON)
class LocalBackupService {
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final Logger _logger = Logger(printer: PrettyPrinter());

  /// Exporta receitas do usuário para um arquivo JSON de forma assíncrona
  /// Utiliza Isolate para não bloquear a UI durante a operação
  Future<BackupResult> exportRecipesToJsonAsync({
    required String userId,
    required String outputPath,
  }) async {
    try {
      _logger.i("Iniciando exportação para o caminho: $outputPath");
      
      // Busca as receitas do usuário no banco de dados
      final List<Receita> recipes = await _receitaRepository.listarReceitasPorUsuario(userId);
      
      if (recipes.isEmpty) {
        return BackupResult(success: false, message: "Nenhuma receita encontrada para exportar.");
      }

      // Cria um isolate para processar a exportação
      final receivePort = ReceivePort();
      await Isolate.spawn(
        IsolateHandlers.exportRecipesToJsonIsolate,
        {
          'userId': userId,
          'outputPath': outputPath,
          'recipes': recipes.map((r) => r.toMapCompleto()).toList(),
          'sendPort': receivePort.sendPort,
        },
      );

      // Aguarda o resultado do isolate
      final result = await receivePort.first as BackupResult;
      return result;
    } catch (e, stackTrace) {
      _logger.e('Erro ao iniciar isolate de exportação', error: e, stackTrace: stackTrace);
      return BackupResult(success: false, message: 'Erro ao exportar: ${e.toString()}');
    }
  }

  /// Importa receitas de um arquivo JSON de forma assíncrona
  /// O isolate prepara os dados e a inserção no banco ocorre no isolate principal
  Future<BackupResult> importRecipesFromJsonAsync({
    required String userId,
    required String jsonString,
  }) async {
    try {
      final receivePort = ReceivePort();

      // Isolate para preparar os dados do JSON
      await Isolate.spawn(
        IsolateHandlers.prepareRecipesFromJsonIsolate,
        BackupIsolateData(
          userId: userId,
          jsonString: jsonString,
          sendPort: receivePort.sendPort,
        ),
      );

      // Recebe o resultado do isolate
      final dynamic isolateResult = await receivePort.first;

      if (isolateResult is BackupResult && !isolateResult.success) {
        return isolateResult;
      }

      final List<Receita> recipesToImport = isolateResult as List<Receita>;
      int importedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      // Insere as receitas no banco de dados (isolate principal)
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

      // Monta mensagem de resultado
      String resultado = "Importação concluída!\n";
      resultado += "$importedCount receitas importadas com sucesso\n";
      if (skippedCount > 0) resultado += "$skippedCount receitas puladas\n";
      if (errorCount > 0) resultado += "$errorCount receitas com erro\n";

      return BackupResult(
        success: true,
        message: resultado,
        data: {'imported': importedCount, 'skipped': skippedCount, 'errors': errorCount},
      );
    } catch (e) {
      _logger.e('Erro ao importar de JSON', error: e);
      return BackupResult(success: false, message: 'Erro ao importar: ${e.toString()}');
    }
  }

  /// Solicita permissão de armazenamento no Android
  /// Para Android 11+ (API 30+) retorna true automaticamente
  Future<bool> solicitarPermissaoArmazenamento() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      // Android 11+ não precisa de permissão especial para acessar Downloads
      if (androidInfo >= 30) {
        return true;
      } else {
        // Versões anteriores precisam de permissão
        final status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        }

        if (status.isDenied) {
          final novoStatus = await Permission.storage.request();
          return novoStatus.isGranted;
        }

        if (status.isPermanentlyDenied) {
          _logger.w("Permissão de armazenamento permanentemente negada. Abrindo configurações.");
          await openAppSettings();
          return false;
        }
      }
    }

    // Para iOS e outras plataformas, retorna true
    return true;
  }

  /// Obtém a versão do Android (simplificado)
  Future<int> _getAndroidVersion() async {
    try {
      // Aqui você poderia usar device_info_plus para obter a versão real
      // Por simplicidade, retornamos 30 (Android 11)
      return 30;
    } catch (e) {
      return 30;
    }
  }
}