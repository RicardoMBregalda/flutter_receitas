import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Esta é a nossa única fonte da verdade para autenticação.
// Ela usa o Firebase e notifica a UI sobre as mudanças.
class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  AuthService() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }
  User? get user => _user;

  String? get userId => _user?.uid;

  bool get isAuthenticated => _user != null;
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Nenhum usuário encontrado para este e-mail.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'invalid-email':
          return 'O formato do e-mail é inválido.';
        default:
          return 'Ocorreu um erro. Tente novamente.';
      }
    }
  }

  Future<String?> register({
    required String email,
    required String nome,
    required String senha,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);
      await userCredential.user?.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Este e-mail já está em uso.';
      }
      return 'Ocorreu um erro durante o registro.';
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> trocarSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "Nenhum usuário encontrado para este e-mail.";
      }
      return "Ocorreu um erro. Tente novamente.";
    }
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }
}
