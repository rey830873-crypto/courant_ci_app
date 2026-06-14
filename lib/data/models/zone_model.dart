/// Statut du réseau électrique pour une zone (commune/quartier).
///
/// Seuils définis dans le CDC (F1) :
/// 1-4 signalements = possible, 5-9 = probable, 10+ = confirmée.
enum ZoneStatus { normal, possible, probable, confirmed }

extension ZoneStatusX on ZoneStatus {
  String get label {
    switch (this) {
      case ZoneStatus.normal:
        return 'Réseau normal';
      case ZoneStatus.possible:
        return 'Coupure possible';
      case ZoneStatus.probable:
        return 'Coupure probable';
      case ZoneStatus.confirmed:
        return 'Coupure confirmée';
    }
  }

  String get description {
    switch (this) {
      case ZoneStatus.normal:
        return 'Aucun signalement récent dans ta zone.';
      case ZoneStatus.possible:
        return 'Quelques signalements en cours de vérification.';
      case ZoneStatus.probable:
        return 'Plusieurs signalements concordants dans ta zone.';
      case ZoneStatus.confirmed:
        return 'Coupure confirmée par la communauté CIC.';
    }
  }

  /// Déduit le statut à partir du nombre de signalements actifs (F1).
  static ZoneStatus fromReportCount(int count) {
    if (count >= 10) return ZoneStatus.confirmed;
    if (count >= 5) return ZoneStatus.probable;
    if (count >= 1) return ZoneStatus.possible;
    return ZoneStatus.normal;
  }
}

/// État courant du réseau pour une zone. Pour une zone précise
/// (commune + quartier), [quartier] est renseigné. Pour un agrégat au
/// niveau commune (utilisé par la carte), [quartier] vaut `''`.
class ZoneStatusInfo {
  final String commune;
  final String quartier;
  final ZoneStatus status;
  final int reportCount;
  final DateTime lastUpdated;

  /// Vrai si un signalement "danger" (F4) récent existe pour cette zone,
  /// indépendamment du statut réseau (coupure) lui-même.
  final bool hasRecentHazard;

  const ZoneStatusInfo({
    required this.commune,
    required this.quartier,
    required this.status,
    required this.reportCount,
    required this.lastUpdated,
    this.hasRecentHazard = false,
  });

  /// État par défaut "aucune donnée encore" pour une zone (aucun
  /// signalement trouvé dans Firestore).
  factory ZoneStatusInfo.empty({
    required String commune,
    required String quartier,
  }) {
    return ZoneStatusInfo(
      commune: commune,
      quartier: quartier,
      status: ZoneStatus.normal,
      reportCount: 0,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Une commune d'Abidjan, ses quartiers principaux et ses coordonnées
/// approximatives (centroïde), utilisées pour placer le marqueur sur la
/// carte (F3).
class Commune {
  final String name;
  final List<String> quartiers;
  final double latitude;
  final double longitude;

  const Commune({
    required this.name,
    required this.quartiers,
    required this.latitude,
    required this.longitude,
  });
}
