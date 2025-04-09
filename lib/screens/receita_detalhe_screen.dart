import 'package:flutter/material.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    _receita = receita;
    _carregarDados();
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

  void editarReceita() async {
    final receitaEditada =
        await Navigator.pushNamed(
              context,
              ReceitaEditScreen.routeName,
              arguments: _receita,
            ).then((_) => _carregarDados())
            as Receita?;
    if (receitaEditada != null) {
      setState(() {
        _receita = receitaEditada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhe')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ElevatedButton(onPressed: editarReceita, child: Text("Editar")),
                Text('ID ${_receita.id}'),
                Text('Nome ${_receita.nome}'),
                Text('Nota ${_receita.nota}'),
                Text('Criado em ${_receita.criadoEm}'),
                Text('Tempo de Preparo ${_receita.tempoPreparo}'),
                Text('Ingredientes'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _ingredientes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${_ingredientes[index].nome} - ${_ingredientes[index].quantidade} unidade(s)',
                      ),
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            IngredienteEditScreen.routeName,
                            arguments: _ingredientes[index],
                          ).then((_) => _carregarDados()),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: criarIngrediente,
                  child: Text("Adicionar Ingrediente"),
                ),
                Text('Instruções'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _instrucoes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_instrucoes[index].instrucao),
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            InstrucaoEditScreen.routeName,
                            arguments: _instrucoes[index],
                          ).then((_) => _carregarDados()),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: criarInstrucao,
                  child: Text("Adicionar Instrução"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
