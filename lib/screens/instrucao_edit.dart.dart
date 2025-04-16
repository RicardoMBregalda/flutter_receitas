import 'package:flutter/material.dart';
import '/repositories/instrucao_repository.dart';
import '/models/instrucao.dart';

class InstrucaoEditScreen extends StatefulWidget {
  const InstrucaoEditScreen({super.key});
  static const String routeName = '/instrucao-edit';

  @override
  // ignore: library_private_types_in_public_api
  _InstrucaoEditScreenState createState() => _InstrucaoEditScreenState();
}

class _InstrucaoEditScreenState extends State<InstrucaoEditScreen> {
  final TextEditingController _controllerInstrucao = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controllerInstrucao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instrucao = ModalRoute.of(context)!.settings.arguments as Instrucao;
    _controllerInstrucao.text = instrucao.instrucao;

    Future<void> onPressed(BuildContext context) async {
      if (_formKey.currentState!.validate()) {
        Instrucao instrucaoEditado = Instrucao(
          id: instrucao.id,
          instrucao: _controllerInstrucao.text,
          receitaId: instrucao.receitaId,
        );
        await InstrucaoRepository().editar(instrucaoEditado);
        if (context.mounted) Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Instrução'), elevation: 0),
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
                  hintText: 'Descreva detalhadamente esta etapa da receita',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                controller: _controllerInstrucao,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? "Insira uma instrução"
                            : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => onPressed(context),
                icon: const Icon(Icons.save),
                label: const Text(
                  "SALVAR ALTERAÇÕES",
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
                icon: const Icon(Icons.cancel),
                label: const Text("CANCELAR"),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
