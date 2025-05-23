class IngredienteSql {
  static String criarTabelaIngrediente() {
    return "create table ingrediente(id text primary key, nome text not null, quantidade text not null, receitaId text not null, FOREIGN KEY(receitaId) REFERENCES receita(id))";
  }

  static List<String> seedIngredientes() {
    return [
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('1', 'Feijão Preto', '500', '1')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('2', 'Carne Seca', '300', '1')",

      "insert into ingrediente(id, nome, quantidade, receitaId) values ('3', 'Massa para Lasanha', '400', '2')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('4', 'Queijo Mussarela', '200', '2')",

      "insert into ingrediente(id, nome, quantidade, receitaId) values ('5', 'Peixe Branco', '600', '3')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('6', 'Leite de Coco', '250', '3')",

      "insert into ingrediente(id, nome, quantidade, receitaId) values ('7', 'Cenoura', '300', '4')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('8', 'Farinha de Trigo', '200', '4')",

      "insert into ingrediente(id, nome, quantidade, receitaId) values ('9', 'Leite Condensado', '395', '5')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('10', 'Ovos', '3', '5')",

      "insert into ingrediente(id, nome, quantidade, receitaId) values ('11', 'Leite Condensado', '395', '6')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('12', 'Chocolate em Pó', '50', '6')",

      "insert into ingrediente(id, nome, quantidade, receitaId) values ('13', 'Limão', '3', '7')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('14', 'Biscoito Maisena', '200', '7')",

      "insert into ingrediente(id, nome, quantidade, receitaId) values ('15', 'Polvilho Doce', '500', '8')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('16', 'Queijo Minas', '200', '8')",

      "insert into ingrediente(id, nome, quantidade, receitaId) values ('17', 'Chocolate em Pó', '200', '9')",
      "insert into ingrediente(id, nome, quantidade, receitaId) values ('18', 'Açúcar', '200', '9')",
    ];
  }
}
