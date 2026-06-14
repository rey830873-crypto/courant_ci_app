import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'app_card.dart';

/// Carte de progression vers le badge "Sentinelle CIC" (CDC F4 : débloqué
/// après [AppConstants.sentinelReportThreshold] signalements valides).
/// Affichée sur l'écran Signaler et sur le Profil.
class SentinelProgressCard extends StatelessWidget {
  final int points;
  final bool isSentinel;

  const SentinelProgressCard({
    super.key,
    required this.points,
    required this.isSentinel,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (points / AppConstants.sentinelReportThreshold).clamp(0.0, 1.0);
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSentinel ? Icons.shield : Icons.shield_outlined,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSentinel ? 'Sentinelle CIC 🎉' : 'Deviens Sentinelle CIC',
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSentinel
                      ? '$points points · merci pour ta fiabilité !'
                      : '$points / ${AppConstants.sentinelReportThreshold} '
                          'points',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
