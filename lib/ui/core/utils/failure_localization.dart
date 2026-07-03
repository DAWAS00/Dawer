import 'package:flutter/widgets.dart';
import '../../../domain/failures/app_failure.dart';
import '../../../l10n/l10n.dart';

extension FailureLocalizationX on AppFailure {
  /// Translates an [AppFailure] to a clean, user-friendly localized message.
  String getLocalizedMessage(BuildContext context) {
    final l10n = context.l10n;

    if (this is NetworkFailure) {
      return l10n.errorConnectionFailed;
    }

    final errCode = code;
    if (errCode != null) {
      switch (errCode) {
        // Postgres SQLSTATE codes
        case '42501':
          return l10n.errorPermissionDenied;
        case '23505':
          return l10n.errorUniqueViolation;
        case '23503':
          return l10n.errorForeignKeyViolation;
        case '57014':
          return l10n.errorTimeout;
        case '08006':
        case '08001':
          return l10n.errorConnectionFailed;

        // Custom Auth Error codes
        case 'phone_not_registered':
          return l10n.errorPhoneNotRegistered;
        case 'invalid_otp':
          return l10n.errorInvalidOtp;
        case 'otp_limit_exceeded':
          return l10n.errorOtpLimitExceeded;
      }
    }

    // Inspect the message substring if the code is missing or unhandled
    final lowercaseMsg = message.toLowerCase();
    if (lowercaseMsg.contains('violates row-level security policy') ||
        lowercaseMsg.contains('insufficient privilege') ||
        lowercaseMsg.contains('permission denied')) {
      return l10n.errorPermissionDenied;
    }
    if (lowercaseMsg.contains('unique constraint') ||
        lowercaseMsg.contains('duplicate key') ||
        lowercaseMsg.contains('already exists')) {
      return l10n.errorUniqueViolation;
    }
    if (lowercaseMsg.contains('foreign key') ||
        lowercaseMsg.contains('violates foreign key')) {
      return l10n.errorForeignKeyViolation;
    }
    if (lowercaseMsg.contains('timeout') ||
        lowercaseMsg.contains('timed out')) {
      return l10n.errorTimeout;
    }
    if (lowercaseMsg.contains('rate limit') ||
        lowercaseMsg.contains('too many requests') ||
        lowercaseMsg.contains('sms limit')) {
      return l10n.errorOtpLimitExceeded;
    }

    // Fallback: If no match, return a general unknown error message
    return l10n.errorUnknown;
  }
}
