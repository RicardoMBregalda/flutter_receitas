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
      if (_formKey.currentState!.validate()) {
        Ingrediente ingredienteEditado = Ingrediente(
          id: ingrediente.id,
          nome: _controllerNome.text,
          quantidade: _controllerQuantidade.text,
          receitaId: ingrediente.receitaId,
        );
        await IngredienteRepository().editar(ingredienteEditado);
        if (context.mounted) Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Ingrediente'), elevation: 0),
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
                  hintText: 'Ex: Farinha de trigo',
                  prefixIcon: Icon(Icons.restaurant),
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
                  labelText: 'Quantidade',
                  hintText: 'Ex: 2 xícaras',
                  prefixIcon: Icon(Icons.scale),
                ),
                controller: _controllerQuantidade,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? "Insira uma quantidade"
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
