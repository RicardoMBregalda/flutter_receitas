import 'dart:convert';

class Ingrediente {
  String id;
  String nome;
  String quantidade;
  String receitaId;

  Ingrediente({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.receitaId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'receitaId': receitaId,
    };
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      id: map['id'] as String,
      nome: map['nome'] as String,
      quantidade: map['quantidade'] as String,
      receitaId: map['receitaId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Ingrediente.fromJson(String source) =>
      Ingrediente.fromMap(json.decode(source) as Map<String, dynamic>);
}
