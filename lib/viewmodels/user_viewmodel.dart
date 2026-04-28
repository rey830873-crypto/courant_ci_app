import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/api_service.dart';

class UserViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  String _userName = "";
  String _userNumber = "";
  bool _isGuest = false;
  String? _profileImageUrl;
  
  String get userName => _userName;
  String get userNumber => _userNumber;
  bool get isGuest => _isGuest;
  String? get profileImageUrl => _profileImageUrl;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login(String name, {bool asGuest = false}) {
    _userName = name;
    _isLoggedIn = true;
    _isGuest = asGuest;
    if (asGuest) {
      _userName = "Invité";
      _userNumber = "GUEST-MODE";
    } else {
      loadData(); // Charger les données réelles au login
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isGuest = false;
    _bills = [];
    notifyListeners();
  }

  // --- GESTION DES DONNÉES VIA API ---
  List<Bill> _bills = [];
  List<Bill> get bills => _bills;
  List<Bill> get unpaidBills => _bills.where((b) => b.status != BillStatus.paid).toList();

  Future<void> loadData() async {
    if (_isGuest) return;
    
    setLoading(true);
    try {
      _bills = await ApiService.fetchBills(_userNumber);
    } catch (e) {
      debugPrint("Erreur lors du chargement des factures: $e");
    } finally {
      setLoading(false);
    }
  }

  void setProfileImage(String path) {
    _profileImageUrl = path;
    notifyListeners();
  }

  void updateProfile({required String name, String? email, String? phone}) {
    _userName = name;
    notifyListeners();
  }

  double _balance = 12500.0;
  double get balance => _balance;

  final List<double> _consumptionData = [120, 150, 110, 180, 200, 170, 140];
  List<double> get consumptionData => _consumptionData;

  final List<String> _contracts = ["Compteur Salon - 45892", "Compteur Studio - 12345"];
  List<String> get contracts => _contracts;

  final List<Map<String, dynamic>> _notifications = [
    {"title": "Facture disponible", "body": "Votre facture de Mars est disponible.", "date": "Il y a 2h"},
    {"title": "Paiement réussi", "body": "Merci pour votre paiement de 15 000 FCFA.", "date": "Hier"},
  ];
  List<Map<String, dynamic>> get notifications => _notifications;

  final List<Map<String, dynamic>> _paymentHistory = [
    {"title": "Paiement Facture Janvier", "amount": 15000.0, "date": "10/02/2024", "method": "Orange Money"},
    {"title": "Rechargement Compte", "amount": 5000.0, "date": "05/02/2024", "method": "Wave"},
  ];
  List<Map<String, dynamic>> get paymentHistory => _paymentHistory;

  final List<Map<String, dynamic>> _incidents = [
    {"type": "Coupure de courant", "status": "En cours", "date": "28/04/2024", "location": "Cocody, Angré"},
  ];
  List<Map<String, dynamic>> get incidents => _incidents;

  void reportIncident(String type, String location, String description) {
    _incidents.insert(0, {
      "type": type,
      "status": "Signalé",
      "date": "Aujourd'hui",
      "location": location,
    });
    notifyListeners();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> payBill(String billId) async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      _bills[index] = Bill(
        id: _bills[index].id,
        month: _bills[index].month,
        amount: _bills[index].amount,
        dueDate: _bills[index].dueDate,
        status: BillStatus.paid,
      );
    }
    setLoading(false);
  }

  Future<void> topUp(double amount) async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    _balance += amount;
    setLoading(false);
  }
}
