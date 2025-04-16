import '/models/receita.dart';
import '/database/database_helper.dart';
import '/models/ingrediente.dart';

class IngredienteRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  Future<int> adicionar(Ingrediente ingrediente) async {
    return _db.inserir("ingrediente", ingrediente.toMap());
  }

  Future<int> editar(Ingrediente ingrediente) async {
    return _db.editar(
      "ingrediente",
      ingrediente.toMap(),
      condicao: 'id = ?',
      conidcaoArgs: [ingrediente.id],
    );
  }

  Future<int> remover(Ingrediente ingrediente) async {
    return _db.remover(
      "ingrediente",
      condicao: 'id = ?',
      conidcaoArgs: [ingrediente.id],
    );
  }

  Future<int> removerTodosIngredientesDeUmaReceita(Receita receita) async {
    return _db.remover(
      "ingrediente",
      condicao: 'receitaId = ?',
      conidcaoArgs: [receita.id],
    );
  }

  Future<List<Ingrediente>> ingredientesReceita(String receitaId) async {
    var ingredientesNoBanco = await _db.obterTodos(
      "ingrediente",
      condicao: "receitaId = ?",
      conidcaoArgs: [receitaId],
    );
    List<Ingrediente> listaDeIngredientes = [];

    for (var i = 0; i < ingredientesNoBanco.length; i++) {
      listaDeIngredientes.add(Ingrediente.fromMap(ingredientesNoBanco[i]));
    }

    return listaDeIngredientes;
  }
}
