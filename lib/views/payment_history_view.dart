import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

// --- PAGE 9: HISTORIQUE DES PAIEMENTS ---
class PaymentHistoryView extends StatelessWidget {
  const PaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Historique des Paiements")),
      body: viewModel.paymentHistory.isEmpty
          ? const Center(child: Text("Aucun historique de paiement"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.paymentHistory.length,
              itemBuilder: (context, index) {
                final payment = viewModel.paymentHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(payment['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${payment['date']} - via ${payment['method']}"),
                    trailing: Text(
                      currencyFormat.format(payment['amount']),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
