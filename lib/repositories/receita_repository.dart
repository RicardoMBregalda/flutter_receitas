import '/repositories/ingrediente_repository.dart';
import '/repositories/instrucao_repository.dart';
import '/database/database_helper.dart';
import '/models/receita.dart';

class ReceitaRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final IngredienteRepository _ingredienteRepo = IngredienteRepository();
  final InstrucaoRepository _instrucaoRepo = InstrucaoRepository();

  Future<int> adicionar(Receita receita) async {
    int receitaId = await _db.inserir("receita", receita.toMap());

    if (receitaId != 0) {
      for (var ingrediente in receita.ingredientes) {
        ingrediente.receitaId = receita.id; // Garante a associação
        await _ingredienteRepo.adicionar(ingrediente);
      }

      for (var instrucao in receita.instrucoes) {
        instrucao.receitaId = receita.id; // Garante a associação
        await _instrucaoRepo.adicionar(instrucao);
      }
    }
    return receitaId;
  }

  Future<void> upsertReceita(Receita receita) async {
    // 1. Acessa a instância do banco de dados a partir do seu DatabaseHelper
    // Estou assumindo que seu _db tem um getter para o objeto Database.
    // Se o nome for diferente (ex: _db.database), ajuste aqui.

    await _db.inserir(
      'receita',
      receita.toMap(), // Os dados da receita para inserir/atualizar
    );

    await _ingredienteRepo.removerTodosIngredientesDeUmaReceita(
      receita.id,
      receita.userId, // Pegamos o userId da própria receita
    );
    await _instrucaoRepo.removerTodasInstrucoesDeUmaReceita(
      receita.id,
      receita.userId, // Pegamos o userId da própria receita
    );

    for (var ingrediente in receita.ingredientes) {
      ingrediente.receitaId = receita.id; // Garante a associação correta
      await _ingredienteRepo.adicionar(ingrediente);
    }

    for (var instrucao in receita.instrucoes) {
      instrucao.receitaId = receita.id; // Garante a associação correta
      await _instrucaoRepo.adicionar(instrucao);
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
      receita.toMap(),
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
}
