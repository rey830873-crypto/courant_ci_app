import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import 'session_viewmodel.dart';

/// Étapes du flux d'inscription par téléphone (CDC section 6.2,
/// étape 2 : "numéro de téléphone + code OTP SMS").
enum AuthFlowStatus { idle, sendingCode, codeSent, verifying, error }

/// Gère le choix "Invité" vs "Créer un compte", ainsi que l'envoi et la
/// vérification du code OTP pour l'inscription.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  final SessionViewModel _session;

  AuthViewModel(this._repo, this._session);

  AuthFlowStatus _status = AuthFlowStatus.idle;
  String? _errorMessage;
  String _phoneNumber = '';

  AuthFlowStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;

  /// Vrai si Firebase est configuré pour ce projet — sinon seul le mode
  /// invité est disponible (voir [AuthService.isAvailable]).
  bool get isFirebaseReady => _repo.isFirebaseReady;

  bool get isBusy =>
      _status == AuthFlowStatus.sendingCode ||
      _status == AuthFlowStatus.verifying;

  /// Active le mode "Invité" : l'utilisateur garde la zone/compteur
  /// choisis pendant l'onboarding, sans créer de compte.
  Future<void> continueAsGuest() async {
    await _session.setUserMode(UserMode.guest);
  }

  /// Envoie un code OTP au numéro fourni. [phone] doit être au format
  /// E.164 (ex: +2250700000000).
  Future<void> sendOtp(String phone) async {
    _phoneNumber = phone;
    _status = AuthFlowStatus.sendingCode;
    _errorMessage = null;
    notifyListeners();

    await _repo.sendOtp(
      phoneNumber: phone,
      onCodeSent: () {
        _status = AuthFlowStatus.codeSent;
        notifyListeners();
      },
      onError: (message) {
        _status = AuthFlowStatus.error;
        _errorMessage = message;
        notifyListeners();
      },
    );
  }

  /// Vérifie le code OTP saisi, crée le profil utilisateur et bascule la
  /// session en mode "Inscrit".
  Future<void> verifyOtp(String code) async {
    _status = AuthFlowStatus.verifying;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.verifyOtpAndGetUser(
        code,
        commune: _session.commune ?? '',
        quartier: _session.quartier ?? '',
        meterNumber: _session.meterNumber,
      );
      await _session.setUserMode(UserMode.registered);
      _status = AuthFlowStatus.idle;
      notifyListeners();
    } catch (_) {
      _status = AuthFlowStatus.error;
      _errorMessage = 'Code invalide ou expiré, réessaie.';
      notifyListeners();
    }
  }

  /// Revient à l'étape de saisie du numéro (ex: "Modifier le numéro").
  void resetToPhoneStep() {
    _status = AuthFlowStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
