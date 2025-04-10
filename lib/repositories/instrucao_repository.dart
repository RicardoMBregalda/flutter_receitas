import 'package:receitas_trabalho_2/models/receita.dart';

import '/database/database_helper.dart';
import '/models/instrucao.dart';

class InstrucaoRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  Future<int> adicionar(Instrucao instrucao) async {
    return _db.inserir("instrucao", instrucao.toMap());
  }

  Future<int> editar(Instrucao instrucao) async {
    return _db.editar(
      "instrucao",
      instrucao.toMap(),
      condicao: 'id = ?',
      conidcaoArgs: [instrucao.id],
    );
  }

  Future<int> remover(Instrucao instrucao) async {
    return _db.remover(
      "instrucao",
      condicao: 'id = ?',
      conidcaoArgs: [instrucao.id],
    );
  }

  Future<int> removerTodasInstrucoesDeUmaReceita(Receita receita) async {
    return _db.remover(
      "instrucao",
      condicao: 'receitaId = ?',
      conidcaoArgs: [receita.id],
    );
  }

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
