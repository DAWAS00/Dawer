import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/app_lang_notifier.dart';
import 'core/services/app_theme_notifier.dart';
import 'core/theme/app_theme.dart';
import 'data/services/app_order_store.dart';
import 'l10n/l10n.dart';
import 'ui/features/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  runApp(DawerApp(prefs: prefs));
}

class DawerApp extends StatelessWidget {
  final SharedPreferences prefs;
  const DawerApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppOrderStore()),
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
