import 'dart:convert';

class Instrucao {
  String id;
  String instrucao;
  String receitaId;

  Instrucao({
    required this.id,
    required this.instrucao,
    required this.receitaId,
  });
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'instrucao': instrucao,
      'receitaId': receitaId,
    };
  }

  factory Instrucao.fromMap(Map<String, dynamic> map) {
    return Instrucao(
      id: map['id'] as String,
      instrucao: map['instrucao'] as String,
      receitaId: map['receitaId'] as String,
    );
  }
  String toJson() => json.encode(toMap());
  factory Instrucao.fromJson(String source) =>
      Instrucao.fromMap(json.decode(source) as Map<String, dynamic>);
}
