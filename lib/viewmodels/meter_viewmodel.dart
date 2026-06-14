import 'package:flutter/material.dart';
import '../data/models/meter_reading_model.dart';
import '../data/repositories/meter_reading_repository.dart';
import 'session_viewmodel.dart';

enum ReadingSubmissionStatus { idle, submitting, success, error }

/// Pilote l'écran Compteur (F2) :
/// - configuration (une fois) du numéro de compteur prépayé ;
/// - saisie d'un nouveau relevé de solde (kWh) ;
/// - historique des relevés, du plus récent au plus ancien.
///
/// Ne dépend pas de [DashboardViewModel] : c'est à l'écran de
/// déclencher `DashboardViewModel.refresh()` après un ajout réussi,
/// pour éviter un couplage entre ViewModels.
class MeterViewModel extends ChangeNotifier {
  final MeterReadingRepository _readingRepo;
  final SessionViewModel _session;
  final String ownerId;

  MeterViewModel({
    required MeterReadingRepository readingRepo,
    required SessionViewModel session,
    required this.ownerId,
  })  : _readingRepo = readingRepo,
        _session = session {
    _loadHistory();
  }

  String? get meterNumber => _session.meterNumber;

  List<MeterReadingModel> _history = const [];

  /// Historique du plus récent au plus ancien.
  List<MeterReadingModel> get history => _history.reversed.toList();

  bool _isLoadingHistory = true;
  bool get isLoadingHistory => _isLoadingHistory;

  ReadingSubmissionStatus _status = ReadingSubmissionStatus.idle;
  ReadingSubmissionStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> _loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    _history = await _readingRepo.fetchReadings(ownerId);
    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Configure (ou modifie) le numéro de compteur.
  Future<void> setMeterNumber(String meterNumber) async {
    await _session.updateMeterNumber(meterNumber);
    notifyListeners();
  }

  /// Ajoute un nouveau relevé de solde. Échoue si aucun numéro de
  /// compteur n'est configuré ou si le solde est négatif.
  Future<void> addReading(double kwhBalance) async {
    final number = meterNumber;
    if (number == null || number.isEmpty) {
      _status = ReadingSubmissionStatus.error;
      _errorMessage = 'Configure d\'abord ton numéro de compteur.';
      notifyListeners();
      return;
    }
    if (kwhBalance < 0) {
      _status = ReadingSubmissionStatus.error;
      _errorMessage = 'Le solde doit être positif.';
      notifyListeners();
      return;
    }

    _status = ReadingSubmissionStatus.submitting;
    notifyListeners();

    try {
      final reading = MeterReadingModel(
        ownerId: ownerId,
        meterNumber: number,
        kwhBalance: kwhBalance,
        timestamp: DateTime.now(),
        commune: _session.commune ?? '',
        quartier: _session.quartier ?? '',
      );
      await _readingRepo.addReading(reading);
      await _loadHistory();
      _status = ReadingSubmissionStatus.success;
    } catch (_) {
      _status = ReadingSubmissionStatus.error;
      _errorMessage =
          'Le relevé n\'a pas pu être enregistré. Vérifie ta connexion.';
    }
    notifyListeners();
  }

  /// Repasse l'état de soumission à "idle" (après affichage d'un
  /// message de succès/erreur par l'écran).
  void resetStatus() {
    _status = ReadingSubmissionStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
