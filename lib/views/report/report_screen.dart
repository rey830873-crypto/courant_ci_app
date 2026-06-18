import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/report_type_style.dart';
import '../../core/theme/zone_status_style.dart';
import '../../data/models/zone_model.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
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
  final _otherDescriptionController = TextEditingController();
  bool _showOtherField = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _otherDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(ReportType type, {String? description}) async {
    final vm = context.read<ReportViewModel>();
    final effectiveDescription =
        description ?? _descriptionController.text.trim();

    await vm.submitReport(
      type,
      description:
          effectiveDescription.isEmpty ? null : effectiveDescription,
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (vm.status == ReportSubmissionStatus.success) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Merci ! Ton signalement a été envoyé à la communauté.'),
      ));
      _descriptionController.clear();
      _otherDescriptionController.clear();
      setState(() => _showOtherField = false);
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(vm.errorMessage ?? 'Une erreur est survenue.'),
      ));
    }
    vm.resetStatus();
  }

  /// "Autre" exige une précision (un signalement sans aucun détail ne
  /// dirait rien à la communauté) — contrairement aux 3 autres types,
  /// auto-explicites par leur seul libellé.
  Future<void> _submitOther() async {
    final description = _otherDescriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Précise de quoi il s\'agit avant d\'envoyer.'),
      ));
      return;
    }
    await _submit(ReportType.other, description: description);
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
                          Text(vm.zoneStatus!.status.description,
                              style: textTheme.bodySmall),
                          if (vm.zoneStatus!.reportCount > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${vm.zoneStatus!.reportCount} signalement'
                              '${vm.zoneStatus!.reportCount > 1 ? 's' : ''} '
                              'dans les dernières heures',
                              style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
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
            if (vm.requiresAccount)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCard(
                  color: AppColors.primaryLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_outline,
                              color: AppColors.primaryDark, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Crée un compte pour signaler',
                              style: textTheme.titleSmall
                                  ?.copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Les signalements demandent un compte vérifié, pour '
                        'que la communauté puisse s\'y fier.',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Créer un compte',
                        icon: Icons.person_add_alt,
                        onPressed: () => context.push(AppRoutes.register),
                      ),
                    ],
                  ),
                ),
              )
            else if (!vm.canSubmit)
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
              onTap: (isSubmitting || vm.requiresAccount)
                  ? null
                  : () => _submit(ReportType.outage),
            ),
            const SizedBox(height: 10),
            _ReportTypeButton(
              type: ReportType.restored,
              subtitle: 'Le courant vient de revenir',
              onTap: (isSubmitting || vm.requiresAccount)
                  ? null
                  : () => _submit(ReportType.restored),
            ),
            const SizedBox(height: 10),
            _ReportTypeButton(
              type: ReportType.hazard,
              subtitle: 'Câble à terre, étincelles, fumée...',
              onTap: (isSubmitting || vm.requiresAccount)
                  ? null
                  : () => _submit(ReportType.hazard),
            ),
            const SizedBox(height: 10),
            _ReportTypeButton(
              type: ReportType.other,
              subtitle: 'Précise de quoi il s\'agit',
              onTap: (isSubmitting || vm.requiresAccount)
                  ? null
                  : () => setState(() => _showOtherField = !_showOtherField),
            ),
            if (_showOtherField) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _otherDescriptionController,
                autofocus: true,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'De quoi s\'agit-il ?',
                  hintText: 'Ex : poteau penché, transformateur qui grésille...',
                ),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Envoyer ce signalement',
                isLoading: isSubmitting,
                onPressed: _submitOther,
              ),
            ],
            const SizedBox(height: 24),
            SentinelProgressCard(
              points: vm.cicPoints,
              isSentinel: vm.isSentinel,
              requiresAccount: vm.requiresAccount,
            ),
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
