import 'package:flutter/material.dart';
import '/models/receita.dart';
import '/screens/receita_create_screen.dart';
import '/screens/receita_detalhe_screen.dart';
import '../repositories/receita_repository.dart';

class ReceitaListScreen extends StatefulWidget {
  const ReceitaListScreen({super.key});
  static const routeName = '/receita';
  @override
  _ReceitaListScreenState createState() => _ReceitaListScreenState();
}

class _ReceitaListScreenState extends State<ReceitaListScreen> {
  List<Receita> _receitas = [];

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  void _carregarReceitas() async {
    final receitas = await ReceitaRepository().todasReceitas();
    setState(() {
      _receitas = receitas;
    });
  }

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
          Navigator.pushNamed(context, ReceitaCreateScreen.routeName).then(
            (_) => setState(() {
              _carregarReceitas();
            }),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
