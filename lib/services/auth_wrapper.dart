import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import '/screens/receita_list_screen.dart';
import '/screens/auth_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.isAuthenticated) {
      return const ReceitaListScreen();
    } else {
      return const AuthScreen();
    }
  }
}
