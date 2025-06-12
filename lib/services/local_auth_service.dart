import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate(String reason) async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return true;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}
