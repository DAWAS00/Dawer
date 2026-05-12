import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

/// Centralizes Supabase initialization and connectivity state.
class SupabaseService {
  static bool _isInitialized = false;
  static String? _initError;

  /// Returns true if [initialize] completed without error.
  static bool get isInitialized => _isInitialized;

  /// Non-null when initialization failed. Displayed as an error screen in
  /// [SplashView] so the user knows the app is not operational.
  static String? get initError => _initError;

  /// Initializes Supabase with the provided config.
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _isInitialized = true;
      _initError = null;
    } catch (e) {
      _isInitialized = false;
      _initError = e.toString();
      AppLogger.error('SupabaseService', e);
    }
  }

  /// Convenience getter for the client.
  static SupabaseClient get client => Supabase.instance.client;
}
