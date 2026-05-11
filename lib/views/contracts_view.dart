import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

// --- PAGE 7: MES CONTRATS ---
class ContractsView extends StatelessWidget {
  const ContractsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: viewModel.contracts.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.bolt, color: AppTheme.cieOrange),
              title: Text(viewModel.contracts[index]),
              subtitle: const Text("CIE - Basse Tension"),
              trailing: const Icon(Icons.more_vert),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.cieOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
