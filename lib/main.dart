import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/screens/receita_edit_screen.dart';
import 'package:receitas_trabalho_2/screens/receita_list_screen.dart';
import 'package:receitas_trabalho_2/screens/receita_detalhe_screen.dart';
import 'package:receitas_trabalho_2/database/database_helper.dart';

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
        ReceitaListScreen.routeName: (context) =>  ReceitaListScreen(),
        ReceitaDetalheScreen.routeName: (context) => ReceitaDetalheScreen(),
        ReceitaEditScreen.routeName: (context) => ReceitaEditScreen(),
      }, 
  
      );
  }
}
