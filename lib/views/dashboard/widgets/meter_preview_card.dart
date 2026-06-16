import 'package:flutter/material.dart';
import '../../../core/router/main_shell_tab_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/meter_model.dart';

/// Aperçu du compteur prépayé (F2, "fonctionnalité signature" du CDC) :
/// solde restant, jauge colorée selon le seuil d'alerte, estimation du
/// nombre de jours restants et accès rapide à la recharge.
class MeterPreviewCard extends StatelessWidget {
  final MeterModel meter;

  const MeterPreviewCard({super.key, required this.meter});

  Color _colorFor(MeterAlertLevel level) {
    switch (level) {
      case MeterAlertLevel.normal:
        return AppColors.success;
      case MeterAlertLevel.info:
        return AppColors.primary;
      case MeterAlertLevel.warning:
        return AppColors.primaryDark;
      case MeterAlertLevel.critical:
        return AppColors.danger;
    }
  }

  String get _daysLabel {
    final days = meter.estimatedDaysRemaining;
    if (days.isInfinite) return '—';
    if (days < 1) return '< 1 jour';
    return '≈ ${days.toStringAsFixed(1)} jours restants';
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(meter.alertLevel);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Compteur prépayé',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      'N° ${meter.meterNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                meter.currentBalanceKwh.toStringAsFixed(0),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('kWh restants',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: meter.balanceRatio,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  meter.alertLevel.message,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
              Text(_daysLabel, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Ajouter un relevé',
            icon: Icons.edit_note_outlined,
            onPressed: () => requestTab(MainShellTab.meter),
          ),
        ],
      ),
    );
  }
}
