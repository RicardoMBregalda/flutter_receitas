import 'package:flutter/material.dart';
import '/models/pessoa.dart';
import '/repositories/pessoa_repository.dart';
import '/screens/pessoa_detalhe_screen.dart';
import 'package:uuid/uuid.dart';

class PessoaListScreen extends StatefulWidget {
  const PessoaListScreen({Key? key}) : super(key: key);

  @override
  _PessoaListScreenState createState() => _PessoaListScreenState();
}

class _PessoaListScreenState extends State<PessoaListScreen> {
  List<Pessoa> _pessoas = [];
  PessoaRepository repository = PessoaRepository();

  @override
  void initState() {
    super.initState();
    carregarPessoas();
  }

  void carregarPessoas() async {
    var pessoasBanco = await repository.todosAbaixoDe(19);
    setState(() {
      _pessoas = pessoasBanco;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pessoas')),
      body: ListView.builder(
        itemCount: _pessoas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_pessoas[index].nome),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PessoaDetalheScreen(pessoa: _pessoas[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var id = Uuid();
          await repository.adicionar(
            Pessoa(id: id.v1(), nome: id.v8(), idade: 19),
          );
          carregarPessoas();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
