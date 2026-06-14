import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
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
                  ConsumptionChartCard(
                    entries: vm.entries,
                    period: vm.period,
                    onPeriodChanged: vm.setPeriod,
                  ),
                  if (vm.summary != null) ...[
                    const SizedBox(height: 16),
                    ConsumptionInsights(summary: vm.summary!),
                  ],
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
