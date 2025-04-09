import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/ingrediente.dart';
import 'package:receitas_trabalho_2/models/instrucao.dart';
import 'package:receitas_trabalho_2/models/receita.dart';
import 'package:receitas_trabalho_2/screens/ingrediente_edit.dart';
import 'package:receitas_trabalho_2/screens/instrucao_edit.dart.dart';
import 'package:receitas_trabalho_2/screens/receita_edit_screen.dart';
import '/models/pessoa.dart';
import '/repositories/pessoa_repository.dart';
import '/screens/pessoa_detalhe_screen.dart';
import 'package:uuid/uuid.dart';

class ReceitaDetalheScreen extends StatelessWidget {
  const ReceitaDetalheScreen({super.key});

  static const routeName = '/receita_detalhe';

  @override
  Widget build(BuildContext context) {
    final receita = ModalRoute.of(context)!.settings.arguments as Receita;
    final List<Ingrediente> ingredientes = [
      Ingrediente(
        id: "1",
        nome: "Farinha de trigo",
        quantidade: 1,
        idReceita: receita.id,
      ),
      Ingrediente(id: "2", nome: "Ovo", quantidade: 2, idReceita: receita.id),
      Ingrediente(
        id: "3",
        nome: "Açúcar",
        quantidade: 5,
        idReceita: receita.id,
      ),
      Ingrediente(id: "4", nome: "Sal", quantidade: 1, idReceita: receita.id),
    ];

    final List<Instrucao> instrucoes = [
      Instrucao(id: "1", instrucao: "Misture tudo", idReceita: receita.id),
      Instrucao(
        id: "2",
        instrucao: "Asse por 30 minutos",
        idReceita: receita.id,
      ),
      Instrucao(id: "3", instrucao: "Deixe esfriar", idReceita: receita.id),
    ];

    void criarIngrediente() {
      // Implement your create ingredient functionality here
      Navigator.pushNamed(
        context,
        ReceitaEditScreen.routeName,
        arguments: receita,
      );
    }

    void criarInstrucao() {
      // Implement your create instruction functionality here
      Navigator.pushNamed(
        context,
        ReceitaEditScreen.routeName,
        arguments: receita,
      );
    }

    void editarReceita() {
      // Implement your edit functionality here
      Navigator.pushNamed(
        context,
        ReceitaEditScreen.routeName,
        arguments: receita,
      );
    }

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
                  itemCount: ingredientes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${ingredientes[index].nome} - ${ingredientes[index].quantidade}',
                      ),
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            IngredienteEditScreen.routeName,
                            arguments: ingredientes[index],
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
                  itemCount: instrucoes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(instrucoes[index].instrucao),
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            InstrucaoEditScreen.routeName,
                            arguments: instrucoes[index],
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
