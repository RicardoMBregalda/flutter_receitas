import 'package:uuid/uuid.dart';

import '/database/database_helper.dart';
import '/models/receita.dart';

class ReceitaRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  Future<int> adicionar(String nome, String nota, String tempoPreparo) async {
    var receita = Receita(
      nome: nome,
      criadoEm: DateTime.now().toString(),
      id: Uuid().v4(),
      nota: int.parse(nota),
      tempoPreparo: tempoPreparo,
    );
    return _db.inserir("receita", receita.toMap());
  }

  Future<List<Receita>> todasReceitas() async {
    var receitasNoBanco = await _db.obterTodos("receita");
    List<Receita> listaDeReceitas = [];

    for (var i = 0; i < receitasNoBanco.length; i++) {
      listaDeReceitas.add(Receita.fromMap(receitasNoBanco[i]));
    }

    return listaDeReceitas;
  }
}
