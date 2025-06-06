import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/receita_list_screen.dart';
import '/screens/auth_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Ouve o stream de mudanças de estado de autenticação
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto está conectando...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Se o snapshot tem dados, significa que o usuário está logado
        if (snapshot.hasData) {
          // snapshot.data contém o objeto User com todas as informações
          // como uid, email, displayName, etc.
          return ReceitaListScreen(
            user: snapshot.data!,
          ); // Redireciona para a tela principal
        }

        // Se não tem dados, o usuário não está logado
        return const AuthScreen(); // Redireciona para a tela de login
      },
    );
  }
}
