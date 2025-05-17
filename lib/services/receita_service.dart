import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/ingrediente.dart';
import '../models/instrucao.dart';
import '../models/receita.dart';
import '../repositories/ingrediente_repository.dart';
import '../repositories/instrucao_repository.dart';
import '../repositories/receita_repository.dart';

class ReceitaService {
  final _uuid = const Uuid();
  final _random = Random();

  String removePontosEVirgulas(String palavra) {
    return palavra.replaceAll(',', '').replaceAll('.', '');
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
        nome: removePontosEVirgulas(
          palavras[Random().nextInt(palavras.length)],
        ),
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
            nome: removePontosEVirgulas(
              palavras[Random().nextInt(palavras.length)],
            ),
            quantidade: '${Random().nextInt(1000)} g',
            receitaId: receita.id,
          ),
        );
      }

      for (var i = 0; i < quantidadeInstrucoes; i++) {
        await InstrucaoRepository().adicionar(
          Instrucao(
            id: const Uuid().v4(),
            instrucao: removePontosEVirgulas(
              palavras[Random().nextInt(palavras.length)],
            ),
            receitaId: receita.id,
          ),
        );
      }
    }
  }
}
