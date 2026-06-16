import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import 'session_viewmodel.dart';
import 'user_viewmodel.dart';

/// Étapes du flux d'inscription par téléphone (CDC section 6.2,
/// étape 2). Pas d'étape de vérification par code : l'authentification
/// est entièrement simulée en local (aucun vrai SMS n'est envoyé), donc
/// un code à recopier n'aurait été qu'une étape à vide sans valeur
/// réelle ici.
enum AuthFlowStatus { idle, registering, error }

/// Gère le choix "Invité" vs "Créer un compte", ainsi que la création
/// du profil à partir du numéro de téléphone.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  final SessionViewModel _session;
  final UserViewModel _userViewModel;

  AuthViewModel(this._repo, this._session, this._userViewModel);

  AuthFlowStatus _status = AuthFlowStatus.idle;
  String? _errorMessage;

  AuthFlowStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// Vrai si Firebase est configuré pour ce projet — sinon seul le mode
  /// invité est disponible (voir [AuthService.isAvailable]).
  bool get isFirebaseReady => _repo.isFirebaseReady;

  bool get isBusy => _status == AuthFlowStatus.registering;

  /// Active le mode "Invité" : l'utilisateur garde la zone/compteur
  /// choisis pendant l'onboarding, sans créer de compte.
  Future<void> continueAsGuest() async {
    await _session.setUserMode(UserMode.guest);
  }

  /// Crée le profil à partir du numéro de téléphone fourni (format
  /// E.164, ex: +2250700000000) et bascule la session en mode
  /// "Inscrit". [displayName] et [email] sont facultatifs (CDC :
  /// aucune information n'est obligatoire au-delà du numéro).
  Future<void> verifyOtp(
    String phoneNumber, {
    String? displayName,
    String? email,
  }) async {
    _status = AuthFlowStatus.registering;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repo.verifyOtpAndGetUser(
        phoneNumber,
        commune: _session.commune ?? '',
        quartier: _session.quartier ?? '',
        meterNumber: _session.meterNumber,
        displayName: displayName,
        email: email,
      );
      _userViewModel.setUser(user);
      await _session.setUserMode(UserMode.registered);
      _status = AuthFlowStatus.idle;
      notifyListeners();
    } catch (_) {
      _status = AuthFlowStatus.error;
      _errorMessage = 'La création du compte a échoué, réessaie.';
      notifyListeners();
    }
  }

  /// Efface un message d'erreur affiché précédemment (ex: après
  /// "Modifier le numéro", pour ne pas garder un ancien message visible
  /// au prochain essai).
  void resetError() {
    if (_status == AuthFlowStatus.error) {
      _status = AuthFlowStatus.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Déconnexion : efface la session inscrite (l'UID simulé, le profil
  /// chargé) et fait retomber l'utilisateur sur l'écran "Créer un
  /// compte / Invité". La zone et le numéro de compteur enregistrés
  /// pendant l'onboarding restent inchangés.
  Future<void> signOut() async {
    await _repo.signOut();
    _userViewModel.setUser(null);
    await _session.clearUserMode();
  }
}
