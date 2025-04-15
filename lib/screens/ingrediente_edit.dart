import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/repositories/ingrediente_repository.dart';
import '/models/ingrediente.dart';

class IngredienteEditScreen extends StatefulWidget {
  const IngredienteEditScreen({super.key});
  static const String routeName = '/ingrediente-edit';

  @override
  _IngredienteEditScreenState createState() => _IngredienteEditScreenState();
}

class _IngredienteEditScreenState extends State<IngredienteEditScreen> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerQuantidade = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerQuantidade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingrediente =
        ModalRoute.of(context)!.settings.arguments as Ingrediente;
    _controllerNome.text = ingrediente.nome;
    _controllerQuantidade.text = ingrediente.quantidade.toString();

    Future<void> onPressed(BuildContext context) async {
      Ingrediente ingredienteEditado = Ingrediente(
        id: ingrediente.id,
        nome: _controllerNome.text,
        quantidade: _controllerQuantidade.text,
        receitaId: ingrediente.receitaId,
      );
      await IngredienteRepository().editar(ingredienteEditado);
      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Ingrediente')),
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
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  controller: _controllerQuantidade,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? "Insira uma quantidade"
                              : null,
                ),
                SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () => onPressed(context),
                  icon: Icon(Icons.save),
                  label: Text("Salvar Ingrediente"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
