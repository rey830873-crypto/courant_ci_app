/// Un relevé de solde de compteur prépayé, saisi manuellement par
/// l'utilisateur (CDC section 10 : pas d'API CIE en V1).
///
/// La consommation (F7) est dérivée de la série de relevés d'un même
/// [ownerId] : une baisse du solde entre deux relevés consécutifs
/// représente de la consommation, une hausse représente une recharge.
class MeterReadingModel {
  final String? id;

  /// Identifiant du propriétaire : UID Firebase si inscrit, sinon un
  /// identifiant d'appareil persistant (voir [LocalStorageService]).
  final String ownerId;
  final String meterNumber;
  final double kwhBalance;
  final DateTime timestamp;

  /// Zone de l'utilisateur au moment du relevé (dénormalisé), pour
  /// permettre une comparaison de quartier (F7) sans avoir à recouper
  /// avec les profils utilisateurs.
  final String commune;
  final String quartier;

  const MeterReadingModel({
    this.id,
    required this.ownerId,
    required this.meterNumber,
    required this.kwhBalance,
    required this.timestamp,
    required this.commune,
    required this.quartier,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'meterNumber': meterNumber,
      'kwhBalance': kwhBalance,
      'timestamp': timestamp.toIso8601String(),
      'commune': commune,
      'quartier': quartier,
    };
  }

  factory MeterReadingModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MeterReadingModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      meterNumber: map['meterNumber'] as String? ?? '',
      kwhBalance: (map['kwhBalance'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
      commune: map['commune'] as String? ?? '',
      quartier: map['quartier'] as String? ?? '',
    );
  }
}
