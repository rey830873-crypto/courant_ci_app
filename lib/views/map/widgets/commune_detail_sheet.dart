import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/router/main_shell_tab_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/zone_status_style.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/report_list_tile.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/report_model.dart';
import '../../../data/models/zone_model.dart';
import '../../../data/repositories/report_repository.dart';

/// Bottom sheet affiché au tap sur un marqueur de la carte (F3) :
/// statut réseau en temps réel de la commune, signalements récents
/// (toutes zones de la commune) et accès rapide à l'écran Signaler.
class CommuneDetailSheet extends StatelessWidget {
  final Commune commune;
  final ZoneStatusInfo status;

  const CommuneDetailSheet({
    super.key,
    required this.commune,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final reportRepo = context.read<ReportRepository>();
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(commune.name, style: textTheme.headlineSmall),
                    ),
                    StatusChip(
                      label: status.status.label,
                      color: status.status.color,
                      icon: status.status.icon,
                    ),
                  ],
                ),
              ),
              if (status.status != ZoneStatus.normal)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${status.reportCount} signalement(s) actif(s)',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ),
              if (status.hasRecentHazard)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Danger électrique signalé récemment dans cette '
                            'commune.',
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<ReportModel>>(
                  stream: reportRepo.watchRecentReportsForCommune(commune.name),
                  builder: (context, snapshot) {
                    final reports = snapshot.data ?? const [];
                    if (reports.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Aucun signalement récent dans cette commune.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: reports.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          ReportListTile(report: reports[index]),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: PrimaryButton(
                  label: 'Signaler dans cette zone',
                  icon: Icons.campaign_outlined,
                  onPressed: () {
                    Navigator.of(context).pop();
                    requestTab(MainShellTab.report);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
