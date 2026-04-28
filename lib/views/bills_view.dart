import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../widgets/bill_card.dart';

// --- PAGE 2: LISTE DES FACTURES ---
class BillsView extends StatelessWidget {
  const BillsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Factures"),
        centerTitle: true,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.bills.isEmpty) {
            return const Center(
              child: Text("Aucune facture pour le moment"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: viewModel.bills.length,
            itemBuilder: (context, index) {
              final bill = viewModel.bills[index];
              return BillCard(
                bill: bill,
                onTap: () {
                  // Action pour voir les détails si besoin
                },
              );
            },
          );
        },
      ),
    );
  }
}
