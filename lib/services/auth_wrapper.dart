import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receitas_trabalho_2/services/auth_service.dart';
import '/screens/receita_list_screen.dart';
import '/screens/auth_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.isAuthenticated) {
      return const ReceitaListScreen(); // ou a sua tela de lista de receitas
    } else {
      // Se não, mostre a tela de autenticação.
      return const AuthScreen();
    }
  }
}
