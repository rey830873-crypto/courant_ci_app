import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/sentinel_progress_card.dart';
import '../../data/models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';

/// Profil : récapitule la zone et le compteur enregistrés, le mode
/// d'accès (invité/inscrit), le plan CIC et les préférences d'affichage.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final reportVM = context.watch<ReportViewModel>();
    final displayName = context.watch<UserViewModel>().currentUser?.displayName;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    session.isRegistered
                        ? Icons.person
                        : Icons.person_outline,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (session.isRegistered && displayName != null)
                            ? displayName
                            : (session.isRegistered
                                ? 'Compte vérifié'
                                : 'Mode invité'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (session.isRegistered && displayName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Compte vérifié',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        SubscriptionPlan.free.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Ma zone',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              TextButton.icon(
                onPressed: () => _editZone(context, session),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Modifier'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Commune',
                  value: session.commune ?? '—',
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.map_outlined,
                  label: 'Quartier',
                  value: session.quartier ?? '—',
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Compteur',
                  value: session.meterNumber ?? 'Non renseigné',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.textSecondary),
                    onPressed: () => _editMeterNumber(context, session),
                    tooltip: 'Modifier le numéro de compteur',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Mes contributions', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SentinelProgressCard(
            points: reportVM.cicPoints,
            isSentinel: reportVM.isSentinel,
            requiresAccount: reportVM.requiresAccount,
          ),
          const SizedBox(height: 24),
          Text('Préférences', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Affichage',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Clair'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Sombre'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.settings_suggest_outlined),
                        label: Text('Système'),
                      ),
                    ],
                    selected: {themeVM.themeMode},
                    onSelectionChanged: (selection) =>
                        themeVM.setThemeMode(selection.first),
                  ),
                ],
              ),
            ),
          ),
          if (session.isGuest) ...[
            const SizedBox(height: 24),
            AppCard(
              color: AppColors.primaryLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passe en compte vérifié',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sauvegarde ton profil et débloque les signalements '
                    'communautaires et le suivi de ta consommation.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Créer un compte',
                    icon: Icons.person_add_alt,
                    onPressed: () => context.push(AppRoutes.register),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Plus', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.info_outline,
                  color: AppColors.primaryDark),
              title: const Text('À propos'),
              subtitle: Text(
                'Notre mission, nos fonctionnalités, la version',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.about),
            ),
          ),
          if (session.isRegistered) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () => _confirmSignOut(context),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Dialogue de modification de la zone (commune + quartier).
Future<void> _editZone(
    BuildContext context, SessionViewModel session) async {
  String? selectedCommune = session.commune;
  String? selectedQuartier = session.quartier;

  final communes = AppConstants.abidjanCommunes;
  List<String> availableQuartiers = selectedCommune != null
      ? communes
          .firstWhere((c) => c.name == selectedCommune,
              orElse: () => communes.first)
          .quartiers
      : [];

  await showDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text('Modifier ma zone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCommune,
                decoration: const InputDecoration(labelText: 'Commune'),
                items: communes
                    .map((c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  setDialogState(() {
                    selectedCommune = v;
                    selectedQuartier = null;
                    availableQuartiers = communes
                        .firstWhere((c) => c.name == v)
                        .quartiers;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: availableQuartiers.contains(selectedQuartier)
                    ? selectedQuartier
                    : null,
                decoration: const InputDecoration(labelText: 'Quartier'),
                items: availableQuartiers
                    .map((q) => DropdownMenuItem(
                          value: q,
                          child: Text(q),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedQuartier = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: (selectedCommune != null && selectedQuartier != null)
                  ? () async {
                      Navigator.of(ctx).pop();
                      await session.updateZone(
                        commune: selectedCommune!,
                        quartier: selectedQuartier!,
                      );
                    }
                  : null,
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    ),
  );
}

/// Dialogue de modification du numéro de compteur.
Future<void> _editMeterNumber(
    BuildContext context, SessionViewModel session) async {
  final controller =
      TextEditingController(text: session.meterNumber ?? '');

  await showDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Numéro de compteur'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Numéro de compteur CIE',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () async {
            final value = controller.text.trim();
            Navigator.of(ctx).pop();
            if (value.isNotEmpty) {
              await session.updateMeterNumber(value);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );

  controller.dispose();
}

/// Demande confirmation avant de déconnecter — une action qui ramène
/// directement à l'écran "Créer un compte / Invité" ne doit pas pouvoir
/// se déclencher par un appui accidentel.
Future<void> _confirmSignOut(BuildContext context) async {
  final authVM = context.read<AuthViewModel>();

  final confirmed = await showDialog<bool>(
    context: context,
    useRootNavigator: false,
    builder: (context) => AlertDialog(
      title: const Text('Se déconnecter ?'),
      content: const Text(
        'Tu pourras te reconnecter à tout moment avec ton numéro de '
        'téléphone. Ta zone et ton compteur resteront enregistrés sur '
        'cet appareil.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Se déconnecter',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await authVM.signOut();
  }
}
