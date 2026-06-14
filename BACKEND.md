# BACKEND.md — CourantInfo CI (CIC) : backend Firestore réel

Ce document décrit le backend **réel** (Firestore) qui alimente le
Dashboard (F1/F2/F7), la Carte (F3) et le Signalement communautaire
(F4). Il n'y a **plus aucune donnée simulée** dans l'application : tout
ce qui est affiché provient soit de Firestore, soit d'une saisie locale
de l'utilisateur.

## 1. Configuration Firebase

L'application appelle `Firebase.initializeApp()` au démarrage
(`lib/main.dart`). Pour que cela fonctionne, le projet doit avoir été
relié à un projet Firebase via la CLI FlutterFire :

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Cette commande génère `lib/firebase_options.dart` (non fourni ici — il
contient des identifiants de projet propres à chaque environnement) et
active les SDK nécessaires (déjà présents dans `pubspec.yaml` :
`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`).

**Si Firebase n'est pas configuré**, `main.dart` intercepte l'erreur et
l'app démarre quand même : Splash, Onboarding, Auth et Profil restent
utilisables, mais le Dashboard, la Carte, le Compteur et Signaler
afficheront des flux Firestore qui échouent silencieusement (listes
vides / chargement infini). C'est un mode de dégradation volontaire
pour ne pas bloquer le développement de l'UI sans backend.

Ensuite, déployez les règles de sécurité (`firestore.rules` à la racine
du projet) :

```bash
firebase deploy --only firestore:rules
```

## 2. Schéma Firestore

### `reports` (F4 → F1 → F3)

Un document par signalement communautaire.

| Champ         | Type                              | Description                                                        |
|---------------|-----------------------------------|---------------------------------------------------------------------|
| `userId`      | `string \| null`                  | UID Firebase si l'auteur est inscrit, sinon `null`.                 |
| `commune`     | `string`                           | Commune de l'auteur au moment du signalement.                       |
| `quartier`    | `string`                           | Quartier de l'auteur.                                                |
| `type`        | `'outage' \| 'restored' \| 'hazard'` | Type de signalement.                                              |
| `timestamp`   | `string` (ISO 8601)                | Horodatage de l'envoi.                                              |
| `description` | `string \| null`                  | Détail optionnel saisi par l'utilisateur (≤ 280 caractères).        |
| `zoneId`      | `string`                           | **Dénormalisé** : `'$commune::$quartier'`.                          |

### `meter_readings` (F2 → F7)

Un document par relevé de solde de compteur prépayé saisi
manuellement.

| Champ         | Type      | Description                                                              |
|---------------|-----------|---------------------------------------------------------------------------|
| `ownerId`     | `string`  | UID Firebase si inscrit, sinon `deviceId` local persistant.               |
| `meterNumber` | `string`  | Numéro de compteur CIE saisi par l'utilisateur.                            |
| `kwhBalance`  | `number`  | Solde affiché sur le compteur au moment du relevé.                        |
| `timestamp`   | `string` (ISO 8601) | Horodatage du relevé.                                            |
| `commune`     | `string`  | **Dénormalisé** : commune de l'utilisateur au moment du relevé.            |
| `quartier`    | `string`  | **Dénormalisé** : quartier de l'utilisateur au moment du relevé.           |

### `users/{uid}`

Profil créé par `AuthRepository` à l'inscription (voir
`lib/data/repositories/auth_repository.dart`, inchangé dans cette
session). Les champs `cicPoints`/`isSentinel` de ce document sont
écrits une seule fois (à `0`/`false`) et **ne sont pas synchronisés**
avec le système de points décrit en section 5 — voir "Limites connues".

## 3. Pourquoi aucun index composite Firestore n'est nécessaire

Toutes les requêtes de l'app utilisent **une seule égalité sur un seul
champ** (`where('zoneId', isEqualTo: ...)`, `where('commune',
isEqualTo: ...)`, `where('commune', whereIn: ...)`, `where('ownerId',
isEqualTo: ...)`), **sans** `orderBy` ni filtre combiné. Firestore crée
automatiquement un index à champ unique pour chaque champ — aucune
configuration manuelle (`firestore.indexes.json`) n'est donc requise.

