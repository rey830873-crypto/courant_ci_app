import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/theme_viewmodel.dart';

/// Widget racine de CourantInfo CI.
/// Branche [AppTheme] (clair/sombre, piloté par [ThemeViewModel]) sur le
/// [GoRouter] construit dans `main.dart`.
class CICApp extends StatelessWidget {
  final GoRouter router;

  const CICApp({required this.router, super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeViewModel>().themeMode;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
