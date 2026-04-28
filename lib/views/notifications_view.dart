import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

// --- PAGE 8: NOTIFICATIONS ---
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: viewModel.notifications.isEmpty
          ? const Center(child: Text("Aucune notification"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.notifications.length,
              itemBuilder: (context, index) {
                final notification = viewModel.notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.cieOrange,
                      child: Icon(Icons.notifications, color: Colors.white),
                    ),
                    title: Text(notification['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification['body']),
                        const SizedBox(height: 4),
                        Text(notification['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
