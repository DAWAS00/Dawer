# Dwaar (دوّر) — SnackBars & Exception Mapping Improvement Plan

This document outlines the system design plan and implementation specifications for translating database and API errors into user-friendly localized messages, and surfacing them using a unified, visually premium snackbar component (**DwaarSnackBar**).

---

## 1. Current State Analysis & Problems

1. **Raw Database/API Error Leakage**: In repositories (e.g., `SupabaseOrderRepository`), when `PostgrestException` is caught, the raw error `message` and `code` are propagated via `UnknownFailure`. In the UI (e.g., `home_router.dart`), this raw message is appended directly: `Text('تعذّر حفظ التغيير: $message')`. This exposes raw database schema information, RLS policies, and SQL terms directly to the user (often in English) in an Arabic-first application.
2. **Inconsistent Snackbar UI & Style**: There are over 70 occurrences of `ScaffoldMessenger.of(context).showSnackBar` throughout the codebase, utilizing different durations, margins, backgrounds, and font weights, without standard color matching or icons.
3. **Typography & Hierarchy**: Most snackbars use default fallback text styling or arbitrary styles, rather than strictly using the brand-aligned **Cairo** font with proper weights, line heights, and margins.
4. **Lack of Standard Warning, Info, and Success Styling**: There is no easy, standard way to trigger colored status-dependent alerts (e.g., green for Success, red for Error, amber for Warning, blue for Info).

---

## 2. Database Exception Mapping Strategy

We must capture raw PostgreSQL/Supabase errors inside `AppFailure` (specifically using SQLSTATE codes or message inspection) and map them to clean, user-friendly localized messages in the UI.

### Common PostgreSQL SQLSTATE / Auth Error Codes & Mappings

| SQLSTATE / Error Code | Error Category | Postgres Error Name | Raw Error String Example | Localized Arabic Message | Localized English Message |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`42501`** | Security / Permission | `insufficient_privilege` | `new row violates row-level security policy...` | عذراً، ليس لديك الصلاحية لإتمام هذه العملية. | Sorry, you do not have permission to perform this action. |
| **`23505`** | Data Integrity | `unique_violation` | `duplicate key value violates unique constraint...` | هذه البيانات مسجلة مسبقاً في النظام. | This record already exists in the system. |
| **`23503`** | Data Integrity | `foreign_key_violation` | `insert or update violates foreign key constraint...` | البيانات المرتبطة غير صحيحة أو لم تعد موجودة. | Related data is invalid or no longer exists. |
| **`57014`** | Network / Timeout | `query_canceled` | `canceling statement due to statement timeout...` | انتهت مهلة الاتصال بالخادم. يرجى المحاولة لاحقاً. | Connection timed out. Please try again later. |
| **`08006`** / **`08001`** | Network | `connection_failure` | `failed host lookup` or `socket connection failed` | فشل الاتصال بالشبكة. يرجى التحقق من اتصالك بالإنترنت. | Network connection failed. Please check your internet. |
| **`phone_not_registered`** | Auth | Custom (Auth) | Profile not found | رقم الهاتف غير مسجل. يرجى إنشاء حساب جديد. | Phone number is not registered. Please sign up. |
| **`invalid_otp`** | Auth | Custom (Auth) | SMS OTP verification failed | رمز التحقق المدخل غير صحيح. يرجى إعادة المحاولة. | The verification code is incorrect. Please try again. |
| **`otp_limit_exceeded`** | Auth | Custom (Auth) | `over_sms_send_limit` or `rate limit exceeded` | تم تجاوز الحد الأقصى لطلب الرموز. حاول بعد قليل. | OTP request limit exceeded. Please try again later. |

### Presentation Layer Localization Extension

Since the domain layer (`lib/domain/failures/app_failure.dart`) should not import Flutter or UI packages like `BuildContext` or `AppLocalizations`, the translation mapping logic will reside in a new UI presentation utility: `lib/ui/core/utils/failure_localization.dart`.

```dart
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
    if (lowercaseMsg.contains('timeout') || lowercaseMsg.contains('timed out')) {
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
```

---

## 3. UI Design Specifications for `DwaarSnackBar`

