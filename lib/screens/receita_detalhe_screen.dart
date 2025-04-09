import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/screens/receita_edit_screen.dart';
import '/models/pessoa.dart';
import '/repositories/pessoa_repository.dart';
import '/screens/pessoa_detalhe_screen.dart';
import 'package:uuid/uuid.dart';

class ReceitaDetalheScreen extends StatelessWidget {
  const ReceitaDetalheScreen({super.key});

  static const routeName = '/receita_detalhe';

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;

    onPressed() {
      // Implement your edit functionality here
      Navigator.pushNamed(
        context,
        ReceitaEditScreen.routeName,
        arguments: receita,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Detalhe')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ElevatedButton(onPressed: onPressed, child: Text("Editar")),
                Text('ID ${receita.id}'),
                Text('Nome ${receita.nome}'),
                Text('Nota ${receita.nota}'),
                Text('Criado em ${receita.criadoEm}'),
                Text('Tempo de Preparo ${receita.tempoPreparo}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
