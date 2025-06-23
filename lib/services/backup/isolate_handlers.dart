import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:intl/intl.dart';
import 'package:receitas_trabalho_2/models/backup.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
/// Classe que contém todas as funções executadas em isolates
/// Isolates não podem acessar banco de dados ou Firestore diretamente
class IsolateHandlers {
  
  /// Função do isolate para exportar receitas para arquivo JSON
  /// Recebe os dados já preparados e apenas cria o arquivo
  static void exportRecipesToJsonIsolate(Map<String, dynamic> data) async {
    final sendPort = data['sendPort'] as SendPort;
    try {
      final userId = data['userId'] as String;
      final outputPath = data['outputPath'] as String;
      final List<dynamic> recipes = data['recipes'];

      // Monta a estrutura do backup
      final Map<String, dynamic> backupData = {
        'metadata': {
          'userId': userId,
          'backupDate': DateTime.now().toIso8601String(),
          'totalRecipes': recipes.length,
          'version': '1.0',
        },
        'recipes': recipes,
      };

      // Converte para JSON formatado
      final String jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      
      // Escreve o arquivo
      final file = File(outputPath);
      await file.writeAsString(jsonString, encoding: utf8);
      final fileSize = await file.length();

      // Envia resultado de sucesso
      sendPort.send(BackupResult(
        success: true,
        message: "Backup criado com sucesso!\nLocal: $outputPath\nTamanho: ${(fileSize / 1024).toStringAsFixed(1)} KB\n${recipes.length} receitas exportadas",
        data: {'filePath': outputPath, 'recipesCount': recipes.length},
      ));
    } catch (e) {
      // Envia erro em caso de falha
      sendPort.send(BackupResult(
        success: false, 
        message: "Erro ao criar backup no isolate: ${e.toString()}"
      ));
    }
  }

  /// Função do isolate para preparar receitas de um JSON
  /// Apenas desserializa os dados, não acessa o banco
  static void prepareRecipesFromJsonIsolate(BackupIsolateData data) {
    try {
      // Decodifica o JSON
      final Map<String, dynamic> backupData = jsonDecode(data.jsonString!);
      
      if (!backupData.containsKey('recipes')) {
        data.sendPort.send(BackupResult(
          success: false, 
          message: "Formato de backup inválido."
        ));
        return;
      }

      final List<dynamic> recipesData = backupData['recipes'];
      final List<Receita> recipesToImport = [];

      // Converte cada item para objeto Receita
      for (final recipeData in recipesData) {
        final receita = Receita.fromMap(recipeData as Map<String, dynamic>);
        receita.userId = data.userId; // Atribui o userId correto
        
        // Filtra receitas vazias
        if (receita.ingredientes.isNotEmpty || receita.instrucoes.isNotEmpty) {
          recipesToImport.add(receita);
        }
      }

      // Envia lista de receitas prontas
      data.sendPort.send(recipesToImport);

    } catch (e) {
      data.sendPort.send(BackupResult(
        success: false, 
        message: "Erro ao processar o arquivo JSON: ${e.toString()}"
      ));
    }
  }

  /// Função do isolate para preparar dados do backup para Firestore
  /// Apenas prepara o mapa de dados, não faz operações no Firestore
  static void prepareFirestoreBackupIsolate(Map<String, dynamic> data) {
    final sendPort = data['sendPort'] as SendPort;
    try {
      // Gera ID único para o backup baseado na data/hora
      final String backupId = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final recipes = data['recipes'] as List<dynamic>;

      // Monta estrutura do backup (timestamp será adicionado no isolate principal)
      final backupData = {
        'metadata': {
          'userId': data['userId'],
          'backupId': backupId,
          // 'criadoEm' será adicionado no isolate principal com FieldValue.serverTimestamp()
          'totalReceitas': recipes.length,
          'versao': '1.0',
        },
        'recipes': recipes,
      };

      // Envia dados preparados
      sendPort.send({
        'backupId': backupId,
        'backupData': backupData,
      });
    } catch (e) {
      sendPort.send({'error': e.toString()});
    }
  }
  
  /// Função do isolate para preparar dados da restauração do Firestore
  /// Apenas desserializa os dados em objetos Receita
  static void prepareRestoreDataIsolate(Map<String, dynamic> data) {
    final sendPort = data['sendPort'] as SendPort;
    try {
      final recipesData = data['recipesData'] as List<dynamic>;
      final userId = data['userId'] as String;
      final List<Receita> restoredRecipes = [];

      // Converte cada item para objeto Receita
      for (final recipeData in recipesData) {
        final receita = Receita.fromMap(recipeData as Map<String, dynamic>);
        receita.userId = userId; // Atribui o userId correto

        // Filtra receitas vazias
        if (receita.ingredientes.isNotEmpty || receita.instrucoes.isNotEmpty) {
          restoredRecipes.add(receita);
        }
      }
      
      // Envia lista de receitas prontas
      sendPort.send(restoredRecipes);

    } catch (e) {
      sendPort.send(BackupResult(
        success: false, 
        message: "Erro ao preparar dados para restauração: ${e.toString()}"
      ));
    }
  }
}