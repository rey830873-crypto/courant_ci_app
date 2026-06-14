import 'dart:async';

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/models/zone_model.dart';
import '../data/repositories/report_repository.dart';

/// Statuts réseau en temps réel pour chaque commune d'Abidjan (F3),
/// utilisés pour colorer les marqueurs de la carte. Une seule
/// souscription Firestore couvre toutes les communes (voir
/// [ReportRepository.watchCommuneStatuses]).
class MapViewModel extends ChangeNotifier {
  final ReportRepository _reportRepo;

  MapViewModel({required ReportRepository reportRepo})
      : _reportRepo = reportRepo {
    final communes =
        AppConstants.abidjanCommunes.map((c) => c.name).toList();
    _subscription =
        _reportRepo.watchCommuneStatuses(communes).listen((statuses) {
      _statuses = {for (final s in statuses) s.commune: s};
      notifyListeners();
    });
  }

  late final StreamSubscription<List<ZoneStatusInfo>> _subscription;

  Map<String, ZoneStatusInfo> _statuses = {};

  /// Vrai dès la première mise à jour du flux temps réel.
  bool get isReady => _statuses.isNotEmpty;

  /// Statut courant d'une commune, ou `null` avant la première mise à
  /// jour du flux.
  ZoneStatusInfo? statusFor(String commune) => _statuses[commune];

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
