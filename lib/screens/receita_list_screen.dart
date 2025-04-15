import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/screens/receita_edit_screen.dart';
import '/models/receita.dart';
import '/screens/receita_create_screen.dart';
import '/screens/receita_detalhe_screen.dart';
import '../repositories/receita_repository.dart';

class ReceitaListScreen extends StatefulWidget {
  const ReceitaListScreen({super.key});
  static const routeName = '/receita';
  @override
  _ReceitaListScreenState createState() => _ReceitaListScreenState();
}

class _ReceitaListScreenState extends State<ReceitaListScreen> {
  List<Receita> _receitas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  void _carregarReceitas() async {
    setState(() {
      _isLoading = true;
    });

    final receitas = await ReceitaRepository().todasReceitas();

    if (mounted) {
      setState(() {
        _receitas = receitas;
        _isLoading = false;
      });
    }
  }

  void removerReceita(Receita receita) async {
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
                child: Text('Cancelar'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await ReceitaRepository().remover(receita);
      _carregarReceitas();
    }
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

  void criarReceita() {
    Navigator.pushNamed(
      context,
      ReceitaCreateScreen.routeName,
    ).then((_) => _carregarReceitas());
  }

  void verDetalhes(Receita receita) {
    Navigator.pushNamed(
      context,
      ReceitaDetalheScreen.routeName,
      arguments: receita,
    ).then((_) => _carregarReceitas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Receitas'), elevation: 2),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _receitas.isEmpty
              ? _buildEmptyState()
              : _buildReceitasList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: criarReceita,
        icon: const Icon(Icons.add),
        label: const Text('Nova Receita'),
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
          SizedBox(height: 8),
          Text(
            'Clique no botão abaixo para adicionar sua primeira receita!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: criarReceita,
            icon: Icon(Icons.add),
            label: Text('Adicionar Receita'),
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
