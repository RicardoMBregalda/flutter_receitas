import '/repositories/ingrediente_repository.dart';
import '/repositories/instrucao_repository.dart';
import '/database/database_helper.dart';
import '/models/receita.dart';

class ReceitaRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final IngredienteRepository _ingredienteRepo = IngredienteRepository();
  final InstrucaoRepository _instrucaoRepo = InstrucaoRepository();

  Future<int> adicionar(Receita receita) async {
    int result = await _db.inserir("receita", receita.toMapSemRelacoes());

    if (result != 0) {
      for (var ingrediente in receita.ingredientes) {
        ingrediente.receitaId = receita.id;
        await _ingredienteRepo.adicionar(ingrediente);
      }

      for (var instrucao in receita.instrucoes) {
        instrucao.receitaId = receita.id;
        await _instrucaoRepo.adicionar(instrucao);
      }
    }
    return result;
  }

  Future<void> upsertReceita(Receita receita) async {
    final exists = await receitaExiste(receita.id, receita.userId);

    if (exists) {
      await _db.editar(
        'receita',
        receita.toMapSemRelacoes(),
        condicao: 'id = ? AND userId = ?',
        conidcaoArgs: [receita.id, receita.userId],
      );
    } else {
      await _db.inserir('receita', receita.toMapSemRelacoes());
    }

    await _ingredienteRepo.removerTodosIngredientesDeUmaReceita(
      receita.id,
      receita.userId,
    );
    await _instrucaoRepo.removerTodasInstrucoesDeUmaReceita(
      receita.id,
      receita.userId,
    );

    for (var ingrediente in receita.ingredientes) {
      ingrediente.receitaId = receita.id;
      await _ingredienteRepo.adicionar(ingrediente);
    }

    for (var instrucao in receita.instrucoes) {
      instrucao.receitaId = receita.id;
      await _instrucaoRepo.adicionar(instrucao);
    }
  }

  Future<bool> adicionarComBackup(Receita receita) async {
    try {
      final receitaExistente = await buscarReceitaCompleta(
        receita.id,
        receita.userId,
      );

      if (receitaExistente != null) {
        print('Receita ${receita.nome} já existe, atualizando...');
        await upsertReceita(receita);
        print('Receita ${receita.nome} atualizada');
      } else {
        print('Adicionando nova receita: ${receita.nome}');
        int result = await adicionar(receita);
        if (result == 0) {
          print('Falha ao adicionar receita ${receita.nome}');
          return false;
        }
        print('Receita ${receita.nome} adicionada');
      }

      return true;
    } catch (e) {
      print('Erro ao adicionar receita ${receita.nome}: $e');
      return false;
    }
  }

  Future<int> remover(String receitaId, String userId) async {
    await _instrucaoRepo.removerTodasInstrucoesDeUmaReceita(receitaId, userId);
    await _ingredienteRepo.removerTodosIngredientesDeUmaReceita(
      receitaId,
      userId,
    );
    return _db.remover(
      "receita",
      condicao: 'id = ? AND userId = ?',
      conidcaoArgs: [receitaId, userId],
    );
  }

  Future<int> editar(Receita receita, String userId) async {
    int result = await _db.editar(
      "receita",
      receita.toMapSemRelacoes(),
      condicao: 'id = ? AND userId = ?',
      conidcaoArgs: [receita.id, userId],
    );
    if (result > 0) {
      await _instrucaoRepo.removerTodasInstrucoesDeUmaReceita(
        receita.id,
        userId,
      );
      await _ingredienteRepo.removerTodosIngredientesDeUmaReceita(
        receita.id,
        userId,
      );
      for (var ingrediente in receita.ingredientes) {
        ingrediente.receitaId = receita.id;
        await _ingredienteRepo.adicionar(ingrediente);
      }
      for (var instrucao in receita.instrucoes) {
        instrucao.receitaId = receita.id;
        await _instrucaoRepo.adicionar(instrucao);
      }
    }
    return result;
  }

  Future<List<Receita>> listarReceitasPorUsuario(String userId) async {
    var receitasNoBanco = await _db.obter(
      "receita",
      condicao: "userId = ?",
      conidcaoArgs: [userId],
    );

    return await Future.wait(
      receitasNoBanco.map((mapa) async {
        var receita = Receita.fromMap(mapa);

        receita.ingredientes = await _ingredienteRepo.ingredientesReceita(
          receita.id,
          userId,
        );

        receita.instrucoes = await _instrucaoRepo.instrucoesReceita(
          receita.id,
          userId,
        );

        return receita;
      }),
    );
  }

  Future<Receita?> buscarReceitaCompleta(
    String receitaId,
    String userId,
  ) async {
    var mapReceita = await _db.obter(
      "receita",
      condicao: "id = ? AND userId = ?",
      conidcaoArgs: [receitaId, userId],
    );

    if (mapReceita.isEmpty) {
      return null;
    }

    var receita = Receita.fromMap(mapReceita.first);

    receita.ingredientes = await _ingredienteRepo.ingredientesReceita(
      receitaId,
      userId,
    );

    receita.instrucoes = await _instrucaoRepo.instrucoesReceita(
      receitaId,
      userId,
    );

    return receita;
  }

  Future<bool> receitaExiste(String receitaId, String userId) async {
    var mapReceita = await _db.obter(
      "receita",
      condicao: "id = ? AND userId = ?",
      conidcaoArgs: [receitaId, userId],
    );

    return mapReceita.isNotEmpty;
  }
}