Le tri (par date), le filtrage par fenêtre temporelle (signalements
"actifs" des 3 dernières heures) et les agrégations (comptage par
type, moyennes de consommation) sont effectués **côté client en
Dart**, après récupération des documents. C'est un choix délibéré pour
la V1/démo : il évite toute configuration d'index, au prix de
transférer un peu plus de documents que strictement nécessaire. À
l'échelle (des milliers de signalements par zone), il faudrait migrer
vers des requêtes avec `orderBy` + index composites, voire des
agrégats pré-calculés (Cloud Functions incrémentant des compteurs).

## 4. Statut réseau temps réel (F1) et carte (F3)

`FirestoreReportRepository` expose trois flux (`Stream`, via
`.snapshots()`) :

- `watchZoneStatus(commune, quartier)` : statut de la zone précise de
  l'utilisateur, utilisé par le Dashboard et l'écran Signaler.
- `watchCommuneStatuses(communes)` : statut agrégé de chaque commune
  (une seule requête `whereIn`), utilisé par les marqueurs de la Carte.
- `watchRecentReports(...)` / `watchRecentReportsForCommune(...)` :
  listes de signalements récents affichées sous forme de flux (mises à
  jour automatiquement quand quelqu'un signale quelque chose).

Algorithme d'agrégation (`_aggregate`, dans `report_repository.dart`) :
seuls les signalements de moins de `activeReportWindowHours` (3h) sont
pris en compte. Si le plus récent est "Courant revenu", la zone repasse
à `normal`. Sinon, le nombre de signalements "Coupure" actifs détermine
le palier (`ZoneStatusX.fromReportCount` : 1-4 → possible, 5-9 →
probable, 10+ → confirmée). Un signalement "Danger" actif est remonté
indépendamment via `ZoneStatusInfo.hasRecentHazard`, qu'il y ait ou non
une coupure en cours.

Toute écriture dans `reports` (un nouveau signalement, par n'importe
quel utilisateur) déclenche donc en temps réel une mise à jour du
Dashboard, de la Carte et de l'écran Signaler de **tous** les
utilisateurs de la zone concernée — sans rafraîchissement manuel.

## 5. Identité invité / inscrit (`ownerId`)

L'app fonctionne entièrement en mode invité (CDC : pas de compte
obligatoire). Pour que les relevés de compteur (F2) et les
signalements (F4) restent associés à "leur" auteur sans imposer de
compte :

- Si l'utilisateur est inscrit (`AuthService.currentUserId` non nul),
  `ownerId` = son UID Firebase.
- Sinon, `ownerId` = un identifiant d'appareil persistant
  (`LocalStorageService.getOrCreateDeviceId()`), généré une fois et
  stocké dans `SharedPreferences`.

Les points CIC / badge "Sentinelle" (CDC F4) sont actuellement stockés
**uniquement en local** (`SharedPreferences`, clé
`AppConstants.prefCicPoints`), pour le mode invité comme pour le mode
inscrit. Idem pour la limitation "5 signalements/heure"
(`AppConstants.maxReportsPerHour`), qui est un anti-spam **par
appareil**, pas par compte.

## 6. Consommation réelle (F2 / F7)

`MeterConsumptionRepository` (dans `dashboard_repository.dart`) ne
contient **aucune valeur simulée**. Tout est dérivé de la série de
`meter_readings` de l'utilisateur :

- Entre deux relevés consécutifs, une **baisse** du solde = consommation
  sur cet intervalle ; une **hausse** (recharge) compte pour 0 kWh
  consommé sur cet intervalle.
- La moyenne quotidienne est calculée sur les intervalles des 14
  derniers jours (somme des kWh / somme des durées, ramenée à 24h).
- Le graphique (F7, Jour/Semaine/Mois) répartit chaque intervalle dans
  le panier temporel où se termine cet intervalle.
- La projection de fin de mois = consommation du mois en cours +
  (moyenne quotidienne × jours restants).
- La comparaison "vs semaine dernière" nécessite environ 13 jours
  d'historique et une semaine précédente non nulle ; sinon `null`
  (l'UI masque alors la carte d'anomalie).
