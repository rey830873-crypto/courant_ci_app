import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Choix entre le mode "Invité" (accès immédiat, fonctionnalités
/// limitées) et la création d'un compte par OTP (CDC section 2 :
/// distinction stricte Invité / Enregistré).
class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64, // 32*2 de padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          size: 32, color: AppColors.onPrimary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Presque prêt !',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crée un compte pour activer les alertes personnalisées '
                      'et sauvegarder ton profil, ou continue en invité.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      label: 'Créer un compte',
                      icon: Icons.person_add_alt,
                      onPressed: () => context.push(AppRoutes.register),
                    ),
                    Center(
                      child: PrimaryButton(
                        label: 'Déjà inscrit ? Se connecter',
                        variant: PrimaryButtonVariant.text,
                        onPressed: () => context.push(AppRoutes.signIn),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Continuer en invité',
                      variant: PrimaryButtonVariant.outlined,
                      isLoading: authVM.isBusy,
                      onPressed: () async {
                        await authVM.continueAsGuest();
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'En mode invité, certaines fonctionnalités '
                      '(signalements, suivi de consommation) seront '
                      'limitées. Tu pourras créer un compte plus tard '
                      'depuis ton profil.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (!authVM.isFirebaseReady) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 18, color: AppColors.primaryDark),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Firebase n\'est pas encore configuré : '
                                'seul le mode invité est disponible pour '
                                'le moment.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        AppConstants.appSlogan,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
