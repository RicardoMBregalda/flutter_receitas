import 'package:flutter/material.dart';
import '/models/instrucao.dart';
import '/models/receita.dart';
import '/repositories/instrucao_repository.dart';
import 'package:uuid/uuid.dart';

class InstrucaoCreateScreen extends StatefulWidget {
  const InstrucaoCreateScreen({super.key});
  static const String routeName = '/intrucao-create';

  @override
  // ignore: library_private_types_in_public_api
  _InstrucaoCreateScreenState createState() => _InstrucaoCreateScreenState();
}

class _InstrucaoCreateScreenState extends State<InstrucaoCreateScreen> {
  final TextEditingController _controllerInstrucao = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void onPressed(BuildContext context, Receita receita) async {
    if (_formKey.currentState!.validate()) {
      var instrucao = Instrucao(
        id: const Uuid().v4(),
        instrucao: _controllerInstrucao.text,
        receitaId: receita.id,
      );
      await InstrucaoRepository().adicionar(instrucao);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Instrução'), elevation: 0),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Passo a Passo',
                  hintText: 'Descreva a instrução para esta receita',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                controller: _controllerInstrucao,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a instrução';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => onPressed(context, receita),
                icon: const Icon(Icons.add),
                label: const Text(
                  "ADICIONAR INSTRUÇÃO",
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
