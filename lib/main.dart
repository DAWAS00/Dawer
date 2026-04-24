import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'backend_integration_locally/local_store.dart';
import 'core/services/app_lang_notifier.dart';
import 'core/services/app_theme_notifier.dart';
import 'core/theme/app_theme.dart';
import 'data/services/app_order_store.dart';
import 'data/services/user_signup_service.dart';
import 'l10n/l10n.dart';
import 'ui/features/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qexwkjwqnbowsrrthxva.supabase.co',
    anonKey: 'sb_publishable_5L9NXEGuDEnPIHrIuiva_g_81fPRwtJ',
  );

  final prefs = await SharedPreferences.getInstance();
  final localStore = await LocalStore.init();
  UserSignUpService.setGlobalStore(localStore);
  runApp(DawerApp(prefs: prefs, localStore: localStore));
}

class DawerApp extends StatelessWidget {
  final SharedPreferences prefs;
  final LocalStore localStore;
  const DawerApp({super.key, required this.prefs, required this.localStore});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStore>.value(value: localStore),
        ChangeNotifierProvider(create: (_) => AppOrderStore(store: localStore)),
        ChangeNotifierProvider(create: (_) => AppThemeNotifier(prefs)),
        ChangeNotifierProvider(create: (_) => AppLangNotifier(prefs)),
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
