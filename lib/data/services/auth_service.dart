/// Abstract interface for authentication operations.
/// Swap [MockAuthService] for a real implementation when a backend is wired up.
abstract interface class IAuthService {
  Future<Map<String, dynamic>> loginRaw(String identifier, String role);
}

/// Mock implementation — simulates a network round-trip with a fixed delay.
class MockAuthService implements IAuthService {
  @override
  Future<Map<String, dynamic>> loginRaw(String identifier, String role) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return {
      'id': 'u_12345',
      'name': 'Mock User',
      'role': role,
      'token': 'mock_jwt_token',
    };
  }
}
