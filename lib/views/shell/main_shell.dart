import 'package:flutter/material.dart';
import '../../core/router/main_shell_tab_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../map/map_screen.dart';
import '../meter/meter_screen.dart';
import '../profile/profile_screen.dart';
import '../report/report_screen.dart';

/// Conteneur du shell de navigation principal : affiche l'onglet actif
/// (Accueil, Carte, Compteur, Signaler, Profil) via un simple
/// [IndexedStack] géré localement, et la barre de navigation associée.
///
/// Volontairement indépendant de GoRouter pour cette partie : on a
/// remplacé `StatefulShellRoute.indexedStack` (qui provoquait des
/// reconstructions incohérentes du Navigator — `_dependents.isEmpty`,
/// `RenderObject.child == child` — lors d'un changement de thème ou de
/// la fermeture d'un dialogue) par un changement d'onglet en mémoire,
/// nettement plus simple et robuste pour 5 onglets fixes qui n'ont pas
/// besoin d'URL propre par onglet sur mobile. Les sous-écrans ouverts
/// "par-dessus" (Conseils, Simulateur, Agences) restent des routes
/// GoRouter classiques, ouvertes via `context.push(...)` — inchangé.
///
/// Pour permettre à un écran extérieur au shell de sélectionner un
/// onglet précis (ex: bouton "Signaler" depuis le Dashboard), voir
/// [mainShellTabRequest] / [requestTab] dans
/// `core/router/main_shell_tab_controller.dart`.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = MainShellTab.dashboard;

  static const _screens = [
    DashboardScreen(),
    MapScreen(),
    MeterScreen(),
    ReportScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    mainShellTabRequest.addListener(_onTabRequested);
  }

  @override
  void dispose() {
    mainShellTabRequest.removeListener(_onTabRequested);
    super.dispose();
  }

  void _onTabRequested() {
    if (!mounted) return;
    setState(() => _currentIndex = mainShellTabRequest.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Carte',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Compteur',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Signaler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
