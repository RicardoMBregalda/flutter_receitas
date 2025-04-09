import 'dart:convert';


class Instrucao {
  String id;
  String instrucao;
  String idReceita;

  Instrucao({
    required this.id,
    required this.instrucao,
    required this.idReceita,
  });
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'instrucao': instrucao,
      'idReceita': idReceita,
    };
  }
  factory Instrucao.fromMap(Map<String, dynamic> map) {
    return Instrucao(
      id: map['id'] as String,
      instrucao: map['instrucao'] as String,
      idReceita: map['idReceita'] as String,
    );
  }
  String toJson() => json.encode(toMap());
  factory Instrucao.fromJson(String source) =>
      Instrucao.fromMap(json.decode(source) as Map<String, dynamic>);

}

