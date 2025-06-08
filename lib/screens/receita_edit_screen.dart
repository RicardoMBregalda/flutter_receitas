import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '/models/ingrediente.dart';
import '/models/instrucao.dart';
import '/models/receita.dart';
import '/repositories/receita_repository.dart';
import '/services/auth_service.dart';

class ReceitaEditScreen extends StatefulWidget {
  static const String routeName = '/receita-edit';
  const ReceitaEditScreen({super.key});

  @override
  State<ReceitaEditScreen> createState() => _ReceitaEditScreenState();
}

// Classe auxiliar para gerenciar os controllers de cada ingrediente
class _IngredienteFieldState {
  final TextEditingController nomeController;
  final TextEditingController qtdController;

  _IngredienteFieldState({String nome = '', String qtd = ''})
    : nomeController = TextEditingController(text: nome),
      qtdController = TextEditingController(text: qtd);

  void dispose() {
    nomeController.dispose();
    qtdController.dispose();
  }
}

class _ReceitaEditScreenState extends State<ReceitaEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  late Receita _receitaOriginal; // Armazena a receita original

  // Controllers para os campos principais da receita
  final _nomeController = TextEditingController();
  final _notaController = TextEditingController();
  final _tempoController = TextEditingController();
  final _urlController = TextEditingController();
  final _descricaoController = TextEditingController();

  // Listas para gerenciar os controllers dos campos dinâmicos
  final List<_IngredienteFieldState> _ingredienteFields = [];
  final List<TextEditingController> _instrucaoControllers = [];

  // Flag para garantir que a inicialização ocorra apenas uma vez
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carrega os dados da receita apenas na primeira vez que o widget é construído
    if (!_isInitialized) {
      final receita = ModalRoute.of(context)!.settings.arguments as Receita;
      _receitaOriginal = receita;

      // Preenche os controllers com os dados da receita
      _nomeController.text = receita.nome;
      _notaController.text = receita.nota.toString();
      _tempoController.text = receita.tempoPreparo;
      _urlController.text = receita.urlImagem ?? '';
      _descricaoController.text = receita.descricao ?? '';

      // Cria controllers para os ingredientes existentes
      for (var ingrediente in receita.ingredientes) {
        _ingredienteFields.add(
          _IngredienteFieldState(
            nome: ingrediente.nome,
            qtd: ingrediente.quantidade,
          ),
        );
      }

      // Cria controllers para as instruções existentes
      for (var instrucao in receita.instrucoes) {
        _instrucaoControllers.add(
          TextEditingController(text: instrucao.instrucao),
        );
      }

      // Garante que haja pelo menos um campo se a lista estiver vazia
      if (_ingredienteFields.isEmpty) _addIngredienteField(silent: true);
      if (_instrucaoControllers.isEmpty) _addInstrucaoField(silent: true);

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    // Limpa todos os controllers para evitar memory leaks
    _nomeController.dispose();
    _notaController.dispose();
    _tempoController.dispose();
    _urlController.dispose();
    _descricaoController.dispose();

    for (var field in _ingredienteFields) {
      field.dispose();
    }
    for (var controller in _instrucaoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Funções para adicionar e remover campos dinamicamente
  void _addIngredienteField({bool silent = false}) {
    final action = () => _ingredienteFields.add(_IngredienteFieldState());
    silent ? action() : setState(action);
  }

  void _removeIngredienteField(int index) {
    setState(() {
      _ingredienteFields[index].dispose();
      _ingredienteFields.removeAt(index);
    });
  }

  void _addInstrucaoField({bool silent = false}) {
    final action = () => _instrucaoControllers.add(TextEditingController());
    silent ? action() : setState(action);
  }

  void _removeInstrucaoField(int index) {
    setState(() {
      _instrucaoControllers[index].dispose();
      _instrucaoControllers.removeAt(index);
    });
  }

  // Método de submissão para salvar as alterações
  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final userId = Provider.of<AuthService>(context, listen: false).userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não autenticado.')),
        );
        return;
      }

      // Converte os controllers de volta para a lista de Ingredientes
      final List<Ingrediente> ingredientes =
          _ingredienteFields
              .where((field) => field.nomeController.text.trim().isNotEmpty)
              .map(
                (field) => Ingrediente(
                  id: _uuid.v4(),
                  nome: field.nomeController.text.trim(),
                  quantidade: field.qtdController.text.trim(),
                  userId: userId,
                  receitaId: _receitaOriginal.id,
                ),
              )
              .toList();

      // Converte os controllers de volta para a lista de Instrucoes
      final List<Instrucao> instrucoes =
          _instrucaoControllers
              .map((controller) => controller.text.trim())
              .where((desc) => desc.isNotEmpty)
              .map(
                (desc) => Instrucao(
                  id: _uuid.v4(),
                  instrucao: desc,
                  userId: userId,
                  receitaId: _receitaOriginal.id,
                ),
              )
              .toList();

      final receitaEditada = Receita(
        id: _receitaOriginal.id, // Mantém o ID original
        nome: _nomeController.text.trim(),
        nota: int.parse(_notaController.text),
        tempoPreparo: _tempoController.text.trim(),
        urlImagem: _urlController.text.trim(),
        descricao: _descricaoController.text.trim(),
        userId: userId,
        criadoEm: _receitaOriginal.criadoEm, // Mantém a data de criação
        ingredientes: ingredientes,
        instrucoes: instrucoes,
      );

      // O repositório deve ser capaz de lidar com a atualização da receita e suas sub-listas
      await ReceitaRepository().editar(receitaEditada, userId);
      if (!mounted) return;
      Navigator.pop(context, receitaEditada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Receita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Informações da Receita',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Receita',
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
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notaController,
                decoration: const InputDecoration(
                  labelText: 'Nota (1-5)',
                  prefixIcon: Icon(Icons.star),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Insira uma nota";
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
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const Divider(height: 48, thickness: 1),
              _buildIngredientesInputList(),
              const Divider(height: 48, thickness: 1),
              _buildInstrucoesInputList(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.save),
                label: const Text("SALVAR ALTERAÇÕES"),
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
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: fieldState.nomeController,
                      decoration: InputDecoration(
                        labelText: 'Ingrediente ${index + 1}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
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
