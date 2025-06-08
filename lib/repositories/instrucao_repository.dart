import '/database/database_helper.dart';
import '/models/instrucao.dart';

class InstrucaoRepository {
  static final DatabaseHelper _db = DatabaseHelper();

  Future<int> adicionar(Instrucao instrucao) async {
    return _db.inserir("instrucao", instrucao.toMap());
  }


  Future<int> editar(Instrucao instrucao, String userId) async {
    return _db.editar(
      "instrucao",
      instrucao.toMap(),
      condicao:
          'id = ? AND receitaId IN (SELECT id FROM receita WHERE userId = ?)',
      conidcaoArgs: [instrucao.id, userId],
    );
  }

  Future<int> remover(Instrucao instrucao, String userId) async {
    return _db.remover(
      "instrucao",
      condicao:
          'id = ? AND receitaId IN (SELECT id FROM receita WHERE userId = ?)',
      conidcaoArgs: [instrucao.id, userId],
    );
  }

  Future<int> removerTodasInstrucoesDeUmaReceita(
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
      "instrucao",
      condicao: 'receitaId = ?',
      conidcaoArgs: [receitaId],
    );
  }

  Future<List<Instrucao>> instrucoesReceita(
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

    var instrucoesNoBanco = await _db.obter(
      "instrucao",
      condicao: "receitaId = ?",
      conidcaoArgs: [receitaId],
    );

    return instrucoesNoBanco.map((mapa) => Instrucao.fromMap(mapa)).toList();
  }
}
