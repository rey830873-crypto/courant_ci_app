import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

// --- PAGE 4: RECHARGEMENT ---
class TopUpView extends StatefulWidget {
  const TopUpView({super.key});

  @override
  State<TopUpView> createState() => _TopUpViewState();
}

class _TopUpViewState extends State<TopUpView> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = "Orange Money";

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Recharger mon compte")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Montant à recharger", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ex: 5000",
                suffixText: "FCFA",
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Méthode de paiement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildPaymentMethod("Orange Money", Icons.phone_android, Colors.orange),
            _buildPaymentMethod("MTN MoMo", Icons.phone_android, Colors.yellow[700]!),
            _buildPaymentMethod("Wave", Icons.waves, Colors.blue),
            const Spacer(),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () async {
                if (_amountController.text.isNotEmpty) {
                  await viewModel.topUp(double.parse(_amountController.text));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Rechargement réussi !"), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
              child: viewModel.isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("Confirmer le rechargement"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String name, IconData icon, Color color) {
    bool isSelected = _selectedMethod == name;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.cieOrange : (isDark ? Colors.transparent : Colors.grey.withOpacity(0.2)),
            width: 2,
          ),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected) 
              const Icon(Icons.check_circle, color: AppTheme.cieOrange)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