The **DwaarSnackBar** helper will format standard floating snackbars with consistent margins, custom colored borders, distinct status icons, and Cairo typography.

### Design Tokens & Color Harmony

The snackbar background, border, text, and icon colors are mapped directly to `AppColors` semantic tokens:

1. **Success (النجاح)**:
   - **Background**: `AppColors.statusCompletedBg` (`#DCFCE7`)
   - **Border**: `#BBF7D0` (Soft Emerald Border)
   - **Foreground & Icon Color**: `AppColors.statusCompletedText` (`#166534`)
   - **Icon**: `Icons.check_circle_rounded`

2. **Error (الخطأ)**:
   - **Background**: `AppColors.statusCancelledBg` (`#FEE2E2`)
   - **Border**: `#FECACA` (Soft Rose Border)
   - **Foreground & Icon Color**: `AppColors.statusCancelledText` (`#991B1B`)
   - **Icon**: `Icons.error_rounded`

3. **Warning (التنبيه)**:
   - **Background**: `AppColors.statusPendingBg` (`#FEF3C7`)
   - **Border**: `#FDE68A` (Soft Amber Border)
   - **Foreground & Icon Color**: `AppColors.statusPendingText` (`#92400E`)
   - **Icon**: `Icons.warning_rounded`

4. **Info (المعلومات)**:
   - **Background**: `AppColors.statusInTransitBg` (`#DBEAFE`)
   - **Border**: `#BFDBFE` (Soft Blue Border)
   - **Foreground & Icon Color**: `AppColors.statusInTransitText` (`#1E40AF`)
   - **Icon**: `Icons.info_rounded`

### Typography

- **Font Family**: Cairo (`GoogleFonts.cairo`)
- **Font Size**: `14`
- **Font Weight**: `FontWeight.w600` (Semi-bold to ensure excellent readability on all status backgrounds)
- **Line Height**: Balanced with appropriate vertical padding (`12`-`16` logical pixels).

---

## 4. `DwaarSnackBar` Implementation Draft

The helper class will live in `lib/ui/core/components/dwaar_snackbar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/failures/app_failure.dart';
import '../utils/failure_localization.dart';

enum SnackBarType { success, error, warning, info }

class SnackBarThemeColors {
  final Color background;
  final Color border;
  final Color foreground;

  const SnackBarThemeColors({
    required this.background,
    required this.border,
    required this.foreground,
  });
}

class DwaarSnackBar {
  static SnackBarThemeColors _getColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const SnackBarThemeColors(
          background: AppColors.statusCompletedBg,
          border: Color(0xFFBBF7D0),
          foreground: AppColors.statusCompletedText,
        );
      case SnackBarType.error:
        return const SnackBarThemeColors(
          background: AppColors.statusCancelledBg,
          border: Color(0xFFFECACA),
          foreground: AppColors.statusCancelledText,
        );
      case SnackBarType.warning:
        return const SnackBarThemeColors(
          background: AppColors.statusPendingBg,
          border: Color(0xFFFDE68A),
          foreground: AppColors.statusPendingText,
        );
      case SnackBarType.info:
        return const SnackBarThemeColors(
          background: AppColors.statusInTransitBg,
          border: Color(0xFFBFDBFE),
          foreground: AppColors.statusInTransitText,
        );
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
    }
  }

  /// Triggers a localized snackbar for an [AppFailure].
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showErrorFailure(
    BuildContext context,
    AppFailure failure, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = failure.getLocalizedMessage(context);
    return show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  /// Base method to show a beautifully styled Dwaar Snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return null;

    final themeColors = _getColors(type);
    final icon = _getIcon(type);

    messenger.hideCurrentSnackBar();

    return messenger.showSnackBar(
      SnackBar(
        backgroundColor: themeColors.background,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: themeColors.border,
            width: 1.5,
          ),
        ),
        content: Row(
          children: [
            Icon(
              icon,
              color: themeColors.foreground,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.cairo(
                  color: themeColors.foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: themeColors.foreground,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
```

---

## 5. Step-by-Step Implementation Instructions

### Step 1: Append Localization Keys

Add the following keys to `lib/l10n/app_ar.arb`:

