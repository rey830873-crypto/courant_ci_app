import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';
import 'main_screen.dart';

import 'forgot_password_view.dart';
import 'register_view.dart';

// --- PAGE 0: CONNEXION ---
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.cieOrange, AppTheme.backgroundDark],
            stops: [0.0, 0.4],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 80, color: Colors.white),
            const SizedBox(height: 10),
            const Text(
              "COURANT CI",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
            TextField(
              decoration: InputDecoration(
                hintText: "Identifiant ou N° Client",
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Mot de passe",
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Utiliser le ViewModel pour se connecter
                Provider.of<UserViewModel>(context, listen: false).login("Jean Marc");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: AppTheme.cieOrange,
                foregroundColor: Colors.white, // Texte en blanc
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              child: const Text("SE CONNECTER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordView()),
                );
              },
              child: const Text("Mot de passe oublié ?", style: TextStyle(color: AppTheme.cieOrange)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Nouveau ?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterView()),
                    );
                  },
                  child: const Text("Créer un compte", style: TextStyle(color: AppTheme.cieOrange, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
