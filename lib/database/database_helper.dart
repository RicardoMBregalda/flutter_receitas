import 'package:path/path.dart';
import 'package:receitas_trabalho_2/database/sqls/instrucao_sql.dart';
import 'package:receitas_trabalho_2/database/sqls/receita_sql.dart';
import 'package:sqflite/sqflite.dart';
import 'sqls/ingrediente_sql.dart';

class DatabaseHelper {
  static final String _nomeBancoDeDados = "meubanco.db";
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
    db.execute(ReceitaSql.criarTabelaReceita());
    db.execute(IngredienteSql.criarTabelaIngrediente());
    db.execute(InstrucaoSql.criarTabelaInstrucao());
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

  Future<int> atualizar(
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

  Future<int> deletar(
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
