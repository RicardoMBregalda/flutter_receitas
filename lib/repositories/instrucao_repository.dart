import '/database/database_helper.dart';
import '/models/instrucao.dart';

class InstrucaoRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  // Future<int> adicionar(Receita receita) async {
  //   return _db.inserir("receita", receita.toMap());
  // }

  Future<List<Instrucao>> instrucoesReceita(String receitaId) async {
    var instrucoesNoBanco = await _db.obterTodos(
      "instrucao",
      condicao: "receitaId = ?",
      conidcaoArgs: [receitaId],
    );
    List<Instrucao> listaDeInstrucoes = [];

    for (var i = 0; i < instrucoesNoBanco.length; i++) {
      listaDeInstrucoes.add(Instrucao.fromMap(instrucoesNoBanco[i]));
    }

    return listaDeInstrucoes;
  }
}
