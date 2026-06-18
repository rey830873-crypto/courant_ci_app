/// Service d'authentification simulé (remplace Firebase Auth).
///
/// Aucun vrai SMS n'est envoyé : la création de compte est immédiate
/// dès que le numéro de téléphone est fourni. L'identifiant retourné
/// est dérivé directement du numéro de téléphone (et non d'une valeur
/// fixe partagée) : deux comptes différents sur le même appareil
/// doivent obtenir deux identifiants différents, pour que leurs
/// relevés de compteur et autres données propres ne se mélangent pas.
class AuthService {
  String? _currentUid;

  /// UID de l'utilisateur connecté (simulé, dérivé du numéro de
  /// téléphone — voir [_uidFromPhone]).
  String? get currentUserId => _currentUid;

  /// Même règle de dérivation que [FirestoreUserRepository._docId] :
  /// le numéro de téléphone (sans le '+') sert directement
  /// d'identifiant, pour qu'un même numéro retombe toujours sur le
  /// même identifiant, sur cet appareil ou un autre.
  String _uidFromPhone(String phoneNumber) =>
      'user_${phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')}';

  /// Simule la création d'un compte à partir du numéro de téléphone.
  Future<String> registerWithPhone(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (phoneNumber.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
      throw Exception('Numéro de téléphone invalide.');
    }

    _currentUid = _uidFromPhone(phoneNumber);
    return _currentUid!;
  }

  /// Simule la reconnexion à un compte existant à partir du numéro de
  /// téléphone (même règle de dérivation que [registerWithPhone], pour
  /// retrouver le même identifiant qu'à l'inscription).
  Future<String> signInWithPhone(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUid = _uidFromPhone(phoneNumber);
    return _currentUid!;
  }

  Future<void> signOut() async {
    _currentUid = null;
  }
}
