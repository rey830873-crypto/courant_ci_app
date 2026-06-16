import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../viewmodels/simulator_viewmodel.dart';

class SimulatorView extends StatelessWidget {
  const SimulatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SimulatorViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Simulateur de facture'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _QuickCalculator(),
            const SizedBox(height: 24),
            Text(
              'Estimation par appareil (Mensuel)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const _ApplianceEstimator(),
          ],
        ),
      ),
    );
  }
}

class _QuickCalculator extends StatelessWidget {
  const _QuickCalculator();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SimulatorViewModel>();

    return AppCard(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calcul Rapide',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: vm.calculate,
            decoration: const InputDecoration(
              labelText: 'Consommation en kWh',
              suffixText: 'kWh',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimation :'),
              Text(
                '${vm.resultFcfa.toStringAsFixed(0)} FCFA',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplianceEstimator extends StatelessWidget {
  const _ApplianceEstimator();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SimulatorViewModel>();

    return Column(
      children: [
        ...vm.appliances.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                          Text('${item.watts}W', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '${item.monthlyKwh.toStringAsFixed(1)} kWh/mois',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: item.hoursPerDay,
                  min: 0,
                  max: 24,
                  divisions: 24,
                  label: '${item.hoursPerDay.toInt()}h/jour',
                  onChanged: (val) => vm.updateApplianceHours(index, val),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        AppCard(
          color: AppColors.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Estimé',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${vm.totalMonthlyKwh.toStringAsFixed(1)} kWh',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${vm.totalMonthlyFcfa.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
