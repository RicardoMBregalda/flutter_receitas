import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
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
      var receita = Receita(
        nome: _controllerNome.text,
        criadoEm: DateTime.now().toString(),
        id: Uuid().v4(),
        nota: int.parse(_controllerNota.text),
        tempoPreparo: _controllerTempo.text,
      );
      await ReceitaRepository().adicionar(receita);
      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Criação de uma Receita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerNome,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira um nome"
                              : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nota',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerNota,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira uma nota"
                              : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tempo de Preparo',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerTempo,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira um tempo de preparo"
                              : null,
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onPressed,
                  label: Text("Adicionar Receita"),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
