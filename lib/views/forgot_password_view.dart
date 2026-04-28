import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// --- PAGE 16: MOT DE PASSE OUBLIÉ ---
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Récupération")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(Icons.lock_reset, size: 80, color: AppTheme.cieOrange),
            const SizedBox(height: 30),
            const Text(
              "Entrez votre email ou numéro client pour recevoir un lien de réinitialisation.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              decoration: InputDecoration(
                hintText: "Email ou N° Client",
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lien envoyé par SMS/Email")),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
              child: const Text("ENVOYER LE LIEN"),
            ),
          ],
        ),
      ),
    );
  }
}
