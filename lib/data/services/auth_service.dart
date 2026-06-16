/// Service d'authentification simulé (remplace Firebase Auth).
///
/// Aucun vrai SMS n'est envoyé : la création de compte est immédiate
/// dès que le numéro de téléphone est fourni.
class AuthService {
  String? _mockUserUid;

  /// UID de l'utilisateur connecté (simulé).
  String? get currentUserId => _mockUserUid;

  /// Simule la création d'un compte à partir du numéro de téléphone.
  Future<String> registerWithPhone(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (phoneNumber.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
      throw Exception('Numéro de téléphone invalide.');
    }

    _mockUserUid = 'user_mock_123';
    return _mockUserUid!;
  }

  Future<void> signOut() async {
    _mockUserUid = null;
  }
}
