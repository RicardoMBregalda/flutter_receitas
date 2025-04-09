import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/models/instrucao.dart';
import 'package:receitas_trabalho_2/screens/ingrediente_edit.dart';
import 'package:receitas_trabalho_2/screens/receita_create_screen.dart';
import 'package:receitas_trabalho_2/screens/receita_edit_screen.dart';
import 'package:receitas_trabalho_2/screens/receita_list_screen.dart';
import 'package:receitas_trabalho_2/screens/receita_detalhe_screen.dart';
import 'package:receitas_trabalho_2/database/database_helper.dart';
import 'package:receitas_trabalho_2/screens/instrucao_edit.dart.dart';
import 'package:receitas_trabalho_2/models/ingrediente.dart';
import 'package:receitas_trabalho_2/models/receita.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReceitaListScreen(),
      routes: {
        ReceitaListScreen.routeName: (context) => ReceitaListScreen(),
        ReceitaDetalheScreen.routeName: (context) => ReceitaDetalheScreen(),
        ReceitaEditScreen.routeName: (context) => ReceitaEditScreen(),
        InstrucaoEditScreen.routeName: (context) => InstrucaoEditScreen(),
        IngredienteEditScreen.routeName: (context) => IngredienteEditScreen(),
        ReceitaCreateScreen.routeName: (context) => ReceitaCreateScreen(),
      },
    );
  }
}
