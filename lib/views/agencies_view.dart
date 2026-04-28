import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// --- PAGE 12: AGENCES CIE ---
class AgenciesView extends StatelessWidget {
  const AgenciesView({super.key});

  final List<Map<String, String>> agencies = const [
    {"name": "Agence Cocody-Angré", "address": "Boulevard Latrille", "hours": "08h - 16h30"},
    {"name": "Agence Marcory", "address": "Près du Grand Marché", "hours": "08h - 16h30"},
    {"name": "Agence Yopougon", "address": "Quartier Selmer", "hours": "08h - 17h00"},
    {"name": "Agence Plateau", "address": "Avenue Houdaille", "hours": "07h30 - 16h00"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nos Agences")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: agencies.length,
        itemBuilder: (context, index) {
          final agency = agencies[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.cieOrange,
                child: Icon(Icons.location_on, color: Colors.white),
              ),
              title: Text(agency['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(agency['address']!),
                  Text("Ouvert: ${agency['hours']}", style: const TextStyle(fontSize: 12, color: AppTheme.cieOrange)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.directions, color: Colors.blue),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
