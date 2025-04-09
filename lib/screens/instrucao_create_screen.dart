import 'package:flutter/material.dart';

class InstrucaoCreateScreen extends StatelessWidget {
  static const String routeName = '/intrucao-create';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const InstrucaoCreateScreen(),
    );
  }

  const InstrucaoCreateScreen({super.key});

  void onPressed() {
    // Implementar a lógica de salvar a receita
    print("Instrucao salva!");
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controllerInstrucao = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Instrução')),
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
                ElevatedButton(onPressed: onPressed, child: Text("Adicionar")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
