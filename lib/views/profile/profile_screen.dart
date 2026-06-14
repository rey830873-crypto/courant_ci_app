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
import '../../viewmodels/report_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

/// Profil : récapitule la zone et le compteur enregistrés, le mode
/// d'accès (invité/inscrit), le plan CIC et les préférences d'affichage.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final reportVM = context.watch<ReportViewModel>();

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
                        session.isRegistered
                            ? 'Compte vérifié'
                            : 'Mode invité',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
          Text('Ma zone', style: Theme.of(context).textTheme.titleSmall),
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
          ),
          const SizedBox(height: 24),
          Text('Préférences', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: themeVM.isDark,
              onChanged: (_) => themeVM.toggle(),
              title: const Text('Mode sombre'),
              secondary: Icon(
                themeVM.isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
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
                    'Sauvegarde ton profil et débloque la recharge directe '
                    'de compteur (F8) et l\'historique complet.',
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
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} (${AppConstants.appShortName})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appSlogan,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
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
      ],
    );
  }
}
