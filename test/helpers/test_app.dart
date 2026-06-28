import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';

/// Wraps a widget with the app's localization delegates so widgets that call
/// `context.l10n` work in tests. Defaults to Arabic (the template locale).
Widget wrapWithL10n(Widget child, {String locale = 'ar'}) {
  return MaterialApp(
    locale: Locale(locale),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
