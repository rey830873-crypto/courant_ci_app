import 'package:flutter/material.dart';
import '../../../core/router/main_shell_tab_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/meter_model.dart';
import 'meter_preview_card.dart';

/// Section "Compteur" du dashboard (F2).
///
/// Trois états possibles, tous honnêtes (aucune donnée inventée) :
/// 1. Aucun numéro de compteur configuré → invite à le faire.
/// 2. Numéro configuré mais aucun relevé saisi → invite à saisir le
///    premier relevé.
/// 3. Au moins un relevé → aperçu du compteur, avec un rappel discret
///    si pas encore assez de relevés pour le graphique de conso (F7).
class MeterStatusSection extends StatelessWidget {
  final String? meterNumber;
  final MeterModel? meter;
  final bool hasConsumptionData;

  const MeterStatusSection({
    super.key,
    required this.meterNumber,
    required this.meter,
    required this.hasConsumptionData,
  });

  @override
  Widget build(BuildContext context) {
    if (meterNumber == null) {
      return const _SetupPrompt(
        icon: Icons.bolt_outlined,
        title: 'Active le suivi de ton compteur',
        description:
            'Renseigne ton numéro de compteur prépayé pour suivre ton '
            'crédit en temps réel (F2).',
        actionLabel: 'Configurer mon compteur',
      );
    }

    final currentMeter = meter;
    if (currentMeter == null) {
      return const _SetupPrompt(
        icon: Icons.edit_note_outlined,
        title: 'Ajoute ton premier relevé',
        description:
            'Saisis le solde actuel de ton compteur pour démarrer le suivi '
            'de ton crédit et de ta consommation.',
        actionLabel: 'Ajouter un relevé',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MeterPreviewCard(meter: currentMeter),
        if (!hasConsumptionData) ...[
          const SizedBox(height: 12),
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
                    'Ajoute un nouveau relevé dans quelques jours pour '
                    'débloquer le graphique et les projections de '
                    'consommation.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryDark,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SetupPrompt extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;

  const _SetupPrompt({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          PrimaryButton(
            label: actionLabel,
            icon: Icons.arrow_forward,
            onPressed: () => requestTab(MainShellTab.meter),
          ),
        ],
      ),
    );
  }
}
