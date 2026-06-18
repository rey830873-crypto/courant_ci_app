import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/local_storage_service.dart';

/// Source de vérité unique pour l'état "session" de l'utilisateur :
/// onboarding terminé ou non, mode invité/inscrit, zone choisie et
/// numéro de compteur enregistré.
///
/// [AppRouter] écoute ce ViewModel ([refreshListenable]) pour rediriger
/// automatiquement vers l'onboarding, l'authentification ou le tableau
/// de bord selon l'état courant.
class SessionViewModel extends ChangeNotifier {
  final LocalStorageService _storage;

  late bool _onboardingDone;
  late UserMode? _userMode;
  late String? _commune;
  late String? _quartier;
  late String? _meterNumber;

  SessionViewModel(this._storage) {
    _onboardingDone = _storage.isOnboardingDone();
    _userMode = _storage.getUserMode();
    _commune = _storage.getCommune();
    _quartier = _storage.getQuartier();
    _meterNumber = _storage.getMeterNumber();
  }

  bool get onboardingDone => _onboardingDone;
  UserMode? get userMode => _userMode;
  String? get commune => _commune;
  String? get quartier => _quartier;
  String? get meterNumber => _meterNumber;

  bool get isGuest => _userMode == UserMode.guest;
  bool get isRegistered => _userMode == UserMode.registered;

  /// Marque l'onboarding comme terminé et enregistre la zone choisie
  /// (et éventuellement le numéro de compteur, F2).
  Future<void> completeOnboarding({
    required String commune,
    required String quartier,
    String? meterNumber,
  }) async {
    _commune = commune;
    _quartier = quartier;
    _meterNumber = meterNumber;
    _onboardingDone = true;

    await _storage.setOnboardingDone(true);
    await _storage.setCommune(commune);
    await _storage.setQuartier(quartier);
    if (meterNumber != null && meterNumber.isNotEmpty) {
      await _storage.setMeterNumber(meterNumber);
    }
    notifyListeners();
  }

  /// Définit le mode utilisateur (invité ou inscrit) à l'issue du choix
  /// d'authentification.
  Future<void> setUserMode(UserMode mode) async {
    _userMode = mode;
    await _storage.setUserMode(mode);
    notifyListeners();
  }

  /// Met à jour le numéro de compteur (peut être renseigné après
  /// l'onboarding, depuis le profil par exemple).
  Future<void> updateMeterNumber(String meterNumber) async {
    _meterNumber = meterNumber;
    await _storage.setMeterNumber(meterNumber);
    notifyListeners();
  }

  /// Met à jour la zone (commune/quartier) depuis le profil, sans
  /// refaire l'onboarding complet. Utilisé par l'édition du profil.
  Future<void> updateZone({
    required String commune,
    required String quartier,
  }) async {
    _commune = commune;
    _quartier = quartier;
    await _storage.setCommune(commune);
    await _storage.setQuartier(quartier);
    notifyListeners();
  }

  /// Déconnexion : efface entièrement les données de session pour que
  /// la personne suivante sur cet appareil (mode invité ou nouvelle
  /// inscription) reparte d'un état vierge — aucune commune, aucun
  /// quartier, aucun numéro de compteur de l'utilisateur précédent ne
  /// doit rester visible. L'onboarding (choix de zone) est donc à
  /// refaire au prochain démarrage, ce qui est volontaire : la zone
  /// appartient à la personne, pas à l'appareil.
  Future<void> clearUserMode() async {
    _userMode = null;
    _commune = null;
    _quartier = null;
    _meterNumber = null;
    _onboardingDone = false;

    await _storage.setUserMode(null);
    await _storage.setOnboardingDone(false);
    await _storage.setCommune(null);
    await _storage.setQuartier(null);
    await _storage.clearMeterNumber();
    notifyListeners();
  }
}
