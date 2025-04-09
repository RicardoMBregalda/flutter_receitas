import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/repositories/ingrediente_repository.dart';
import 'package:receitas_trabalho_2/repositories/instrucao_repository.dart';
import 'package:receitas_trabalho_2/screens/ingrediente_create_screen.dart';
import 'package:receitas_trabalho_2/screens/instrucao_create_screen.dart';
import '/models/ingrediente.dart';
import '/models/instrucao.dart';
import '/models/receita.dart';
import '/screens/ingrediente_edit.dart';
import '/screens/instrucao_edit.dart.dart';
import '/screens/receita_edit_screen.dart';
import '/models/pessoa.dart';
import 'package:uuid/uuid.dart';

class ReceitaDetalheScreen extends StatefulWidget {
  const ReceitaDetalheScreen({super.key});
  static const routeName = '/receita_detalhe';
  @override
  _ReceitaDetalheScreenState createState() => _ReceitaDetalheScreenState();
}

class _ReceitaDetalheScreenState extends State<ReceitaDetalheScreen> {
  List<Ingrediente> _ingredientes = [];
  List<Instrucao> _instrucoes = [];
  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    void criarIngrediente() {
      Navigator.pushNamed(
        context,
        IngredienteCreateScreen.routeName,
        arguments: receita,
      );
    }

    void carregarIngredientes() async {
      var ingredientes = await IngredienteRepository().ingredientesReceita(
        receita.id,
      );
      setState(() {
        _ingredientes = ingredientes;
      });
    }

    void carregarInstrucoes() async {
      var instrucoes = await InstrucaoRepository().instrucoesReceita(
        receita.id,
      );
      setState(() {
        _instrucoes = instrucoes;
      });
    }

    void criarInstrucao() {
      Navigator.pushNamed(
        context,
        InstrucaoCreateScreen.routeName,
        arguments: receita,
      );
    }

    void editarReceita() {
      Navigator.pushNamed(
        context,
        ReceitaEditScreen.routeName,
        arguments: receita,
      );
    }

    carregarIngredientes();
    carregarInstrucoes();
    return Scaffold(
      appBar: AppBar(title: Text('Detalhe')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ElevatedButton(onPressed: editarReceita, child: Text("Editar")),
                Text('ID ${receita.id}'),
                Text('Nome ${receita.nome}'),
                Text('Nota ${receita.nota}'),
                Text('Criado em ${receita.criadoEm}'),
                Text('Tempo de Preparo ${receita.tempoPreparo}'),
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
                          ),
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
                          ),
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
