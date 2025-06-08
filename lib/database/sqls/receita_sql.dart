class ReceitaSql {
  static String criarTabelaReceita() {
    return "create table receita(id text primary key, userId text not null, nome text not null, descricao text, nota integer not null, urlImagem text, criadoEm text not null, tempoPreparo text not null)";
  }

  static List<String> seedReceitas() {
    String userId = "1c3wK2laJfdgMDNnnFpBQlSLJmH2";
    String now = DateTime.now().toString();

    return [
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('1', '$userId', 'Feijoada', 'Prato tradicional brasileiro à base de feijão preto e carnes de porco.', 5, '', '$now', '2h')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('2', '$userId', 'Lasanha', 'Massa em camadas intercalada com molho à bolonhesa, queijo e presunto.', 4, '', '$now', '1h30m')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('3', '$userId', 'Moqueca', 'Cozido de peixe com leite de coco, azeite de dendê, pimentões e coentro.', 5, ', '$now', '1h45m')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('4', '$userId', 'Bolo de Cenoura', 'Bolo fofinho de cenoura com uma deliciosa cobertura de brigadeiro.', 5, '', '$now', '1h')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('5', '$userId', 'Pudim', 'Sobremesa clássica feita com leite condensado, ovos e uma calda de caramelo.', 5, '', '$now', '1h')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('6', '$userId', 'Brigadeiro', 'Doce brasileiro icônico feito com leite condensado, chocolate em pó e manteiga.', 5, '', '$now', '30m')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('7', '$userId', 'Torta de Limão', 'Torta com base de biscoito, recheio cremoso de limão e cobertura de merengue.', 5, '', '$now', '1h')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('8', '$userId', 'Pão de Queijo', 'Quitute mineiro tradicional, crocante por fora e macio por dentro.', 5, '', '$now', '1h')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('9', '$userId', 'Bolo de Chocolate', 'Um clássico irresistível para os amantes de chocolate, com massa fofinha e úmida.', 5, '', '$now', '1h')",
      "insert into receita(id, userId, nome, descricao, nota, urlImagem, criadoEm, tempoPreparo) values ('10', '$userId', 'Arroz de Pato', 'Prato saboroso da culinária portuguesa com pato desfiado e arroz.', 5, '', '$now', '1h30m')",
    ];
  }
}
