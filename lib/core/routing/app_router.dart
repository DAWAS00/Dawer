import 'package:go_router/go_router.dart';

import '../../data/models/user_role.dart';
import '../../ui/features/auth/views/login_view.dart';
import '../../ui/features/auth/views/verification_view.dart';
import '../../ui/features/error/backend_error_screen.dart';
import '../../ui/features/home/home_router.dart';
import '../../ui/features/splash/views/splash_view.dart';

/// Central route table for the Dawer app.
///
/// - `/`             — SplashView (checks session → redirects to /home or /login)
/// - `/login`        — LoginView
/// - `/login/verify` — VerificationView (extra: phone as String)
/// - `/login/forgot` — ForgotPasswordOtpView (extra: email as String)
/// - `/home`         — HomeRouter (extra: Map with role/supplierType/userName)
/// - `/error`        — BackendErrorScreen (extra: detail as String)
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashView()),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
      routes: [
        GoRoute(
          path: 'verify',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return VerificationView(
              phoneNumber: extra['phone'] as String? ?? '',
              initialRole: extra['role'] as UserRole? ?? UserRole.supplier,
              initialSupplierType: extra['supplierType'] as SupplierType?,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return HomeRouter(
          role: extra['role'] as UserRole? ?? UserRole.supplier,
          supplierType:
              extra['supplierType'] as SupplierType? ?? SupplierType.individual,
          userName: extra['userName'] as String? ?? '',
          aiSuggestedCategories:
              (extra['aiSuggestedCategories'] as List?)?.cast<String>() ??
              const [],
        );
      },
    ),
    GoRoute(
      path: '/error',
      builder: (context, state) =>
          BackendErrorScreen(detail: state.extra as String? ?? ''),
    ),
  ],
);
