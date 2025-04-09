import 'package:flutter/material.dart';

class IngredienteCreateScreen extends StatelessWidget {
  static const String routeName = '/ingrediente-create';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const IngredienteCreateScreen(),
    );
  }

  const IngredienteCreateScreen({super.key});

  void onPressed() {
    // Implementar a lógica de salvar a receita
    print("Ingrediente salva!");
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controllerNome = TextEditingController();
    final TextEditingController _controllerQuantidade = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Ingrediente')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ingrediente'),
                  controller: _controllerNome,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  controller: _controllerQuantidade,
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
