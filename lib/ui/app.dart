import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/routing/app_router.dart';
import '../core/services/app_lang_notifier.dart';
import '../core/services/app_theme_notifier.dart';
import '../core/theme/app_theme.dart';
import '../data/local/local_store.dart';
import '../data/repositories/mock_auth_repository.dart';
import '../data/repositories/supabase_order_repository.dart';
import '../data/services/app_order_store.dart';
import '../data/services/driver_order_store.dart';
import '../data/services/recycling_order_store.dart';
import '../data/services/supplier_order_store.dart';
import '../data/services/supabase_auth_service.dart';
import '../data/services/user_signup_service.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_file_storage_repository.dart';
import '../domain/repositories/i_order_repository.dart';
import '../l10n/l10n.dart';
import 'features/auth/viewmodels/login_viewmodel.dart';

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
        // TODO(auth): swap back to SupabaseAuthRepository when Supabase auth is re-enabled
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

class BackendMissingApp extends StatelessWidget {
  const BackendMissingApp({super.key});

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
