import 'package:flutter/material.dart';

/// Variantes visuelles du [PrimaryButton].
enum PrimaryButtonVariant { filled, outlined, text }

/// Bouton standard CIC : gère un état de chargement et une icône optionnelle.
/// S'appuie sur les thèmes définis dans [AppTheme] (couleurs/formes déjà
/// configurées globalement).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final PrimaryButtonVariant variant;
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = PrimaryButtonVariant.filled,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == PrimaryButtonVariant.filled
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final onTap = isLoading ? null : onPressed;

    Widget button;
    switch (variant) {
      case PrimaryButtonVariant.filled:
        button = ElevatedButton(onPressed: onTap, child: child);
        break;
      case PrimaryButtonVariant.outlined:
        button = OutlinedButton(onPressed: onTap, child: child);
        break;
      case PrimaryButtonVariant.text:
        button = TextButton(onPressed: onTap, child: child);
        break;
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
