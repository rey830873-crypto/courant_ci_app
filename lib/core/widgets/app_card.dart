import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Carte standard utilisée dans tout le dashboard et les écrans CIC.
/// Donne une apparence cohérente (fond, bordure douce, coins arrondis)
/// sans avoir à répéter une [BoxDecoration] partout.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = color ??
        (isDark ? AppColors.surfaceDark : AppColors.surface);
    final border = isDark ? AppColors.borderDark : AppColors.border;

    final card = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}
