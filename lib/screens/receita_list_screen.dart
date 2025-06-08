import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // AJUSTE: Importe o Provider
import 'package:receitas_trabalho_2/screens/receita_edit_screen.dart';
import '/services/auth_service.dart'; // AJUSTE: Importe seu AuthService
import '/services/receita_service.dart';
import '/models/receita.dart';
import '/screens/receita_create_screen.dart';
import '/screens/receita_detalhe_screen.dart';
import '/repositories/receita_repository.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class ReceitaListScreen extends StatefulWidget {
  const ReceitaListScreen({super.key});
  static const routeName = '/receita'; // Ou '/home' se for sua tela inicial
  @override
  State<ReceitaListScreen> createState() => _ReceitaListScreenState();
}

class _ReceitaListScreenState extends State<ReceitaListScreen> {
  List<Receita> _receitas = [];
  bool _isLoading = true;
  final _key = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    // Atrasar um pouco a chamada para garantir que o 'context' esteja pronto para o Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarReceitas();
    });
  }

  Future<void> _carregarReceitas() async {
    setState(() => _isLoading = true);
    final userId = Provider.of<AuthService>(context, listen: false).userId;

    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final receitas = await ReceitaRepository().listarReceitasPorUsuario(userId);

    if (mounted) {
      setState(() {
        _receitas = receitas;
        _isLoading = false;
      });
    }
  }

  Future<void> _gerarReceitaAleatoria() async {
    setState(() => _isLoading = true);

    final userId = Provider.of<AuthService>(context, listen: false).userId;
    if (userId == null) return;

    await ReceitaService().criarReceitaAleatoria(userId);
    _carregarReceitas();
  }

  void editarReceita(Receita receita) async {
    await Navigator.pushNamed(
          context,
          ReceitaEditScreen.routeName,
          arguments: receita,
        )
        as Receita?;

    _carregarReceitas();
  }

  void removerReceita(Receita receita) async {
    // ... (seu código de showDialog está ótimo)
    final confirmar = await showDialog<bool>(
      context: context,

      builder:
          (context) => AlertDialog(
            title: Text('Confirmar exclusão'),

            content: Text(
              'Deseja realmente excluir a receita "${receita.nome}"?',
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),

                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),

                child: Text('Cancelar'),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context, true),

                child: Text('Excluir'),
              ),
            ],
          ),
    );
    if (confirmar == true) {
      final userId = Provider.of<AuthService>(context, listen: false).userId;
      if (userId == null) return;

      await ReceitaRepository().remover(receita.id, userId);
      _carregarReceitas();
    }
  }

  void criarReceita() async {
    final result = await Navigator.pushNamed(
      context,
      ReceitaCreateScreen.routeName,
    );

    _carregarReceitas();

    if (result is Receita && mounted) {
      verDetalhes(result);
    }
  }

  void _signOut() async {
    await Provider.of<AuthService>(context, listen: false).logout();
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Você saiu com sucesso!')));
    }
  }

  void verDetalhes(Receita receita) async {
    await Navigator.pushNamed(
      context,
      ReceitaDetalheScreen.routeName,
      arguments: receita,
    );
    _carregarReceitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Receitas'),
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _receitas.isEmpty
              ? _buildEmptyState()
              : _buildReceitasList(),

      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.small,
        ),
        children: [
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.add),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                criarReceita();
                state.toggle();
              }
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.shuffle),
            onPressed: () async {
              final state = _key.currentState;
              if (state != null) {
                _gerarReceitaAleatoria();
                state.toggle();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Nenhuma receita encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceitasList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: _receitas.length,
        itemBuilder: (context, index) {
          final receita = _receitas[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => verDetalhes(receita),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            receita.nome,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => editarReceita(receita),
                              icon: Icon(Icons.edit),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              onPressed: () => removerReceita(receita),
                              icon: Icon(Icons.delete),
                              tooltip: 'Excluir',
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16),
                        SizedBox(width: 4),
                        Text('${receita.nota}'),
                        SizedBox(width: 16),
                        Icon(Icons.timer, size: 16),
                        SizedBox(width: 4),
                        Text(receita.tempoPreparo),
                        SizedBox(width: 16),
                        Icon(Icons.restaurant, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${receita.quantidadeIngredientes.toString()} ingredientes',
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
