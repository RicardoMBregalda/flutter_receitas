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

      // Exemplo para a receita com id '4'
      "insert into instrucao(id, instrucao, receitaId) values ('7', 'Misturar os ingredientes da massa', '4')",
      "insert into instrucao(id, instrucao, receitaId) values ('8', 'Assar por 30 minutos', '4')",

      //exemplo para a receita com id '5'
      "insert into instrucao(id, instrucao, receitaId) values ('9', 'Misturar os ingredientes', '5')",
      "insert into instrucao(id, instrucao, receitaId) values ('10', 'Colocar na forma e assar por 1h', '5')",

      //exemplo para a receita com id '6'
      "insert into instrucao(id, instrucao, receitaId) values ('11', 'Misturar os ingredientes', '6')",
      "insert into instrucao(id, instrucao, receitaId) values ('12', 'Colocar na forma e assar por 30 minutos', '6')",

      //exemplo para a receita com id '7'
      "insert into instrucao(id, instrucao, receitaId) values ('13', 'Misturar os ingredientes', '7')",
      "insert into instrucao(id, instrucao, receitaId) values ('14', 'Colocar na forma e assar por 1h', '7')",

      //exemplo para a receita com id '8'
      "insert into instrucao(id, instrucao, receitaId) values ('15', 'Misturar os ingredientes', '8')",
      "insert into instrucao(id, instrucao, receitaId) values ('16', 'Colocar na forma e assar por 30 minutos', '8')",
    ];
  }
}
