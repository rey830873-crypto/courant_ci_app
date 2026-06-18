import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import 'dashboard_viewmodel.dart';
import 'meter_viewmodel.dart';
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

  /// Ces trois dépendances sont optionnelles (`null` autorisé) pour ne
  /// pas casser un éventuel test ou usage de [AuthViewModel] qui ne
  /// les fournirait pas — mais en pratique, `main.dart` les fournit
  /// toujours, pour que [_syncDownstreamViewModels] puisse vraiment
  /// propager le nouveau compte (zone, identifiant propriétaire) aux
  /// ViewModels construits une seule fois au démarrage de l'app.
  final DashboardViewModel? _dashboardViewModel;
  final MeterViewModel? _meterViewModel;
  final MeterConsumptionRepository? _meterConsumptionRepo;

  AuthViewModel(
    this._repo,
    this._session,
    this._userViewModel, {
    DashboardViewModel? dashboardViewModel,
    MeterViewModel? meterViewModel,
    MeterConsumptionRepository? meterConsumptionRepo,
  })  : _dashboardViewModel = dashboardViewModel,
        _meterViewModel = meterViewModel,
        _meterConsumptionRepo = meterConsumptionRepo;

  AuthFlowStatus _status = AuthFlowStatus.idle;
  String? _errorMessage;

  /// Vrai uniquement quand [signIn] a échoué parce qu'aucun compte
  /// n'existe avec ce numéro (par opposition à une erreur technique) —
  /// permet à l'écran de proposer "Créer un compte" précisément dans
  /// ce cas, plutôt que d'inspecter le texte de [errorMessage].
  bool _accountNotFound = false;
  bool get accountNotFound => _accountNotFound;

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
    _accountNotFound = false;
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
      await _syncDownstreamViewModels(user);
      _status = AuthFlowStatus.idle;
      notifyListeners();
    } catch (_) {
      _status = AuthFlowStatus.error;
      _errorMessage = 'La création du compte a échoué, réessaie.';
      notifyListeners();
    }
  }

  /// Reconnexion à partir du numéro de téléphone : retrouve le profil
  /// déjà créé (sur cet appareil ou un autre) sans repasser par
  /// l'inscription complète. Si aucun compte n'existe avec ce numéro,
  /// [accountNotFound] passe à `true` plutôt que de simuler un succès.
  Future<void> signIn(String phoneNumber) async {
    _status = AuthFlowStatus.registering;
    _errorMessage = null;
    _accountNotFound = false;
    notifyListeners();

    try {
      final user = await _repo.signIn(phoneNumber);
      if (user == null) {
        _status = AuthFlowStatus.error;
        _accountNotFound = true;
        _errorMessage = 'Aucun compte trouvé avec ce numéro.';
        notifyListeners();
        return;
      }
      _userViewModel.setUser(user);
      await _session.setUserMode(UserMode.registered);
      await _syncDownstreamViewModels(user);
      _status = AuthFlowStatus.idle;
      notifyListeners();
    } catch (_) {
      _status = AuthFlowStatus.error;
      _errorMessage = 'La connexion a échoué, vérifie ta connexion internet.';
      notifyListeners();
    }
  }

  /// Propage la zone (commune/quartier/compteur) et l'identifiant du
  /// compte qui vient de se connecter ou de s'inscrire vers les
  /// ViewModels qui en dépendent, mais qui ne les reçoivent
  /// normalement qu'une seule fois, au démarrage de l'application
  /// (voir `main.dart`). Sans cet appel, le tableau de bord et
  /// l'historique du compteur resteraient associés au tout premier
  /// compte utilisé sur cet appareil depuis le dernier redémarrage
  /// complet de l'application — quelle que soit la zone réellement
  /// choisie ou stockée sur le nouveau compte.
  Future<void> _syncDownstreamViewModels(UserModel user) async {
    final ownerId = user.uid;

    _meterConsumptionRepo?.updateOwnerAndZone(
      ownerId: ownerId ?? _meterConsumptionRepo!.ownerId,
      commune: user.commune,
      quartier: user.quartier,
    );

    await _dashboardViewModel?.updateLocation(
      commune: user.commune,
      quartier: user.quartier,
      meterNumber: user.meterNumber,
    );

    if (ownerId != null) {
      await _meterViewModel?.updateOwnerId(ownerId);
    }
  }

  /// Efface un message d'erreur affiché précédemment (ex: après
  /// "Modifier le numéro", pour ne pas garder un ancien message visible
  /// au prochain essai).
  void resetError() {
    if (_status == AuthFlowStatus.error) {
      _status = AuthFlowStatus.idle;
      _errorMessage = null;
      _accountNotFound = false;
      notifyListeners();
    }
  }

  /// Déconnexion : efface la session inscrite (l'UID simulé, le profil
  /// chargé) et fait retomber l'utilisateur sur l'écran "Créer un
  /// compte / Invité". [SessionViewModel.clearUserMode] efface aussi
  /// la zone et le numéro de compteur enregistrés, pour que la
  /// personne suivante sur cet appareil reparte d'un état vierge.
  Future<void> signOut() async {
    await _repo.signOut();
    _userViewModel.setUser(null);
    await _session.clearUserMode();
  }
}
