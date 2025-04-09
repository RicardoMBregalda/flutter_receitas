class InstrucaoSql {
  static String criarTabelaInstrucao() {
    return "create table instrucao(id text primary key, instrucao text not null, receitaId text not null, FOREIGN KEY(receitaId) REFERENCES receita(id))";
  }

  static List<String> seedInstrucoes() {
    return [
      // Exemplo para a receita com id '1'
      "insert into instrucao(id, instrucao, receitaId) values ('1', 'Preparar os ingredientes', '1')",
      "insert into instrucao(id, instrucao, receitaId) values ('2', 'Cozinhar em fogo baixo por 2h', '1')",

      // Exemplo para a receita com id '2'
      "insert into instrucao(id, instrucao, receitaId) values ('3', 'Cozinhar o molho', '2')",
      "insert into instrucao(id, instrucao, receitaId) values ('4', 'Montar a lasanha e assar por 40 minutos', '2')",

      // Exemplo para a receita com id '3'
      "insert into instrucao(id, instrucao, receitaId) values ('5', 'Refogar os temperos', '3')",
      "insert into instrucao(id, instrucao, receitaId) values ('6', 'Adicionar os peixes e deixar cozinhar', '3')",
    ];
  }
}
