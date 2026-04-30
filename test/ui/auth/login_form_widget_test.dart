import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/data/services/user_signup_service.dart' show SignUpRequest;
import 'package:dwaar/domain/failures/app_failure.dart';
import 'package:dwaar/domain/repositories/i_auth_repository.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/ui/features/auth/viewmodels/login_viewmodel.dart';
import 'package:dwaar/ui/features/auth/views/widgets/login_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test double
// ─────────────────────────────────────────────────────────────────────────────

class _FakeAuthRepository implements IAuthRepository {
  AppResult<AuthSession> nextSignInResult = const Success(
    AuthSession(userId: 'fake-id', role: UserRole.driver),
  );

  String? lastEmail;
  String? lastPassword;
  int signInCallCount = 0;

  @override
  Future<AppResult<AuthSession>> signInWithEmail(
      String email, String password) async {
    signInCallCount++;
    lastEmail = email;
    lastPassword = password;
    return nextSignInResult;
  }

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async =>
      throw UnimplementedError('not exercised in these tests');

  @override
  Future<AppResult<void>> requestOtp(String phone) async =>
      throw UnimplementedError('not exercised in these tests');

  @override
  Future<AppResult<AuthSession>> verifyOtp(String phone, String otp) async =>
      throw UnimplementedError('not exercised in these tests');

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthSession?> watchAuthState() => const Stream.empty();

  @override
  AuthSession? get currentSession => null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _pumpLoginForm(
  WidgetTester tester, {
  required _FakeAuthRepository repo,
  Locale locale = const Locale('ar'),
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(authRepository: repo),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar'), Locale('en')],
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: LoginForm(),
          ),
        ),
      ),
    ),
  );
  // Let initial frame + locale resolution settle.
  await tester.pumpAndSettle();
}

LoginViewModel _vm(WidgetTester tester) {
  final formFinder = find.byType(LoginForm);
  return Provider.of<LoginViewModel>(
    tester.element(formFinder),
    listen: false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('LoginForm — validation', () {
    testWidgets('tapping login with empty email surfaces an error',
        (tester) async {
      final repo = _FakeAuthRepository();
      await _pumpLoginForm(tester, repo: repo);

      // Tap the login button without typing anything.
      await tester.tap(find.byIcon(Icons.login_rounded));
      await tester.pump();

      expect(repo.signInCallCount, 0,
          reason: 'repo must not be called when email is empty');
      expect(_vm(tester).error, isNotNull);
      expect(_vm(tester).error, contains('البريد'));
    });

    testWidgets('email but empty password surfaces password error',
        (tester) async {
      final repo = _FakeAuthRepository();
      await _pumpLoginForm(tester, repo: repo);

      await tester.enterText(
        find.byKey(const ValueKey('email_input')),
        'user@example.com',
      );
      await tester.tap(find.byIcon(Icons.login_rounded));
      await tester.pump();

      expect(repo.signInCallCount, 0);
      expect(_vm(tester).error, contains('كلمة المرور'));
    });
  });

  group('LoginForm — repository wiring', () {
    testWidgets('successful sign-in flips signedIn and stops loading',
        (tester) async {
      final repo = _FakeAuthRepository()
        ..nextSignInResult = const Success(
          AuthSession(userId: 'u-1', role: UserRole.driver),
        );

      await _pumpLoginForm(tester, repo: repo);

      // Type valid credentials.
      await tester.enterText(
        find.byKey(const ValueKey('email_input')),
        'user@example.com',
      );
      // The password field is the only obscured TextField in the form.
      final passwordField = find.descendant(
        of: find.byType(LoginForm),
        matching: find.byWidgetPredicate(
          (w) => w is TextField && w.obscureText == true,
        ),
      );
      await tester.enterText(passwordField, 'Password123');

      await tester.tap(find.byIcon(Icons.login_rounded));
      await tester.pump(); // start loading
      await tester.pump(const Duration(milliseconds: 16)); // resolve future

      expect(repo.signInCallCount, 1);
      expect(repo.lastEmail, 'user@example.com');
      expect(repo.lastPassword, 'Password123');

      final vm = _vm(tester);
      expect(vm.signedIn, isTrue);
      expect(vm.error, isNull);
      expect(vm.isLoading, isFalse);
      expect(vm.session?.userId, 'u-1');
    });

    testWidgets('failed sign-in surfaces the failure message', (tester) async {
      final repo = _FakeAuthRepository()
        ..nextSignInResult = const Failure(
          AuthFailure(message: 'بيانات الدخول غير صحيحة'),
        );

      await _pumpLoginForm(tester, repo: repo);

      await tester.enterText(
        find.byKey(const ValueKey('email_input')),
        'user@example.com',
      );
      final passwordField = find.descendant(
        of: find.byType(LoginForm),
        matching: find.byWidgetPredicate(
          (w) => w is TextField && w.obscureText == true,
        ),
      );
      await tester.enterText(passwordField, 'wrong-pass');

      await tester.tap(find.byIcon(Icons.login_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(repo.signInCallCount, 1);
      final vm = _vm(tester);
      expect(vm.signedIn, isFalse);
      expect(vm.error, 'بيانات الدخول غير صحيحة');
    });
  });
}
