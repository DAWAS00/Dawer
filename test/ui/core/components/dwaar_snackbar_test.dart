import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/domain/failures/app_failure.dart';
import 'package:dwaar/ui/core/components/dwaar_snackbar.dart';
import 'package:dwaar/l10n/l10n.dart';

Widget buildTestApp(WidgetBuilder builder) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: Builder(builder: builder)),
  );
}

void main() {
  setUpAll(() {
    // Avoid GoogleFonts trying to download fonts during tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('DwaarSnackBar.show displays correct success theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp((context) {
        return ElevatedButton(
          onPressed: () {
            DwaarSnackBar.show(
              context,
              message: 'Success Message',
              type: SnackBarType.success,
            );
          },
          child: const Text('Show Success'),
        );
      }),
    );

    await tester.tap(find.text('Show Success'));
    await tester.pump(); // Start SnackBar animation
    await tester.pump(const Duration(milliseconds: 750)); // Settle animation

    // Verify SnackBar exists
    final snackBarFinder = find.byType(SnackBar);
    expect(snackBarFinder, findsOneWidget);

    final SnackBar snackBar = tester.widget(snackBarFinder);
    expect(snackBar.backgroundColor, AppColors.statusCompletedBg);

    // Verify Shape and Border color
    final shape = snackBar.shape as RoundedRectangleBorder;
    expect(shape.side.color, const Color(0xFFBBF7D0));
    expect(shape.side.width, 1.5);

    // Verify Text
    expect(find.text('Success Message'), findsOneWidget);

    // Verify Icon
    final iconFinder = find.byIcon(Icons.check_circle_rounded);
    expect(iconFinder, findsOneWidget);
    final Icon icon = tester.widget(iconFinder);
    expect(icon.color, AppColors.statusCompletedText);
  });

  testWidgets(
    'DwaarSnackBar.showErrorFailure displays correct error theme and localized message',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp((context) {
          return ElevatedButton(
            onPressed: () {
              DwaarSnackBar.showErrorFailure(
                context,
                const UnknownFailure(message: 'error', code: '42501'),
              );
            },
            child: const Text('Show Error'),
          );
        }),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final SnackBar snackBar = tester.widget(snackBarFinder);
      expect(snackBar.backgroundColor, AppColors.statusCancelledBg);

      // Verify Shape and Border color
      final shape = snackBar.shape as RoundedRectangleBorder;
      expect(shape.side.color, const Color(0xFFFECACA));

      // Verify Icon
      final iconFinder = find.byIcon(Icons.error_rounded);
      expect(iconFinder, findsOneWidget);
      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, AppColors.statusCancelledText);

      // Verify translated text is present (in English, code '42501' is errorPermissionDenied)
      expect(
        find.text(
          'Sorry, you do not have sufficient permissions to perform this action.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('DwaarSnackBar warning and info themes display correctly', (
    tester,
  ) async {
    // Test Warning
    await tester.pumpWidget(
      buildTestApp((context) {
        return ElevatedButton(
          onPressed: () {
            DwaarSnackBar.show(
              context,
              message: 'Warning Message',
              type: SnackBarType.warning,
            );
          },
          child: const Text('Show Warning'),
        );
      }),
    );

    await tester.tap(find.text('Show Warning'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, AppColors.statusPendingBg);
    final shape = snackBar.shape as RoundedRectangleBorder;
    expect(shape.side.color, const Color(0xFFFDE68A));
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);

    // Test Info
    await tester.pumpWidget(
      buildTestApp((context) {
        return ElevatedButton(
          onPressed: () {
            DwaarSnackBar.show(
              context,
              message: 'Info Message',
              type: SnackBarType.info,
            );
          },
          child: const Text('Show Info'),
        );
      }),
    );

    await tester.tap(find.text('Show Info'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    final infoSnackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(infoSnackBar.backgroundColor, AppColors.statusInTransitBg);
    final infoShape = infoSnackBar.shape as RoundedRectangleBorder;
    expect(infoShape.side.color, const Color(0xFFBFDBFE));
    expect(find.byIcon(Icons.info_rounded), findsOneWidget);
  });
}
