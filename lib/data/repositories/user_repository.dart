import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Stocke/retrouve un profil [UserModel] par numéro de téléphone, pour
/// permettre une vraie reconnexion (CDC : un utilisateur qui change
/// d'appareil ou réinstalle l'app ne doit pas avoir à recréer son
/// compte de zéro).
///
/// Le numéro de téléphone (format E.164, ex: +2250700000000) sert
/// directement de clé de document : pas de système d'UID séparé à
/// gérer, et la recherche à la connexion devient une simple lecture
/// par identifiant plutôt qu'une requête `where`.
abstract class UserRepository {
  /// Enregistre (ou met à jour) le profil pour ce numéro.
  Future<void> saveUser(UserModel user);

  /// Retrouve le profil associé à ce numéro, ou `null` s'il n'existe
  /// pas encore de compte avec ce numéro.
  Future<UserModel?> findByPhoneNumber(String phoneNumber);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Le numéro contient un '+' (E.164), invalide comme ID de document
  /// Firestore tel quel dans certains contextes ; on le retire pour
  /// obtenir un identifiant sûr, sans perdre d'information puisque
  /// tous les numéros de ce projet partagent le même préfixe pays.
  String _docId(String phoneNumber) => phoneNumber.replaceAll('+', '');

  @override
  Future<void> saveUser(UserModel user) async {
    final phoneNumber = user.phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    await _users.doc(_docId(phoneNumber)).set(user.toMap());
  }

  @override
  Future<UserModel?> findByPhoneNumber(String phoneNumber) async {
    final snapshot = await _users.doc(_docId(phoneNumber)).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return UserModel.fromMap(data, uid: phoneNumber);
  }
}

/// Implémentation simulée (Mock) pour le mode sans Firebase : les
/// profils ne survivent qu'en mémoire pendant la session de l'app, ce
/// qui reste suffisant pour tester le flux de connexion localement.
class MockUserRepository implements UserRepository {
  final Map<String, UserModel> _store = {};

  @override
  Future<void> saveUser(UserModel user) async {
    final phoneNumber = user.phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    await Future.delayed(const Duration(milliseconds: 300));
    _store[phoneNumber] = user;
  }

  @override
  Future<UserModel?> findByPhoneNumber(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _store[phoneNumber];
  }
}
