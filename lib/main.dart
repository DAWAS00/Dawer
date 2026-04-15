import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/app_theme_notifier.dart';
import 'core/theme/app_theme.dart';
import 'data/services/app_order_store.dart';
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
      ],
      child: Consumer<AppThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'دوّر',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.mode,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: const SplashView(),
          );
        },
      ),
    );
  }
}