import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/repositories/instrucao_repository.dart';
import '/models/instrucao.dart';

class InstrucaoEditScreen extends StatefulWidget {
  const InstrucaoEditScreen({super.key});
  static const String routeName = '/instrucao-edit';

  @override
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
      Instrucao instrucaoEditado = Instrucao(
        id: instrucao.id,
        instrucao: _controllerInstrucao.text,
        receitaId: instrucao.receitaId,
      );
      await InstrucaoRepository().editar(instrucaoEditado);
      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Instrucao')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Instrucao',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerInstrucao,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira uma instrucao"
                              : null,
                ),
                SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () => onPressed(context),
                  icon: Icon(Icons.save),
                  label: Text("Salvar Instrução"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
