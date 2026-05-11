import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

import 'payment_history_view.dart';
import 'incidents_view.dart';
import 'settings_view.dart';
import 'help_support_view.dart';
import 'edit_profile_view.dart';
import 'login_view.dart';

// --- PAGE 3: PROFIL UTILISATEUR ---
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.cieOrange,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Numéro client: ${viewModel.userNumber}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildProfileItem(Icons.person_outline, "Modifier le profil", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileView()));
            }),
            _buildProfileItem(Icons.settings, "Paramètres", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsView()));
            }),
            _buildProfileItem(Icons.history, "Historique des paiements", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentHistoryView()));
            }),
            _buildProfileItem(Icons.report_problem_outlined, "Signaler un incident", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const IncidentsView()));
            }),
            _buildProfileItem(Icons.help_outline, "Aide & Support", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportView()));
            }),
            const SizedBox(height: 20),
            _buildProfileItem(Icons.logout, "Déconnexion", () {
              viewModel.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            }, textColor: Colors.red, iconColor: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {Color? textColor, Color? iconColor}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.cieOrange),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
