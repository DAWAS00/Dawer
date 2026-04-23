/// Abstract interface for authentication operations.
abstract interface class IAuthService {
  Future<Map<String, dynamic>> loginRaw(String identifier, String role);
}

/// Lightweight stub used in tests that need an [IAuthService] without a real
/// [LocalAuthService]/[LocalStore] pair.
class MockAuthService implements IAuthService {
  @override
  Future<Map<String, dynamic>> loginRaw(String identifier, String role) async {
    final normalized = identifier.trim();
    if (normalized.isEmpty) {
      throw const FormatException('identifier is required');
    }
    return {
      'id': 'local_$normalized',
      'name': normalized,
      'role': role,
      'token': 'local_session_token',
    };
  }
}
