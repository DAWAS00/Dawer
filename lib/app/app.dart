import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend_integration_locally/local_store.dart';
import '../core/services/app_lang_notifier.dart';
import '../core/services/app_theme_notifier.dart';
import '../core/theme/app_theme.dart';
import '../l10n/l10n.dart';
import '../ui/features/splash/views/splash_view.dart';
import 'app_providers.dart';

class DawerApp extends StatelessWidget {
  const DawerApp({
    super.key,
    required this.prefs,
    required this.localStore,
    required this.useSupabase,
    required this.mockAuth,
  });

  final SharedPreferences prefs;
  final LocalStore localStore;
  final bool useSupabase;
  final bool mockAuth;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...buildProviders(
          prefs: prefs,
          localStore: localStore,
          useSupabase: useSupabase,
          mockAuth: mockAuth,
        ),
      ],
      child: Consumer2<AppThemeNotifier, AppLangNotifier>(
        builder: (context, themeNotifier, langNotifier, _) {
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
