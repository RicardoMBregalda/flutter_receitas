import 'package:flutter/material.dart';
import '/models/ingrediente.dart';
import '/models/receita.dart';
import '/repositories/ingrediente_repository.dart';
import 'package:uuid/uuid.dart';

class IngredienteCreateScreen extends StatefulWidget {
  const IngredienteCreateScreen({super.key});
  static const String routeName = '/ingrediente-create';

  @override
  _IngredienteCreateScreenState createState() =>
      _IngredienteCreateScreenState();
}

class _IngredienteCreateScreenState extends State<IngredienteCreateScreen> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerQuantidade = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void onPressed(BuildContext context, Receita receita) async {
    if (_formKey.currentState!.validate()) {
      var ingrediente = Ingrediente(
        id: const Uuid().v4(),
        nome: _controllerNome.text,
        quantidade: _controllerQuantidade.text,
        receitaId: receita.id,
      );
      await IngredienteRepository().adicionar(ingrediente);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Ingrediente'), elevation: 0),
      body: Container(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nome do Ingrediente',
                  prefixIcon: Icon(Icons.restaurant),
                ),
                controller: _controllerNome,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do ingrediente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  prefixIcon: Icon(Icons.scale),
                ),
                controller: _controllerQuantidade,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => onPressed(context, receita),
                icon: const Icon(Icons.add),
                label: const Text(
                  "ADICIONAR INGREDIENTE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("VOLTAR"),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
