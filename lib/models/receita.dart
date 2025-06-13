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
    return toMapSemRelacoes();
  }

  Map<String, dynamic> toMapSemRelacoes() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao ?? '',
      'nota': nota,
      'criadoEm': criadoEm,
      'tempoPreparo': tempoPreparo,
      'urlImagem': urlImagem ?? '',
      'userId': userId,
    };
  }

  Map<String, dynamic> toMapCompleto() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao ?? '',
      'nota': nota,
      'criadoEm': criadoEm,
      'tempoPreparo': tempoPreparo,
      'urlImagem': urlImagem ?? '',
      'userId': userId,
      'ingredientes':
          ingredientes.map((ingrediente) => ingrediente.toMap()).toList(),
      'instrucoes': instrucoes.map((instrucao) => instrucao.toMap()).toList(),
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      descricao: map['descricao']?.toString(),
      nota: _parseToInt(map['nota']),
      criadoEm: map['criadoEm']?.toString() ?? '',
      tempoPreparo: map['tempoPreparo']?.toString() ?? '',
      urlImagem: map['urlImagem']?.toString(),
      userId: map['userId']?.toString() ?? '',
      ingredientes:
          (map['ingredientes'] as List<dynamic>?)
              ?.map((item) => Ingrediente.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],

      instrucoes:
          (map['instrucoes'] as List<dynamic>?)
              ?.map((item) => Instrucao.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  String toJson() => json.encode(toMapSemRelacoes());
  String toJsonCompleto() => json.encode(toMapCompleto());

  factory Receita.fromJson(String source) =>
      Receita.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Receita(id: $id, nome: $nome, ingredientes: ${ingredientes.length}, instrucoes: ${instrucoes.length})';
  }
}