```json
  "errorConnectionFailed": "فشل الاتصال بالشبكة. يرجى التحقق من اتصالك بالإنترنت وإعادة المحاولة.",
  "errorPermissionDenied": "عذراً، ليس لديك الصلاحية الكافية لإتمام هذه العملية.",
  "errorUniqueViolation": "البيانات التي تحاول إدخالها مسجلة مسبقاً في النظام.",
  "errorForeignKeyViolation": "البيانات المرتبطة غير صحيحة أو لم تعد موجودة.",
  "errorTimeout": "انتهت مهلة الاتصال بالخادم. يرجى المحاولة لاحقاً.",
  "errorPhoneNotRegistered": "رقم الهاتف غير مسجل. يرجى إنشاء حساب جديد.",
  "errorInvalidOtp": "رمز التحقق المدخل غير صحيح. يرجى إعادة المحاولة.",
  "errorOtpLimitExceeded": "لقد تجاوزت الحد الأقصى لطلب الرموز. يرجى المحاولة بعد قليل.",
  "errorUnknown": "حدث خطأ غير متوقع في النظام. يرجى المحاولة لاحقاً."
```

Add corresponding values to `lib/l10n/app_en.arb`:

```json
  "errorConnectionFailed": "Network connection failed. Please check your internet connection and try again.",
  "errorPermissionDenied": "Sorry, you do not have sufficient permissions to perform this action.",
  "errorUniqueViolation": "The data you are trying to enter already exists in the system.",
  "errorForeignKeyViolation": "The associated data is invalid or no longer exists.",
  "errorTimeout": "Server connection timed out. Please try again later.",
  "errorPhoneNotRegistered": "Phone number is not registered. Please create a new account.",
  "errorInvalidOtp": "The verification code is incorrect. Please try again.",
  "errorOtpLimitExceeded": "You have exceeded the OTP request limit. Please try again in a few minutes.",
  "errorUnknown": "An unexpected system error occurred. Please try again later."
```

After updating these files, regenerate the localization files by running:
```bash
flutter gen-l10n
```

### Step 2: Implement Failure Localization Extension
Create the file `lib/ui/core/utils/failure_localization.dart` and insert the mapping code defined in **Section 2**.

### Step 3: Implement `DwaarSnackBar` Component
Create the file `lib/ui/core/components/dwaar_snackbar.dart` and insert the component code defined in **Section 4**.

### Step 4: Refactor Root Views (`home_router.dart` and others)
Update `home_router.dart` inside the `_showErrorSnackBar` method:

```diff
-  void _showErrorSnackBar(AppFailure failure) {
-    final messenger = ScaffoldMessenger.maybeOf(context);
-    if (messenger == null) return;
-    final message = failure.message;
-    // Clear so the same error isn't re-shown on the next notifyListeners().
-    context.read<AppOrderStore>().clearError();
-    messenger
-      ..hideCurrentSnackBar()
-      ..showSnackBar(
-        SnackBar(
-          content: Text('تعذّر حفظ التغيير: $message'),
-          behavior: SnackBarBehavior.floating,
-          duration: const Duration(seconds: 4),
-        ),
-      );
-  }
+  void _showErrorSnackBar(AppFailure failure) {
+    // Clear so the same error isn't re-shown on the next notifyListeners().
+    context.read<AppOrderStore>().clearError();
+    DwaarSnackBar.showErrorFailure(context, failure);
+  }
```

Then, sequentially migrate other ScaffoldMessenger calls in the screens (e.g. `signup_role_details_screen.dart`, `driver_home_view.dart`, `restaurant_home_view.dart`, `market_item_details_view.dart`) to use `DwaarSnackBar.show` or `DwaarSnackBar.showErrorFailure` for consistent UX.

### Step 5: Test and Verify
1. **Unit Tests**: Create a unit test file `test/ui/core/utils/failure_localization_test.dart` to assert that different error codes (`42501`, `23505`, etc.) resolve to correct translations when given a mocked `BuildContext`.
2. **Widget Tests**: Create a widget test `test/ui/core/components/dwaar_snackbar_test.dart` to verify that the snackbar renders correct colors, icons, and text styles under light and dark theme configurations.
3. **Execution**: Run `flutter test` to ensure all tests pass cleanly.
