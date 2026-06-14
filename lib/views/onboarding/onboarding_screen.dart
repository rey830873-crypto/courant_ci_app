import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';

/// Parcours de première utilisation (CDC section 6.2, objectif "moins de
/// 90 secondes") : bienvenue, choix de zone, compteur optionnel (F2),
/// notifications. Se termine en appelant
/// [SessionViewModel.completeOnboarding], ce qui redirige automatiquement
/// vers l'écran d'authentification.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 4;

  final PageController _pageController = PageController();
  final TextEditingController _meterController = TextEditingController();
  int _page = 0;
  bool _isFinishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    _meterController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    setState(() => _isFinishing = true);
    final onboarding = context.read<OnboardingViewModel>();
    final session = context.read<SessionViewModel>();
    await onboarding.finish(session, meterNumber: _meterController.text);
    // La redirection vers /auth est gérée par AppRouter (refreshListenable).
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  const _WelcomePage(),
                  _ZonePage(onboarding: onboarding),
                  _MeterPage(controller: _meterController),
                  const _NotificationsPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pageCount, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  if (_page == 2) ...[
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Passer',
                            variant: PrimaryButtonVariant.outlined,
                            onPressed: () => _goTo(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Suivant',
                            onPressed: () => _goTo(3),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_page == _pageCount - 1) ...[
                    PrimaryButton(
                      label: 'Terminer',
                      isLoading: _isFinishing,
                      onPressed: _finish,
                    ),
                  ] else ...[
                    PrimaryButton(
                      label: 'Suivant',
                      onPressed: _page == 1 && !onboarding.hasSelectedZone
                          ? null
                          : () => _goTo(_page + 1),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page 1 — Bienvenue : reprend le slogan CIC en trois temps.
class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded,
                size: 36, color: AppColors.onPrimary),
          ),
          const SizedBox(height: 24),
          Text('Bienvenue sur', style: Theme.of(context).textTheme.bodyLarge),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 32),
          const _ValueProp(
            icon: Icons.notifications_active_outlined,
            title: 'Informé avant',
            description:
                'Une alerte communautaire avant même les SMS officiels.',
          ),
          const SizedBox(height: 20),
          const _ValueProp(
            icon: Icons.shield_outlined,
            title: 'Protégé pendant',
            description:
                'Des conseils pour protéger tes appareils dès la coupure.',
          ),
          const SizedBox(height: 20),
          const _ValueProp(
            icon: Icons.bolt_outlined,
            title: 'Prêt après',
            description:
                'Suis ton crédit compteur et ta consommation au quotidien.',
          ),
        ],
      ),
    );
  }
}

class _ValueProp extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ValueProp({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(description,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// Page 2 — Sélection de la commune et du quartier (carte Abidjan
/// simplifiée en menus déroulants pour la V1).
class _ZonePage extends StatelessWidget {
  final OnboardingViewModel onboarding;

  const _ZonePage({required this.onboarding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined,
              size: 40, color: AppColors.primaryDark),
          const SizedBox(height: 16),
          Text('Où es-tu ?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Choisis ta commune et ton quartier pour recevoir les alertes '
            'de ta zone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          DropdownButtonFormField<String>(
            initialValue: onboarding.selectedCommune,
            decoration: const InputDecoration(labelText: 'Commune'),
            items: onboarding.communeNames
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {
              if (value != null) onboarding.selectCommune(value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: onboarding.selectedQuartier,
            decoration: const InputDecoration(labelText: 'Quartier'),
            items: onboarding.availableQuartiers
                .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                .toList(),
            onChanged: onboarding.selectedCommune == null
                ? null
                : (value) {
                    if (value != null) onboarding.selectQuartier(value);
                  },
          ),
        ],
      ),
    );
  }
}

/// Page 3 — Numéro de compteur prépayé, optionnel (active F2).
class _MeterPage extends StatelessWidget {
  final TextEditingController controller;

  const _MeterPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt_outlined, size: 40, color: AppColors.primaryDark),
          const SizedBox(height: 16),
          Text('Ton compteur prépayé',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Renseigne ton numéro de compteur pour activer les alertes de '
            'crédit (20, 10, 5 et 0 kWh restants). Tu peux le faire plus '
            'tard depuis ton profil.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Numéro de compteur (optionnel)',
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 4 — Activation des notifications (F1 : "Active pour ne plus être
/// surpris").
class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active_outlined,
              size: 40, color: AppColors.primaryDark),
          const SizedBox(height: 16),
          Text('Active pour ne plus être surpris',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'CIC t\'envoie une alerte dès qu\'une coupure est signalée dans '
            'ta zone, et dès que ton crédit compteur devient faible. Tu '
            'pourras gérer ces alertes à tout moment dans ton profil.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Text(
            'Appuie sur "Terminer" pour découvrir CIC.',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
