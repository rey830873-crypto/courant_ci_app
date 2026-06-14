/// Type de signalement communautaire (F4).
enum ReportType { outage, restored, hazard }

extension ReportTypeX on ReportType {
  String get label {
    switch (this) {
      case ReportType.outage:
        return 'Coupure de courant';
      case ReportType.restored:
        return 'Courant revenu';
      case ReportType.hazard:
        return 'Danger électrique';
    }
  }
}

/// Signalement remonté par un utilisateur (F4 — signalement communautaire).
///
/// Modèle posé dès les fondations pour préparer l'écran "Signaler",
/// mais non encore relié à un backend.
class ReportModel {
  final String? id;
  final String? userId;
  final String commune;
  final String quartier;
  final ReportType type;
  final DateTime timestamp;
  final String? description;

  const ReportModel({
    this.id,
    this.userId,
    required this.commune,
    required this.quartier,
    required this.type,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'commune': commune,
      'quartier': quartier,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ReportModel(
      id: id,
      userId: map['userId'] as String?,
      commune: map['commune'] as String? ?? '',
      quartier: map['quartier'] as String? ?? '',
      type: ReportType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => ReportType.outage,
      ),
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
      description: map['description'] as String?,
    );
  }
}
