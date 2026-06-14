import 'package:flutter/material.dart';

/// Palette officielle CourantInfo CI (CIC) — voir CDC section 4.1.
/// Les couleurs "brand" sont fixes (logo, alertes, identité).
/// Les couleurs "semantic" s'adaptent entre le thème clair et sombre.
class AppColors {
  AppColors._();

  // --- Couleurs de marque CIC (fixes, mêmes en clair et sombre) ---
  static const Color primary = Color(0xFFF5A623); // Orange Principal
  static const Color primaryDark = Color(0xFFD4881A); // Orange Foncé
  static const Color primaryLight = Color(0xFFFEF3CD); // Orange Clair
  static const Color success = Color(0xFF1DBF6B); // Vert Confirmation
  static const Color danger = Color(0xFFE8443A); // Rouge Alerte

  // Couleur du texte/icônes posés sur un fond `primary` (orange vif).
  // Un texte sombre est plus lisible qu'un blanc sur cet orange.
  static const Color onPrimary = softBlack;

  // --- Mode clair ---
  static const Color white = Color(0xFFFFFFFF); // Blanc
  static const Color offWhite = Color(0xFFFFF9EF); // Blanc Cassé
  static const Color softBlack = Color(0xFF1A1A1A); // Noir Doux

  static const Color background = white;
  static const Color surface = offWhite;
  static const Color textPrimary = softBlack;
  static const Color textSecondary = Color(0xFF80766A);
  static const Color border = Color(0xFFEFE6D8);

  // --- Mode sombre (dérivées de la palette CIC) ---
  static const Color backgroundDark = Color(0xFF15120D);
  static const Color surfaceDark = Color(0xFF231D14);
  static const Color textPrimaryDark = Color(0xFFFBF6EE);
  static const Color textSecondaryDark = Color(0xFFB9AD9C);
  static const Color borderDark = Color(0xFF3A3022);
}
