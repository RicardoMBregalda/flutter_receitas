import 'package:flutter/material.dart';
import 'package:receitas_trabalho_2/screens/ingrediente_create_screen.dart';
import 'package:receitas_trabalho_2/screens/instrucao_create_screen.dart';
import '/models/instrucao.dart';
import '/screens/ingrediente_edit.dart';
import '/screens/receita_create_screen.dart';
import '/screens/receita_edit_screen.dart';
import '/screens/receita_list_screen.dart';
import '/screens/receita_detalhe_screen.dart';
import '/database/database_helper.dart';
import '/screens/instrucao_edit.dart.dart';
import '/models/ingrediente.dart';
import '/models/receita.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        InstrucaoCreateScreen.routeName: (context) => InstrucaoCreateScreen(),
        IngredienteCreateScreen.routeName:
            (context) => IngredienteCreateScreen(),
      },
    );
  }
}
