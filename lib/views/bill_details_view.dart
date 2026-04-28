import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bill_model.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

// --- PAGE 5: DÉTAILS DE FACTURE ---
class BillDetailsView extends StatelessWidget {
  final Bill bill;

  const BillDetailsView({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Détails ${bill.id}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 32),
            _buildInfoSection("Période", bill.month),
            _buildInfoSection("Montant total", currencyFormat.format(bill.amount)),
            _buildInfoSection("Date d'échéance", DateFormat('dd MMMM yyyy', 'fr_FR').format(bill.dueDate)),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            if (bill.status != BillStatus.paid)
              ElevatedButton(
                onPressed: viewModel.isLoading ? null : () async {
                  await viewModel.payBill(bill.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Paiement effectué avec succès !")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                child: viewModel.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Payer maintenant"),
              )
            else
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 64),
                    const SizedBox(height: 16),
                    const Text("Cette facture est déjà payée", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    TextButton.icon(
                      onPressed: () {}, 
                      icon: const Icon(Icons.download), 
                      label: const Text("Télécharger le reçu"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bill.status == BillStatus.paid ? Colors.green.withOpacity(0.1) : AppTheme.cieOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            bill.status == BillStatus.paid ? Icons.verified : Icons.warning_amber_rounded,
            color: bill.status == BillStatus.paid ? Colors.green : AppTheme.cieOrange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Text(
            bill.status == BillStatus.paid ? "FACTURE RÉGLÉE" : "FACTURE À RÉGLER",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: bill.status == BillStatus.paid ? Colors.green : AppTheme.cieOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
