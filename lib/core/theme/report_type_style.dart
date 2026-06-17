import 'package:flutter/material.dart';
import '../../data/models/report_model.dart';
import 'app_colors.dart';

/// Icône/couleur associées à chaque type de signalement (F4), partagées
/// par l'écran Signaler et les listes de signalements récents (détail
/// commune, dashboard).
extension ReportTypeStyle on ReportType {
  IconData get icon {
    switch (this) {
      case ReportType.outage:
        return Icons.power_off_outlined;
      case ReportType.restored:
        return Icons.bolt;
      case ReportType.hazard:
        return Icons.warning_amber_rounded;
      case ReportType.other:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case ReportType.outage:
        return AppColors.primary;
      case ReportType.restored:
        return AppColors.success;
      case ReportType.hazard:
        return AppColors.danger;
      case ReportType.other:
        return AppColors.textSecondary;
    }
  }
}
