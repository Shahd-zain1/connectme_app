import 'package:local_auth/local_auth.dart';

// Wraps local_auth so ProfileScreen's gate only deals with a plain bool,
// true only if the device supports biometrics and the user actually
// passed the fingerprint check.
class BiometricService {
  final _localAuth = LocalAuthentication();

  Future<bool> authenticate(String reason) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }
}
