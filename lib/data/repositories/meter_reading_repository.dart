import '../models/meter_reading_model.dart';

/// Interface pour les relevés de compteur prépayé (F2).
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
