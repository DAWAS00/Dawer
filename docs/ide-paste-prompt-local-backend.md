# IDE Paste Prompt — Dwaar Local Backend Implementation

> Copy everything between the triple-backtick fences and paste into your IDE AI
> (Cursor Composer, Copilot Chat, etc.). No edits needed before pasting.

---

```
You are implementing the local backend for Dwaar — an Arabic Flutter/Dart
waste-recycling app (RTL, Jordan). The project is at C:/Users/dawas/dwaar.

## What already exists (do NOT change unless told)

- lib/data/services/auth_service.dart
  Contains IAuthService interface and a stub LocalAuthService.loginRaw().
  After this task, LocalAuthService here becomes a thin alias for the real one.

- lib/data/services/user_signup_service.dart
  Contains SignUpRequest, SignUpException, and UserSignUpService.
  UserSignUpService uses in-memory maps (_otpByDestination, _profilesByDestination)
  as a placeholder. After this task, it delegates to LocalAuthService from
  lib/backend_integration_locally/.

- lib/data/services/reward_service.dart — pure local calculation, no changes needed.
- lib/ui/features/auth/viewmodels/signup_viewmodel.dart — no changes needed.
- lib/ui/features/auth/viewmodels/verification_viewmodel.dart — no changes needed.
- lib/ui/features/auth/viewmodels/login_viewmodel.dart — no changes needed.
- lib/main.dart — Supabase already removed; needs LocalStore + LocalAuthService init.

## Your task: create lib/backend_integration_locally/

Create this exact folder structure. All files must compile with zero analyzer errors.

### File 1: lib/backend_integration_locally/models/local_user.dart

A plain Dart class with these fields:
  final String id;         // UUID string
  final String name;
  final String phone;
  final String? email;
  final String role;       // matches UserRole.dbValue: 'driver'|'supplier'|'recyclingCo'
  final String? supplierType;  // 'individual'|'storeBusiness'|null
  final String? vehiclePlate;
  final String? vehicleModel;
  final String? vehicleColor;
  final String createdAt;  // ISO 8601

Add:
  factory LocalUser.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
  LocalUser copyWith({...})

Import nothing outside dart:core.

### File 2: lib/backend_integration_locally/models/otp_record.dart

A plain Dart class:
  final String code;         // 6-digit string
  final String expiresAt;    // ISO 8601
  final int attempts;
  final int maxAttempts;     // default 3

Add:
  bool get isExpired  // DateTime.now().isAfter(DateTime.parse(expiresAt))
  bool get isExhausted  // attempts >= maxAttempts
  factory OtpRecord.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
  OtpRecord withAttempt()  // returns copy with attempts + 1

Import nothing outside dart:core.

### File 3: lib/backend_integration_locally/local_store.dart

A class wrapping SharedPreferences. Static async factory:
  static Future<LocalStore> init() async { ... }

SharedPreferences keys:
  static const _usersKey = 'dwaar_users';
  static const _currentUserKey = 'dwaar_current_user_id';
  String _otpKey(String identifier) => 'dwaar_otp_${identifier.trim().toLowerCase()}';

Methods (all sync except init):
  List<Map<String, dynamic>> readUsers()
  Future<void> writeUsers(List<Map<String, dynamic>> users)
  OtpRecord? readOtp(String identifier)
  Future<void> writeOtp(String identifier, OtpRecord record)
  Future<void> clearOtp(String identifier)
  String? getCurrentUserId()
  Future<void> setCurrentUserId(String id)
  Future<void> clearCurrentUserId()

Imports: dart:convert, package:shared_preferences/shared_preferences.dart,
         local models (otp_record.dart).

### File 4: lib/backend_integration_locally/local_auth_service.dart

This is the core service. It depends on LocalStore and LocalNotificationService.

Constructor:
  LocalAuthService({required LocalStore store, BuildContext? context})

OTP rules:
  - 6 digits, generated with dart:math Random.secure()
  - Expiry: 120 seconds from generation
  - Max attempts: 3 per OTP record
  - On sendOtp: generate code, persist via LocalStore.writeOtp(), call
    LocalNotificationService.show(context, 'رمز التحقق: $code') if context != null

Public API:
  Future<void> sendOtp(String identifier, {BuildContext? context})
    - normalizes identifier (trim + lowercase)
    - generates 6-digit OTP
    - stores OtpRecord in LocalStore
    - shows in-app banner

  Future<Map<String, dynamic>?> verifyOtp(
    String identifier,
    String code, {
    SignUpRequest? pendingRequest,
  })
    - loads OtpRecord; if null: throw SignUpException('لم يتم إرسال رمز')
    - if isExpired: throw SignUpException('انتهت صلاحية الرمز، اضغط إعادة الإرسال')
    - if isExhausted: throw SignUpException('تجاوزت الحد المسموح، اضغط إعادة الإرسال')
    - if code != record.code: persist withAttempt(); throw SignUpException('الرمز غير صحيح')
    - on success: clearOtp(); find or create user; set current user id; return user map

  Finding/creating user logic inside verifyOtp:
    - search readUsers() for matching phone OR email (case-insensitive)
    - if found: setCurrentUserId; return user.toJson()
    - if not found and pendingRequest == null: throw SignUpException('لا يوجد حساب، سجّل أولاً')
    - if not found and pendingRequest != null: create LocalUser from request (uuid via
      DateTime.now().millisecondsSinceEpoch.toString()), append to users list,
      persist, setCurrentUserId, return user.toJson()

  Future<Map<String, dynamic>?> getCurrentUser()
    - read getCurrentUserId(); if null return null
    - find in readUsers() by id; return toJson() or null

  Future<void> logout()
    - clearCurrentUserId()

Imports:
  dart:math, dart:convert (for uuid fallback),
  package:flutter/material.dart (for BuildContext),
  local_store.dart, models/local_user.dart, models/otp_record.dart,
  package:dwaar/data/services/user_signup_service.dart (for SignUpRequest, SignUpException)

### File 5: lib/backend_integration_locally/local_notification_service.dart

Static overlay banner:
  static OverlayEntry? _current;

  static void show(BuildContext context, String message) {
    _current?.remove();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => _OtpBanner(message: message, onDismiss: () {
      entry.remove();
      _current = null;
    }));
    _current = entry;
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 8), () {
      if (_current == entry) {
        entry.remove();
        _current = null;
      }
    });
  }

_OtpBanner is a StatelessWidget:
  - Positioned at top, full width, safe area padding
  - Background: Color(0xFF06402B)  // AppColors.primaryGreen equivalent
  - RTL text direction
  - Icon: Icons.message_outlined in white
  - Message in white Cairo font, size 14
  - Tap to dismiss (calls onDismiss)
  - Show for 8 seconds then auto-dismiss

Imports: package:flutter/material.dart only.

## After creating the 5 files, make these targeted changes:

### Change A: lib/data/services/auth_service.dart
Replace the LocalAuthService class body with:
  export 'package:dwaar/backend_integration_locally/local_auth_service.dart'
    show LocalAuthService;
Keep IAuthService and MockAuthService (MockAuthService extends LocalAuthService).

Actually — simpler: add this at the top:
  import '../../../backend_integration_locally/local_auth_service.dart' as _local;
And make LocalAuthService = _local.LocalAuthService typedef.

Even simpler: just remove the body of LocalAuthService and add a part directive,
OR just leave auth_service.dart as-is and update user_signup_service.dart to
import LocalAuthService from the new location directly.

PREFERRED APPROACH: In user_signup_service.dart, change:
  import 'auth_service.dart';
to:
  import '../../backend_integration_locally/local_auth_service.dart';
And in auth_service.dart, remove LocalAuthService (keep only IAuthService and
MockAuthService which now imports from local_auth_service.dart).

### Change B: lib/data/services/user_signup_service.dart
- Remove: _defaultOtp, _nextProfileId, _emailRegex (static fields), _otpByDestination, _profilesByDestination
- Remove: signUp(), requestOtp(), requestEmailOtp(), verifyEmailOtpAndGetProfile(),
  getCurrentProfile(), _normalizeDestination() — all replaced by delegation
- Keep: SignUpRequest, SignUpException, ValidationErrors (these are data classes, no imports needed)
- Keep: UserSignUpService class but slim it to:

  class UserSignUpService {
    UserSignUpService({LocalAuthService? authService, BuildContext? context})
        : _auth = authService ?? LocalAuthService(store: _globalStore!),
          _context = context;

    final LocalAuthService _auth;
    final BuildContext? _context;

    static LocalStore? _globalStore;
    static void setGlobalStore(LocalStore store) => _globalStore = store;

    Future<void> requestEmailOtp(String email, {required bool shouldCreateUser}) =>
        _auth.sendOtp(email, context: _context);

    Future<void> requestOtp({required String destination}) =>
        _auth.sendOtp(destination, context: _context);

    Future<Map<String, dynamic>?> verifyOtpAndGetProfile({
      required String destination,
      required String otp,
      required bool isEmail,
      SignUpRequest? pendingRequest,
    }) => _auth.verifyOtp(destination, otp, pendingRequest: pendingRequest);

    Future<Map<String, dynamic>?> verifyEmailOtpAndGetProfile({
      required String email,
      required String otp,
      SignUpRequest? pendingRequest,
    }) => _auth.verifyOtp(email, otp, pendingRequest: pendingRequest);

    Future<Map<String, dynamic>?> getCurrentProfile() => _auth.getCurrentUser();
  }

### Change C: lib/main.dart
After `WidgetsFlutterBinding.ensureInitialized()` and before `runApp`, add:
  final localStore = await LocalStore.init();
  UserSignUpService.setGlobalStore(localStore);

Add import:
  import 'backend_integration_locally/local_store.dart';
  import 'data/services/user_signup_service.dart';

No Provider change needed — UserSignUpService already defaults via setGlobalStore.

## Constraints
- dart:math for random, dart:convert for JSON, shared_preferences for persistence
- No new packages
- All user-facing strings in Arabic
- RTL layout in the banner widget
- flutter analyze must pass with zero errors after all changes
- Do NOT change any View (.dart in lib/ui/) other than what is explicitly listed above
- Do NOT change any ViewModel other than what is explicitly listed above
- Do NOT change pubspec.yaml (supabase_flutter removal is a separate step)
```
