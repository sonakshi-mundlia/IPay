import '../services/api_service.dart';
import 'package:flutter/material.dart';

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final ValueNotifier<int?> currentAccountNotifier = ValueNotifier<int?>(null);
  int? get currentAccountId => currentAccountNotifier.value;

  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> get accounts => _accounts;

  // Load profile from backend
  Future<void> load(ApiService api) async {
    try {
      final token = await api.getToken();

      if (token == null) {
        debugPrint("No token available");
        return;
      }

      final profile = await api.getProfile();

      _accounts = profile['accounts'] != null
          ? List<Map<String, dynamic>>.from(profile['accounts'])
          : [];

      currentAccountNotifier.value =
          profile['active_account_id'] ??
              (_accounts.isNotEmpty ? _accounts.first['id'] : null);
    } catch (e) {
      debugPrint("AppState load failed: $e");
    }
  }

  // Set & persist active account manually
  void setAccount(int id) {
    currentAccountNotifier.value = id;
  }

  // Clear account
  void clear() {
    currentAccountNotifier.value = null;
  }
}
