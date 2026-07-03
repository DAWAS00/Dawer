import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/domain/failures/app_failure.dart';
import 'package:dwaar/ui/core/utils/failure_localization.dart';
import 'package:dwaar/l10n/l10n.dart';

Widget buildTestWidget({
  required Locale locale,
  required WidgetBuilder builder,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: Scaffold(body: Builder(builder: builder)),
  );
}

void main() {
  group('FailureLocalizationX Arabic tests', () {
    testWidgets('maps NetworkFailure to errorConnectionFailed', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ar'),
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      );

      const failure = NetworkFailure();
      expect(
        failure.getLocalizedMessage(testContext),
        testContext.l10n.errorConnectionFailed,
      );
    });

    testWidgets('maps error codes correctly', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ar'),
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      );

      final mappings = {
        '42501': testContext.l10n.errorPermissionDenied,
        '23505': testContext.l10n.errorUniqueViolation,
        '23503': testContext.l10n.errorForeignKeyViolation,
        '57014': testContext.l10n.errorTimeout,
        '08006': testContext.l10n.errorConnectionFailed,
        '08001': testContext.l10n.errorConnectionFailed,
        'phone_not_registered': testContext.l10n.errorPhoneNotRegistered,
        'invalid_otp': testContext.l10n.errorInvalidOtp,
        'otp_limit_exceeded': testContext.l10n.errorOtpLimitExceeded,
      };

      mappings.forEach((code, expectedMessage) {
        final failure = UnknownFailure(
          message: 'some error message',
          code: code,
        );
        expect(failure.getLocalizedMessage(testContext), expectedMessage);
      });
    });

    testWidgets('maps message substrings correctly when code is missing', (
      tester,
    ) async {
      late BuildContext testContext;
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ar'),
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      );

      final mappings = {
        'violates row-level security policy':
            testContext.l10n.errorPermissionDenied,
        'insufficient privilege': testContext.l10n.errorPermissionDenied,
        'permission denied': testContext.l10n.errorPermissionDenied,
        'unique constraint': testContext.l10n.errorUniqueViolation,
        'duplicate key': testContext.l10n.errorUniqueViolation,
        'already exists': testContext.l10n.errorUniqueViolation,
        'foreign key': testContext.l10n.errorForeignKeyViolation,
        'violates foreign key': testContext.l10n.errorForeignKeyViolation,
        'timeout': testContext.l10n.errorTimeout,
        'timed out': testContext.l10n.errorTimeout,
        'rate limit': testContext.l10n.errorOtpLimitExceeded,
        'too many requests': testContext.l10n.errorOtpLimitExceeded,
        'sms limit': testContext.l10n.errorOtpLimitExceeded,
        'completely unknown message': testContext.l10n.errorUnknown,
      };

      mappings.forEach((message, expectedMessage) {
        final failure = UnknownFailure(message: message);
        expect(failure.getLocalizedMessage(testContext), expectedMessage);
      });
    });
  });

  group('FailureLocalizationX English tests', () {
    testWidgets('maps NetworkFailure to errorConnectionFailed', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('en'),
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      );

      const failure = NetworkFailure();
      expect(
        failure.getLocalizedMessage(testContext),
        testContext.l10n.errorConnectionFailed,
      );
    });

    testWidgets('maps error codes correctly', (tester) async {
      late BuildContext testContext;
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('en'),
          builder: (context) {
            testContext = context;
            return const SizedBox();
          },
        ),
      );

      final mappings = {
        '42501': testContext.l10n.errorPermissionDenied,
        '23505': testContext.l10n.errorUniqueViolation,
        '23503': testContext.l10n.errorForeignKeyViolation,
        '57014': testContext.l10n.errorTimeout,
        '08006': testContext.l10n.errorConnectionFailed,
        '08001': testContext.l10n.errorConnectionFailed,
        'phone_not_registered': testContext.l10n.errorPhoneNotRegistered,
        'invalid_otp': testContext.l10n.errorInvalidOtp,
        'otp_limit_exceeded': testContext.l10n.errorOtpLimitExceeded,
      };

      mappings.forEach((code, expectedMessage) {
        final failure = UnknownFailure(
          message: 'some error message',
          code: code,
        );
        expect(failure.getLocalizedMessage(testContext), expectedMessage);
      });
    });
  });
}
