import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate(String reason) async {
    try {
      // Verifica se o dispositivo suporta biometria
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        // Se não houver biometria, pode-se optar por permitir ou negar.
        // Neste caso, retornamos 'true' para não bloquear usuários sem sensor.
        // Ou pode-se retornar 'false' e mostrar uma mensagem.
        return true;
      }

      // Tenta autenticar o usuário
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly:
              true, // Força o uso apenas de biometria (digital, facial)
          stickyAuth:
              true, // Mantém a solicitação na tela se o app for para segundo plano
        ),
      );
    } on PlatformException catch (e) {
      // Lida com erros, como sensor não disponível ou usuário não cadastrado
      print(e);
      return false;
    }
  }
}
