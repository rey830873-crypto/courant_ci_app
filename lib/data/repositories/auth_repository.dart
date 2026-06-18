import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'user_repository.dart';

/// Repository d'authentification : fait le lien entre [AuthService] (Simulé)
/// et le modèle métier [UserModel], et persiste les profils via
/// [UserRepository] pour permettre une vraie reconnexion.
class AuthRepository {
  final AuthService _authService;
  final UserRepository _userRepo;

  AuthRepository(this._authService, this._userRepo);

  // Le service est toujours prêt maintenant qu'on n'utilise plus Firebase
  bool get isFirebaseReady => true;

  /// Crée (simule) un compte à partir du numéro de téléphone, construit
  /// le profil [UserModel], et le sauvegarde via [UserRepository] pour
  /// qu'il soit retrouvable à une future connexion.
  ///
  /// [displayName] et [email] sont facultatifs (CDC : pas de compte
  /// obligatoire, l'inscription par téléphone seule reste valide).
  Future<UserModel> verifyOtpAndGetUser(
    String phoneNumber, {
    required String commune,
    required String quartier,
    String? meterNumber,
    String? displayName,
    String? email,
  }) async {
    final uid = await _authService.registerWithPhone(phoneNumber);

    final user = UserModel(
      uid: uid,
      phoneNumber: phoneNumber,
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

    await _userRepo.saveUser(user);
    debugPrint('AuthRepository: Profil sauvegardé pour $phoneNumber');

    return user;
  }

  /// Reconnexion : retrouve un profil déjà inscrit à partir de son
  /// numéro de téléphone (format E.164). Retourne `null` si aucun
  /// compte n'existe avec ce numéro — c'est à l'appelant de décider
  /// quoi faire dans ce cas (proposer de créer un compte, par ex.).
  ///
  /// Met aussi à jour l'identifiant courant dans [AuthService] : sans
  /// cela, les relevés de compteur ajoutés après une reconnexion
  /// resteraient associés au tout dernier identifiant utilisé sur cet
  /// appareil (un autre compte, ou aucun), plutôt qu'à ce compte.
  Future<UserModel?> signIn(String phoneNumber) async {
    final user = await _userRepo.findByPhoneNumber(phoneNumber);
    if (user != null) {
      await _authService.signInWithPhone(phoneNumber);
    }
    return user;
  }

  Future<void> signOut() => _authService.signOut();
}
