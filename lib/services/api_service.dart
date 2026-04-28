import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bill_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.courant-ci.com/v1';

  static Future<List<Bill>> fetchBills(String userNumber) async {
    try {

      await Future.delayed(const Duration(seconds: 1));
      

      return [
        Bill(
          id: "API-001",
          month: "Avril 2024",
          amount: 25000.0,
          dueDate: DateTime(2024, 5, 15),
          status: BillStatus.unpaid,
        ),
        Bill(
          id: "API-002",
          month: "Mai 2024",
          amount: 15750.0,
          dueDate: DateTime(2024, 6, 15),
          status: BillStatus.pending,
        ),
      ];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des factures : $e');
    }
  }

  static Future<bool> processPayment(String billId, double amount) async {
    await Future.delayed(const Duration(seconds: 2));
    return true; 
  }
}
