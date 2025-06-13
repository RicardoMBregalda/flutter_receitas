import 'package:path/path.dart';
import '/database/sqls/instrucao_sql.dart';
import '/database/sqls/receita_sql.dart';
import 'package:sqflite/sqflite.dart';
import 'sqls/ingrediente_sql.dart';

class DatabaseHelper {
  static final String _nomeBancoDeDados = "receita.db";
  static final int _versaoBancoDeDados = 2;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String caminhoBanco = join(await getDatabasesPath(), _nomeBancoDeDados);
    return await openDatabase(
      caminhoBanco,
      version: _versaoBancoDeDados,
      onCreate: _criarBD,
    );
  }

  Future _criarBD(Database db, int versao) async {
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
    final db = await instance.database;
    return await db.insert(tabela, valores);
  }

  Future<List<Map<String, Object?>>> obter(
    String tabela, {
    String? condicao,
    List<Object>? conidcaoArgs,
  }) async {
    final db = await instance.database;
    return await db.query(tabela, where: condicao, whereArgs: conidcaoArgs);
  }

  Future<int> editar(
    String tabela,
    Map<String, Object?> valores, {
    String? condicao,
    List<Object>? conidcaoArgs,
  }) async {
    final db = await instance.database;
    return await db.update(
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
    final db = await instance.database;
    return await db.delete(tabela, where: condicao, whereArgs: conidcaoArgs);
  }
}
