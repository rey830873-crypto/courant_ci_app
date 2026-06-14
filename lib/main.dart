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

  final prefs = await SharedPreferences.getInstance();
  final localStorage = LocalStorageService(prefs);

  final session = SessionViewModel(localStorage);
  final authService = AuthService();
  final authRepository = AuthRepository(authService);
  final router = AppRouter.create(session);

  // Utilisation d'identifiants locaux (Mode API simulé)
  final ownerId = authService.currentUserId ?? localStorage.getOrCreateDeviceId();

  // Utilisation des dépôts Mock (Simulés)
  final reportRepo = MockReportRepository(); 
  final meterReadingRepo = MockMeterReadingRepository();

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
          create: (_) => AuthViewModel(authRepository, session),
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
