import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/screens/receita_create_screen.dart';
import 'package:receitas_trabalho_2/screens/receita_detalhe_screen.dart';
import '/models/pessoa.dart';
import '/repositories/pessoa_repository.dart';
import '/screens/pessoa_detalhe_screen.dart';
import 'package:uuid/uuid.dart';

class ReceitaListScreen extends StatelessWidget {
  const ReceitaListScreen({super.key});

  static final List<Receita> _receitas = [
    Receita(
      id: '1',
      nome: 'Receita 1',
      nota: 5,
      criadoEm: DateTime.now().toString(),
      tempoPreparo: '30 min',
    ),
    Receita(
      id: '2',
      nome: 'Receita 2',
      nota: 4,
      criadoEm: DateTime.now().toString(),
      tempoPreparo: '45 min',
    ),
    Receita(
      id: '3',
      nome: 'Receita 3',
      nota: 3,
      criadoEm: DateTime.now().toString(),
      tempoPreparo: '1 hora',
    ),
    Receita(
      id: '4',
      nome: 'Receita 4',
      nota: 2,
      criadoEm: DateTime.now().toString(),
      tempoPreparo: '15 min',
    ),
    Receita(
      id: '5',
      nome: 'Receita 5',
      nota: 1,
      criadoEm: DateTime.now().toString(),
      tempoPreparo: '2 horas',
    ),
    Receita(
      id: '6',
      nome: 'Receita 6',
      nota: 5,
      criadoEm: DateTime.now().toString(),
      tempoPreparo: '30 min',
    ),
    Receita(
      id: '7',
      nome: 'Receita 7',
      nota: 4,
      criadoEm: DateTime.now().toString(),
      tempoPreparo: '45 min',
    ),
  ];

  static const routeName = '/receita';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receitas')),
      body: Center(
        child: ListView.builder(
          itemCount: _receitas.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_receitas[index].nome),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ReceitaDetalheScreen.routeName,
                  arguments: _receitas[index],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushNamed(context, ReceitaCreateScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
