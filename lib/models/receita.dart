import 'dart:convert';
import 'package:receitas_trabalho_2/models/ingrediente.dart';
import 'package:receitas_trabalho_2/models/instrucao.dart';

class Receita {
  String id;
  String nome;
  String? descricao = '';
  int nota;
  String criadoEm;
  String tempoPreparo;
  String? urlImagem;
  String userId;

  List<Ingrediente> ingredientes;
  List<Instrucao> instrucoes;

  int get quantidadeIngredientes => ingredientes.length;
  int get quantidadeInstrucoes => instrucoes.length;

  // Em models/receita.dart, dentro da classe Receita

  Receita copyWith({
    String? id,
    String? userId,
    String? nome,
    String? descricao,
    int? nota,
    String? criadoEm,
    String? tempoPreparo,
    String? urlImagem,
    List<Ingrediente>? ingredientes,
    List<Instrucao>? instrucoes,
  }) {
    return Receita(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      nota: nota ?? this.nota,
      criadoEm: criadoEm ?? this.criadoEm,
      tempoPreparo: tempoPreparo ?? this.tempoPreparo,
      urlImagem: urlImagem ?? this.urlImagem,
      ingredientes: ingredientes ?? this.ingredientes,
      instrucoes: instrucoes ?? this.instrucoes,
    );
  }

  Receita({
    required this.id,
    required this.nome,
    this.descricao,
    required this.nota,
    required this.criadoEm,
    required this.tempoPreparo,
    this.urlImagem,
    required this.userId,
    this.ingredientes = const [],
    this.instrucoes = const [],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'nota': nota,
      'criadoEm': criadoEm,
      'tempoPreparo': tempoPreparo,
      'urlImagem': urlImagem,
      'userId': userId,
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'] as String,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String?,
      nota: map['nota'] as int,
      criadoEm: map['criadoEm'] as String,
      tempoPreparo: map['tempoPreparo'] as String,
      urlImagem: map['urlImagem'] as String?,
      userId: map['userId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Receita.fromJson(String source) =>
      Receita.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMapCompleto() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'nota': nota,
      'criadoEm': criadoEm,
      'tempoPreparo': tempoPreparo,
      'urlImagem': urlImagem,
      'userId': userId,
      // Aqui mapeamos cada objeto da lista para seu respectivo mapa.
      'ingredientes': ingredientes.map((x) => x.toMap()).toList(),
      'instrucoes': instrucoes.map((x) => x.toMap()).toList(),
    };
  }

  String toJsonCompleto() => json.encode(toMapCompleto());
}
