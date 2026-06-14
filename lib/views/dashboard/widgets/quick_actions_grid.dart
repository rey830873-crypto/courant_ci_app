import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

/// Raccourcis vers les autres fonctionnalités cœur depuis l'accueil :
/// signaler une coupure (F4), consulter la carte (F1/F3), recharger le
/// compteur (F2) et revoir les conseils de prévention (F5).
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});


  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _ActionTile(
          icon: Icons.campaign_outlined,
          label: 'Signaler',
          onTap: () => context.go(AppRoutes.report),
        ),
        _ActionTile(
          icon: Icons.calculate_outlined,
          label: 'Simulateur',
          onTap: () => context.push(AppRoutes.simulator),
        ),
        _ActionTile(
          icon: Icons.add_card_outlined,
          label: 'Recharger',
          onTap: () => context.go(AppRoutes.meter),
        ),
        _ActionTile(
          icon: Icons.shield_outlined,
          label: 'Conseils',
          onTap: () => context.push(AppRoutes.tips),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

