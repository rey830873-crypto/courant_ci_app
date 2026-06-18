import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Affiche des notifications locales (coupure signalée dans la zone de
/// l'utilisateur, crédit du compteur prépayé faible).
///
/// "Locale" signifie : déclenchée par le code de l'application
/// elle-même, pendant qu'elle est ouverte ou en arrière-plan récent —
/// par opposition à une notification "push" envoyée par un serveur,
/// qui arriverait même si l'application est complètement fermée
/// depuis longtemps. Cette dernière demanderait une Cloud Function
/// Firebase (plan payant "Blaze") en plus de ce service ; voir la
/// discussion avec l'utilisateur du 18 juin 2026 dans BACKEND.md.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _outageChannelId = 'cic_outage_alerts';
  static const _meterChannelId = 'cic_meter_alerts';

  bool _initialized = false;

  /// À appeler une seule fois, au démarrage de l'application (avant
  /// d'afficher la moindre notification). Idempotent : un second appel
  /// ne fait rien.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Canaux Android : un par type d'alerte, pour que l'utilisateur
    // puisse les couper indépendamment depuis les réglages système de
    // son téléphone (ex: garder les coupures, masquer le crédit
    // faible) sans tout désactiver d'un coup.
    const outageChannel = AndroidNotificationChannel(
      _outageChannelId,
      'Coupures dans ta zone',
      description: 'Alerte quand un signalement de coupure ou de '
          'rétablissement est publié dans ta commune/quartier.',
      importance: Importance.high,
    );
    const meterChannel = AndroidNotificationChannel(
      _meterChannelId,
      'Crédit compteur faible',
      description: 'Alerte quand le solde de ton compteur prépayé '
          'devient bas.',
      importance: Importance.high,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(outageChannel);
    await androidPlugin?.createNotificationChannel(meterChannel);

    _initialized = true;
  }

  /// Demande la permission d'afficher des notifications (obligatoire à
  /// partir d'Android 13). À appeler à un moment qui a du sens pour la
  /// personne (ex: juste après l'onboarding), pas automatiquement au
  /// chargement de l'app.
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted =
        await androidPlugin?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// [previousStatus] et [newStatus] utilisent les libellés de
  /// [ZoneStatus] (voir zone_model.dart) plutôt que le type lui-même,
  /// pour ne pas créer de dépendance entre ce service (purement
  /// technique) et les modèles métier de l'application.
  Future<void> showZoneStatusAlert({
    required String quartier,
    required String commune,
    required String previousStatusLabel,
    required String newStatusLabel,
    required bool isImprovement,
  }) async {
    if (!_initialized) return;

    final title = isImprovement ? 'Réseau rétabli' : 'Coupure signalée';
    final body = isImprovement
        ? 'Le réseau semble revenu à la normale à $quartier, $commune.'
        : '$newStatusLabel à $quartier, $commune.';

    await _plugin.show(
      _outageChannelId.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _outageChannelId,
          'Coupures dans ta zone',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showLowMeterAlert({required double kwhBalance}) async {
    if (!_initialized) return;

    await _plugin.show(
      _meterChannelId.hashCode,
      'Crédit compteur faible',
      'Ton solde est descendu à ${kwhBalance.toStringAsFixed(1)} kWh. '
          'Pense à recharger pour éviter une coupure.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _meterChannelId,
          'Crédit compteur faible',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
