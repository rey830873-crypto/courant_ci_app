import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meter_reading_model.dart';


abstract class MeterReadingRepository {
  Future<void> addReading(MeterReadingModel reading);
  Future<List<MeterReadingModel>> fetchReadings(String ownerId);
  Future<List<MeterReadingModel>> fetchReadingsForCommune(String commune, {String? excludeOwnerId});
}

/// Implémentation simulée (Mock) pour le mode API.
class MockMeterReadingRepository implements MeterReadingRepository {
  final List<MeterReadingModel> _mockReadings = [];

  MockMeterReadingRepository() {
    // Quelques données initiales pour le Dashboard
    _mockReadings.add(MeterReadingModel(
      id: 'r1',
      ownerId: 'user123',
      meterNumber: '123456789',
      kwhBalance: 1500,
      timestamp: DateTime.now().subtract(const Duration(days: 30)),
      commune: 'Cocody',
      quartier: 'Angré',
    ));
  }

  @override
  Future<void> addReading(MeterReadingModel reading) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulation API
    _mockReadings.add(reading);
  }

  @override
  Future<List<MeterReadingModel>> fetchReadings(String ownerId) async {
    return _mockReadings.where((r) => r.ownerId == ownerId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<List<MeterReadingModel>> fetchReadingsForCommune(String commune, {String? excludeOwnerId}) async {
    var readings = _mockReadings.where((r) => r.commune == commune).toList();
    if (excludeOwnerId != null) {
      readings = readings.where((r) => r.ownerId != excludeOwnerId).toList();
    }
    return readings..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}

/// Implémentation réelle : Firestore (collection `meter_readings`).
///
/// Utilisée quand Firebase est correctement configuré, sinon
/// [MockMeterReadingRepository] est utilisé à la place — voir
/// BACKEND.md et `main.dart`.
class FirestoreMeterReadingRepository implements MeterReadingRepository {
  final FirebaseFirestore _firestore;

  FirestoreMeterReadingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _readings =>
      _firestore.collection('meter_readings');

  @override
  Future<void> addReading(MeterReadingModel reading) async {
    await _readings.add(reading.toMap());
  }

  @override
  Future<List<MeterReadingModel>> fetchReadings(String ownerId) async {
    // Égalité sur un seul champ ('ownerId') : pas d'index composite
    // nécessaire. Tri chronologique fait côté client.
    final snapshot = await _readings.where('ownerId', isEqualTo: ownerId).get();
    return _parseSorted(snapshot);
  }

  @override
  Future<List<MeterReadingModel>> fetchReadingsForCommune(
    String commune, {
    String? excludeOwnerId,
  }) async {
    final snapshot = await _readings.where('commune', isEqualTo: commune).get();
    final readings = _parseSorted(snapshot);
    if (excludeOwnerId == null) return readings;
    return readings.where((r) => r.ownerId != excludeOwnerId).toList();
  }

  List<MeterReadingModel> _parseSorted(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final readings = snapshot.docs
        .map((doc) => MeterReadingModel.fromMap(doc.data(), id: doc.id))
        .toList();
    readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return readings;
  }
}
