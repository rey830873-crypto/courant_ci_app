/// Mode d'accès de l'utilisateur (CDC section 2 : distinction stricte
/// entre "Invité" et "Enregistré").
enum UserMode { guest, registered }

/// Plans tarifaires CIC (CDC section 7.1). Seul `free` est utilisable en V1,
/// les autres sont conservés pour préparer l'évolution vers le modèle payant.
enum SubscriptionPlan { free, pro, business }

extension SubscriptionPlanX on SubscriptionPlan {
  String get label {
    switch (this) {
      case SubscriptionPlan.free:
        return 'CIC Gratuit';
      case SubscriptionPlan.pro:
        return 'CIC Pro';
      case SubscriptionPlan.business:
        return 'CIC Business';
    }
  }
}

/// Profil utilisateur CIC.
///
/// En mode invité, [uid] et [phoneNumber] sont `null` : seules les
/// préférences locales (zone, compteur) sont connues.
class UserModel {
  final String? uid;
  final String? phoneNumber;
  final String displayName;
  final String commune;
  final String quartier;
  final String? meterNumber;
  final UserMode mode;
  final SubscriptionPlan plan;
  final int cicPoints;
  final bool isSentinel;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.displayName,
    required this.commune,
    required this.quartier,
    required this.meterNumber,
    required this.mode,
    required this.plan,
    required this.cicPoints,
    required this.isSentinel,
    required this.createdAt,
  });

  /// Construit un profil "Invité" minimal à partir des préférences locales.
  factory UserModel.guest({
    required String commune,
    required String quartier,
    String? meterNumber,
  }) {
    return UserModel(
      uid: null,
      phoneNumber: null,
      displayName: 'Invité',
      commune: commune,
      quartier: quartier,
      meterNumber: meterNumber,
      mode: UserMode.guest,
      plan: SubscriptionPlan.free,
      cicPoints: 0,
      isSentinel: false,
      createdAt: DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? commune,
    String? quartier,
    String? meterNumber,
    UserMode? mode,
    SubscriptionPlan? plan,
    int? cicPoints,
    bool? isSentinel,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      commune: commune ?? this.commune,
      quartier: quartier ?? this.quartier,
      meterNumber: meterNumber ?? this.meterNumber,
      mode: mode ?? this.mode,
      plan: plan ?? this.plan,
      cicPoints: cicPoints ?? this.cicPoints,
      isSentinel: isSentinel ?? this.isSentinel,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'commune': commune,
      'quartier': quartier,
      'meterNumber': meterNumber,
      'mode': mode.name,
      'plan': plan.name,
      'cicPoints': cicPoints,
      'isSentinel': isSentinel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    return UserModel(
      uid: uid,
      phoneNumber: map['phoneNumber'] as String?,
      displayName: map['displayName'] as String? ?? 'Utilisateur CIC',
      commune: map['commune'] as String? ?? '',
      quartier: map['quartier'] as String? ?? '',
      meterNumber: map['meterNumber'] as String?,
      mode: UserMode.values.firstWhere(
        (m) => m.name == map['mode'],
        orElse: () => UserMode.registered,
      ),
      plan: SubscriptionPlan.values.firstWhere(
        (p) => p.name == map['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      cicPoints: (map['cicPoints'] as num?)?.toInt() ?? 0,
      isSentinel: map['isSentinel'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
