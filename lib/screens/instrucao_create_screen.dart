import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/instrucao.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/repositories/instrucao_repository.dart';
import 'package:uuid/uuid.dart';

class InstrucaoCreateScreen extends StatefulWidget {
  const InstrucaoCreateScreen({super.key});
  static const String routeName = '/intrucao-create';
  @override
  _InstrucaoCreateScreenState createState() => _InstrucaoCreateScreenState();
}

class _InstrucaoCreateScreenState extends State<InstrucaoCreateScreen> {
  final TextEditingController _controllerInstrucao = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void onPressed(BuildContext context, Receita receita) async {
    var instrucao = Instrucao(
      id: Uuid().v4(),
      instrucao: _controllerInstrucao.text,
      receitaId: receita.id,
    );
    await InstrucaoRepository().adicionar(instrucao);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Instrução')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Instrução',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerInstrucao,
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => onPressed(context, receita),
                  icon: Icon(Icons.add),
                  label: Text("Adicionar Instrucao"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
