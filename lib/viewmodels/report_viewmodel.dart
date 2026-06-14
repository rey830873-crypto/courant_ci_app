import 'dart:async';

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/models/report_model.dart';
import '../data/models/zone_model.dart';
import '../data/repositories/report_repository.dart';
import '../data/services/auth_service.dart';
import '../data/services/local_storage_service.dart';
import 'session_viewmodel.dart';

enum ReportSubmissionStatus { idle, submitting, success, error }

/// Pilote l'écran Signaler (F4) :
/// - envoi d'un signalement en un appui (2 clics au total avec
///   l'ouverture de l'onglet) ;
/// - limitation locale à [AppConstants.maxReportsPerHour] / heure ;
/// - points CIC et badge "Sentinelle" (stockage local) ;
/// - statut réseau et signalements récents de la zone, en temps réel.
class ReportViewModel extends ChangeNotifier {
  final ReportRepository _reportRepo;
  final LocalStorageService _localStorage;
  final SessionViewModel _session;
  final AuthService _authService;

  ReportViewModel({
    required ReportRepository reportRepo,
    required LocalStorageService localStorage,
    required SessionViewModel session,
    required AuthService authService,
  })  : _reportRepo = reportRepo,
        _localStorage = localStorage,
        _session = session,
        _authService = authService {
    _zoneSubscription =
        _reportRepo.watchZoneStatus(commune, quartier).listen((status) {
      _zoneStatus = status;
      notifyListeners();
    });
    _reportsSubscription =
        _reportRepo.watchRecentReports(commune, quartier).listen((reports) {
      _recentReports = reports;
      notifyListeners();
    });
  }

  late final StreamSubscription<ZoneStatusInfo> _zoneSubscription;
  late final StreamSubscription<List<ReportModel>> _reportsSubscription;

  String get commune => _session.commune ?? '';
  String get quartier => _session.quartier ?? '';

  ZoneStatusInfo? _zoneStatus;
  ZoneStatusInfo? get zoneStatus => _zoneStatus;

  List<ReportModel> _recentReports = const [];
  List<ReportModel> get recentReports => _recentReports;

  ReportSubmissionStatus _status = ReportSubmissionStatus.idle;
  ReportSubmissionStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Points CIC / Sentinelle (CDC F4) ---
  int get cicPoints => _localStorage.getCicPoints();
  bool get isSentinel => cicPoints >= AppConstants.sentinelReportThreshold;

  // --- Anti-spam local (CDC F4 : max 5/heure) ---
  int get reportsRemainingThisHour =>
      (AppConstants.maxReportsPerHour - _localStorage.getReportCountLastHour())
          .clamp(0, AppConstants.maxReportsPerHour);
  bool get canSubmit => reportsRemainingThisHour > 0;

  /// Envoie un signalement pour la zone de l'utilisateur. [description]
  /// est optionnelle (non requise pour le flux "2 clics").
  Future<void> submitReport(ReportType type, {String? description}) async {
    if (!canSubmit) {
      _status = ReportSubmissionStatus.error;
      _errorMessage =
          'Tu as atteint la limite de ${AppConstants.maxReportsPerHour} '
          'signalements par heure. Réessaie un peu plus tard.';
      notifyListeners();
      return;
    }

    _status = ReportSubmissionStatus.submitting;
    notifyListeners();

    try {
      final report = ReportModel(
        userId: _authService.currentUserId,
        commune: commune,
        quartier: quartier,
        type: type,
        timestamp: DateTime.now(),
        description:
            (description != null && description.trim().isNotEmpty)
                ? description.trim()
                : null,
      );
      await _reportRepo.submitReport(report);
      await _localStorage.recordReportTimestamp();
      await _localStorage.addCicPoints(AppConstants.cicPointsPerReport);

      _status = ReportSubmissionStatus.success;
    } catch (_) {
      _status = ReportSubmissionStatus.error;
      _errorMessage =
          'Le signalement n\'a pas pu être envoyé. Vérifie ta connexion.';
    }
    notifyListeners();
  }

  /// Repasse l'état de soumission à "idle" (après affichage d'un
  /// message de succès/erreur par l'écran).
  void resetStatus() {
    _status = ReportSubmissionStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _zoneSubscription.cancel();
    _reportsSubscription.cancel();
    super.dispose();
  }
}
