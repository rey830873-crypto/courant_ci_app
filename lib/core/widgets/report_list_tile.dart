import 'package:flutter/material.dart';
import '../../data/models/report_model.dart';
import '../theme/report_type_style.dart';

/// Ligne d'affichage d'un signalement (F4) : icône colorée par type,
/// libellé, quartier et horodatage relatif. Utilisée par le détail
/// commune (carte) et l'écran Signaler.
class ReportListTile extends StatelessWidget {
  final ReportModel report;

  const ReportListTile({super.key, required this.report});

  String get _timeAgo {
    final diff = DateTime.now().difference(report.timestamp);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    final type = report.type;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(type.icon, color: type.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        type.label,
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(_timeAgo, style: textTheme.bodySmall),
                  ],
                ),
                if (report.quartier.isNotEmpty)
                  Text(report.quartier, style: textTheme.bodySmall),
                if ((report.description ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(report.description!, style: textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
