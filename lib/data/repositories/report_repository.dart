import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/zone_model.dart';
import '../../core/constants/app_constants.dart';

/// Construit l'identifiant de zone dénormalisé stocké sur chaque
/// signalement (`commune::quartier`). Permet de filtrer les
/// signalements d'une zone avec une simple égalité sur un seul champ —
/// donc sans index composite Firestore à configurer.
String zoneId(String commune, String quartier) => '$commune::$quartier';

/// Interface pour les signalements.
abstract class ReportRepository {
  Future<void> submitReport(ReportModel report);
  Stream<ZoneStatusInfo> watchZoneStatus(String commune, String quartier);
  Stream<List<ZoneStatusInfo>> watchCommuneStatuses(List<String> communes);
  Stream<List<ReportModel>> watchRecentReports(String commune, String quartier, {int limit = 20});
  Stream<List<ReportModel>> watchRecentReportsForCommune(String commune, {int limit = 20});
}

/// Implémentation simulée (Mock) pour le mode hors-ligne/développement.
class MockReportRepository implements ReportRepository {
  final _controller = StreamController<List<ReportModel>>.broadcast();
  final List<ReportModel> _mockReports = [];

  MockReportRepository() {
    // Données de test initiales. Comme `_controller` est un stream
    // broadcast, on ne les envoie PAS via `_controller.add(...)` ici :
    // un broadcast stream ne "rejoue" pas les événements passés aux
    // abonnés qui s'inscrivent plus tard (DashboardViewModel/MapViewModel
    // ne sont créés qu'après ce constructeur). Chaque `watch*` ci-dessous
    // émet donc directement l'état courant de `_mockReports` à l'abonnement,
    // puis suit les mises à jour via `_controller`.
    _mockReports.addAll([
      ReportModel(
        id: '1',
        type: ReportType.outage,
        commune: 'Cocody',
        quartier: 'Angré',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        description: 'Coupure secteur 3',
      ),
      ReportModel(
        id: '2',
        type: ReportType.hazard,
        commune: 'Marcory',
        quartier: 'Zone 4',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        description: 'Poteau penché',
      ),
    ]);
  }

  @override
  Future<void> submitReport(ReportModel report) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulation réseau
    _mockReports.insert(0, report);
    _controller.add(_mockReports);
  }

  @override
  Stream<ZoneStatusInfo> watchZoneStatus(String commune, String quartier) async* {
    yield _zoneStatusFor(commune, quartier, _mockReports);
    yield* _controller.stream.map((reports) => _zoneStatusFor(commune, quartier, reports));
  }

  @override
  Stream<List<ZoneStatusInfo>> watchCommuneStatuses(List<String> communes) async* {
    yield _communeStatusesFor(communes, _mockReports);
    yield* _controller.stream.map((reports) => _communeStatusesFor(communes, reports));
  }

  @override
  Stream<List<ReportModel>> watchRecentReports(String commune, String quartier, {int limit = 20}) async* {
    yield _recentReportsFor(commune, quartier, limit, _mockReports);
    yield* _controller.stream.map((reports) => _recentReportsFor(commune, quartier, limit, reports));
  }

  @override
  Stream<List<ReportModel>> watchRecentReportsForCommune(String commune, {int limit = 20}) async* {
    yield _recentReportsForCommune(commune, limit, _mockReports);
    yield* _controller.stream.map((reports) => _recentReportsForCommune(commune, limit, reports));
  }

  ZoneStatusInfo _zoneStatusFor(String commune, String quartier, List<ReportModel> reports) {
    final forZone = reports.where((r) => r.commune == commune && r.quartier == quartier).length;
    return ZoneStatusInfo(
      commune: commune,
      quartier: quartier,
      status: forZone > 5 ? ZoneStatus.confirmed : (forZone > 0 ? ZoneStatus.possible : ZoneStatus.normal),
      reportCount: forZone,
      lastUpdated: DateTime.now(),
      hasRecentHazard: reports.any((r) => r.commune == commune && r.type == ReportType.hazard),
    );
  }

  List<ZoneStatusInfo> _communeStatusesFor(List<String> communes, List<ReportModel> reports) {
    return communes.map((commune) {
      final count = reports.where((r) => r.commune == commune).length;
      return ZoneStatusInfo(
        commune: commune,
        quartier: '',
        status: count > 0 ? ZoneStatus.possible : ZoneStatus.normal,
        reportCount: count,
        lastUpdated: DateTime.now(),
      );
    }).toList();
  }

  List<ReportModel> _recentReportsFor(String commune, String quartier, int limit, List<ReportModel> reports) {
    return reports.where((r) => r.commune == commune && r.quartier == quartier).take(limit).toList();
  }

  List<ReportModel> _recentReportsForCommune(String commune, int limit, List<ReportModel> reports) {
    return reports.where((r) => r.commune == commune).take(limit).toList();
  }
}

