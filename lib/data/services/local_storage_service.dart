import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Enveloppe [SharedPreferences] pour centraliser toutes les clés de
/// stockage local utilisées par CIC (onboarding, mode invité/inscrit,
/// zone choisie, thème...).
///
/// Une instance de [SharedPreferences] est obtenue une seule fois au
/// démarrage (`await SharedPreferences.getInstance()`), puis toutes les
/// lectures ci-dessous sont synchrones.
class LocalStorageService {
  final SharedPreferences _prefs;

  const LocalStorageService(this._prefs);

  // --- Onboarding ---
  bool isOnboardingDone() =>
      _prefs.getBool(AppConstants.prefOnboardingDone) ?? false;

  Future<void> setOnboardingDone(bool value) async {
    await _prefs.setBool(AppConstants.prefOnboardingDone, value);
  }

  // --- Mode utilisateur (invité / inscrit) ---
  UserMode? getUserMode() {
    final raw = _prefs.getString(AppConstants.prefUserMode);
    if (raw == null) return null;
    return UserMode.values.where((m) => m.name == raw).firstOrNull;
  }

  Future<void> setUserMode(UserMode? mode) async {
    if (mode == null) {
      await _prefs.remove(AppConstants.prefUserMode);
    } else {
      await _prefs.setString(AppConstants.prefUserMode, mode.name);
    }
  }

  // --- Zone (commune / quartier) ---
  String? getCommune() => _prefs.getString(AppConstants.prefCommune);

  Future<void> setCommune(String commune) async {
    await _prefs.setString(AppConstants.prefCommune, commune);
  }

  String? getQuartier() => _prefs.getString(AppConstants.prefQuartier);

  Future<void> setQuartier(String quartier) async {
    await _prefs.setString(AppConstants.prefQuartier, quartier);
  }

  // --- Numéro de compteur (F2) ---
  String? getMeterNumber() => _prefs.getString(AppConstants.prefMeterNumber);

  Future<void> setMeterNumber(String meterNumber) async {
    await _prefs.setString(AppConstants.prefMeterNumber, meterNumber);
  }

  Future<void> clearMeterNumber() async {
    await _prefs.remove(AppConstants.prefMeterNumber);
  }

  // --- Thème ---
  ThemeMode getThemeMode() {
    final raw = _prefs.getString(AppConstants.prefThemeMode);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(AppConstants.prefThemeMode, mode.name);
  }

  // --- Identifiant d'appareil ---
  // Permet aux utilisateurs invités d'avoir des données Firestore
  // (relevés de compteur) qui leur sont propres, sans compte.
  String getOrCreateDeviceId() {
    final existing = _prefs.getString(AppConstants.prefDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = _generateId();
    _prefs.setString(AppConstants.prefDeviceId, generated);
    return generated;
  }

  // --- Signalements (F4) : anti-spam local + points CIC ---
  /// Nombre de signalements envoyés depuis cet appareil au cours de la
  /// dernière heure (CDC : maximum 5/heure).
  int getReportCountLastHour() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    return _reportTimestamps().where((t) => t.isAfter(cutoff)).length;
  }

  /// Enregistre l'horodatage d'un nouveau signalement (purge au passage
  /// les entrées de plus d'une heure).
  Future<void> recordReportTimestamp() async {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 1));
    final updated = _reportTimestamps().where((t) => t.isAfter(cutoff)).toList()
      ..add(now);
    await _prefs.setStringList(
      AppConstants.prefReportTimestamps,
      updated.map((t) => t.toIso8601String()).toList(),
    );
  }

  List<DateTime> _reportTimestamps() {
    final raw =
        _prefs.getStringList(AppConstants.prefReportTimestamps) ?? const [];
    return raw.map(DateTime.tryParse).whereType<DateTime>().toList();
  }

  /// Points CIC accumulés sur cet appareil (CDC F4 : score de
  /// fiabilité / badge "Sentinelle CIC").
  int getCicPoints() => _prefs.getInt(AppConstants.prefCicPoints) ?? 0;

  Future<void> addCicPoints(int points) async {
    await _prefs.setInt(AppConstants.prefCicPoints, getCicPoints() + points);
  }

  String _generateId() {
    final random = Random();
    final timestampPart =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final randomPart =
        List.generate(8, (_) => random.nextInt(36).toRadixString(36)).join();
    return '$timestampPart$randomPart';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
