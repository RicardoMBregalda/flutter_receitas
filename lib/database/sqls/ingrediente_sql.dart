class IngredienteSql {
  static String criarTabelaIngrediente() {
    return "create table ingrediente(id text primary key, userId text not null, nome text not null, quantidade text not null, receitaId text not null, FOREIGN KEY(receitaId) REFERENCES receita(id))";
  }

  static List<String> seedIngredientes() {
    String userId = "1c3wK2laJfdgMDNnnFpBQlSLJmH2";
    return [
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('1', '$userId','Feijão Preto', '500', '1')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('2', '$userId','Carne Seca', '300', '1')",

      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('3', '$userId','Massa para Lasanha', '400', '2')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('4', '$userId','Queijo Mussarela', '200', '2')",

      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('5', '$userId','Peixe Branco', '600', '3')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('6', '$userId','Leite de Coco', '250', '3')",

      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('7', '$userId','Cenoura', '300', '4')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('8', '$userId','Farinha de Trigo', '200', '4')",

      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('9', '$userId','Leite Condensado', '395', '5')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('10', '$userId','Ovos', '3', '5')",

      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('11', '$userId','Leite Condensado', '395', '6')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('12', '$userId','Chocolate em Pó', '50', '6')",

      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('13', '$userId','Limão', '3', '7')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('14', '$userId','Biscoito Maisena', '200', '7')",

      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('15', '$userId','Polvilho Doce', '500', '8')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('16', '$userId','Queijo Minas', '200', '8')",

      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('17', '$userId','Chocolate em Pó', '200', '9')",
      "insert into ingrediente(id, userId, nome, quantidade, receitaId) values ('18', '$userId','Açúcar', '200', '9')",
    ];
  }
}
