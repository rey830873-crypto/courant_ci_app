import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

// --- PAGE 10: SIGNALEMENT D'INCIDENT ---
class IncidentsView extends StatelessWidget {
  const IncidentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Signaler un Incident")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionCard(
              context,
              "Signaler une coupure",
              "Signalez une interruption de service dans votre zone.",
              Icons.flash_off,
              () => _showReportDialog(context, "Coupure de courant"),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              "Danger / Poteau tombé",
              "Signalez un danger électrique ou un équipement endommagé.",
              Icons.warning_amber_rounded,
              () => _showReportDialog(context, "Équipement endommagé"),
            ),
            const SizedBox(height: 32),
            const Text("Mes Signalements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...viewModel.incidents.map((incident) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.history, color: AppTheme.cieOrange),
                title: Text(incident['type']),
                subtitle: Text("${incident['location']} - ${incident['date']}"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(incident['status'], style: const TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String desc, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cieOrange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.cieOrange, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, String type) {
    final locationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Signaler: $type"),
        content: TextField(
          controller: locationController,
          decoration: const InputDecoration(hintText: "Lieu de l'incident (ex: Marcory Zone 4)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              Provider.of<UserViewModel>(context, listen: false)
                  .reportIncident(type, locationController.text, "");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signalement envoyé")));
            }, 
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }
}
