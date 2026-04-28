import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// --- PAGE 11: SIMULATEUR DE CONSOMMATION ---
class SimulatorView extends StatefulWidget {
  const SimulatorView({super.key});

  @override
  State<SimulatorView> createState() => _SimulatorViewState();
}

class _SimulatorViewState extends State<SimulatorView> {
  double _kwh = 0;
  double _result = 0;

  void _calculate() {
    setState(() {
      // Calcul simplifié (ex: 75 FCFA par KWh)
      _result = _kwh * 75;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulateur")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Estimez le montant de votre consommation en saisissant votre index actuel.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Index KWh",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
              onChanged: (value) {
                _kwh = double.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.cieOrange,
              ),
              child: const Text("CALCULER"),
            ),
            if (_result > 0) ...[
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cieOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cieOrange),
                ),
                child: Column(
                  children: [
                    const Text("Estimation Facture", style: TextStyle(fontSize: 16)),
                    Text(
                      "${_result.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.cieOrange),
                    ),
                    const Text("(Hors taxes et redevances)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
