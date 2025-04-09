class ReceitaSql {
  static String criarTabelaReceita() {
    return "create table receita(id text primary key, nome text not null, nota integer not null, criadoEm text not null, tempoPreparo text not null)";
  }
}
