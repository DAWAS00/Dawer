import '../../l10n/l10n.dart';
import 'package:flutter/widgets.dart';

/// Resolves ViewModel error keys to localized strings.
///
/// The ViewModel stores error codes (not English text) to stay
/// context-free. This helper maps those codes to l10n strings.
String? resolveErrorKey(BuildContext context, String? errorKey) {
  if (errorKey == null) return null;
  final l10n = context.l10n;
  switch (errorKey) {
    case 'restaurantSignupErrorCompanyNameRequired':
      return l10n.restaurantSignupErrorCompanyNameRequired;
    case 'restaurantSignupErrorOwnerNameRequired':
      return l10n.restaurantSignupErrorOwnerNameRequired;
    case 'restaurantSignupErrorTaglineRequired':
      return l10n.restaurantSignupErrorTaglineRequired;
    case 'restaurantSignupErrorAiProfileRequired':
      return l10n.restaurantSignupErrorAiProfileRequired;
    case 'restaurantSignupErrorCategoryRequired':
      return l10n.restaurantSignupErrorCategoryRequired;
    case 'restaurantSignupErrorAddressRequired':
      return l10n.restaurantSignupErrorAddressRequired;
    case 'restaurantSignupErrorVerificationRequired':
      return l10n.restaurantSignupErrorVerificationRequired;
    case 'restaurantSignupErrorAiGenerationFailed':
      return l10n.restaurantSignupErrorAiGenerationFailed;
    case 'restaurantSignupErrorVerificationFailed':
      return l10n.restaurantSignupErrorVerificationFailed;
    case 'restaurantSignupErrorTaglineFirst':
      return l10n.restaurantSignupErrorTaglineFirst;
    case 'restaurantSignupErrorAddressFirst':
      return l10n.restaurantSignupErrorAddressFirst;
    case 'aiValidationStatusSuccess':
      return l10n.aiValidationStatusSuccess;
    case 'aiValidationStatusInvalid':
      return l10n.aiValidationStatusInvalid;
    case 'aiValidationStatusErrorUnknown':
      return l10n.aiValidationStatusErrorUnknown;
    default:
      return errorKey; // Fallback: return raw key if no mapping found
  }
}
