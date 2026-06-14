import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/consumption_model.dart';

/// Bloc d'analyses sous le graphique de consommation (F7) :
/// - projection de la facture de fin de mois (toujours affichée dès
///   qu'une [ConsumptionSummary] existe) ;
/// - comparaison avec la moyenne du quartier, si des données d'autres
///   utilisateurs sont disponibles ;
/// - alerte d'anomalie si la hausse vs la semaine dernière dépasse le
///   seuil (nécessite ~2 semaines d'historique) ;
/// - conseil d'économie contextuel.
class ConsumptionInsights extends StatelessWidget {
  final ConsumptionSummary summary;

  const ConsumptionInsights({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final fcfa = NumberFormat('#,##0', 'fr_FR');
    final textTheme = Theme.of(context).textTheme;
    final vsLastWeek = summary.comparisonToPreviousWeekPercent;
    final vsNeighborhood = summary.comparisonToNeighborhoodPercent;
    final isAnomalous =
        vsLastWeek != null && vsLastWeek >= AppConstants.anomalyThresholdPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAnomalous) ...[
          AppCard(
            color: AppColors.danger.withValues(alpha: 0.08),
            child: _InsightRow(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.danger,
              child: Text.rich(
                TextSpan(
                  style: textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'Consommation inhabituelle : '),
                    TextSpan(
                      text: '+${vsLastWeek.toStringAsFixed(0)}% ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                    const TextSpan(
                      text: 'par rapport à la semaine dernière.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        AppCard(
          child: Column(
            children: [
              _InsightRow(
                icon: Icons.trending_up,
                iconColor: AppColors.primaryDark,
                child: Text.rich(
                  TextSpan(
                    style: textTheme.bodyMedium,
                    children: [
                      const TextSpan(
                        text: 'À ce rythme, ta facture sera d\'environ ',
                      ),
                      TextSpan(
                        text:
                            '${fcfa.format(summary.projectedCostFcfaEndOfMonth)} FCFA ',
                        style:
                            const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: 'ce mois-ci.'),
                    ],
                  ),
                ),
              ),
              if (vsNeighborhood != null) ...[
                const Divider(height: 24),
                _InsightRow(
                  icon: Icons.people_outline,
                  iconColor: AppColors.primaryDark,
                  child: Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'Tu consommes '),
                        TextSpan(
                          text: '${vsNeighborhood.abs().toStringAsFixed(0)}% ',
                          style:
                              const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: vsNeighborhood < 0 ? 'de moins ' : 'de plus ',
                        ),
                        const TextSpan(
                          text: 'que les foyers de ton quartier.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: AppColors.primaryLight,
          child: _InsightRow(
            icon: Icons.lightbulb_outline,
            iconColor: AppColors.primaryDark,
            child: Text(
              summary.tip,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _InsightRow({
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }
}
