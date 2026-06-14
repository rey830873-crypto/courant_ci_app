import 'dart:async';

import 'package:flutter/material.dart';
import '../data/models/consumption_model.dart';
import '../data/models/meter_model.dart';
import '../data/models/zone_model.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/report_repository.dart';

/// Agrège toutes les données affichées sur l'écran d'accueil :
/// consommation (F7), aperçu du compteur prépayé (F2) et statut réseau
/// de la zone de l'utilisateur (F1), ce dernier en temps réel.
class DashboardViewModel extends ChangeNotifier {
  final ConsumptionRepository _consumptionRepo;
  final MeterRepository _meterRepo;
  final ReportRepository _reportRepo;

  final String commune;
  final String quartier;
  final String? meterNumber;

  DashboardViewModel({
    required ConsumptionRepository consumptionRepo,
    required MeterRepository meterRepo,
    required ReportRepository reportRepo,
    required this.commune,
    required this.quartier,
    this.meterNumber,
  })  : _consumptionRepo = consumptionRepo,
        _meterRepo = meterRepo,
        _reportRepo = reportRepo {
    // Statut réseau en temps réel (F1) : chaque nouveau signalement
    // Firestore met à jour la carte de statut sans action de
    // l'utilisateur.
    _zoneSubscription =
        _reportRepo.watchZoneStatus(commune, quartier).listen((status) {
      _zoneStatus = status;
      notifyListeners();
    });
    _load();
  }

  late final StreamSubscription<ZoneStatusInfo> _zoneSubscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ConsumptionPeriod _period = ConsumptionPeriod.week;
  ConsumptionPeriod get period => _period;

  List<ConsumptionEntry> _entries = const [];
  List<ConsumptionEntry> get entries => _entries;

  /// `null` si pas encore assez de relevés (F2) pour une synthèse F7.
  ConsumptionSummary? _summary;
  ConsumptionSummary? get summary => _summary;

  /// `null` si aucun relevé de compteur n'a encore été saisi.
  MeterModel? _meter;
  MeterModel? get meter => _meter;

  /// `null` jusqu'à la première mise à jour du flux temps réel.
  ZoneStatusInfo? _zoneStatus;
  ZoneStatusInfo? get zoneStatus => _zoneStatus;

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _consumptionRepo.getEntries(_period),
      _meterRepo.getMeter(),
    ]);

    _entries = results[0] as List<ConsumptionEntry>;
    _meter = results[1] as MeterModel?;
    _summary = await _consumptionRepo.getSummary();

    _isLoading = false;
    notifyListeners();
  }

  /// Change la période affichée sur le graphique (Jour/Semaine/Mois)
  /// sans recharger le reste du dashboard.
  Future<void> setPeriod(ConsumptionPeriod newPeriod) async {
    if (newPeriod == _period) return;
    _period = newPeriod;
    notifyListeners();
    _entries = await _consumptionRepo.getEntries(_period);
    notifyListeners();
  }

  /// Recharge compteur/consommation (tiré-pour-rafraîchir, ou après
  /// l'ajout d'un nouveau relevé depuis l'onglet Compteur).
  Future<void> refresh() => _load();

  @override
  void dispose() {
    _zoneSubscription.cancel();
    super.dispose();
  }
}
