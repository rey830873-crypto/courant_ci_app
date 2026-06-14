import 'dart:convert';

class ApiService {
  // Simule une base de données de factures
  final String _mockBillsJson = '''
  [
    {"id": "INV-2024-001", "month": "Janvier 2024", "amount": 25400, "status": "unpaid", "dueDate": "2024-02-15"},
    {"id": "INV-2023-012", "month": "Décembre 2023", "amount": 18200, "status": "paid", "dueDate": "2024-01-15"}
  ]
  ''';

  // Simule une base de données d'agences CIE
  final String _mockAgenciesJson = '''
  [
    {"id": "AG-001", "name": "Agence Cocody-Angré", "commune": "Cocody", "address": "Boulevard du 8ème arrondissement", "phone": "2722400000", "latitude": 5.3940, "longitude": -3.9770},
    {"id": "AG-002", "name": "Agence Yopougon-Selmer", "commune": "Yopougon", "address": "Près du carrefour SELMER", "phone": "2723400000", "latitude": 5.3450, "longitude": -4.0850},
    {"id": "AG-003", "name": "Agence Plateau", "commune": "Plateau", "address": "Avenue Houdaille", "phone": "2720400000", "latitude": 5.3197, "longitude": -4.0181}
  ]
  ''';

  Future<List<Map<String, dynamic>>> fetchBills() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulation délai réseau
    return List<Map<String, dynamic>>.from(json.decode(_mockBillsJson));
  }

  Future<List<Map<String, dynamic>>> fetchAgencies() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List<Map<String, dynamic>>.from(json.decode(_mockAgenciesJson));
  }

  Future<bool> processPayment(String billId, String method) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulation paiement
    return true;
  }
}
