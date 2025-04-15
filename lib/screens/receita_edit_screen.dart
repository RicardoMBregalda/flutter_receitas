import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/repositories/receita_repository.dart';
import '/models/receita.dart';

class ReceitaEditScreen extends StatefulWidget {
  const ReceitaEditScreen({super.key});
  static const String routeName = '/receita-edit';

  @override
  _ReceitaEditScreenState createState() => _ReceitaEditScreenState();
}

class _ReceitaEditScreenState extends State<ReceitaEditScreen> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerNota = TextEditingController();
  final TextEditingController _controllerTempo = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _controllerNome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    _controllerTempo.text = receita.tempoPreparo;
    _controllerNome.text = receita.nome;
    _controllerNota.text = receita.nota.toString();

    Future<void> onPressed(BuildContext context) async {
      Receita receitaEditada = Receita(
        id: receita.id,
        nome: _controllerNome.text,
        nota: int.parse(_controllerNota.text),
        criadoEm: receita.criadoEm,
        tempoPreparo: _controllerTempo.text,
      );
      await ReceitaRepository().editar(receitaEditada);
      if (context.mounted) Navigator.pop(context, receitaEditada);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Receita')),
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
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira um nome"
                              : null,
                ),
                SizedBox(height: 12),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nota',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerNota,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira uma nota"
                              : null,
                ),
                SizedBox(height: 12),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tempo de Preparo',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerTempo,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira um tempo de preparo"
                              : null,
                ),
                SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () => onPressed(context),
                  icon: Icon(Icons.save),
                  label: Text("Salvar Receita"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
