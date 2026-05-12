import 'package:go_router/go_router.dart';

import '../../ui/features/auth/views/forgot_password_otp_view.dart';
import '../../ui/features/auth/views/login_view.dart';
import '../../ui/features/auth/views/verification_view.dart';
import '../../ui/features/home/home_router.dart';
import '../../ui/features/splash/views/splash_view.dart';

/// Central route table for the Dawer app.
///
/// Navigation rules:
/// - `/`             — SplashView (checks session → redirects to /home or /login)
/// - `/login`        — LoginView
/// - `/login/verify` — VerificationView (extra: phone as String)
/// - `/login/forgot` — ForgotPasswordOtpView (extra: email as String)
/// - `/home`         — HomeRouter (role-dispatches from IAuthRepository.currentSession)
/// - `/error`        — BackendErrorScreen (extra: detail as String)
///
/// Auth guards (redirect-based) are added in Sprint 2 once Firebase auth notifier exists.
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
      routes: [
        GoRoute(
          path: 'verify',
          builder: (context, state) => VerificationView(
            phoneNumber: state.extra as String? ?? '',
          ),
        ),
        GoRoute(
          path: 'forgot',
          builder: (context, state) => ForgotPasswordOtpView(
            email: state.extra as String? ?? '',
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeRouter(),
    ),
    GoRoute(
      path: '/error',
      builder: (context, state) => BackendErrorScreen(
        detail: state.extra as String? ?? '',
      ),
    ),
  ],
);
