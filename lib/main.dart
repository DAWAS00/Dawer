import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend_integration_locally/local_store.dart';
import 'core/services/app_lang_notifier.dart';
import 'core/services/app_theme_notifier.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/config/ai_config.dart';
import 'data/repositories/mock_auth_repository.dart';
import 'data/repositories/supabase_auth_repository.dart';
import 'data/repositories/supabase_file_storage_repository.dart';
import 'data/repositories/supabase_order_repository.dart';
import 'data/repositories/supabase_wallet_repository.dart';
import 'data/services/app_order_store.dart';
import 'data/services/noop_notification_service.dart';
import 'data/services/user_signup_service.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_file_storage_repository.dart';
import 'domain/repositories/i_order_repository.dart';
import 'domain/repositories/i_wallet_repository.dart';
import 'domain/services/i_notification_service.dart';
import 'domain/chat/repositories/i_chat_repository.dart';
import 'data/chat/mock_chat_repository.dart';
import 'data/chat/supabase_chat_repository.dart';
import 'l10n/l10n.dart';
import 'ui/features/auth/viewmodels/login_viewmodel.dart';
import 'ui/features/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await dotenv.load(fileName: ".env.local");
  } catch (e) {
    debugPrint('Could not load .env.local file. Ensure it exists in the root directory.');
  }

  AiConfig.assertConfigured();

  // Initialize Supabase from `.env.local`. Best-effort: if the URL/key are
  // missing or the project is unreachable, `isInitialized` stays false and the
  // app boots in mock/offline mode. No hardcoded fallback — `.env.local` is the
  // single source of truth. See docs/architecture-decisions/backend-strategy.md.
  await SupabaseService.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final prefs = await SharedPreferences.getInstance();
  final localStore = await LocalStore.init();

  // After best-effort init, decide which backend to bind. When Supabase is
  // initialized (URL/key present and accepted), bind the Supabase repositories;
  // otherwise fall back to the Mock / NoOp implementations so the app still
  // boots offline and `flutter test` runs without a live backend. This is the
  // single seam a future GCP re-platform swaps. See
  // docs/architecture-decisions/backend-strategy.md.
  final useSupabase = SupabaseService.isInitialized;

  runApp(DawerApp(prefs: prefs, localStore: localStore, useSupabase: useSupabase));
}

class DawerApp extends StatelessWidget {
  final SharedPreferences prefs;
  final LocalStore localStore;
  final bool useSupabase;

  const DawerApp({
    super.key,
    required this.prefs,
    required this.localStore,
    required this.useSupabase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStore>.value(value: localStore),
        Provider<IFileStorageRepository>(
          create: (_) => useSupabase
              ? SupabaseFileStorageRepository()
              : const NoOpFileStorageRepository(),
        ),
        Provider<INotificationService>(
          create: (_) => const NoopNotificationService(),
        ),
        Provider<IOrderRepository>(
          create: (_) => useSupabase
              ? SupabaseOrderRepository(SupabaseService.client)
              : const NoOpOrderRepository(),
        ),
        Provider<IWalletRepository>(
          create: (_) => useSupabase
              ? SupabaseWalletRepository(SupabaseService.client)
              : const NoOpWalletRepository(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AppOrderStore(
            store: localStore,
            remote: ctx.read<IOrderRepository>(),
            wallet: ctx.read<IWalletRepository>(),
            skipMockSeed: useSupabase,
          ),
        ),
        ChangeNotifierProvider(create: (_) => AppThemeNotifier(prefs)),
        ChangeNotifierProvider(create: (_) => AppLangNotifier(prefs)),
        Provider<IAuthRepository>(
          create: (_) => useSupabase
              ? SupabaseAuthRepository(SupabaseService.client, localStore)
              : MockAuthRepository(),
        ),
        Provider<UserSignUpService>(
          create: (ctx) => UserSignUpService(
            authRepository: ctx.read<IAuthRepository>(),
            fileStorage: ctx.read<IFileStorageRepository>(),
          ),
        ),
        Provider<IChatRepository>(
          create: (_) => useSupabase
              ? SupabaseChatRepository(SupabaseService.client)
              : MockChatRepository(),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (ctx) => LoginViewModel(
            authRepository: ctx.read<IAuthRepository>(),
          ),
        ),
      ],
      child: Consumer2<AppThemeNotifier, AppLangNotifier>(
        builder: (context, themeNotifier, langNotifier, child) {
          return MaterialApp(
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
            home: const SplashView(),
          );
        },
      ),
    );
  }
}
