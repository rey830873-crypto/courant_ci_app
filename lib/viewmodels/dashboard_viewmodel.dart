import 'dart:async';

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/models/consumption_model.dart';
import '../data/models/meter_model.dart';
import '../data/models/zone_model.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/services/notification_service.dart';

/// Agrège toutes les données affichées sur l'écran d'accueil :
/// consommation (F7), aperçu du compteur prépayé (F2) et statut réseau
/// de la zone de l'utilisateur (F1), ce dernier en temps réel.
class DashboardViewModel extends ChangeNotifier {
  final ConsumptionRepository _consumptionRepo;
  final MeterRepository _meterRepo;
  final ReportRepository _reportRepo;
  final NotificationService? _notifications;

  String commune;
  String quartier;
  String? meterNumber;

  /// Vrai uniquement pour la toute première valeur reçue du flux
  /// temps réel après une (ré)inscription à [_subscribeToZone] —
  /// évite de notifier "réseau rétabli" simplement parce que l'état
  /// précédent venait d'être remis à `null` par [updateLocation],
  /// alors qu'aucune vraie amélioration n'a eu lieu.
  bool _isFirstZoneUpdate = true;

  /// Vrai dès qu'une alerte de crédit faible a déjà été envoyée pour
  /// le solde courant — évite de notifier à nouveau à chaque
  /// rafraîchissement tant que le solde reste sous le seuil sans
  /// avoir d'abord remonté au-dessus (après une recharge).
  bool _lowMeterAlertSent = false;

  DashboardViewModel({
    required ConsumptionRepository consumptionRepo,
    required MeterRepository meterRepo,
    required ReportRepository reportRepo,
    required this.commune,
    required this.quartier,
    this.meterNumber,
    NotificationService? notifications,
  })  : _consumptionRepo = consumptionRepo,
        _meterRepo = meterRepo,
        _reportRepo = reportRepo,
        _notifications = notifications {
    _subscribeToZone();
    _load();
  }

  void _subscribeToZone() {
    _isFirstZoneUpdate = true;
    _zoneSubscription =
        _reportRepo.watchZoneStatus(commune, quartier).listen((status) {
      _handleZoneStatusUpdate(status);
    });
  }

  void _handleZoneStatusUpdate(ZoneStatusInfo status) {
    final previous = _zoneStatus;
    _zoneStatus = status;

    final shouldNotify = !_isFirstZoneUpdate &&
        previous != null &&
        previous.status != status.status;

    if (shouldNotify) {
      final isImprovement = status.status == ZoneStatus.normal &&
          previous!.status != ZoneStatus.normal;
      _notifications?.showZoneStatusAlert(
        commune: commune,
        quartier: quartier,
        previousStatusLabel: previous!.status.label,
        newStatusLabel: status.status.label,
        isImprovement: isImprovement,
      );
    }

    _isFirstZoneUpdate = false;
    notifyListeners();
  }

  late StreamSubscription<ZoneStatusInfo> _zoneSubscription;

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

    _checkLowMeterAlert();

    _isLoading = false;
    notifyListeners();
  }

  void _checkLowMeterAlert() {
    final balance = _meter?.currentBalanceKwh;
    if (balance == null) return;

    final isLow = balance <= AppConstants.meterWarningThresholdKwh;
    if (isLow && !_lowMeterAlertSent) {
      _lowMeterAlertSent = true;
      _notifications?.showLowMeterAlert(kwhBalance: balance);
    } else if (!isLow) {
      // Le solde est remonté au-dessus du seuil (recharge) : une
      // future redescente devra à nouveau être notifiée.
      _lowMeterAlertSent = false;
    }
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

  /// Met à jour la zone affichée (commune/quartier) et le numéro de
  /// compteur après un changement de compte (inscription ou
  /// reconnexion), puis recharge tout ce qui en dépend.
  ///
  /// Sans cet appel, le tableau de bord continuerait d'afficher la
  /// commune et le statut réseau du tout premier compte utilisé sur
  /// cet appareil depuis le dernier redémarrage complet de
  /// l'application — `commune`/`quartier` ne sont sinon lus qu'une
  /// seule fois, au démarrage, dans `main.dart`.
  Future<void> updateLocation({
    required String commune,
    required String quartier,
    String? meterNumber,
  }) async {
    if (commune == this.commune &&
        quartier == this.quartier &&
        meterNumber == this.meterNumber) {
      return;
    }
    this.commune = commune;
    this.quartier = quartier;
    this.meterNumber = meterNumber;
    _lowMeterAlertSent = false;

    await _zoneSubscription.cancel();
    _zoneStatus = null;
    _subscribeToZone();

    await _load();
  }

  @override
  void dispose() {
    _zoneSubscription.cancel();
    super.dispose();
  }
}
