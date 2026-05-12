import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routing/app_router.dart';
import 'core/services/app_lang_notifier.dart';
import 'core/services/app_theme_notifier.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/local_store.dart';
import 'data/repositories/mock_auth_repository.dart';
import 'data/repositories/supabase_auth_repository.dart';
import 'data/repositories/supabase_file_storage_repository.dart';
import 'data/repositories/supabase_order_repository.dart';
import 'data/services/app_order_store.dart';
import 'data/services/driver_order_store.dart';
import 'data/services/recycling_order_store.dart';
import 'data/services/supplier_order_store.dart';
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

  // Load .env.local at runtime (dev). CI/CD passes values via --dart-define instead.
  await dotenv.load(fileName: '.env.local', mergeWith: {}).catchError((_) {});

  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim().isNotEmpty == true
      ? dotenv.env['SUPABASE_URL']!
      : const String.fromEnvironment('SUPABASE_URL');

  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim().isNotEmpty == true
      ? dotenv.env['SUPABASE_ANON_KEY']!
      : const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const _BackendMissingApp());
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

/// Shown when the app is launched without the required --dart-define credentials.
/// Prevents any network calls from reaching a non-existent backend.
class _BackendMissingApp extends StatelessWidget {
  const _BackendMissingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF06402B),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_outlined, size: 64, color: Colors.white54),
                  const SizedBox(height: 24),
                  Text(
                    'لم يتم تهيئة الخادم',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'يرجى التواصل مع الدعم الفني.',
                    style: GoogleFonts.cairo(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DawerApp extends StatelessWidget {
  final SharedPreferences prefs;
  final LocalStore localStore;
  final IFileStorageRepository fileStorage;
  final SupabaseAuthService authService;
  const DawerApp({
    super.key,
    required this.prefs,
    required this.localStore,
    required this.fileStorage,
    required this.authService,
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
        ProxyProvider<AppOrderStore, DriverOrderStore>(
          update: (_, store, prev) => prev ?? DriverOrderStore(store),
          dispose: (_, store) => store.dispose(),
        ),
        ProxyProvider<AppOrderStore, SupplierOrderStore>(
          update: (_, store, prev) => prev ?? SupplierOrderStore(store),
          dispose: (_, store) => store.dispose(),
        ),
        ProxyProvider<AppOrderStore, RecyclingOrderStore>(
          update: (_, store, prev) => prev ?? RecyclingOrderStore(store),
          dispose: (_, store) => store.dispose(),
        ),
        ChangeNotifierProvider(create: (_) => AppThemeNotifier(prefs)),
        ChangeNotifierProvider(create: (_) => AppLangNotifier(prefs)),
        Provider<SupabaseAuthService>.value(value: authService),
        Provider<UserSignUpService>(
          create: (ctx) => UserSignUpService(authService: ctx.read<SupabaseAuthService>()),
        ),
        Provider<IAuthRepository>(
          create: (ctx) => SupabaseService.isInitialized
              ? SupabaseAuthRepository(
                  SupabaseService.client,
                  ctx.read<UserSignUpService>(),
                  localStore,
                )
              : MockAuthRepository(), // dev fallback when init fails
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

