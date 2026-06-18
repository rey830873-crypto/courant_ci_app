import '../../core/constants/app_constants.dart';
import '../models/consumption_model.dart';
import '../models/meter_model.dart';
import '../models/meter_reading_model.dart';
import 'meter_reading_repository.dart';

/// --- F2 : compteur prépayé -------------------------------------------

abstract class MeterRepository {
  /// État courant du compteur, dérivé du dernier relevé. `null` si
  /// l'utilisateur n'a encore saisi aucun relevé.
  Future<MeterModel?> getMeter();
}

/// --- F7 : suivi de consommation ---------------------------------------

abstract class ConsumptionRepository {
  Future<List<ConsumptionEntry>> getEntries(ConsumptionPeriod period);

  /// `null` si moins de [AppConstants.minReadingsForStats] relevés sont
  /// disponibles (pas assez de données pour une synthèse).
  Future<ConsumptionSummary?> getSummary();
}

/// Implémentation réelle de [MeterRepository] et [ConsumptionRepository],
/// entièrement dérivée des relevés de compteur saisis par l'utilisateur
/// (F2, voir [MeterReadingRepository]) — aucune donnée simulée.
///
/// Principe : entre deux relevés consécutifs, une baisse du solde est
/// de la "consommation" répartie sur l'intervalle de temps entre les
/// deux relevés ; une hausse (recharge) compte pour 0 kWh consommé sur
/// cet intervalle.
class MeterConsumptionRepository
    implements MeterRepository, ConsumptionRepository {
  final MeterReadingRepository _readingRepo;
  String ownerId;
  String commune;
  String quartier;

  MeterConsumptionRepository({
    required MeterReadingRepository readingRepo,
    required this.ownerId,
    required this.commune,
    required this.quartier,
  }) : _readingRepo = readingRepo;

  /// Met à jour le propriétaire et la zone de référence après un
  /// changement de compte (inscription ou reconnexion) — sans cela,
  /// les relevés et les comparaisons de voisinage resteraient associés
  /// au compte précédent, ou à l'appareil, jusqu'au prochain
  /// redémarrage complet de l'application.
  void updateOwnerAndZone({
    required String ownerId,
    required String commune,
    required String quartier,
  }) {
    this.ownerId = ownerId;
    this.commune = commune;
    this.quartier = quartier;
  }

  Future<List<MeterReadingModel>> _myReadings() =>
      _readingRepo.fetchReadings(ownerId);

  @override
  Future<MeterModel?> getMeter() async {
    final readings = await _myReadings();
    if (readings.isEmpty) return null;

    final intervals = _buildIntervals(readings);
    return MeterModel(
      meterNumber: readings.last.meterNumber,
      currentBalanceKwh: readings.last.kwhBalance,
      averageDailyConsumptionKwh: _averageDaily(intervals, DateTime.now()),
      lastUpdated: readings.last.timestamp,
    );
  }

  @override
  Future<List<ConsumptionEntry>> getEntries(ConsumptionPeriod period) async {
    final readings = await _myReadings();
    if (readings.length < AppConstants.minReadingsForStats) return const [];

    final intervals = _buildIntervals(readings);
    final now = DateTime.now();

    switch (period) {
      case ConsumptionPeriod.day:
        return _bucketed(intervals, _dayBuckets(now));
      case ConsumptionPeriod.week:
        return _bucketed(intervals, _weekBuckets(now));
      case ConsumptionPeriod.month:
        return _bucketed(intervals, _monthBuckets(now));
    }
  }

  @override
  Future<ConsumptionSummary?> getSummary() async {
    final readings = await _myReadings();
    if (readings.length < AppConstants.minReadingsForStats) return null;

    final now = DateTime.now();
    final intervals = _buildIntervals(readings);

    final totalKwhThisMonth = intervals
        .where((iv) => iv.end.year == now.year && iv.end.month == now.month)
        .fold<double>(0, (sum, iv) => sum + iv.kwh);

    final avgDaily = _averageDaily(intervals, now);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = (daysInMonth - now.day).clamp(0, daysInMonth);
    final projectedKwh = totalKwhThisMonth + avgDaily * daysRemaining;

    final vsLastWeek = _weekOverWeek(intervals, readings, now);
    final vsNeighborhood = await _neighborhoodComparison(avgDaily, now);

    return ConsumptionSummary(
      totalKwhThisMonth: totalKwhThisMonth,
      totalCostFcfaThisMonth:
          totalKwhThisMonth * AppConstants.estimatedKwhPriceFcfa,
      projectedCostFcfaEndOfMonth:
          projectedKwh * AppConstants.estimatedKwhPriceFcfa,
      comparisonToPreviousWeekPercent: vsLastWeek,
      comparisonToNeighborhoodPercent: vsNeighborhood,
      tip: _tipFor(vsLastWeek, vsNeighborhood),
    );
  }

  // --- Comparaisons -----------------------------------------------------

  /// `null` si moins de ~13 jours d'historique (pas de semaine
  /// précédente complète à comparer), ou si la semaine précédente n'a
  /// révélé aucune consommation (division par zéro évitée).
  double? _weekOverWeek(
    List<_Interval> intervals,
    List<MeterReadingModel> readings,
    DateTime now,
  ) {
    if (readings.first.timestamp.isAfter(now.subtract(const Duration(days: 13)))) {
      return null;
    }
    final thisWeek = _sumEndingBetween(
      intervals,
      now.subtract(const Duration(days: 7)),
      now,
    );
    final prevWeek = _sumEndingBetween(
      intervals,
      now.subtract(const Duration(days: 14)),
      now.subtract(const Duration(days: 7)),
    );
    if (prevWeek <= 0) return null;
    return (thisWeek - prevWeek) / prevWeek * 100;
  }

  /// Compare la moyenne quotidienne de l'utilisateur à celle des autres
  /// utilisateurs ayant déjà au moins [AppConstants.minReadingsForStats]
  /// relevés dans la même commune. `null` si aucun voisin exploitable
  /// n'est trouvé (encore peu d'utilisateurs sur cette commune).
  Future<double?> _neighborhoodComparison(double myAvg, DateTime now) async {
    if (myAvg <= 0) return null;

    final others = await _readingRepo.fetchReadingsForCommune(
      commune,
      excludeOwnerId: ownerId,
    );

    final byOwner = <String, List<MeterReadingModel>>{};
    for (final reading in others) {
      byOwner.putIfAbsent(reading.ownerId, () => []).add(reading);
    }

    final otherAverages = <double>[];
    for (final readings in byOwner.values) {
      if (readings.length < AppConstants.minReadingsForStats) continue;
      readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final avg = _averageDaily(_buildIntervals(readings), now);
      if (avg > 0) otherAverages.add(avg);
    }

    if (otherAverages.isEmpty) return null;
    final neighborhoodAvg =
        otherAverages.reduce((a, b) => a + b) / otherAverages.length;
    if (neighborhoodAvg <= 0) return null;

    return (myAvg - neighborhoodAvg) / neighborhoodAvg * 100;
  }

  String _tipFor(double? vsLastWeek, double? vsNeighborhood) {
    if ((vsLastWeek ?? 0) >= AppConstants.anomalyThresholdPercent) {
      return 'Ta consommation a nettement augmenté cette semaine. '
          'Vérifie qu\'aucun appareil (climatiseur, chauffe-eau, fer à '
          'repasser) n\'est resté allumé inutilement.';
    }
    if ((vsNeighborhood ?? 0) > 10) {
      return 'Régler la climatisation à 24°C plutôt que 18°C peut réduire '
          'ta facture d\'environ 30%.';
    }
    return 'Débranche les appareils en veille : ils représentent souvent '
        '5 à 10% de la facture mensuelle.';
  }
}

