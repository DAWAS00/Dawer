import 'dart:async';

class AuthService {
  // Stateless API Wrapper for Authentication
  Future<Map<String, dynamic>> loginRaw(String phone, String role) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock response
    return {
      'id': 'u_12345',
      'name': 'Mock User',
      'role': role,
      'token': 'mock_jwt_token',
    };
  }
}
