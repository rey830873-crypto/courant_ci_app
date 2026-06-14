import '../../data/models/zone_model.dart';

/// Constantes globales de CourantInfo CI (CIC).
/// Centralise les valeurs issues du cahier des charges pour éviter
/// les "nombres magiques" dispersés dans le code.
class AppConstants {
  AppConstants._();

  // --- Identité ---
  static const String appName = 'CourantInfo CI';
  static const String appShortName = 'CIC';
  static const String appSlogan =
      'Informé avant. Protégé pendant. Prêt après.';

  // --- Seuils F2 : alerte compteur prépayé (en kWh restants) ---
  static const double meterInfoThresholdKwh = 20; // 🟡 "Ton crédit baisse"
  static const double meterWarningThresholdKwh = 10; // 🟠 "Recharge bientôt"
  static const double meterCriticalThresholdKwh = 5; // 🔴 "Crédit critique"

  // --- Tarification (F7) ---
  /// Estimation provisoire en FCFA/kWh pour les calculs de facture.
  /// À remplacer par le vrai barème CIE (tarification par tranches)
  /// lorsque les données officielles seront disponibles.
  static const double estimatedKwhPriceFcfa = 95;

  /// Seuil au-delà duquel une hausse de consommation est jugée anormale (F7).
  static const double anomalyThresholdPercent = 30;

  // --- Clés de stockage local (SharedPreferences) ---
  static const String prefOnboardingDone = 'cic_onboarding_done';
  static const String prefUserMode = 'cic_user_mode';
  static const String prefThemeMode = 'cic_theme_mode';
  static const String prefCommune = 'cic_commune';
  static const String prefQuartier = 'cic_quartier';
  static const String prefMeterNumber = 'cic_meter_number';
  static const String prefDeviceId = 'cic_device_id';
  static const String prefReportTimestamps = 'cic_report_timestamps';
  static const String prefCicPoints = 'cic_points';

  // --- Zones Abidjan (Phase 1 du CDC) ---
  // Liste simplifiée : quelques quartiers représentatifs par commune.
  static const List<Commune> abidjanCommunes = [
    Commune(
      name: 'Cocody',
      quartiers: ['Angré', 'Riviera', 'II Plateaux', 'Danga'],
      latitude: 5.3640,
      longitude: -3.9870,
    ),
    Commune(
      name: 'Yopougon',
      quartiers: ['Niangon', 'Maroc', 'Sicogi', 'Toits Rouges'],
      latitude: 5.3450,
      longitude: -4.0850,
    ),
    Commune(
      name: 'Plateau',
      quartiers: ['Centre administratif', 'Indénié'],
      latitude: 5.3197,
      longitude: -4.0181,
    ),
    Commune(
      name: 'Treichville',
      quartiers: ['Zone 3', 'Biafra', 'Arras'],
      latitude: 5.2926,
      longitude: -4.0107,
    ),
    Commune(
      name: 'Marcory',
      quartiers: ['Anoumabo', 'Zone 4', 'Biétry'],
      latitude: 5.2934,
      longitude: -3.9836,
    ),
    Commune(
      name: 'Adjamé',
      quartiers: ['Liberté', '220 Logements', 'Williamsville'],
      latitude: 5.3530,
      longitude: -4.0270,
    ),
    Commune(
      name: 'Abobo',
      quartiers: ['Avocatier', 'Anonkoua-Kouté', 'Plaque'],
      latitude: 5.4189,
      longitude: -4.0167,
    ),
    Commune(
      name: 'Koumassi',
      quartiers: ['Sicogi', 'Remblais', 'Grand Campement'],
      latitude: 5.2925,
      longitude: -3.9445,
    ),
  ];

  // --- Carte (F3) ---
  /// Centre par défaut de la carte (centroïde des communes ci-dessus,
  /// zone d'Abidjan). Le zoom minimal permet de dézoomer pour replacer
  /// Abidjan dans le contexte de la Côte d'Ivoire.
  static const double mapCenterLat = 5.335;
  static const double mapCenterLng = -4.009;
  static const double mapDefaultZoom = 11.5;
  static const double mapMinZoom = 6;
  static const double mapMaxZoom = 17;

  // --- Signalements (F1 / F4) ---
  /// Durée pendant laquelle un signalement est considéré "actif" pour le
  /// calcul du statut réseau (F1) et l'affichage des dangers récents.
  static const int activeReportWindowHours = 3;

  /// Nombre maximum de signalements qu'un même appareil peut envoyer par
  /// heure (CDC F4 : anti-spam).
  static const int maxReportsPerHour = 5;

  /// Nombre de signalements à partir duquel le badge "Sentinelle CIC"
  /// est débloqué (CDC F4).
  static const int sentinelReportThreshold = 10;

  /// Points CIC gagnés par signalement valide.
  static const int cicPointsPerReport = 1;

  // --- Compteur / consommation (F2 / F7) ---
  /// Nombre minimum de relevés nécessaires pour calculer une
  /// consommation (il faut au moins deux points pour une différence).
  static const int minReadingsForStats = 2;
}
