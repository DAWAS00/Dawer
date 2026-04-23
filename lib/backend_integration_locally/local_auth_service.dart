import '../data/models/user_role.dart';
import '../data/services/user_signup_service.dart'
    show SignUpRequest, SignUpException;
import 'local_store.dart';
import 'models/local_user.dart';
import 'password_hasher.dart';

/// Local email/phone + password auth service.
///
/// Owned by `main.dart` via Provider. Services/ViewModels that need auth
/// receive it by constructor injection (never read SharedPreferences directly).
///
/// Rate limiting is kept in-memory (process lifetime only) and is scoped per
/// normalized identifier. It is intentionally NOT persisted — the goal is to
/// slow down casual brute forcing within a session, not to survive process
/// restart.
class LocalAuthService {
  LocalAuthService({required LocalStore store}) : _store = store;

  final LocalStore _store;

  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(seconds: 60);
  static final Map<String, _Attempts> _attemptsByIdentifier = {};

  // ── Sign-up ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signUp(SignUpRequest request) async {
    final errors = request.validate();
    if (errors.isNotEmpty) {
      throw SignUpException('invalid signup request', fieldErrors: errors);
    }
    final pw = request.password;
    if (pw == null || pw.isEmpty) {
      throw const SignUpException(
        'كلمة المرور مطلوبة',
        fieldErrors: {'password': 'كلمة المرور مطلوبة'},
      );
    }

    final users = _store.readUsers();
    final email = request.email?.trim().toLowerCase();
    final phone = request.phone.trim().toLowerCase();

    final exists = users.any((row) {
      final rowPhone = (row['phone'] as String?)?.trim().toLowerCase();
      final rowEmail = (row['email'] as String?)?.trim().toLowerCase();
      return rowPhone == phone ||
          (email != null && email.isNotEmpty && rowEmail == email);
    });
    if (exists) {
      throw const SignUpException('يوجد حساب بهذه البيانات بالفعل');
    }

    final salt = PasswordHasher.newSalt();
    final hash = PasswordHasher.hash(password: pw, saltBase64: salt);
    final user = _buildUser(request, hash: hash, salt: salt);

    users.add(user.toJson());
    await _store.writeUsers(users);
    await _store.setCurrentUserId(user.id);
    return user.toJson();
  }

  // ── Sign-in ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signIn({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim().toLowerCase();
    if (id.isEmpty) {
      throw const SignUpException('أدخل البريد الإلكتروني أو رقم الهاتف');
    }
    if (password.isEmpty) {
      throw const SignUpException('أدخل كلمة المرور');
    }

    _checkLockout(id);

    final users = _store.readUsers();
    Map<String, dynamic>? match;
    for (final row in users) {
      final rowPhone = (row['phone'] as String?)?.trim().toLowerCase();
      final rowEmail = (row['email'] as String?)?.trim().toLowerCase();
      if (rowPhone == id || (rowEmail != null && rowEmail == id)) {
        match = row;
        break;
      }
    }

    if (match == null) {
      _registerFailure(id);
      throw const SignUpException('بيانات الدخول غير صحيحة');
    }

    final salt = match['password_salt'] as String? ?? '';
    final hash = match['password_hash'] as String? ?? '';
    if (salt.isEmpty || hash.isEmpty) {
      _registerFailure(id);
      throw const SignUpException('بيانات الدخول غير صحيحة');
    }

    final ok = PasswordHasher.verify(
      password: password,
      saltBase64: salt,
      expectedHashBase64: hash,
    );
    if (!ok) {
      _registerFailure(id);
      throw const SignUpException('بيانات الدخول غير صحيحة');
    }

    _attemptsByIdentifier.remove(id);
    final userId = match['id'] as String;
    await _store.setCurrentUserId(userId);
    return Map<String, dynamic>.from(match);
  }

  // ── Session ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final id = _store.getCurrentUserId();
    if (id == null) return null;
    final users = _store.readUsers();
    for (final row in users) {
      if (row['id'] == id) return Map<String, dynamic>.from(row);
    }
    return null;
  }

  Future<void> logout() async {
    await _store.clearCurrentUserId();
  }

  // ── Rate limiting ────────────────────────────────────────────────────────

  void _checkLockout(String id) {
    final entry = _attemptsByIdentifier[id];
    if (entry == null) return;
    if (entry.failures < _maxFailedAttempts) return;
    final unlockAt = entry.lastFailure.add(_lockoutDuration);
    if (DateTime.now().isBefore(unlockAt)) {
      throw const SignUpException('تم إيقاف المحاولات مؤقتاً، حاول بعد دقيقة');
    }
    // Cooldown expired — reset so the user can try again.
    _attemptsByIdentifier.remove(id);
  }

  void _registerFailure(String id) {
    final now = DateTime.now();
    final entry = _attemptsByIdentifier[id];
    if (entry == null) {
      _attemptsByIdentifier[id] = _Attempts(1, now);
    } else {
      _attemptsByIdentifier[id] = _Attempts(entry.failures + 1, now);
    }
  }

  /// Test-only helper to clear the in-memory rate-limit table between tests.
  static void debugResetRateLimiter() => _attemptsByIdentifier.clear();

  // ── Helpers ──────────────────────────────────────────────────────────────

  LocalUser _buildUser(
    SignUpRequest req, {
    required String hash,
    required String salt,
  }) {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    String? trimOrNull(String? v) {
      if (v == null) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    return LocalUser(
      id: id,
      name: req.name.trim(),
      phone: req.phone.trim(),
      email: trimOrNull(req.email),
      role: req.role.dbValue,
      supplierType: req.supplierType?.dbValue,
      vehiclePlate: trimOrNull(req.vehiclePlate),
      vehicleModel: trimOrNull(req.vehicleModel),
      vehicleColor: trimOrNull(req.vehicleColor),
      passwordHash: hash,
      passwordSalt: salt,
      createdAt: now.toIso8601String(),
    );
  }
}

class _Attempts {
  final int failures;
  final DateTime lastFailure;
  const _Attempts(this.failures, this.lastFailure);
}
