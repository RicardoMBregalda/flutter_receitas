class ReceitaSql {
  static String criarTabelaReceita() {
    return "create table receita(id text primary key, nome text not null, nota integer not null, criadoEm text not null, tempoPreparo text not null)";
  }

  static List<String> seedReceitas() {
    return [
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('1', 'Feijoada', 5, '${DateTime.now().toString()}', '2h')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('2', 'Lasanha', 4, '${DateTime.now().toString()}', '1h30m')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('3', 'Moqueca', 5, '${DateTime.now().toString()}', '1h45m')",
    ];
  }
}
