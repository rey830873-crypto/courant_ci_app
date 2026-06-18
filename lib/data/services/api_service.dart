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
    {"id": "AG-002", "name": "Agence Cocody-Riviera", "commune": "Cocody", "address": "Riviera 2, près du carrefour Lycée", "phone": "2722400001", "latitude": 5.3780, "longitude": -3.9600},
    {"id": "AG-003", "name": "Agence Yopougon-Selmer", "commune": "Yopougon", "address": "Près du carrefour SELMER", "phone": "2723400000", "latitude": 5.3450, "longitude": -4.0850},
    {"id": "AG-004", "name": "Agence Yopougon-Niangon", "commune": "Yopougon", "address": "Niangon Nord, face au marché", "phone": "2723400001", "latitude": 5.3560, "longitude": -4.0720},
    {"id": "AG-005", "name": "Agence Plateau", "commune": "Plateau", "address": "Avenue Houdaille", "phone": "2720400000", "latitude": 5.3197, "longitude": -4.0181},
    {"id": "AG-006", "name": "Agence Marcory", "commune": "Marcory", "address": "Boulevard de Marseille, Zone 4", "phone": "2724400000", "latitude": 5.2934, "longitude": -3.9836},
    {"id": "AG-007", "name": "Agence Treichville", "commune": "Treichville", "address": "Avenue 17, près du marché", "phone": "2725400000", "latitude": 5.2926, "longitude": -4.0107},
    {"id": "AG-008", "name": "Agence Adjamé", "commune": "Adjamé", "address": "Boulevard Nangui Abrogoua", "phone": "2726400000", "latitude": 5.3530, "longitude": -4.0270},
    {"id": "AG-009", "name": "Agence Abobo", "commune": "Abobo", "address": "Abobo Baoulé, face à la mairie", "phone": "2727400000", "latitude": 5.4189, "longitude": -4.0167},
    {"id": "AG-010", "name": "Agence Koumassi", "commune": "Koumassi", "address": "Koumassi Grand Campement", "phone": "2728400000", "latitude": 5.2925, "longitude": -3.9445},
    {"id": "AG-011", "name": "Agence Grand-Bassam", "commune": "Grand-Bassam", "address": "Quartier France, rue du Commerce", "phone": "2729400000", "latitude": 5.2118, "longitude": -3.7388},
    {"id": "AG-012", "name": "Agence Bingerville", "commune": "Bingerville", "address": "Centre-ville, près de la préfecture", "phone": "2721400000", "latitude": 5.3556, "longitude": -3.8853},
    {"id": "AG-013", "name": "Agence Anyama", "commune": "Anyama", "address": "Anyama centre, avenue principale", "phone": "2722500000", "latitude": 5.4877, "longitude": -4.0517}
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
