import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import '../data/models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserModel? _currentUser;
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  List<Map<String, dynamic>> get bills => _bills;
  bool get isLoading => _isLoading;

  void setUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bills = await _apiService.fetchBills();
    } catch (e) {
      debugPrint('Erreur lors du chargement des factures: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payBill(String billId, String method) async {
    final success = await _apiService.processPayment(billId, method);
    if (success) {
      // Met à jour la facture localement pour simuler le succès immédiat
      final index = _bills.indexWhere((b) => b['id'] == billId);
      if (index != -1) {
        _bills[index]['status'] = 'paid';
      }
      notifyListeners();
    }
    return success;
  }
  
  // Simulation de mise à jour de profil
  Future<void> updateProfile({String? name, String? commune, String? quartier}) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      displayName: name ?? _currentUser!.displayName,
      commune: commune ?? _currentUser!.commune,
      quartier: quartier ?? _currentUser!.quartier,
    );
    notifyListeners();
  }
}
