import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import 'widgets/consumption_chart_card.dart';
import 'widgets/consumption_insights.dart';
import 'widgets/meter_status_section.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/zone_status_card.dart';

/// Écran "Accueil" : vue d'ensemble (statut réseau de la zone en temps
/// réel, aperçu du compteur prépayé) et suivi de consommation détaillé
/// (F7).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DashboardViewModel>(
          builder: (context, vm, _) {
            // On attend le chargement initial ET la première mise à jour
            // du statut réseau temps réel avant d'afficher l'écran.
            if (vm.isLoading || vm.zoneStatus == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: vm.refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Header(commune: vm.commune, quartier: vm.quartier),
                  const SizedBox(height: 16),
                  ZoneStatusCard(status: vm.zoneStatus!),
                  const SizedBox(height: 16),
                  MeterStatusSection(
                    meterNumber: vm.meterNumber,
                    meter: vm.meter,
                    hasConsumptionData: vm.summary != null,
                  ),
                  const SizedBox(height: 16),
                  if (context.watch<SessionViewModel>().isRegistered) ...[
                    ConsumptionChartCard(
                      entries: vm.entries,
                      period: vm.period,
                      onPeriodChanged: vm.setPeriod,
                    ),
                    if (vm.summary != null) ...[
                      const SizedBox(height: 16),
                      ConsumptionInsights(summary: vm.summary!),
                    ],
                  ] else
                    const _ConsumptionLockedCard(),
                  const SizedBox(height: 16),
                  const QuickActionsGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConsumptionLockedCard extends StatelessWidget {
  const _ConsumptionLockedCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline,
                  color: AppColors.primaryDark, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Suivi de consommation',
                  style: textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Crée un compte pour suivre l\'évolution de ta consommation et '
            'estimer ta facture de fin de mois.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Créer un compte',
            icon: Icons.person_add_alt,
            onPressed: () => context.push(AppRoutes.register),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String commune;
  final String quartier;

  const _Header({required this.commune, required this.quartier});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    final location = (commune.isEmpty && quartier.isEmpty)
        ? null
        : '$quartier, $commune';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour 👋', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                location ?? 'Ta zone',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: themeVM.toggle,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.primaryDark,
          ),
          icon: Icon(
            themeVM.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
        ),
      ],
    );
  }
}
