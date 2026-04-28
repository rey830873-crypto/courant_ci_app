import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../viewmodels/user_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: ListView(
        children: [
          _buildSectionTitle("Compte"),
          _buildSettingItem(Icons.notifications_active_outlined, "Notifications", true),
          _buildSettingItem(Icons.fingerprint, "Authentification biométrique", true),
          _buildSectionTitle("Préférences"),
          Consumer<UserViewModel>(
            builder: (context, vm, child) => ListTile(
              leading: const Icon(Icons.dark_mode_outlined, color: Colors.grey),
              title: const Text("Mode sombre"),
              trailing: Switch(
                value: vm.isDarkMode,
                onChanged: (v) => vm.toggleTheme(),
                activeThumbColor: AppTheme.cieOrange,
              ),
            ),
          ),
          _buildSettingItem(Icons.language, "Langue", false, trailingText: "Français"),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: () {},
              child: const Text("Supprimer mon compte", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(title, style: const TextStyle(color: AppTheme.cieOrange, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, bool isSwitch, {String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: isSwitch 
        ? Switch(value: true, onChanged: (v) {}, activeThumbColor: AppTheme.cieOrange)
        : Text(trailingText ?? "", style: const TextStyle(color: Colors.grey)),
    );
  }
}
