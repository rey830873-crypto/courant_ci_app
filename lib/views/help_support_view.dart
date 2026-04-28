import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// --- PAGE 19: AIDE & SUPPORT ---
class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aide & Support")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Comment pouvons-nous vous aider ?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildFAQItem("Comment payer ma facture ?", "Vous pouvez payer via Orange Money, Wave ou Moov Money dans l'onglet 'Factures'."),
          _buildFAQItem("Où trouver mon numéro client ?", "Votre numéro client est indiqué en haut à gauche de vos factures papier."),
          _buildFAQItem("Ma recharge n'apparaît pas ?", "Le délai de traitement peut aller jusqu'à 5 minutes. Si le problème persiste, contactez le 179."),
          const SizedBox(height: 30),
          const Text("Nous contacter", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ListTile(
            leading: const Icon(Icons.phone, color: AppTheme.cieOrange),
            title: const Text("Centre d'appel (179)"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: AppTheme.cieOrange),
            title: const Text("support@cie.ci"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
