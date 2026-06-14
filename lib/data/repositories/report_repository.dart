import 'dart:async';
import '../models/report_model.dart';
import '../models/zone_model.dart';

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
    // Ajout de quelques données de test
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
    _controller.add(_mockReports);
  }

  @override
  Future<void> submitReport(ReportModel report) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulation réseau
    _mockReports.insert(0, report);
    _controller.add(_mockReports);
  }

  @override
  Stream<ZoneStatusInfo> watchZoneStatus(String commune, String quartier) {
    return _controller.stream.map((reports) {
      final forZone = reports.where((r) => r.commune == commune && r.quartier == quartier).length;
      return ZoneStatusInfo(
        commune: commune,
        quartier: quartier,
        status: forZone > 5 ? ZoneStatus.confirmed : (forZone > 0 ? ZoneStatus.possible : ZoneStatus.normal),
        reportCount: forZone,
        lastUpdated: DateTime.now(),
        hasRecentHazard: reports.any((r) => r.commune == commune && r.type == ReportType.hazard),
      );
    });
  }

  @override
  Stream<List<ZoneStatusInfo>> watchCommuneStatuses(List<String> communes) {
    return _controller.stream.map((reports) {
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
    });
  }

  @override
  Stream<List<ReportModel>> watchRecentReports(String commune, String quartier, {int limit = 20}) {
    return _controller.stream.map((reports) => 
      reports.where((r) => r.commune == commune && r.quartier == quartier).take(limit).toList());
  }

  @override
  Stream<List<ReportModel>> watchRecentReportsForCommune(String commune, {int limit = 20}) {
    return _controller.stream.map((reports) => 
      reports.where((r) => r.commune == commune).take(limit).toList());
  }
}
