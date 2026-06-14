import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'session_viewmodel.dart';

/// État du parcours d'onboarding (CDC section 6.2).
///
/// Gère principalement la sélection commune/quartier — l'étape la plus
/// "dynamique" du parcours (la liste des quartiers dépend de la commune
/// choisie). Les autres étapes (bienvenue, compteur, notifications)
/// n'ont pas besoin d'état partagé et restent locales aux écrans.
class OnboardingViewModel extends ChangeNotifier {
  String? _selectedCommune;
  String? _selectedQuartier;

  String? get selectedCommune => _selectedCommune;
  String? get selectedQuartier => _selectedQuartier;

  List<String> get communeNames =>
      AppConstants.abidjanCommunes.map((c) => c.name).toList();

  /// Quartiers disponibles pour la commune actuellement sélectionnée.
  List<String> get availableQuartiers {
    final commune = _selectedCommune;
    if (commune == null) return const [];
    return AppConstants.abidjanCommunes
        .firstWhere((c) => c.name == commune)
        .quartiers;
  }

  /// Vrai si commune ET quartier ont été choisis — condition pour
  /// avancer à l'étape suivante de l'onboarding.
  bool get hasSelectedZone =>
      _selectedCommune != null && _selectedQuartier != null;

  void selectCommune(String commune) {
    _selectedCommune = commune;
    // Le quartier précédemment choisi peut ne plus être valide pour la
    // nouvelle commune : on réinitialise.
    _selectedQuartier = null;
    notifyListeners();
  }

  void selectQuartier(String quartier) {
    _selectedQuartier = quartier;
    notifyListeners();
  }

  /// Termine l'onboarding : enregistre la zone (et le numéro de compteur
  /// optionnel, F2) dans la session, ce qui déclenche la redirection du
  /// routeur vers l'écran d'authentification.
  Future<void> finish(SessionViewModel session, {String? meterNumber}) async {
    if (!hasSelectedZone) return;
    await session.completeOnboarding(
      commune: _selectedCommune!,
      quartier: _selectedQuartier!,
      meterNumber:
          (meterNumber != null && meterNumber.trim().isNotEmpty)
              ? meterNumber.trim()
              : null,
    );
  }
}
