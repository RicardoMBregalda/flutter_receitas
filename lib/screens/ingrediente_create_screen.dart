import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/ingrediente.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/repositories/ingrediente_repository.dart';
import 'package:receitas_trabalho_2/repositories/instrucao_repository.dart';
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
    var ingrediente = Ingrediente(
      id: Uuid().v4(),
      nome: _controllerNome.text,
      quantidade: _controllerQuantidade.text,
      receitaId: receita.id,
    );
    await IngredienteRepository().adicionar(ingrediente);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Ingrediente')),
      body: Padding(
        padding: const EdgeInsets.all(8),
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
                ),
                SizedBox(height: 12),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerQuantidade,
                ),
                SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () => onPressed(context, receita),
                  icon: Icon(Icons.add),
                  label: Text("Adicionar Ingrediente"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
