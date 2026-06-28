import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

/// Initializes the Supabase client from `.env.local`.
///
/// Thin delegate to [SupabaseService.initialize] so there is a single source of
/// truth for init behavior (best-effort, no hardcoded fallback). Kept for
/// backwards compatibility with call sites that reference `SupabaseConfig.init`.
class SupabaseConfig {
  SupabaseConfig._();

  /// Initializes Supabase from `SUPABASE_URL` / `SUPABASE_ANON_KEY` in `.env.local`.
  /// Returns `true` on success; `false` (logged) when config is missing/invalid
  /// so the app can fall back to mock mode instead of crashing.
  static Future<bool> init() async {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    await SupabaseService.initialize(url: url, anonKey: anonKey);
    return SupabaseService.isInitialized;
  }

  /// Shorthand for the global Supabase client. Only valid once initialized.
  static SupabaseClient get client => Supabase.instance.client;
}
