class InstrucaoSql {
  static String criarTabelaInstrucao() {
    return "create table ingrediente(id text primary key, nome text not null, quantidade integer not null, receitaId text not null, FOREIGN KEY(receitaId) REFERENCES receita(id))";
  }
}
