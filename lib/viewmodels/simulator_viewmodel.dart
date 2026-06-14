import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class SimulatorViewModel extends ChangeNotifier {
  double _kwh = 0;
  double _resultFcfa = 0;

  double get kwh => _kwh;
  double get resultFcfa => _resultFcfa;

  void calculate(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0;
    _kwh = parsed;
    // Utilise le tarif de base défini dans les constantes
    _resultFcfa = _kwh * AppConstants.estimatedKwhPriceFcfa;
    notifyListeners();
  }

  // Simulation par appareils (v1 simplifiée)
  final List<ApplianceSimulation> _appliances = [
    ApplianceSimulation(name: 'Climatiseur (1.5 CV)', watts: 1200, hoursPerDay: 8),
    ApplianceSimulation(name: 'Réfrigérateur', watts: 200, hoursPerDay: 24),
    ApplianceSimulation(name: 'Téléviseur LED', watts: 100, hoursPerDay: 5),
    ApplianceSimulation(name: 'Ampoule LED (x5)', watts: 50, hoursPerDay: 6),
  ];

  List<ApplianceSimulation> get appliances => _appliances;

  double get totalMonthlyKwh {
    return _appliances.fold(0, (sum, item) => sum + item.monthlyKwh);
  }

  double get totalMonthlyFcfa {
    return totalMonthlyKwh * AppConstants.estimatedKwhPriceFcfa;
  }

  void updateApplianceHours(int index, double hours) {
    _appliances[index].hoursPerDay = hours;
    notifyListeners();
  }
}

class ApplianceSimulation {
  final String name;
  final int watts;
  double hoursPerDay;

  ApplianceSimulation({
    required this.name,
    required this.watts,
    required this.hoursPerDay,
  });

  double get monthlyKwh => (watts * hoursPerDay * 30) / 1000;
}
