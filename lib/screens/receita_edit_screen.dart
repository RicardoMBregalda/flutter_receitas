import 'package:flutter/material.dart';
import '/repositories/receita_repository.dart';
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
    _controllerNota.dispose();
    _controllerTempo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    _controllerTempo.text = receita.tempoPreparo;
    _controllerNome.text = receita.nome;
    _controllerNota.text = receita.nota.toString();

    Future<void> onPressed(BuildContext context) async {
      if (_formKey.currentState!.validate()) {
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
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Receita'), elevation: 0),
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
                    hintText: 'Ex: Bolo de Chocolate',
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
                    prefixIcon: Icon(Icons.star),
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
                    hintText: 'Ex: 45 minutos',
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
                  onPressed: () => onPressed(context),
                  icon: const Icon(Icons.save),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: const Text(
                    "SALVAR ALTERAÇÕES",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),

                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text("CANCELAR"),
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
