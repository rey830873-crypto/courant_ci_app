import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';
import '../widgets/bill_card.dart';
import 'bill_details_view.dart';
import 'topup_view.dart';
import 'consumption_view.dart';
import 'simulator_view.dart';
import 'agencies_view.dart';
import 'help_support_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.bills.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.cieOrange),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.cieOrange, Color(0xFFFF8C33)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "⚡ COMPTE RÉSIDENTIEL",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Bonjour, ${viewModel.userName}",
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "N° Client: ${viewModel.userNumber}",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(context, viewModel, currencyFormat, isDark),
                      const SizedBox(height: 24),
                      const Text("Actions rapides", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      const Text("Services CIE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildServiceGrid(context, isDark),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Factures Récentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => viewModel.setNavIndex(1),
                            child: const Text("Voir tout", style: TextStyle(color: AppTheme.cieOrange)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...viewModel.bills.take(2).map((bill) => BillCard(
                        bill: bill,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BillDetailsView(bill: bill))),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showGuestRestriction(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Accès Limité"),
        content: const Text("Veuillez créer un compte ou vous connecter pour accéder à cette fonctionnalité."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Rediriger vers l'inscription
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cieOrange),
            child: const Text("S'INSCRIRE"),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, UserViewModel viewModel, NumberFormat format, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: AppTheme.cieOrange.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Solde disponible", style: TextStyle(color: Colors.grey)),
          Text(
            viewModel.isGuest ? "--- FCFA" : format.format(viewModel.balance),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.cieOrange),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              if (viewModel.isGuest) {
                _showGuestRestriction(context);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TopUpView()));
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("RECHARGER MON COMPTE"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(context, Icons.bar_chart, "Conso.", () {
          if (viewModel.isGuest) {
            _showGuestRestriction(context);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsumptionView()));
          }
        }),
        _buildActionButton(context, Icons.calculate_outlined, "Simul.", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SimulatorView()))),
        _buildActionButton(context, Icons.receipt_long, "Factures", () {
          if (viewModel.isGuest) {
            _showGuestRestriction(context);
          } else {
            viewModel.setNavIndex(1);
          }
        }),
        _buildActionButton(context, Icons.map_outlined, "Agences", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgenciesView()))),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppTheme.cieOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: AppTheme.cieOrange),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildServiceGrid(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildServiceCard(context, "Aide & Support", Icons.help_outline, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportView())), isDark),
        _buildServiceCard(context, "Conseils CIE", Icons.lightbulb_outline, () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Section Conseils bientôt disponible")));
        }, isDark),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.cieOrange, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
