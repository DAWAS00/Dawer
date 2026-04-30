import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] that owns every persisted key used
/// by the local backend. UI layers must never read SharedPreferences directly
/// for backend state — always go through a service that holds a [LocalStore].
class LocalStore {
  LocalStore._(this._prefs);

  final SharedPreferences _prefs;

  static const String _usersKey = 'dwaar_users';
  static const String _currentUserKey = 'dwaar_current_user_id';
  static const String _currentUserRoleKey = 'dwaar_current_user_role';
  static const String _currentSupplierTypeKey = 'dwaar_current_supplier_type';
  static const String _ordersKey = 'dwaar_orders';
  static const String _marketKey = 'dwaar_market';
  static const String _firstLaunchKey = 'dwaar_first_launch_done';
  static const String _authSchemaKey = 'dwaar_auth_schema';

  /// Async factory. Must be awaited exactly once during app bootstrap.
  static Future<LocalStore> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStore._(prefs);
  }

  // ── Users ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> readUsers() => _readMapList(_usersKey);

  Future<void> writeUsers(List<Map<String, dynamic>> users) async {
    await _prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<void> clearAllUsers() async {
    await _prefs.remove(_usersKey);
  }

  // ── Orders ───────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> readOrders() => _readMapList(_ordersKey);

  Future<void> writeOrders(List<Map<String, dynamic>> orders) async {
    await _prefs.setString(_ordersKey, jsonEncode(orders));
  }

  List<Map<String, dynamic>> readMarket() => _readMapList(_marketKey);

  Future<void> writeMarket(List<Map<String, dynamic>> market) async {
    await _prefs.setString(_marketKey, jsonEncode(market));
  }

  bool get isFirstLaunch => !(_prefs.getBool(_firstLaunchKey) ?? false);

  Future<void> markFirstLaunchDone() async {
    await _prefs.setBool(_firstLaunchKey, true);
  }

  Future<void> resetFirstLaunch() async {
    await _prefs.remove(_firstLaunchKey);
  }

  // ── Auth schema version ──────────────────────────────────────────────────

  int get authSchemaVersion => _prefs.getInt(_authSchemaKey) ?? 1;

  Future<void> setAuthSchemaVersion(int version) async {
    await _prefs.setInt(_authSchemaKey, version);
  }

  List<Map<String, dynamic>> _readMapList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ── Current session ──────────────────────────────────────────────────────

  String? getCurrentUserId() => _prefs.getString(_currentUserKey);

  Future<void> setCurrentUserId(String id) async {
    await _prefs.setString(_currentUserKey, id);
  }

  Future<void> clearCurrentUserId() async {
    await _prefs.remove(_currentUserKey);
  }

  String? getCurrentUserRole() => _prefs.getString(_currentUserRoleKey);

  Future<void> setCurrentUserRole(String role) async {
    await _prefs.setString(_currentUserRoleKey, role);
  }

  Future<void> clearCurrentUserRole() async {
    await _prefs.remove(_currentUserRoleKey);
  }

  String? getCurrentSupplierType() => _prefs.getString(_currentSupplierTypeKey);

  Future<void> setCurrentSupplierType(String type) async {
    await _prefs.setString(_currentSupplierTypeKey, type);
  }

  Future<void> clearCurrentSupplierType() async {
    await _prefs.remove(_currentSupplierTypeKey);
  }
}
