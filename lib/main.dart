import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'backend_integration_locally/local_store.dart';
import 'core/config/ai_config.dart';
import 'core/config/maps_config.dart';
import 'core/services/supabase_service.dart';
import 'data/services/fcm_notification_service.dart';
import 'data/services/gemini_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmNotificationService.instance.init();

  try {
    await dotenv.load(fileName: '.env.local');
  } catch (_) {
    debugPrint('Warning: .env.local not found — app will run in mock/offline mode.');
  }

  AiConfig.assertConfigured();

  await SupabaseService.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final geminiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
  if (geminiKey.isNotEmpty) GeminiService.instance.init(geminiKey);

  final mapsKey = dotenv.env['MAPS_API_KEY']?.trim() ?? '';
  if (mapsKey.isNotEmpty) {
    MapsConfig.init(mapsKey);
  }

  final prefs = await SharedPreferences.getInstance();
  final localStore = await LocalStore.init();

  const mockAuth = false;

  runApp(
    DawerApp(
      prefs: prefs,
      localStore: localStore,
      useSupabase: SupabaseService.isInitialized,
      mockAuth: mockAuth,
    ),
  );
}
