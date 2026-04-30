import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralizes Supabase initialization and connectivity state.
class SupabaseService {
  static bool _isInitialized = false;

  /// Returns true if [initialize] was called successfully.
  static bool get isInitialized => _isInitialized;

  /// Initializes Supabase with the provided config.
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      // In production we might log this to Sentry
    }
  }

  /// Convenience getter for the client.
  static SupabaseClient get client => Supabase.instance.client;
}
