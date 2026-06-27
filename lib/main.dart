import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'backend_integration_locally/local_store.dart';
import 'core/routing/app_router.dart';
import 'data/services/gemini_service.dart';
import 'core/services/app_lang_notifier.dart';
import 'core/services/app_theme_notifier.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/config/ai_config.dart';
import 'data/repositories/mock_auth_repository.dart';
import 'data/repositories/supabase_file_storage_repository.dart';
import 'data/repositories/supabase_order_repository.dart';
import 'data/services/app_order_store.dart';
import 'data/services/supabase_auth_service.dart';
import 'data/services/user_signup_service.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_file_storage_repository.dart';
import 'domain/repositories/i_order_repository.dart';
import 'l10n/l10n.dart';
import 'ui/features/auth/viewmodels/login_viewmodel.dart';
     void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await dotenv.load(fileName: ".env.local");
  } catch (e) {
    debugPrint('Could not load .env.local file. Ensure it exists in the root directory.');
  }

  AiConfig.assertConfigured();

  // Initialize Supabase via service
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint('WARNING: SUPABASE_URL or SUPABASE_ANON_KEY is not defined in .env.local. App will run in mock mode or fail if backend is required.');
  }

  await SupabaseService.initialize(
    url: supabaseUrl.isNotEmpty ? supabaseUrl : 'https://bpzuwwbtqqrpohfqjcuo.supabase.co',
    anonKey: supabaseAnonKey.isNotEmpty ? supabaseAnonKey : 'sb_publishable__JiNp6XeCpIOC1rWi9PwpA_JA51eBU7',
  );

  final geminiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
  if (geminiKey.isNotEmpty) {
    GeminiService.instance.init(geminiKey);
  }

  final prefs = await SharedPreferences.getInstance();
  final localStore = await LocalStore.init();

  final fileStorage = SupabaseFileStorageRepository();
  UserSignUpService.setGlobalAuthService(
    SupabaseAuthService(store: localStore, fileStorage: fileStorage),
  );

  runApp(DawerApp(
    prefs: prefs,
    localStore: localStore,
    fileStorage: fileStorage,
  ));
}

class DawerApp extends StatelessWidget {
  final SharedPreferences prefs;
  final LocalStore localStore;
  final IFileStorageRepository fileStorage;
  const DawerApp({
    super.key,
    required this.prefs,
    required this.localStore,
    required this.fileStorage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStore>.value(value: localStore),
        Provider<IFileStorageRepository>.value(value: fileStorage),
        Provider<IOrderRepository>(
          create: (_) => SupabaseOrderRepository(Supabase.instance.client),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AppOrderStore(
            store: localStore,
            remote: ctx.read<IOrderRepository>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AppThemeNotifier(prefs)),
        ChangeNotifierProvider(create: (_) => AppLangNotifier(prefs)),
        Provider<IAuthRepository>(
          create: (_) => MockAuthRepository(),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (ctx) => LoginViewModel(
            authRepository: ctx.read<IAuthRepository>(),
          ),
        ),
      ],
      child: Consumer2<AppThemeNotifier, AppLangNotifier>(
        builder: (context, themeNotifier, langNotifier, child) {
          return MaterialApp.router(
            title: 'دوّر',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.mode,
            locale: langNotifier.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
