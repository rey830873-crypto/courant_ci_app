import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../viewmodels/user_viewmodel.dart';
import 'login_view.dart';
import 'register_view.dart';
import 'main_screen.dart';

class P02LandingPage extends StatelessWidget {
  const P02LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: AppTheme.cieOrange.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bolt_rounded, size: 60, color: AppTheme.cieOrange),
                const SizedBox(height: 30),
                const Text(
                  "Bienvenue sur\nCourantInfo CI",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Gérez votre électricité en toute simplicité. Suivez votre consommation, payez vos factures et signalez vos incidents en un clic.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: AppTheme.cieOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("SE CONNECTER", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterView()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    side: const BorderSide(color: AppTheme.cieOrange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "CRÉER UN COMPTE",
                    style: TextStyle(color: AppTheme.cieOrange, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Provider.of<UserViewModel>(context, listen: false).login("Invité", asGuest: true);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                    child: const Text(
                      "Continuer en tant qu'invité",
                      style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
