import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _apiService;
  User? _currentUser;

  AuthRepository(this._apiService);

  Future<User> login(String phone, String role) async {
    final rawData = await _apiService.loginRaw(phone, role);
    
    final user = User(
      id: rawData['id'],
      name: rawData['name'],
      role: rawData['role'],
    );
    
    _currentUser = user;
    return user;
  }

  User? get currentUser => _currentUser;
}
