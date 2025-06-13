import 'package:path/path.dart';
import '/database/sqls/instrucao_sql.dart';
import '/database/sqls/receita_sql.dart';
import 'package:sqflite/sqflite.dart';
import 'sqls/ingrediente_sql.dart';

class DatabaseHelper {
  static final String _nomeBancoDeDados = "receita.db";
  static final int _versaoBancoDeDados = 2;

  // --- MUDANÇA 1: Implementação do Singleton ---
  // Torna o construtor privado
  DatabaseHelper._privateConstructor();
  // Cria uma instância estática e única
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Teremos apenas uma única instância do banco de dados para todo o app
  static Database? _database;

  // Getter para o banco de dados. Abre a conexão na primeira vez que é acessado.
  Future<Database> get database async {
    // Se o banco de dados já existe, retorne-o.
    if (_database != null) return _database!;

    // Senão, inicialize o banco de dados pela primeira vez.
    _database = await _initDatabase();
    return _database!;
  }

  // --- MUDANÇA 2: O método de inicialização se torna privado ---
  // Este método agora só é chamado UMA VEZ pelo getter 'database'.
  Future<Database> _initDatabase() async {
    String caminhoBanco = join(await getDatabasesPath(), _nomeBancoDeDados);
    return await openDatabase(
      caminhoBanco,
      version: _versaoBancoDeDados,
      onCreate: _criarBD, // Renomeado para seguir convenção de método privado
    );
  }

  // Lógica de criação do banco (seu código original, apenas renomeado)
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

  // --- MUDANÇA 3: Métodos de operação agora usam o getter 'database' ---
  // Note que REMOVEMOS a chamada 'await inicializar();' de todos eles.

  Future<int> inserir(String tabela, Map<String, Object?> valores) async {
    final db = await instance.database; // Pega a instância única
    return await db.insert(tabela, valores);
  }

  Future<List<Map<String, Object?>>> obter(
    String tabela, {
    String? condicao,
    List<Object>? conidcaoArgs,
  }) async {
    final db = await instance.database; // Pega a instância única
    return await db.query(tabela, where: condicao, whereArgs: conidcaoArgs);
  }

  Future<int> editar(
    String tabela,
    Map<String, Object?> valores, {
    String? condicao,
    List<Object>? conidcaoArgs,
  }) async {
    final db = await instance.database; // Pega a instância única
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
    final db = await instance.database; // Pega a instância única
    return await db.delete(tabela, where: condicao, whereArgs: conidcaoArgs);
  }
}
