class InstrucaoSql {
  static String criarTabelaInstrucao() {
    return "create table instrucao(id text primary key, userId text not null, instrucao text not null, receitaId text not null, FOREIGN KEY(receitaId) REFERENCES receita(id))";
  }

  static List<String> seedInstrucoes() {
    String userId = "1c3wK2laJfdgMDNnnFpBQlSLJmH2";
    return [
      "insert into instrucao(id, userId, instrucao, receitaId) values ('1', '$userId', 'Preparar os ingredientes', '1')",
      "insert into instrucao(id, userId, instrucao, receitaId) values ('2', '$userId','Cozinhar em fogo baixo por 2h', '1')",

      "insert into instrucao(id, userId, instrucao, receitaId) values ('3', '$userId','Cozinhar o molho', '2')",
      "insert into instrucao(id, userId, instrucao, receitaId) values ('4', '$userId','Montar a lasanha e assar por 40 minutos', '2')",

      "insert into instrucao(id, userId, instrucao, receitaId) values ('5', '$userId','Refogar os temperos', '3')",
      "insert into instrucao(id, userId, instrucao, receitaId) values ('6', '$userId','Adicionar os peixes e deixar cozinhar', '3')",

      "insert into instrucao(id, userId, instrucao, receitaId) values ('7', '$userId','Misturar os ingredientes da massa', '4')",
      "insert into instrucao(id, userId, instrucao, receitaId) values ('8', '$userId','Assar por 30 minutos', '4')",

      "insert into instrucao(id, userId, instrucao, receitaId) values ('9', '$userId','Misturar os ingredientes', '5')",
      "insert into instrucao(id, userId, instrucao, receitaId) values ('10', '$userId','Colocar na forma e assar por 1h', '5')",

      "insert into instrucao(id, userId, instrucao, receitaId) values ('11', '$userId','Misturar os ingredientes', '6')",
      "insert into instrucao(id, userId, instrucao, receitaId) values ('12', '$userId','Colocar na forma e assar por 30 minutos', '6')",

      "insert into instrucao(id, userId, instrucao, receitaId) values ('13', '$userId','Misturar os ingredientes', '7')",
      "insert into instrucao(id, userId, instrucao, receitaId) values ('14', '$userId','Colocar na forma e assar por 1h', '7')",

      "insert into instrucao(id, userId, instrucao, receitaId) values ('15', '$userId','Misturar os ingredientes', '8')",
      "insert into instrucao(id, userId, instrucao, receitaId) values ('16', '$userId','Colocar na forma e assar por 30 minutos', '8')",
    ];
  }
}
