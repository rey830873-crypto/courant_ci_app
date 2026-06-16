import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Repository d'authentification : fait le lien entre [AuthService] (Simulé)
/// et le modèle métier [UserModel].
class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // Le service est toujours prêt maintenant qu'on n'utilise plus Firebase
  bool get isFirebaseReady => true;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(String message) onError,
  }) {
    return _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  /// Vérifie le code OTP (simulé), puis construit le profil [UserModel].
  ///
  /// [displayName] et [email] sont facultatifs (CDC : pas de compte
  /// obligatoire, l'inscription par téléphone seule reste valide).
  Future<UserModel> verifyOtpAndGetUser(
    String smsCode, {
    required String commune,
    required String quartier,
    String? meterNumber,
    String? phoneNumber, // Ajouté pour la simulation
    String? displayName,
    String? email,
  }) async {
    final uid = await _authService.verifyOtp(smsCode);

    final user = UserModel(
      uid: uid,
      phoneNumber: phoneNumber ?? '+2250700000000',
      displayName: (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : 'Utilisateur Courant CI',
      email: (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : null,
      commune: commune,
      quartier: quartier,
      meterNumber: meterNumber,
      mode: UserMode.registered,
      plan: SubscriptionPlan.free,
      cicPoints: 50, // Points de bienvenue !
      isSentinel: false,
      createdAt: DateTime.now(),
    );

    // Ici, on pourrait ajouter un appel API pour sauvegarder le profil
    debugPrint('AuthRepository: Profil utilisateur créé localement pour $uid');

    return user;
  }

  Future<void> signOut() => _authService.signOut();
}
