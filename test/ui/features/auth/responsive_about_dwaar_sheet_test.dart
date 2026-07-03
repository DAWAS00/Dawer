import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dwaar/data/repositories/mock_partner_data_request_repository.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/domain/repositories/i_partner_data_request_repository.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/ui/features/auth/views/widgets/about_dwaar_sheet.dart';

Widget _harness() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppOrderStore()),
      Provider<IPartnerDataRequestRepository>(
        create: (_) => MockPartnerDataRequestRepository(),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showAboutDwaarSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final devices = {
    'iPhone SE (Small Phone)': const Size(320, 568),
    'Pixel 7 (Standard Phone)': const Size(412, 915),
    'iPad Pro (Tablet)': const Size(1024, 1366),
  };

  devices.forEach((deviceName, size) {
    testWidgets('About Dwaar sheet renders correctly on $deviceName', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_harness());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

      // Scroll down to ensure offscreen lazy-loaded elements are built and visible
      final listFinder = find.byType(ListView);
      if (listFinder.evaluate().isNotEmpty) {
        await tester.drag(listFinder, const Offset(0.0, -300.0));
        await tester.pumpAndSettle();
      }

      // Confirm title resides in layout and loads properly
      expect(find.text(l10n.aboutDwaarImpactTitle), findsOneWidget);

      // Ensure there are no render flex overflows or errors thrown
      expect(tester.takeException(), isNull);
    });
  });
}
