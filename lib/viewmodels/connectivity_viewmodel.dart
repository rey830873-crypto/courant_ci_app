import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Suit l'état de connexion réseau (WiFi/cellulaire) pour piloter
/// l'indicateur "Hors-ligne" affiché en permanence pendant une coupure.
///
/// Ne décide PAS si les écritures Firestore doivent être mises en
/// attente : ça reste géré nativement par le SDK Firestore lui-même
/// (persistance offline activée par défaut sur Android/iOS), qui met
/// en file d'attente puis synchronise automatiquement au retour du
/// réseau. Ce ViewModel ne fait qu'informer l'utilisateur de l'état
/// actuel, sans changer le comportement réel de l'app.
class ConnectivityViewModel extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityViewModel() {
    _checkInitial();
    _subscription =
        Connectivity().onConnectivityChanged.listen(_handleResults);
  }

  Future<void> _checkInitial() async {
    final results = await Connectivity().checkConnectivity();
    _handleResults(results);
  }

  void _handleResults(List<ConnectivityResult> results) {
    final online =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
