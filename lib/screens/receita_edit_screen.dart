import 'package:flutter/material.dart';
import '/models/receita.dart';

class ReceitaEditScreen extends StatelessWidget {
  static const String routeName = '/receita-edit';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const ReceitaEditScreen(),
    );
  }

  const ReceitaEditScreen({super.key});

  void onPressed() {
    // Implementar a lógica de salvar a receita
    print("Receita salva!");
  }

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;

    final TextEditingController _controllerNome = TextEditingController();
    final TextEditingController _controllerNota = TextEditingController();
    final TextEditingController _controllerTempo = TextEditingController();

    _controllerTempo.text = receita.tempoPreparo;
    _controllerNome.text = receita.nome;
    _controllerNota.text = receita.nota.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Receita')),
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
                ElevatedButton(onPressed: onPressed, child: Text("Salvar")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
