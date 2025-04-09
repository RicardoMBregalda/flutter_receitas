import '/database/database_helper.dart';
import '/models/ingrediente.dart';

class IngredienteRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  // Future<int> adicionar(Receita receita) async {
  //   return _db.inserir("receita", receita.toMap());
  // }

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