- La comparaison "vs quartier" interroge les relevés des **autres**
  utilisateurs de la même commune (`fetchReadingsForCommune`,
  dénormalisé sur `meter_readings.commune`) ; `null` si aucun voisin
  n'a au moins 2 relevés.

Tant qu'un utilisateur n'a saisi **aucun** relevé, le Dashboard affiche
une invite à configurer son compteur / ajouter un premier relevé (pas
de graphique ni de chiffres inventés). Avec un seul relevé, le
graphique et les comparaisons restent vides/masqués jusqu'au second
relevé (`AppConstants.minReadingsForStats = 2`).

## 7. Choix de la carte : flutter_map + OpenStreetMap

La Carte (F3) utilise `flutter_map` avec des tuiles
`https://tile.openstreetmap.org/{z}/{x}/{y}.png`, plutôt que
`google_maps_flutter`. Avantages pour ce projet :

- Aucune clé API, aucune facturation, aucune configuration
  Android/iOS spécifique (SHA-1, `Info.plist`, etc.).
- Le rendu des tuiles nécessite un accès internet à l'exécution
  (`tile.openstreetmap.org`) — c'est attendu, l'app est de toute façon
  inutilisable hors-ligne (Firestore).

Les 8 communes d'Abidjan ont des coordonnées approximatives
(centroïdes) codées dans `AppConstants.abidjanCommunes`. Le centre par
défaut de la carte (`mapCenterLat`/`mapCenterLng`) est le centroïde de
ces 8 communes.

## 8. Limites connues et pistes pour la suite

- **Migration invité → inscrit** : si un utilisateur invité crée un
  compte, ses anciens relevés/signalements (associés à son
  `deviceId`) ne sont **pas** automatiquement réassociés à son nouveau
  UID. Une migration (requête sur `ownerId == deviceId`, ré-écriture
  avec le nouvel UID) serait nécessaire.
- **Points CIC non synchronisés** : `users/{uid}.cicPoints` /
  `isSentinel` (écrits une fois à l'inscription) ne reflètent pas les
  points réels (stockés en local). Pour un classement multi-appareils
  ou un affichage du score sur le profil d'un autre utilisateur, il
  faudrait écrire les points dans Firestore (`users/{uid}` ou une
  sous-collection) à chaque signalement.
- **Anti-spam par appareil, pas par compte** : un utilisateur inscrit
  sur deux appareils peut envoyer 5+5 signalements/heure. Acceptable
  en V1 ; à corriger via une règle serveur (Cloud Function) si abus.
- **Lecture de tous les relevés d'une commune pour la comparaison de
  quartier** (`fetchReadingsForCommune`) : fonctionne bien pour une
  démo/V1, mais coûteux en lectures Firestore si une commune compte des
  milliers d'utilisateurs actifs. À terme : agrégats pré-calculés
  (moyenne de quartier mise à jour par Cloud Function à chaque nouveau
  relevé).
- **Pas de validation serveur du contenu** : `firestore.rules` valide
  la *forme* des documents (types, champs requis, bornes) mais pas de
  logique métier complexe (ex: cohérence `zoneId`/`commune`/`quartier`
  au-delà de l'égalité textuelle). Pour un déploiement à plus grande
  échelle, ajouter App Check (anti-bot) et/ou des Cloud Functions de
  validation.

## 9. Comment peupler des données de démonstration

Il n'y a pas de script de seed : la manière prévue d'obtenir des
données réalistes est d'**utiliser l'app elle-même** (plusieurs fois,
éventuellement avec des `deviceId` différents en réinstallant ou en
effaçant les données de l'app) :

1. Compléter l'onboarding avec différentes communes/quartiers.
2. Sur l'écran Signaler, envoyer quelques signalements "Coupure" pour
   faire monter le statut d'une zone (1 → possible, 5 → probable, 10 →
   confirmée).
3. Sur l'écran Compteur, ajouter 2-3 relevés à quelques jours
   d'intervalle (en modifiant l'horloge du simulateur si besoin, ou en
   attendant) pour voir apparaître le graphique de consommation (F7) et
   les comparaisons.

Chaque document ainsi créé est un document Firestore réel, identique à
ceux que produirait un utilisateur final — pas de distinction
"démo"/"prod" dans le schéma.