/// Implémentation réelle : Firestore (collection `reports`).
///
/// Utilisée quand Firebase est correctement configuré
/// (`flutterfire configure` exécuté → `firebase_options.dart` présent
/// → `Firebase.initializeApp()` réussit dans `main.dart`). Sinon,
/// `main.dart` utilise [MockReportRepository] à la place — voir
/// BACKEND.md.
class FirestoreReportRepository implements ReportRepository {
  final FirebaseFirestore _firestore;

  FirestoreReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  @override
  Future<void> submitReport(ReportModel report) async {
    await _reports.add({
      ...report.toMap(),
      'zoneId': zoneId(report.commune, report.quartier),
    });
  }

  @override
  Stream<ZoneStatusInfo> watchZoneStatus(String commune, String quartier) {
    return _reports
        .where('zoneId', isEqualTo: zoneId(commune, quartier))
        .snapshots()
        .map((snapshot) {
      return _aggregate(
        commune: commune,
        quartier: quartier,
        reports: _parse(snapshot),
      );
    });
  }

  @override
  Stream<List<ZoneStatusInfo>> watchCommuneStatuses(List<String> communes) {
    if (communes.isEmpty) return Stream.value(const []);

    // `whereIn` reste une égalité sur le seul champ `commune` : pas
    // d'index composite requis, même combiné à un agrégat côté client.
    return _reports
        .where('commune', whereIn: communes)
        .snapshots()
        .map((snapshot) {
      final reports = _parse(snapshot);
      return communes.map((commune) {
        final forCommune = reports.where((r) => r.commune == commune).toList();
        return _aggregate(commune: commune, quartier: '', reports: forCommune);
      }).toList();
    });
  }

  @override
  Stream<List<ReportModel>> watchRecentReports(
    String commune,
    String quartier, {
    int limit = 20,
  }) {
    return _reports
        .where('zoneId', isEqualTo: zoneId(commune, quartier))
        .snapshots()
        .map((snapshot) {
      final reports = _parse(snapshot)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reports.take(limit).toList();
    });
  }

  @override
  Stream<List<ReportModel>> watchRecentReportsForCommune(
    String commune, {
    int limit = 20,
  }) {
    return _reports
        .where('commune', isEqualTo: commune)
        .snapshots()
        .map((snapshot) {
      final reports = _parse(snapshot)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reports.take(limit).toList();
    });
  }

  List<ReportModel> _parse(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => ReportModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  /// Calcule le statut réseau (F1) à partir des signalements "actifs"
  /// (moins de [AppConstants.activeReportWindowHours] heures) :
  /// - un signalement "retour du courant" plus récent que les
  ///   signalements de coupure remet la zone à `normal` ;
  /// - sinon, le nombre de signalements "coupure" actifs détermine le
  ///   palier (`ZoneStatusX.fromReportCount`) ;
  /// - un signalement "danger" actif est remonté indépendamment via
  ///   [ZoneStatusInfo.hasRecentHazard].
  ZoneStatusInfo _aggregate({
    required String commune,
    required String quartier,
    required List<ReportModel> reports,
  }) {
    final now = DateTime.now();
    final window = Duration(hours: AppConstants.activeReportWindowHours);

    final active = reports
        .where((r) => now.difference(r.timestamp) <= window)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final hasRecentHazard = active.any((r) => r.type == ReportType.hazard);
    final statusReports =
        active.where((r) => r.type != ReportType.hazard).toList();

    if (statusReports.isEmpty) {
      return ZoneStatusInfo(
        commune: commune,
        quartier: quartier,
        status: ZoneStatus.normal,
        reportCount: 0,
        lastUpdated: now,
        hasRecentHazard: hasRecentHazard,
      );
    }

    final mostRecent = statusReports.first;
    if (mostRecent.type == ReportType.restored) {
      return ZoneStatusInfo(
        commune: commune,
        quartier: quartier,
        status: ZoneStatus.normal,
        reportCount: 0,
        lastUpdated: mostRecent.timestamp,
        hasRecentHazard: hasRecentHazard,
      );
    }

    final outageCount =
        statusReports.where((r) => r.type == ReportType.outage).length;

    return ZoneStatusInfo(
      commune: commune,
      quartier: quartier,
      status: ZoneStatusX.fromReportCount(outageCount),
      reportCount: outageCount,
      lastUpdated: mostRecent.timestamp,
      hasRecentHazard: hasRecentHazard,
    );
  }
}
