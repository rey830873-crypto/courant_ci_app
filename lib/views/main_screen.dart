import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';
import 'dashboard_view.dart';
import 'bills_view.dart';
import 'consumption_view.dart';
import 'contracts_view.dart';
import 'profile_view.dart';
import 'notifications_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);

    // Liste des pages pour la navigation
    final List<Widget> pages = [
      const DashboardView(),    // PAGE 1: ACCUEIL
      const BillsView(),        // PAGE 2: FACTURES
      const ConsumptionView(),  // PAGE 6: CONSOMMATION
      const ContractsView(),    // PAGE 7: CONTRATS
      const ProfileView(),      // PAGE 3: PROFIL
    ];

    return Scaffold(
      appBar: viewModel.currentNavIndex == 0 ? null : AppBar(
        title: Text(_getTitle(viewModel.currentNavIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsView()), // PAGE 8
            ),
          ),
        ],
      ),
      body: pages[viewModel.currentNavIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.currentNavIndex,
        onTap: (index) => viewModel.setNavIndex(index),
        selectedItemColor: AppTheme.cieOrange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceDark,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Factures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Conso.',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.electric_bolt_rounded),
            label: 'Contrats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 1: return "Mes Factures";
      case 2: return "Consommation";
      case 3: return "Mes Contrats";
      case 4: return "Mon Profil";
      default: return "CIE Courant";
    }
  }
}