// --- Calculs internes : intervalles de consommation entre relevés -------

class _Interval {
  final DateTime start;
  final DateTime end;

  /// Consommation en kWh sur cet intervalle (0 si le solde a augmenté,
  /// c'est-à-dire une recharge entre les deux relevés).
  final double kwh;

  const _Interval(this.start, this.end, this.kwh);
}

List<_Interval> _buildIntervals(List<MeterReadingModel> readings) {
  final intervals = <_Interval>[];
  for (var i = 1; i < readings.length; i++) {
    final prev = readings[i - 1];
    final curr = readings[i];
    final delta = prev.kwhBalance - curr.kwhBalance;
    intervals.add(_Interval(prev.timestamp, curr.timestamp, delta > 0 ? delta : 0));
  }
  return intervals;
}

/// Moyenne quotidienne sur les 14 derniers jours d'intervalles
/// (consommation totale / durée totale couverte, en jours).
double _averageDaily(List<_Interval> intervals, DateTime now) {
  final cutoff = now.subtract(const Duration(days: 14));
  final recent = intervals.where((iv) => iv.end.isAfter(cutoff)).toList();
  if (recent.isEmpty) return 0;

  final totalKwh = recent.fold<double>(0, (sum, iv) => sum + iv.kwh);
  final totalHours = recent.fold<double>(
    0,
    (sum, iv) => sum + iv.end.difference(iv.start).inMinutes / 60.0,
  );
  if (totalHours <= 0) return 0;
  return totalKwh / (totalHours / 24);
}

