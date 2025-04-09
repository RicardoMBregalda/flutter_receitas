import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/instrucao.dart';
import 'package:receitas_trabalho_2/models/receita.dart';

class InstrucaoEditScreen extends StatelessWidget {
  static const String routeName = '/intrucao-edit';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const InstrucaoEditScreen(),
    );
  }

  const InstrucaoEditScreen({super.key});

  void onPressed() {
    // Implementar a lógica de salvar a receita
    print("Instrucao salva!");
  }

  @override
  Widget build(BuildContext context) {
    final instrucao = ModalRoute.of(context)!.settings.arguments as Instrucao;

    final TextEditingController _controllerInstrucao = TextEditingController();

    _controllerInstrucao.text = instrucao.instrucao;

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
                  controller: _controllerInstrucao,
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
