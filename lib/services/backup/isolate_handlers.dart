import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:intl/intl.dart';
import 'package:receitas_trabalho_2/models/backup.dart';
import 'package:receitas_trabalho_2/models/receita.dart';

class IsolateHandlers {

  static void exportRecipesToJsonIsolate(Map<String, dynamic> data) async {
    final sendPort = data['sendPort'] as SendPort;
    try {
      final userId = data['userId'] as String;
      final outputPath = data['outputPath'] as String;
      final List<dynamic> recipes = data['recipes'];

      final Map<String, dynamic> backupData = {
        'metadata': {
          'userId': userId,
          'backupDate': DateTime.now().toIso8601String(),
          'totalRecipes': recipes.length,
          'version': '1.0',
        },
        'recipes': recipes,
      };

      final String jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      
      final file = File(outputPath);
      await file.writeAsString(jsonString, encoding: utf8);
      final fileSize = await file.length();

      sendPort.send(BackupResult(
        success: true,
        message: "Backup criado com sucesso!\nLocal: $outputPath\nTamanho: ${(fileSize / 1024).toStringAsFixed(1)} KB\n${recipes.length} receitas exportadas",
        data: {'filePath': outputPath, 'recipesCount': recipes.length},
      ));
    } catch (e) {
      sendPort.send(BackupResult(
        success: false, 
        message: "Erro ao criar backup no isolate: ${e.toString()}"
      ));
    }
  }


  static void prepareRecipesFromJsonIsolate(BackupIsolateData data) {
    try {
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

      for (final recipeData in recipesData) {
        final receita = Receita.fromMap(recipeData as Map<String, dynamic>);
        receita.userId = data.userId; 
        
        if (receita.ingredientes.isNotEmpty || receita.instrucoes.isNotEmpty) {
          recipesToImport.add(receita);
        }
      }

      data.sendPort.send(recipesToImport);

    } catch (e) {
      data.sendPort.send(BackupResult(
        success: false, 
        message: "Erro ao processar o arquivo JSON: ${e.toString()}"
      ));
    }
  }


  static void prepareFirestoreBackupIsolate(Map<String, dynamic> data) {
    final sendPort = data['sendPort'] as SendPort;
    try {
      final String backupId = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final recipes = data['recipes'] as List<dynamic>;

      final backupData = {
        'metadata': {
          'userId': data['userId'],
          'backupId': backupId,
          'totalReceitas': recipes.length,
          'versao': '1.0',
        },
        'recipes': recipes,
      };

      sendPort.send({
        'backupId': backupId,
        'backupData': backupData,
      });
    } catch (e) {
      sendPort.send({'error': e.toString()});
    }
  }

  static void prepareRestoreDataIsolate(Map<String, dynamic> data) {
    final sendPort = data['sendPort'] as SendPort;
    try {
      final recipesData = data['recipesData'] as List<dynamic>;
      final userId = data['userId'] as String;
      final List<Receita> restoredRecipes = [];

      for (final recipeData in recipesData) {
        final receita = Receita.fromMap(recipeData as Map<String, dynamic>);
        receita.userId = userId;

        if (receita.ingredientes.isNotEmpty || receita.instrucoes.isNotEmpty) {
          restoredRecipes.add(receita);
        }
      }
      
      sendPort.send(restoredRecipes);

    } catch (e) {
      sendPort.send(BackupResult(
        success: false, 
        message: "Erro ao preparar dados para restauração: ${e.toString()}"
      ));
    }
  }
}