import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill_model.dart';
import '../core/app_theme.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback onTap;

  const BillCard({super.key, required this.bill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bill.status == BillStatus.paid 
                ? Colors.green.withOpacity(0.1) 
                : AppTheme.cieOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            bill.status == BillStatus.paid ? Icons.check_circle : Icons.receipt_long,
            color: bill.status == BillStatus.paid ? Colors.green : AppTheme.cieOrange,
          ),
        ),
        title: Text(
          bill.month,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Échéance: ${DateFormat('dd/MM/yyyy').format(bill.dueDate)}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(bill.amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              bill.status == BillStatus.paid ? "Payée" : "À payer",
              style: TextStyle(
                color: bill.status == BillStatus.paid ? Colors.green : AppTheme.cieOrange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
