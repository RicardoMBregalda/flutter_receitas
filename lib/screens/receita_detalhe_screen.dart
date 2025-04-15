import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import '/repositories/ingrediente_repository.dart';
import '/repositories/instrucao_repository.dart';
import '/screens/ingrediente_create_screen.dart';
import '/screens/instrucao_create_screen.dart';
import '/models/ingrediente.dart';
import '/models/instrucao.dart';
import '/models/receita.dart';
import '/screens/ingrediente_edit.dart';
import '/screens/instrucao_edit.dart.dart';
import '/screens/receita_edit_screen.dart';

class ReceitaDetalheScreen extends StatefulWidget {
  const ReceitaDetalheScreen({super.key});
  static const routeName = '/receita_detalhe';
  @override
  _ReceitaDetalheScreenState createState() => _ReceitaDetalheScreenState();
}

class _ReceitaDetalheScreenState extends State<ReceitaDetalheScreen> {
  List<Ingrediente> _ingredientes = [];
  List<Instrucao> _instrucoes = [];
  late Receita _receita;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final receita = ModalRoute.of(context)!.settings.arguments as Receita;
      _receita = receita;
      _isInitialized = true;
      _carregarDados();
    }
  }

  Future<void> _carregarDados() async {
    var ingredientes = await IngredienteRepository().ingredientesReceita(
      _receita.id,
    );
    var instrucoes = await InstrucaoRepository().instrucoesReceita(_receita.id);
    setState(() {
      _ingredientes = ingredientes;
      _instrucoes = instrucoes;
    });
  }

  void criarIngrediente() {
    Navigator.pushNamed(
      context,
      IngredienteCreateScreen.routeName,
      arguments: _receita,
    ).then((_) => _carregarDados());
  }

  void criarInstrucao() {
    Navigator.pushNamed(
      context,
      InstrucaoCreateScreen.routeName,
      arguments: _receita,
    ).then((_) => _carregarDados());
  }

  void editarIngrediente(Ingrediente ingrediente) {
    Navigator.pushNamed(
      context,
      IngredienteEditScreen.routeName,
      arguments: ingrediente,
    ).then((_) => _carregarDados());
  }

  void editarInstrucao(Instrucao instrucao) {
    Navigator.pushNamed(
      context,
      InstrucaoEditScreen.routeName,
      arguments: instrucao,
    ).then((_) => _carregarDados());
  }

  void removerInstrucao(Instrucao instrucao) async {
    await InstrucaoRepository().remover(instrucao);
    await _carregarDados();
  }

  void removerIngrediente(Ingrediente ingrediente) async {
    await IngredienteRepository().remover(ingrediente);
    await _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_receita.nome)),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                _buildListaIngredientes(),
                SizedBox(height: 16),
                _buildListaInstrucoes(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Container(
        decoration: BoxDecoration(),
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _receita.nome,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                // ElevatedButton(onPressed: () {}, child: Icon(Icons.edit)),
              ],
            ),

            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star),
                SizedBox(width: 4),
                Text(_receita.nota.toString()),
                SizedBox(width: 8),
                Icon(Icons.timer),
                SizedBox(width: 4),
                Text(_receita.tempoPreparo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaIngredientes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(
              "Ingredientes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: criarIngrediente,
              icon: Icon(Icons.add),
              label: Text("Adicionar"),
            ),
          ],
        ),
        SizedBox(height: 8),
        Card(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _ingredientes.length,
            itemBuilder: (context, index) {
              return ListTile(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => editarIngrediente(_ingredientes[index]),
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => removerIngrediente(_ingredientes[index]),
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
                title: Text(
                  '${_ingredientes[index].nome} - ${_ingredientes[index].quantidade}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListaInstrucoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(
              "Instrucoes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: criarInstrucao,
              icon: Icon(Icons.add),
              label: Text("Adicionar"),
            ),
          ],
        ),
        SizedBox(height: 8),
        Card(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _instrucoes.length,
            itemBuilder: (context, index) {
              return ListTile(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => editarInstrucao(_instrucoes[index]),
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => removerInstrucao(_instrucoes[index]),
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
                title: Text(_instrucoes[index].instrucao),
              );
            },
          ),
        ),
      ],
    );
  }
}
