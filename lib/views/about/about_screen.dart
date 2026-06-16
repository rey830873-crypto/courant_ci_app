import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';

/// Écran "À propos" : présente le projet CourantInfo CI, ses
/// fonctionnalités phares, et les informations de version.
///
/// Accessible depuis le profil (demande explicite : enrichir l'écran
/// profil avec une vraie section "À propos" plutôt que les deux lignes
/// minimales nom + slogan affichées jusqu'ici en bas de cet écran).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded,
                    size: 36, color: AppColors.onPrimary),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                AppConstants.appName,
                style: textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                AppConstants.appSlogan,
                textAlign: TextAlign.center,
                style:
                    textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 28),
            Text('Notre mission', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            AppCard(
              child: Text(
                '${AppConstants.appShortName} aide les habitants d\'Abidjan '
                'à anticiper les coupures de courant grâce aux signalements '
                'de la communauté, à protéger leurs appareils dès qu\'une '
                'coupure est annoncée, et à suivre leur consommation '
                'électrique au quotidien pour mieux gérer leur compteur '
                'prépayé.',
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
            Text('Comment ça marche', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            const AppCard(
              child: Column(
                children: [
                  _FeatureRow(
                    icon: Icons.campaign_outlined,
                    title: 'Signalements communautaires',
                    description:
                        'Chaque coupure signalée par un utilisateur aide à '
                        'estimer en temps réel l\'état du réseau dans ta '
                        'zone.',
                  ),
                  Divider(height: 28),
                  _FeatureRow(
                    icon: Icons.map_outlined,
                    title: 'Carte en direct',
                    description:
                        'Visualise les zones en coupure, possibles ou '
                        'normales, commune par commune.',
                  ),
                  Divider(height: 28),
                  _FeatureRow(
                    icon: Icons.bolt_outlined,
                    title: 'Suivi du compteur prépayé',
                    description:
                        'Enregistre tes relevés de solde pour suivre ta '
                        'consommation et anticiper les recharges.',
                  ),
                  Divider(height: 28),
                  _FeatureRow(
                    icon: Icons.shield_outlined,
                    title: 'Conseils de prévention',
                    description:
                        'Des gestes simples pour protéger tes appareils '
                        'avant, pendant et après une coupure.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Informations', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _InfoLine(label: 'Application', value: AppConstants.appName),
                  const Divider(height: 24),
                  const _InfoLine(label: 'Version', value: '1.0.0'),
                  const Divider(height: 24),
                  const _InfoLine(label: 'Zone couverte', value: 'Grand Abidjan'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Fait avec soin pour la communauté de Côte d\'Ivoire 🇨🇮',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(description,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
