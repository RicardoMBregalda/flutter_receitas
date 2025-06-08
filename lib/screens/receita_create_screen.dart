import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '/models/ingrediente.dart';
import '/models/instrucao.dart';
import '/models/receita.dart';
import '/repositories/receita_repository.dart';
import '/services/auth_service.dart';

class ReceitaCreateScreen extends StatefulWidget {
  static const String routeName = '/receita-create';
  const ReceitaCreateScreen({super.key});

  @override
  State<ReceitaCreateScreen> createState() => _ReceitaCreateScreenState();
}

class _IngredienteFieldState {
  final TextEditingController nomeController;
  final TextEditingController qtdController;

  _IngredienteFieldState()
    : nomeController = TextEditingController(),
      qtdController = TextEditingController();

  void dispose() {
    nomeController.dispose();
    qtdController.dispose();
  }
}

class _ReceitaCreateScreenState extends State<ReceitaCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _nomeController = TextEditingController();
  final _notaController = TextEditingController();
  final _tempoController = TextEditingController();
  final _urlController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _descricaoController = TextEditingController();

  final List<_IngredienteFieldState> _ingredienteFields = [];
  final List<TextEditingController> _instrucaoControllers = [];

  @override
  void initState() {
    super.initState();
    _addIngredienteField();
    _addInstrucaoField();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _notaController.dispose();
    _tempoController.dispose();
    _urlController.dispose();
    _quantidadeController.dispose();
    _descricaoController.dispose();

    for (var field in _ingredienteFields) {
      field.dispose();
    }
    for (var controller in _instrucaoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredienteField() {
    setState(() {
      _ingredienteFields.add(_IngredienteFieldState());
    });
  }

  void _removeIngredienteField(int index) {
    setState(() {
      _ingredienteFields[index].dispose();
      _ingredienteFields.removeAt(index);
    });
  }

  void _addInstrucaoField() {
    setState(() {
      _instrucaoControllers.add(TextEditingController());
    });
  }

  void _removeInstrucaoField(int index) {
    setState(() {
      _instrucaoControllers[index].dispose();
      _instrucaoControllers.removeAt(index);
    });
  }

  void _onPressed() async {
    if (_formKey.currentState!.validate()) {
      final userId = Provider.of<AuthService>(context, listen: false).userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não autenticado.')),
        );
        return;
      }
      final List<Ingrediente> ingredientes =
          _ingredienteFields
              .where((field) => field.nomeController.text.trim().isNotEmpty)
              .map((field) {
                return Ingrediente(
                  id: _uuid.v4(),
                  nome: field.nomeController.text.trim(),
                  quantidade: field.qtdController.text.trim(),
                  userId: userId,
                  receitaId: '',
                );
              })
              .toList();

      final List<Instrucao> instrucoes =
          _instrucaoControllers
              .map((controller) => controller.text.trim())
              .where((desc) => desc.isNotEmpty) // Ignora campos vazios
              .map(
                (desc) => Instrucao(
                  id: _uuid.v4(),
                  instrucao: desc,
                  userId: userId,
                  receitaId: '',
                ),
              )
              .toList();

      final receita = Receita(
        id: _uuid.v4(),
        nome: _nomeController.text.trim(),
        nota: int.parse(_notaController.text),
        tempoPreparo: _tempoController.text.trim(),
        urlImagem: _urlController.text.trim(),
        userId: userId,
        criadoEm: DateTime.now().toIso8601String(),
        ingredientes: ingredientes, // Adiciona a lista de ingredientes
        instrucoes: instrucoes, // Adiciona a lista de instruções
      );

      await ReceitaRepository().adicionar(receita);
      if (!mounted) return;
      Navigator.pop(context, receita);
    }
  }

  @override
  Widget build(BuildContext context) {
    // AJUSTE: O código que estava aqui foi removido por ser desnecessário na tela de criação.
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Receita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CAMPOS PRINCIPAIS (Nome, Nota, etc.)
              Text(
                'Informações da Receita',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Receita',
                  hintText: 'Ex: Bolo de Chocolate',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? "Insira um nome"
                            : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Uma deliciosa receita de bolo de chocolate.',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? "Insira uma descrição"
                            : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notaController,
                decoration: const InputDecoration(
                  labelText: 'Nota (1-5)',
                  hintText: 'Ex: 4',
                  prefixIcon: Icon(Icons.star),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Insira uma nota";
                  }
                  final nota = int.tryParse(value);
                  if (nota == null || nota < 1 || nota > 5) {
                    return "A nota deve ser entre 1 e 5";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempoController,
                decoration: const InputDecoration(
                  labelText: 'Tempo de Preparo',
                  hintText: 'Ex: 30 minutos',
                  prefixIcon: Icon(Icons.timer),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? "Insira o tempo de preparo"
                            : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL da Imagem',
                  hintText: 'Ex: https://exemplo.com/imagem.jpg',
                  prefixIcon: Icon(Icons.image),
                ),
              ),

              const Divider(height: 48, thickness: 1),

              _buildIngredientesInputList(),
              const Divider(height: 48, thickness: 1),

              _buildInstrucoesInputList(),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _onPressed,
                icon: const Icon(Icons.add),
                label: const Text("ADICIONAR RECEITA"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientesInputList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredientes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _ingredienteFields.length,
          itemBuilder: (context, index) {
            final fieldState = _ingredienteFields[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo para o NOME do ingrediente
                  Expanded(
                    flex: 3, // Ocupa mais espaço
                    child: TextFormField(
                      controller: fieldState.nomeController,
                      decoration: InputDecoration(
                        labelText: 'Ingrediente ${index + 1}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Campo para a QUANTIDADE
                  Expanded(
                    flex: 2, // Ocupa menos espaço
                    child: TextFormField(
                      controller: fieldState.qtdController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => _removeIngredienteField(index),
                  ),
                ],
              ),
            );
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Adicionar Ingrediente'),
          onPressed: _addIngredienteField,
        ),
      ],
    );
  }

  Widget _buildInstrucoesInputList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instruções', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _instrucaoControllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _instrucaoControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Passo ${index + 1}',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => _removeInstrucaoField(index),
                  ),
                ],
              ),
            );
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Adicionar Instrução'),
          onPressed: _addInstrucaoField,
        ),
      ],
    );
  }
}
