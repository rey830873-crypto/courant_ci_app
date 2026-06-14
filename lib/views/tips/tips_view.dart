import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';

class TipsView extends StatelessWidget {
  const TipsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conseils CIE'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TipSection(
            title: 'Économie d\'Énergie',
            tips: [
              _TipItem(
                icon: Icons.lightbulb_outline,
                title: 'Éclairage LED',
                description: 'Remplacez vos ampoules à incandescence par des LED. Elles consomment 80% moins d\'énergie.',
              ),
              _TipItem(
                icon: Icons.ac_unit,
                title: 'Climatisation à 24°C',
                description: 'Maintenez votre clim à 24°C. Chaque degré en moins augmente votre consommation de 7%.',
              ),
            ],
          ),
          SizedBox(height: 24),
          _TipSection(
            title: 'Sécurité Électrique',
            tips: [
              _TipItem(
                icon: Icons.warning_amber_rounded,
                title: 'Installations Vétustes',
                description: 'Faites vérifier vos installations par un professionnel agréé CIE tous les 10 ans.',
              ),
              _TipItem(
                icon: Icons.power_off,
                title: 'En cas d\'orage',
                description: 'Débranchez vos appareils sensibles (TV, PC) pour éviter les dommages liés à la foudre.',
              ),
            ],
          ),
          SizedBox(height: 24),
          _TipSection(
            title: 'Le saviez-vous ?',
            tips: [
              _TipItem(
                icon: Icons.info_outline,
                title: 'Appareils en veille',
                description: 'Les appareils en veille peuvent représenter jusqu\'à 10% de votre facture annuelle.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipSection extends StatelessWidget {
  final String title;
  final List<_TipItem> tips;

  const _TipSection({required this.title, required this.tips});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        ...tips,
      ],
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _TipItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
