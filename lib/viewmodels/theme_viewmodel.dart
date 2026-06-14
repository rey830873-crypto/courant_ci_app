import 'package:flutter/material.dart';
import '../data/services/local_storage_service.dart';

/// Gère le [ThemeMode] de l'application (clair / sombre / système) et le
/// persiste via [LocalStorageService] (CDC : "Mode Sombre/Clair").
class ThemeViewModel extends ChangeNotifier {
  final LocalStorageService _storage;

  late ThemeMode _themeMode;

  ThemeViewModel(this._storage) {
    _themeMode = _storage.getThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _storage.setThemeMode(mode);
  }

  /// Bascule simplement entre clair et sombre (utilisé par le bouton
  /// rapide du dashboard/profil). Si le mode courant est "système",
  /// on part du principe qu'il est actuellement clair.
  Future<void> toggle() async {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}
