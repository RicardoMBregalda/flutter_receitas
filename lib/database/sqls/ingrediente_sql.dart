class IngredienteSql {
  static String criarTabelaIngrediente() {
    return "create table ingrediente(id text primary key, nome text not null, quantidade text not null, receitaId text not null, FOREIGN KEY(receitaId) REFERENCES receita(id))";
  }

  static List<String> seedIngredientes() {
    return [
      // Ingredientes para a receita com id '1' (Feijoada)
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('1', 'Feijão Preto', '500', '1')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('2', 'Carne Seca', '300', '1')",

      // Ingredientes para a receita com id '2' (Lasanha)
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('3', 'Massa para Lasanha', '400', '2')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('4', 'Queijo Mussarela', '200', '2')",

      // Ingredientes para a receita com id '3' (Moqueca)
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('5', 'Peixe Branco', '600', '3')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('6', 'Leite de Coco', '250', '3')",
    ];
  }
}
