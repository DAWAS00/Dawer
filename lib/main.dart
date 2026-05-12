import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/supabase_service.dart';
import 'data/local/local_store.dart';
import 'data/repositories/supabase_file_storage_repository.dart';
import 'data/services/supabase_auth_service.dart';
import 'ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load .env.local at runtime (dev). CI/CD passes values via --dart-define instead.
  await dotenv.load(fileName: '.env.local', mergeWith: {}).catchError((_) {});

  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim().isNotEmpty == true
      ? dotenv.env['SUPABASE_URL']!
      : const String.fromEnvironment('SUPABASE_URL');

  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim().isNotEmpty == true
      ? dotenv.env['SUPABASE_ANON_KEY']!
      : const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const BackendMissingApp());
    return;
  }

  await SupabaseService.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final prefs = await SharedPreferences.getInstance();
  final localStore = await LocalStore.init();
  final fileStorage = SupabaseFileStorageRepository();
  final authService = SupabaseAuthService(store: localStore, fileStorage: fileStorage);

  runApp(DawerApp(
    prefs: prefs,
    localStore: localStore,
    fileStorage: fileStorage,
    authService: authService,
  ));
}
