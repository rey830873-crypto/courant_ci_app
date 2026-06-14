import 'package:flutter/foundation.dart';

/// Service d'authentification simulé (remplace Firebase Auth).
class AuthService {
  String? _mockUserUid;

  /// UID de l'utilisateur connecté (simulé).
  String? get currentUserId => _mockUserUid;

  /// Simule l'envoi d'un code OTP.
  Future<void> sendOtp({
    required String phoneNumber,
    required VoidCallback onCodeSent,
    required void Function(String message) onError,
  }) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    
    if (phoneNumber.length < 8) {
      onError('Numéro de téléphone invalide.');
      return;
    }

    // Dans une vraie API, on appellerait un endpoint ici
    debugPrint('SIMULATION : Code envoyé au $phoneNumber');
    onCodeSent();
  }

  /// Simule la vérification du code OTP (le code "123456" est toujours valide).
  Future<String> verifyOtp(String smsCode) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (smsCode == '123456' || kDebugMode) {
      _mockUserUid = 'user_mock_123';
      return _mockUserUid!;
    } else {
      throw Exception('Code OTP incorrect.');
    }
  }

  Future<void> signOut() async {
    _mockUserUid = null;
  }
}
