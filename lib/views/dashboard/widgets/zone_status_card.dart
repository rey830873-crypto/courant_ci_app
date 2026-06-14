import 'package:flutter/material.dart';
import '../../../core/theme/zone_status_style.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/zone_model.dart';

/// Affiche le statut réseau courant de la zone de l'utilisateur (F1),
/// avec le code couleur CIC : vert = normal, orange = signalement en
/// cours, rouge = coupure confirmée.
class ZoneStatusCard extends StatelessWidget {
  final ZoneStatusInfo status;

  const ZoneStatusCard({super.key, required this.status});

  String get _timeAgo {
    final diff = DateTime.now().difference(status.lastUpdated);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    return 'il y a ${diff.inHours} h';
  }

  @override
  Widget build(BuildContext context) {
    final color = status.status.color;

    return AppCard(
      color: color.withValues(alpha: 0.10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(status.status.icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.status.label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  '${status.quartier}, ${status.commune}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  status.status == ZoneStatus.normal
                      ? 'Mis à jour $_timeAgo'
                      : '${status.reportCount} signalement(s) · $_timeAgo',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
