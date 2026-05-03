sealed class AppFailure {
  final String message;
  final String? code;

  const AppFailure({required this.message, this.code});
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message = 'تحقق من اتصالك بالإنترنت',
    super.code,
  });
}

final class AuthFailure extends AppFailure {
  const AuthFailure({required super.message, super.code});
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({required super.message, super.code});
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure({required super.message, super.code});
}

final class StorageFailure extends AppFailure {
  const StorageFailure({required super.message, super.code});
}

/// Field-level validation failure. [fieldErrors] is keyed by request field
/// name (e.g. `email`, `password`) so ViewModels can map straight onto inputs.
final class ValidationFailure extends AppFailure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.code,
  });
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure({required super.message, super.code});

  UnknownFailure.fromException(Object? cause)
      : super(message: cause?.toString() ?? 'خطأ غير معروف');
}
