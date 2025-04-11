import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
import 'package:receitas_trabalho_2/screens/receita_detalhe_screen.dart';
import 'package:uuid/uuid.dart';

import '/models/receita.dart';

class ReceitaCreateScreen extends StatelessWidget {
  static const String routeName = '/receita-create';
  const ReceitaCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controllerNome = TextEditingController();
    final TextEditingController _controllerNota = TextEditingController();
    final TextEditingController _controllerTempo = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    void onPressed() async {
      if (_formKey.currentState!.validate()) {
        var receita = Receita(
          nome: _controllerNome.text,
          criadoEm: DateTime.now().toString(),
          id: Uuid().v4(),
          nota: int.parse(_controllerNota.text),
          tempoPreparo: _controllerTempo.text,
        );
        await ReceitaRepository().adicionar(receita);
        if (context.mounted)
          Navigator.pushReplacementNamed(
            context,
            ReceitaDetalheScreen.routeName,
            arguments: receita,
          );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Receita')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nome'),
                  controller: _controllerNome,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira um nome"
                              : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nota'),
                  controller: _controllerNota,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira uma nota"
                              : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tempo de Preparo',
                  ),
                  controller: _controllerTempo,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira um tempo de preparo"
                              : null,
                ),
                ElevatedButton(onPressed: onPressed, child: Text("Criar")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
