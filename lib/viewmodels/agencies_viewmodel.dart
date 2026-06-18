import 'package:flutter/material.dart';
import '../data/models/agency_model.dart';
import '../data/services/api_service.dart';

class AgenciesViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String? userCommune;

  List<AgencyModel> _allAgencies = [];
  List<AgencyModel> _filteredAgencies = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<AgencyModel> get agencies => _filteredAgencies;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// Vrai quand une recherche est en cours (pour afficher "Toutes les
  /// agences" au lieu de "Agences à [commune]").
  bool get isSearching => _searchQuery.isNotEmpty;

  AgenciesViewModel({this.userCommune}) {
    loadAgencies();
  }

  Future<void> loadAgencies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.fetchAgencies();
      _allAgencies = data.map((json) => AgencyModel.fromJson(json)).toList();
      _applyFilter();
    } catch (e) {
      debugPrint('Erreur lors du chargement des agences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    // Quand l'utilisateur tape une recherche → toutes les agences
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredAgencies = _allAgencies.where((agency) {
        return agency.name.toLowerCase().contains(query) ||
            agency.commune.toLowerCase().contains(query) ||
            agency.address.toLowerCase().contains(query);
      }).toList();
      return;
    }

    // Sans recherche : agences de la commune de l'utilisateur en priorité
    if (userCommune != null && userCommune!.isNotEmpty) {
      final communeMatch = _allAgencies
          .where((a) =>
              a.commune.toLowerCase() == userCommune!.toLowerCase())
          .toList();
      // Si aucune agence pour cette commune, on affiche tout
      _filteredAgencies =
          communeMatch.isNotEmpty ? communeMatch : List.from(_allAgencies);
    } else {
      _filteredAgencies = List.from(_allAgencies);
    }
  }
}
