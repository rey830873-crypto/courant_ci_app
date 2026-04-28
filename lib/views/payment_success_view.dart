import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// --- PAGE 17: SUCCÈS DE PAIEMENT ---
class PaymentSuccessView extends StatelessWidget {
  final String amount;
  const PaymentSuccessView({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              const SizedBox(height: 30),
              const Text(
                "Paiement Réussi !",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Votre paiement de $amount a été traité avec succès.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: AppTheme.cieOrange,
                ),
                child: const Text("RETOUR À L'ACCUEIL"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
