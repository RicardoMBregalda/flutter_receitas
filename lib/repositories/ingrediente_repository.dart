import '/database/database_helper.dart';
import '/models/ingrediente.dart';

class IngredienteRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  // O método 'adicionar' é mantido simples. A responsabilidade de garantir
  // que o 'ingrediente.receitaId' pertence ao usuário logado é do
  // ReceitaRepository, que orquestra a criação completa da receita.
  Future<int> adicionar(Ingrediente ingrediente) async {
    return _db.inserir("ingrediente", ingrediente.toMap());
  }

  // AJUSTADO: Garante que um usuário só pode editar um ingrediente
  // de uma receita que lhe pertence.
  Future<int> editar(Ingrediente ingrediente, String userId) async {
    return _db.editar(
      "ingrediente",
      ingrediente.toMap(),
      // A condição verifica o ID do ingrediente E se a receita-mãe pertence ao usuário.
      condicao:
          'id = ? AND receitaId IN (SELECT id FROM receita WHERE userId = ?)',
      conidcaoArgs: [ingrediente.id, userId],
    );
  }

  // AJUSTADO: Garante que um usuário só pode remover um ingrediente
  // de uma receita que lhe pertence.
  Future<int> remover(Ingrediente ingrediente, String userId) async {
    return _db.remover(
      "ingrediente",
      // A mesma lógica de segurança do 'editar' é aplicada aqui.
      condicao:
          'id = ? AND receitaId IN (SELECT id FROM receita WHERE userId = ?)',
      conidcaoArgs: [ingrediente.id, userId],
    );
  }

  // AJUSTADO: Remove todos os ingredientes de uma receita de forma segura.
  Future<int> removerTodosIngredientesDeUmaReceita(
    String receitaId,
    String userId,
  ) async {
    // Passo 1: Verificar se a receita realmente pertence ao usuário.
    final receitaDoUsuario = await _db.obter(
      "receita",
      condicao: "id = ? AND userId = ?",
      conidcaoArgs: [receitaId, userId],
    );

    // Se a receita não pertencer ao usuário, a operação é abortada.
    if (receitaDoUsuario.isEmpty) {
      return 0; // 0 linhas afetadas
    }

    // Passo 2: Se a propriedade foi confirmada, remover os ingredientes.
    return _db.remover(
      "ingrediente",
      condicao: 'receitaId = ?',
      conidcaoArgs: [receitaId],
    );
  }

  // AJUSTADO: Busca os ingredientes de uma receita de forma segura.
  Future<List<Ingrediente>> ingredientesReceita(
    String receitaId,
    String userId,
  ) async {
    // Passo 1: Verificar se a receita pertence ao usuário.
    final receitaDoUsuario = await _db.obter(
      "receita",
      condicao: "id = ? AND userId = ?",
      conidcaoArgs: [receitaId, userId],
    );

    // Se não pertencer, retorna uma lista vazia para evitar vazamento de dados.
    if (receitaDoUsuario.isEmpty) {
      return [];
    }

    // Passo 2: Se a propriedade foi confirmada, buscar os ingredientes.
    var ingredientesNoBanco = await _db.obter(
      "ingrediente",
      condicao: "receitaId = ?",
      conidcaoArgs: [receitaId],
    );

    // Converte a lista de mapas do banco em uma lista de objetos Ingrediente.
    return ingredientesNoBanco
        .map((mapa) => Ingrediente.fromMap(mapa))
        .toList();
  }
}
