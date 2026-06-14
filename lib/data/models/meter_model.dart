import '../../core/constants/app_constants.dart';

/// Niveaux d'alerte du compteur prépayé (F2), du plus serein au plus urgent.
/// Les seuils correspondent au CDC : 20 / 10 / 5 / 0 kWh restants.
enum MeterAlertLevel { normal, info, warning, critical }

extension MeterAlertLevelX on MeterAlertLevel {
  /// Message affiché à l'utilisateur, repris (et adapté) du CDC F2.
  String get message {
    switch (this) {
      case MeterAlertLevel.normal:
        return 'Ton crédit est suffisant pour le moment.';
      case MeterAlertLevel.info:
        return 'Ton crédit baisse, pense à recharger.';
      case MeterAlertLevel.warning:
        return 'Recharge bientôt pour éviter une coupure.';
      case MeterAlertLevel.critical:
        return 'Crédit critique : recharge maintenant !';
    }
  }
}

/// État du compteur prépayé d'un utilisateur.
///
/// En V1 (sans API CIE), [currentBalanceKwh] et
/// [averageDailyConsumptionKwh] proviennent d'une saisie manuelle ou
/// d'une estimation locale — voir CDC section 10 (analyse des risques).
class MeterModel {
  final String meterNumber;
  final double currentBalanceKwh;
  final double averageDailyConsumptionKwh;
  final DateTime lastUpdated;

  const MeterModel({
    required this.meterNumber,
    required this.currentBalanceKwh,
    required this.averageDailyConsumptionKwh,
    required this.lastUpdated,
  });

  /// Estimation du nombre de jours de crédit restants, basée sur la
  /// consommation moyenne des derniers jours (CDC section 5.2, étape 5).
  double get estimatedDaysRemaining {
    if (averageDailyConsumptionKwh <= 0) return double.infinity;
    return currentBalanceKwh / averageDailyConsumptionKwh;
  }

  /// Niveau d'alerte courant, dérivé des seuils [AppConstants].
  MeterAlertLevel get alertLevel {
    if (currentBalanceKwh <= AppConstants.meterCriticalThresholdKwh) {
      return MeterAlertLevel.critical;
    }
    if (currentBalanceKwh <= AppConstants.meterWarningThresholdKwh) {
      return MeterAlertLevel.warning;
    }
    if (currentBalanceKwh <= AppConstants.meterInfoThresholdKwh) {
      return MeterAlertLevel.info;
    }
    return MeterAlertLevel.normal;
  }

  /// Progression du solde par rapport au premier seuil d'alerte (20 kWh),
  /// bornée entre 0 et 1 — pratique pour une barre de progression.
  double get balanceRatio {
    final ratio = currentBalanceKwh / AppConstants.meterInfoThresholdKwh;
    if (ratio.isNaN || ratio < 0) return 0;
    return ratio > 1 ? 1 : ratio;
  }
}
