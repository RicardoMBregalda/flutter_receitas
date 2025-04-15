import 'package:flutter/material.dart';
import '/screens/ingrediente_create_screen.dart';
import '/screens/instrucao_create_screen.dart';
import '/screens/ingrediente_edit.dart';
import '/screens/instrucao_edit.dart.dart';
import '/screens/receita_create_screen.dart';
import '/screens/receita_detalhe_screen.dart';
import '/screens/receita_edit_screen.dart';
import '/screens/receita_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
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