/// Somme des kWh des intervalles se terminant dans `(start, end]`.
double _sumEndingBetween(List<_Interval> intervals, DateTime start, DateTime end) {
  return intervals
      .where((iv) => iv.end.isAfter(start) && !iv.end.isAfter(end))
      .fold<double>(0, (sum, iv) => sum + iv.kwh);
}

/// Répartit chaque intervalle dans le panier temporel auquel
/// appartient sa fin : le panier `i` couvre `[bucketStarts[i],
/// bucketStarts[i+1])`, et le **dernier** panier couvre
/// `[bucketStarts[last], +∞)`.
///
/// Le dernier panier est volontairement ouvert (pas de borne
/// supérieure) : sans cela, un relevé se terminant "maintenant" (le
/// plus récent, donc le plus important) tomberait juste après la borne
/// supérieure théorique du dernier panier — calculée à partir de
/// minuit — et serait silencieusement exclu du graphique (notamment en
/// vue "Mois", où le dernier panier représenterait `[J-7, J)` alors que
/// `now` est toujours dans `[J, J+1)`).
///
/// Un intervalle dont la fin précède [bucketStarts] premier élément
/// (hors de la période affichée) est simplement ignoré.
List<ConsumptionEntry> _bucketed(
  List<_Interval> intervals,
  List<DateTime> bucketStarts,
) {
  final totals = List<double>.filled(bucketStarts.length, 0);
  for (final interval in intervals) {
    for (var i = bucketStarts.length - 1; i >= 0; i--) {
      if (!interval.end.isBefore(bucketStarts[i])) {
        totals[i] += interval.kwh;
        break;
      }
    }
  }
  return List.generate(
    bucketStarts.length,
    (i) => ConsumptionEntry(date: bucketStarts[i], kwh: totals[i]),
  );
}

List<DateTime> _dayBuckets(DateTime now) {
  final start = DateTime(now.year, now.month, now.day);
  return List.generate(8, (i) => start.add(Duration(hours: i * 3)));
}

List<DateTime> _weekBuckets(DateTime now) {
  final start =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  return List.generate(7, (i) => start.add(Duration(days: i)));
}

List<DateTime> _monthBuckets(DateTime now) {
  final start =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 28));
  return List.generate(4, (i) => start.add(Duration(days: i * 7)));
}
