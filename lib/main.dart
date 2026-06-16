import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/meter_reading_repository.dart';
import 'data/repositories/report_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/local_storage_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart';
import 'viewmodels/meter_viewmodel.dart';
import 'viewmodels/onboarding_viewmodel.dart';
import 'viewmodels/report_viewmodel.dart';
import 'viewmodels/session_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase si le projet a été configuré (`flutterfire
  // configure`, qui génère lib/firebase_options.dart). Si ce fichier
  // n'existe pas encore ou que l'init échoue pour une autre raison, on
  // continue avec des dépôts simulés (Mock) ci-dessous — l'app reste
  // utilisable, voir BACKEND.md section 1.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase non initialisé (flutterfire configure ?) : $e');
  }
  final firebaseReady = Firebase.apps.isNotEmpty;

  final prefs = await SharedPreferences.getInstance();
  final localStorage = LocalStorageService(prefs);

  final session = SessionViewModel(localStorage);
  final authService = AuthService();
  final authRepository = AuthRepository(authService);
  final router = AppRouter.create(session);

  // Utilisation d'identifiants locaux (Mode API simulé)
  final ownerId = authService.currentUserId ?? localStorage.getOrCreateDeviceId();

  // Firestore si Firebase est configuré, sinon dépôts simulés (Mock) —
  // dans les deux cas l'app fonctionne immédiatement (voir BACKEND.md).
  final ReportRepository reportRepo =
      firebaseReady ? FirestoreReportRepository() : MockReportRepository();
  final MeterReadingRepository meterReadingRepo = firebaseReady
      ? FirestoreMeterReadingRepository()
      : MockMeterReadingRepository();

  final meterConsumptionRepo = MeterConsumptionRepository(
    readingRepo: meterReadingRepo,
    ownerId: ownerId,
    commune: session.commune ?? '',
    quartier: session.quartier ?? '',
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider(create: (_) => ThemeViewModel(localStorage)),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()), // Ajout du UserViewModel
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            authRepository,
            session,
            context.read<UserViewModel>(),
          ),
        ),
        Provider<ReportRepository>.value(value: reportRepo),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            consumptionRepo: meterConsumptionRepo,
            meterRepo: meterConsumptionRepo,
            reportRepo: reportRepo,
            commune: session.commune ?? '',
            quartier: session.quartier ?? '',
            meterNumber: session.meterNumber,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MapViewModel(reportRepo: reportRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportViewModel(
            reportRepo: reportRepo,
            localStorage: localStorage,
            session: session,
            authService: authService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MeterViewModel(
            readingRepo: meterReadingRepo,
            session: session,
            ownerId: ownerId,
          ),
        ),
      ],
      child: CICApp(router: router),
    ),
  );
}
