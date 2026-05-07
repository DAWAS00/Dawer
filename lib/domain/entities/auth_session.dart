import '../../data/models/user_role.dart';

class AuthSession {
  final String userId;
  final String userName;
  final UserRole role;
  final SupplierType? supplierType;
  final List<String> categories;

  const AuthSession({
    required this.userId,
    required this.userName,
    required this.role,
    this.supplierType,
    this.categories = const [],
  });
}
