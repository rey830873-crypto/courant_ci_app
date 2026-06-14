import 'package:flutter/material.dart';
import '../../data/models/zone_model.dart';
import 'app_colors.dart';

/// Code couleur/icône CIC pour le statut réseau (F1) : vert = normal,
/// orange = signalement en cours, rouge = coupure confirmée.
///
/// Partagé entre [ZoneStatusCard] (Dashboard) et les marqueurs de la
/// carte (F3) pour garantir une cohérence visuelle.
extension ZoneStatusStyle on ZoneStatus {
  Color get color {
    switch (this) {
      case ZoneStatus.normal:
        return AppColors.success;
      case ZoneStatus.possible:
      case ZoneStatus.probable:
        return AppColors.primary;
      case ZoneStatus.confirmed:
        return AppColors.danger;
    }
  }

  IconData get icon {
    switch (this) {
      case ZoneStatus.normal:
        return Icons.check_circle_outline;
      case ZoneStatus.possible:
      case ZoneStatus.probable:
        return Icons.error_outline;
      case ZoneStatus.confirmed:
        return Icons.power_off_outlined;
    }
  }
}
