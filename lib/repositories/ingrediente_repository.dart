import '/database/database_helper.dart';
import '/models/ingrediente.dart';

class IngredienteRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> adicionar(Ingrediente ingrediente) async {
    return _db.inserir("ingrediente", ingrediente.toMap());
  }

  Future<int> editar(Ingrediente ingrediente, String userId) async {
    return _db.editar(
      "ingrediente",
      ingrediente.toMap(),
      condicao:
          'id = ? AND receitaId IN (SELECT id FROM receita WHERE userId = ?)',
      conidcaoArgs: [ingrediente.id, userId],
    );
  }

  Future<int> remover(Ingrediente ingrediente, String userId) async {
    return _db.remover(
      "ingrediente",
      condicao:
          'id = ? AND receitaId IN (SELECT id FROM receita WHERE userId = ?)',
      conidcaoArgs: [ingrediente.id, userId],
    );
  }

  Future<int> removerTodosIngredientesDeUmaReceita(
    String receitaId,
    String userId,
  ) async {
    final receitaDoUsuario = await _db.obter(
      "receita",
      condicao: "id = ? AND userId = ?",
      conidcaoArgs: [receitaId, userId],
    );

    if (receitaDoUsuario.isEmpty) {
      return 0;
    }
    return _db.remover(
      "ingrediente",
      condicao: 'receitaId = ?',
      conidcaoArgs: [receitaId],
    );
  }

  Future<List<Ingrediente>> ingredientesReceita(
    String receitaId,
    String userId,
  ) async {
    final receitaDoUsuario = await _db.obter(
      "receita",
      condicao: "id = ? AND userId = ?",
      conidcaoArgs: [receitaId, userId],
    );

    if (receitaDoUsuario.isEmpty) {
      return [];
    }

    var ingredientesNoBanco = await _db.obter(
      "ingrediente",
      condicao: "receitaId = ?",
      conidcaoArgs: [receitaId],
    );

    return ingredientesNoBanco
        .map((mapa) => Ingrediente.fromMap(mapa))
        .toList();
  }
}
