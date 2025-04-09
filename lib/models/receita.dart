import 'dart:convert';

class Receita {
  String id;
  String nome;
  int nota;
  String criadoEm;
  String tempoPreparo;

  Receita({
    required this.id,
    required this.nome,
    required this.nota,
    required this.criadoEm,
    required this.tempoPreparo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'nota': nota,
      'criadoEm': criadoEm,
      'tempoPreparo': tempoPreparo,
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'] as String,
      nome: map['nome'] as String,
      nota: map['nota'] as int,
      criadoEm: map['criadoEm'] as String,
      tempoPreparo: map['tempoPreparo'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Receita.fromJson(String source) =>
      Receita.fromMap(json.decode(source) as Map<String, dynamic>);

}