import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/ingrediente.dart';
import 'package:receitas_trabalho_2/models/receita.dart';

class IngredienteEditScreen extends StatelessWidget {
  static const String routeName = '/ingrediente-edit';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const IngredienteEditScreen(),
    );
  }

  const IngredienteEditScreen({super.key});

  void onPressed() {
    // Implementar a lógica de salvar a receita
    print("Ingrediente salva!");
  }

  @override
  Widget build(BuildContext context) {
    final ingrediente =
        ModalRoute.of(context)!.settings.arguments as Ingrediente;

    final TextEditingController _controllerNome = TextEditingController();
    final TextEditingController _controllerQuantidade = TextEditingController();

    _controllerNome.text = ingrediente.nome;
    _controllerQuantidade.text = ingrediente.quantidade.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Instrução')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Instrução'),
                  controller: _controllerNome,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  controller: _controllerQuantidade,
                ),
                ElevatedButton(onPressed: onPressed, child: Text("Salvar")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
