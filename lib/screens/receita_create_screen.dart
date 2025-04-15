import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
import 'package:uuid/uuid.dart';
import '/models/receita.dart';

class ReceitaCreateScreen extends StatefulWidget {
  static const String routeName = '/receita-create';
  const ReceitaCreateScreen({super.key});

  @override
  State<ReceitaCreateScreen> createState() => _ReceitaCreateScreenState();
}

class _ReceitaCreateScreenState extends State<ReceitaCreateScreen> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerNota = TextEditingController();
  final TextEditingController _controllerTempo = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerNota.dispose();
    _controllerTempo.dispose();
    super.dispose();
  }

  void onPressed() async {
    if (_formKey.currentState!.validate()) {
      var receita = Receita(
        nome: _controllerNome.text,
        criadoEm: DateTime.now().toString(),
        id: const Uuid().v4(),
        nota: int.parse(_controllerNota.text),
        tempoPreparo: _controllerTempo.text,
      );
      await ReceitaRepository().adicionar(receita);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Receita'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome da Receita',
                    hintText: 'Ex: Risoto de Funghi',
                    prefixIcon: Icon(Icons.restaurant_menu),
                  ),
                  controller: _controllerNome,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira um nome"
                              : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nota (1-5)',
                    hintText: 'Avalie de 1 a 5',
                    prefixIcon: Icon(Icons.star_rate),
                  ),
                  controller: _controllerNota,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Insira uma nota";
                    }
                    int? nota = int.tryParse(value);
                    if (nota == null || nota < 1 || nota > 5) {
                      return "Nota deve ser um número entre 1 e 5";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tempo de Preparo',
                    hintText: 'Ex: 30 minutos',
                    prefixIcon: Icon(Icons.timer),
                  ),
                  controller: _controllerTempo,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira um tempo de preparo"
                              : null,
                ),
                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: const Text(
                    "ADICIONAR RECEITA",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),

                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("VOLTAR"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
