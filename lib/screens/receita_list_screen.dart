import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/ingrediente.dart';
import 'package:receitas_trabalho_2/models/instrucao.dart';
import 'package:receitas_trabalho_2/repositories/ingrediente_repository.dart';
import 'package:receitas_trabalho_2/repositories/instrucao_repository.dart';
import 'package:uuid/uuid.dart';
import '/screens/receita_edit_screen.dart';
import '/models/receita.dart';
import '/screens/receita_create_screen.dart';
import '/screens/receita_detalhe_screen.dart';
import '../repositories/receita_repository.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:http/http.dart' as http;

class ReceitaListScreen extends StatefulWidget {
  const ReceitaListScreen({super.key});
  static const routeName = '/receita';
  @override
  // ignore: library_private_types_in_public_api
  _ReceitaListScreenState createState() => _ReceitaListScreenState();
}

class _ReceitaListScreenState extends State<ReceitaListScreen> {
  List<Receita> _receitas = [];
  bool _isLoading = true;
  final _key = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  Future<void> criarReceitaAleatoria() async {
    final url = Uri.parse(
      'https://randommer.io/api/Text/LoremIpsum?loremType=normal&type=paragraphs&number=5',
    );

    final response = await http.get(
      url,
      headers: {'accept': '*/*', 'X-Api-Key': dotenv.env['API_KEY'] ?? ''},
    );

    if (response.statusCode == 200) {
      String texto = jsonDecode(response.body) as String;
      List<String> palavras = texto.split(' ');
      int tempo = Random().nextInt(30) + 1;

      var receita = Receita(
        nome: palavras[Random().nextInt(palavras.length)],
        criadoEm: DateTime.now().toString(),
        id: const Uuid().v4(),
        nota: Random().nextInt(5),
        tempoPreparo: tempo < 6 ? '$tempo horas' : '$tempo minutos',
      );

      await ReceitaRepository().adicionar(receita);

      var quantidadeIngredientes = Random().nextInt(4) + 1;
      var quantidadeInstrucoes = Random().nextInt(4) + 1;

      for (var i = 0; i < quantidadeIngredientes; i++) {
        await IngredienteRepository().adicionar(
          Ingrediente(
            id: const Uuid().v4(),
            nome: palavras[Random().nextInt(palavras.length)],
            quantidade: '${Random().nextInt(1000)} g',
            receitaId: receita.id,
          ),
        );
      }

      for (var i = 0; i < quantidadeInstrucoes; i++) {
        await InstrucaoRepository().adicionar(
          Instrucao(
            id: const Uuid().v4(),
            instrucao: palavras[Random().nextInt(palavras.length)],
            receitaId: receita.id,
          ),
        );
      }
    }
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
      appBar: AppBar(title: const Text('Minhas Receitas'), elevation: 2),
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
            child: const Icon(Icons.question_mark),
            onPressed: () async {
              final state = _key.currentState;
              if (state != null) {
                await criarReceitaAleatoria();
                _carregarReceitas();
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
