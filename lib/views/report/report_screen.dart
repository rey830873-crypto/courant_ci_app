import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/report_type_style.dart';
import '../../core/theme/zone_status_style.dart';
import '../../data/models/zone_model.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/report_list_tile.dart';
import '../../core/widgets/sentinel_progress_card.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/report_model.dart';
import '../../viewmodels/report_viewmodel.dart';

/// Écran "Signaler" (F4) : signalement communautaire en un appui
/// (Coupure / Retour du courant / Danger), écrit en temps réel dans
/// Firestore et visible immédiatement par les autres utilisateurs de
/// la zone et sur la carte (F3).
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(ReportType type) async {
    final vm = context.read<ReportViewModel>();
    final description = _descriptionController.text.trim();

    await vm.submitReport(
      type,
      description: description.isEmpty ? null : description,
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (vm.status == ReportSubmissionStatus.success) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Merci ! Ton signalement a été envoyé à la communauté.'),
      ));
      _descriptionController.clear();
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(vm.errorMessage ?? 'Une erreur est survenue.'),
      ));
    }
    vm.resetStatus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final isSubmitting = vm.status == ReportSubmissionStatus.submitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Signaler')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (vm.zoneStatus != null) ...[
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${vm.quartier}, ${vm.commune}',
                              style: textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('Statut réseau actuel', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: vm.zoneStatus!.status.label,
                      color: vm.zoneStatus!.status.color,
                      icon: vm.zoneStatus!.status.icon,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text('Que se passe-t-il dans ta zone ?',
                style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Un appui suffit pour informer la communauté.',
                style: textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Ajouter un détail (optionnel)',
                hintText: 'Ex : coupure depuis ce matin, câble tombé...',
              ),
            ),
            const SizedBox(height: 16),
            if (!vm.canSubmit)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Limite de ${AppConstants.maxReportsPerHour} '
                          'signalements/heure atteinte. Réessaie un peu plus '
                          'tard.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _ReportTypeButton(
              type: ReportType.outage,
              subtitle: 'Le courant est coupé chez toi',
              onTap: isSubmitting ? null : () => _submit(ReportType.outage),
            ),
            const SizedBox(height: 10),
            _ReportTypeButton(
              type: ReportType.restored,
              subtitle: 'Le courant vient de revenir',
              onTap: isSubmitting ? null : () => _submit(ReportType.restored),
            ),
            const SizedBox(height: 10),
            _ReportTypeButton(
              type: ReportType.hazard,
              subtitle: 'Câble à terre, étincelles, fumée...',
              onTap: isSubmitting ? null : () => _submit(ReportType.hazard),
            ),
            const SizedBox(height: 24),
            SentinelProgressCard(points: vm.cicPoints, isSentinel: vm.isSentinel),
            const SizedBox(height: 24),
            Text('Signalements récents dans ta zone',
                style: textTheme.titleMedium),
            const SizedBox(height: 4),
            if (vm.recentReports.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Aucun signalement pour le moment. Sois le premier à '
                  'informer ton quartier !',
                  style: textTheme.bodyMedium,
                ),
              )
            else
              ...vm.recentReports
                  .map((report) => ReportListTile(report: report)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ReportTypeButton extends StatelessWidget {
  final ReportType type;
  final String subtitle;
  final VoidCallback? onTap;

  const _ReportTypeButton({
    required this.type,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(type.icon, color: type.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label, style: textTheme.titleSmall),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
