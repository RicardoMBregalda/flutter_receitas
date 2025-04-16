import 'package:path/path.dart';
import '/database/sqls/instrucao_sql.dart';
import '/database/sqls/receita_sql.dart';
import 'package:sqflite/sqflite.dart';
import 'sqls/ingrediente_sql.dart';

class DatabaseHelper {
  static final String _nomeBancoDeDados = "receitas.db";
  static final int _versaoBancoDeDados = 1;
  static late Database _bancoDeDados;

  inicializar() async {
    String caminhoBanco = join(await getDatabasesPath(), _nomeBancoDeDados);
    _bancoDeDados = await openDatabase(
      caminhoBanco,
      version: _versaoBancoDeDados,
      onCreate: criarBD,
    );
  }

  Future criarBD(Database db, int versao) async {
    await db.execute(ReceitaSql.criarTabelaReceita());
    await db.execute(IngredienteSql.criarTabelaIngrediente());
    await db.execute(InstrucaoSql.criarTabelaInstrucao());
    for (String sql in ReceitaSql.seedReceitas()) {
      await db.execute(sql);
    }
    for (String sql in IngredienteSql.seedIngredientes()) {
      await db.execute(sql);
    }
    for (String sql in InstrucaoSql.seedInstrucoes()) {
      await db.execute(sql);
    }
  }

  Future<int> inserir(String tabela, Map<String, Object?> valores) async {
    await inicializar();
    return await _bancoDeDados.insert(tabela, valores);
  }

  Future<List<Map<String, Object?>>> obterTodos(
    String tabela, {
    String? condicao,
    List<Object>? conidcaoArgs,
  }) async {
    await inicializar();
    return await _bancoDeDados.query(
      tabela,
      where: condicao,
      whereArgs: conidcaoArgs,
    );
  }

  Future<int> editar(
    String tabela,
    Map<String, Object?> valores, {
    String? condicao,
    List<Object>? conidcaoArgs,
  }) async {
    await inicializar();
    return await _bancoDeDados.update(
      tabela,
      valores,
      where: condicao,
      whereArgs: conidcaoArgs,
    );
  }

  Future<int> remover(
    String tabela, {
    String? condicao,
    List<Object>? conidcaoArgs,
  }) async {
    await inicializar();
    return await _bancoDeDados.delete(
      tabela,
      where: condicao,
      whereArgs: conidcaoArgs,
    );
  }
}
