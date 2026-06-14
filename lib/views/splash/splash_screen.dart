import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';

/// Écran de démarrage : affiche l'identité CIC puis laisse le routeur
/// rediriger automatiquement (onboarding, authentification ou
/// dashboard) selon l'état de la session.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      // La destination réelle est décidée par AppRouter.redirect en
      // fonction de SessionViewModel : on déclenche simplement une
      // navigation pour sortir de l'écran de démarrage.
      context.go(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 52,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.softBlack,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appShortName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.softBlack.withValues(alpha: 0.7),
                        letterSpacing: 4,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appSlogan,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softBlack.withValues(alpha: 0.75),
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.softBlack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
