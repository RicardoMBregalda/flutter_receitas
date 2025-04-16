class ReceitaSql {
  static String criarTabelaReceita() {
    return "create table receita(id text primary key, nome text not null, nota integer not null, criadoEm text not null, tempoPreparo text not null)";
  }

  static List<String> seedReceitas() {
    return [
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('1', 'Feijoada', 5, '${DateTime.now().toString()}', '2h')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('2', 'Lasanha', 4, '${DateTime.now().toString()}', '1h30m')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('3', 'Moqueca', 5, '${DateTime.now().toString()}', '1h45m')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('4', 'Bolo de Cenoura', 5, '${DateTime.now().toString()}', '1h')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('5', 'Pudim', 5, '${DateTime.now().toString()}', '1h')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('6', 'Brigadeiro', 5, '${DateTime.now().toString()}', '30m')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('7', 'Torta de Limão', 5, '${DateTime.now().toString()}', '1h')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('8', 'Pão de Queijo', 5, '${DateTime.now().toString()}', '1h')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('9', 'Bolo de Chocolate', 5, '${DateTime.now().toString()}', '1h')",
      "insert into receita(id, nome, nota, criadoEm, tempoPreparo) values ('10', 'Arroz de Pato', 5, '${DateTime.now().toString()}', '1h30m')",
    ];
  }
}
