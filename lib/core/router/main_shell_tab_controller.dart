import 'package:flutter/material.dart';

/// Index des 5 onglets du shell principal, dans l'ordre où ils
/// apparaissent dans [MainShell._screens] / la barre de navigation.
class MainShellTab {
  MainShellTab._();

  static const int dashboard = 0;
  static const int map = 1;
  static const int meter = 2;
  static const int report = 3;
  static const int profile = 4;
}

/// Notifie [MainShell] de l'onglet à afficher, depuis n'importe quel
/// écran extérieur au shell.
///
/// Remplace les anciens `context.go(AppRoutes.report)` /
/// `context.go(AppRoutes.meter)`, qui fonctionnaient avec
/// `StatefulShellRoute` mais n'ont plus de route GoRouter équivalente
/// depuis que le shell utilise un [IndexedStack] interne (voir
/// `app_router.dart`). Utilisation : si l'écran courant est déjà dans
/// le shell (Dashboard, Carte...), `requestTab(MainShellTab.report)`
/// suffit. Si l'écran courant est hors du shell (ex: une bottom sheet
/// poussée par-dessus la Carte), appeler aussi
/// `context.go(AppRoutes.dashboard)` avant/après pour s'assurer que le
/// shell est bien à l'écran.
final ValueNotifier<int> mainShellTabRequest =
    ValueNotifier<int>(MainShellTab.dashboard);

void requestTab(int index) {
  mainShellTabRequest.value = index;
}
