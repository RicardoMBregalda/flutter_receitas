import 'dart:ffi';

import 'package:flutter/material.dart';
import '/models/receita.dart';

class ReceitaCreateScreen extends StatelessWidget {
  static const String routeName = '/receita-create';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const ReceitaCreateScreen(),
    );
  }

  const ReceitaCreateScreen({super.key});

  void onPressed() {
    // Implementar a lógica de salvar a receita
    print("Receita salva!");
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controllerNome = TextEditingController();
    final TextEditingController _controllerNota = TextEditingController();
    final TextEditingController _controllerTempo = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Receita')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nome'),
                  controller: _controllerNome,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nota'),
                  controller: _controllerNota,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tempo de Preparo',
                  ),
                  controller: _controllerTempo,
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
