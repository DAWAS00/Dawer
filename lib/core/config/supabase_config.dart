import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes the Supabase client from `.env.local`.
///
/// Must be called once from `main()` after `dotenv.load()`.
class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> init() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env.local',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  /// Shorthand for the global Supabase client.
  static SupabaseClient get client => Supabase.instance.client;
}
