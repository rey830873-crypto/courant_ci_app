/// Période d'agrégation affichée dans le graphique de consommation (F7).
enum ConsumptionPeriod { day, week, month }

extension ConsumptionPeriodX on ConsumptionPeriod {
  String get label {
    switch (this) {
      case ConsumptionPeriod.day:
        return 'Jour';
      case ConsumptionPeriod.week:
        return 'Semaine';
      case ConsumptionPeriod.month:
        return 'Mois';
    }
  }
}

/// Un point de consommation (en kWh) pour un instant donné.
/// La signification de [date] dépend de la période sélectionnée :
/// tranche horaire (jour), jour (semaine) ou semaine (mois).
class ConsumptionEntry {
  final DateTime date;
  final double kwh;

  const ConsumptionEntry({required this.date, required this.kwh});
}

/// Synthèse de consommation affichée sous le graphique (F7) :
/// projection de facture, comparaisons et conseil d'économie.
class ConsumptionSummary {
  /// Total consommé depuis le début du mois en cours (kWh).
  final double totalKwhThisMonth;

  /// Coût estimé correspondant, en FCFA.
  final double totalCostFcfaThisMonth;

  /// Projection du coût total en fin de mois, au rythme actuel (FCFA).
  final double projectedCostFcfaEndOfMonth;

  /// Évolution par rapport à la semaine précédente, en %.
  /// Positif = hausse de consommation. `null` si on n'a pas encore deux
  /// semaines de relevés pour calculer une comparaison.
  final double? comparisonToPreviousWeekPercent;

  /// Comparaison avec la moyenne du quartier, en %. Négatif =
  /// l'utilisateur consomme moins que ses voisins. `null` si aucune
  /// donnée de quartier n'est disponible (pas assez d'utilisateurs).
  final double? comparisonToNeighborhoodPercent;

  /// Conseil d'économie personnalisé (CDC F7).
  final String tip;

  const ConsumptionSummary({
    required this.totalKwhThisMonth,
    required this.totalCostFcfaThisMonth,
    required this.projectedCostFcfaEndOfMonth,
    this.comparisonToPreviousWeekPercent,
    this.comparisonToNeighborhoodPercent,
    required this.tip,
  });

  /// Vrai si la hausse de consommation dépasse le seuil d'anomalie (F7 :
  /// "Tu consommes +40% cette semaine").
  bool get isAnomalous => (comparisonToPreviousWeekPercent ?? 0) >= 30;
}
