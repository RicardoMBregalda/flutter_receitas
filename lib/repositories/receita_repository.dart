import '/repositories/ingrediente_repository.dart';
import '/repositories/instrucao_repository.dart';
import '/database/database_helper.dart';
import '/models/receita.dart';
import 'package:logger/logger.dart';

class ReceitaRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final IngredienteRepository _ingredienteRepo = IngredienteRepository();
  final InstrucaoRepository _instrucaoRepo = InstrucaoRepository();

  // Logger configurado
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<int> adicionar(Receita receita) async {
    _logger.d(
      'Iniciando adição de nova receita',
      error: {
        'receitaId': receita.id,
        'nome': receita.nome,
        'userId': receita.userId,
        'ingredientesCount': receita.ingredientes.length,
        'instrucoesCount': receita.instrucoes.length,
      },
    );

    int result = await _db.inserir("receita", receita.toMapSemRelacoes());

    if (result != 0) {
      _logger.d(
        'Receita inserida com sucesso, adicionando ingredientes e instruções',
      );

      for (var ingrediente in receita.ingredientes) {
        ingrediente.receitaId = receita.id;
        await _ingredienteRepo.adicionar(ingrediente);
      }

      for (var instrucao in receita.instrucoes) {
        instrucao.receitaId = receita.id;
        await _instrucaoRepo.adicionar(instrucao);
      }

      _logger.i(
        'Receita adicionada com sucesso',
        error: {
          'receitaId': receita.id,
          'nome': receita.nome,
          'result': result,
        },
      );
    } else {
      _logger.w(
        'Falha ao inserir receita no banco',
        error: {
          'receitaId': receita.id,
          'nome': receita.nome,
          'result': result,
        },
      );
    }

    return result;
  }

  Future<void> upsertReceita(Receita receita) async {
    _logger.d(
      'Iniciando upsert de receita',
      error: {
        'receitaId': receita.id,
        'nome': receita.nome,
        'userId': receita.userId,
      },
    );

    final exists = await receitaExiste(receita.id, receita.userId);

    if (exists) {
      _logger.d('Receita existe, atualizando');
      await _db.editar(
        'receita',
        receita.toMapSemRelacoes(),
        condicao: 'id = ? AND userId = ?',
        conidcaoArgs: [receita.id, receita.userId],
      );
    } else {
      _logger.d('Receita não existe, inserindo nova');
      await _db.inserir('receita', receita.toMapSemRelacoes());
    }

    // Remove ingredientes e instruções antigas
    await _ingredienteRepo.removerTodosIngredientesDeUmaReceita(
      receita.id,
      receita.userId,
    );
    await _instrucaoRepo.removerTodasInstrucoesDeUmaReceita(
      receita.id,
      receita.userId,
    );

    // Adiciona novos ingredientes e instruções
    for (var ingrediente in receita.ingredientes) {
      ingrediente.receitaId = receita.id;
      await _ingredienteRepo.adicionar(ingrediente);
    }

    for (var instrucao in receita.instrucoes) {
      instrucao.receitaId = receita.id;
      await _instrucaoRepo.adicionar(instrucao);
    }

    _logger.i(
      'Upsert de receita concluído com sucesso',
      error: {
        'receitaId': receita.id,
        'nome': receita.nome,
        'operacao': exists ? 'atualização' : 'inserção',
      },
    );
  }

  Future<bool> adicionarComBackup(Receita receita) async {
    try {
      _logger.d(
        'Iniciando adição com backup',
        error: {
          'receitaId': receita.id,
          'nome': receita.nome,
          'userId': receita.userId,
        },
      );

      final receitaExistente = await buscarReceitaCompleta(
        receita.id,
        receita.userId,
      );

      if (receitaExistente != null) {
        _logger.i('Receita ${receita.nome} já existe, atualizando...');
        await upsertReceita(receita);
        _logger.i('Receita ${receita.nome} atualizada com sucesso');
      } else {
        _logger.i('Adicionando nova receita: ${receita.nome}');
        int result = await adicionar(receita);
        if (result == 0) {
          _logger.e(
            'Falha ao adicionar receita ${receita.nome}',
            error: {'receitaId': receita.id, 'result': result},
          );
          return false;
        }
        _logger.i('Receita ${receita.nome} adicionada com sucesso');
      }

      return true;
    } catch (e) {
      _logger.e('Erro ao adicionar receita ${receita.nome}', error: e);
      return false;
    }
  }

  Future<int> remover(String receitaId, String userId) async {
    _logger.d(
      'Iniciando remoção de receita',
      error: {'receitaId': receitaId, 'userId': userId},
    );

    try {
      // Remove instruções e ingredientes primeiro
      await _instrucaoRepo.removerTodasInstrucoesDeUmaReceita(
        receitaId,
        userId,
      );
      await _ingredienteRepo.removerTodosIngredientesDeUmaReceita(
        receitaId,
        userId,
      );

      // Remove a receita
      int result = await _db.remover(
        "receita",
        condicao: 'id = ? AND userId = ?',
        conidcaoArgs: [receitaId, userId],
      );

      if (result > 0) {
        _logger.i(
          'Receita removida com sucesso',
          error: {'receitaId': receitaId, 'userId': userId, 'result': result},
        );
      } else {
        _logger.w(
          'Nenhuma receita foi removida',
          error: {'receitaId': receitaId, 'userId': userId, 'result': result},
        );
      }

      return result;
    } catch (e) {
      _logger.e('Erro ao remover receita', error: e);
      rethrow;
    }
  }

  Future<int> editar(Receita receita, String userId) async {
    _logger.d(
      'Iniciando edição de receita',
      error: {
        'receitaId': receita.id,
        'nome': receita.nome,
        'userId': userId,
        'ingredientesCount': receita.ingredientes.length,
        'instrucoesCount': receita.instrucoes.length,
      },
    );

    try {
      int result = await _db.editar(
        "receita",
        receita.toMapSemRelacoes(),
        condicao: 'id = ? AND userId = ?',
        conidcaoArgs: [receita.id, userId],
      );

      if (result > 0) {
        _logger.d(
          'Receita atualizada, removendo ingredientes e instruções antigas',
        );

        // Remove ingredientes e instruções antigas
        await _instrucaoRepo.removerTodasInstrucoesDeUmaReceita(
          receita.id,
          userId,
        );
        await _ingredienteRepo.removerTodosIngredientesDeUmaReceita(
          receita.id,
          userId,
        );

        // Adiciona novos ingredientes e instruções
        for (var ingrediente in receita.ingredientes) {
          ingrediente.receitaId = receita.id;
          await _ingredienteRepo.adicionar(ingrediente);
        }
        for (var instrucao in receita.instrucoes) {
          instrucao.receitaId = receita.id;
          await _instrucaoRepo.adicionar(instrucao);
        }

        _logger.i(
          'Receita editada com sucesso',
          error: {
            'receitaId': receita.id,
            'nome': receita.nome,
            'userId': userId,
          },
        );
      } else {
        _logger.w(
          'Nenhuma receita foi editada',
          error: {
            'receitaId': receita.id,
            'nome': receita.nome,
            'userId': userId,
            'result': result,
          },
        );
      }

      return result;
    } catch (e) {
      _logger.e('Erro ao editar receita', error: e);
      rethrow;
    }
  }

  Future<List<Receita>> listarReceitasPorUsuario(String userId) async {
    _logger.d('Listando receitas por usuário', error: {'userId': userId});

    try {
      var receitasNoBanco = await _db.obter(
        "receita",
        condicao: "userId = ?",
        conidcaoArgs: [userId],
      );

      _logger.d(
        'Receitas encontradas no banco',
        error: {'userId': userId, 'count': receitasNoBanco.length},
      );

      List<Receita> receitas = await Future.wait(
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

      _logger.i(
        'Receitas listadas com sucesso',
        error: {
          'userId': userId,
          'totalReceitas': receitas.length,
          'totalIngredientes': receitas.fold(
            0,
            (sum, r) => sum + r.ingredientes.length,
          ),
          'totalInstrucoes': receitas.fold(
            0,
            (sum, r) => sum + r.instrucoes.length,
          ),
        },
      );

      return receitas;
    } catch (e) {
      _logger.e('Erro ao listar receitas por usuário', error: e);
      rethrow;
    }
  }

  Future<Receita?> buscarReceitaCompleta(
    String receitaId,
    String userId,
  ) async {
    _logger.d(
      'Buscando receita completa',
      error: {'receitaId': receitaId, 'userId': userId},
    );

    try {
      var mapReceita = await _db.obter(
        "receita",
        condicao: "id = ? AND userId = ?",
        conidcaoArgs: [receitaId, userId],
      );

      if (mapReceita.isEmpty) {
        _logger.d(
          'Receita não encontrada',
          error: {'receitaId': receitaId, 'userId': userId},
        );
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

      _logger.d(
        'Receita completa encontrada',
        error: {
          'receitaId': receitaId,
          'nome': receita.nome,
          'userId': userId,
          'ingredientesCount': receita.ingredientes.length,
          'instrucoesCount': receita.instrucoes.length,
        },
      );

      return receita;
    } catch (e) {
      _logger.e('Erro ao buscar receita completa', error: e);
      rethrow;
    }
  }

  Future<bool> receitaExiste(String receitaId, String userId) async {
    _logger.d(
      'Verificando se receita existe',
      error: {'receitaId': receitaId, 'userId': userId},
    );

    try {
      var mapReceita = await _db.obter(
        "receita",
        condicao: "id = ? AND userId = ?",
        conidcaoArgs: [receitaId, userId],
      );

      bool existe = mapReceita.isNotEmpty;

      _logger.d(
        'Verificação de existência concluída',
        error: {'receitaId': receitaId, 'userId': userId, 'existe': existe},
      );

      return existe;
    } catch (e) {
      _logger.e('Erro ao verificar se receita existe', error: e);
      rethrow;
    }
  }
}
