import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/login_viewmodel.dart';
import '../../auth/views/login_view.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../home/home_router.dart';
import 'dawer_splash_screen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const bool _bypassLogin = false;
  static const UserRole _bypassRole = UserRole.driver;
  static const SupplierType _bypassSupplierType = SupplierType.individual;
  static const String _bypassUserName = 'Demo User';

  void _onSplashFinished() {
    if (!mounted) return;
    if (_bypassLogin) {
      Navigator.of(context).pushReplacement(
        _fadeRoute(
          const HomeRouter(
            role: _bypassRole,
            supplierType: _bypassSupplierType,
            userName: _bypassUserName,
          ),
        ),
      );
    } else {
      _resolveNavigation();
    }
  }

  Future<void> _resolveNavigation() async {
    if (!mounted) return;
    try {
      final authRepo = context.read<IAuthRepository>();
      final session = authRepo.currentSession;

      if (session != null && mounted) {
        Navigator.of(context).pushReplacement(
          _fadeRoute(
            HomeRouter(
              role: session.role,
              supplierType: session.supplierType ?? SupplierType.individual,
              userName: session.userName,
              aiSuggestedCategories: session.categories,
            ),
          ),
        );
        return;
      }
    } catch (_) {
      // Fall through to login
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(_fadeRoute(const LoginView()));
  }

  PageRouteBuilder<void> _fadeRoute(Widget page) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return PageRouteBuilder(
      opaque: false, // keeps splash painted behind incoming page
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration(milliseconds: reduceMotion ? 0 : 900),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        if (reduceMotion) return child;

        // Delay fade-in to let the splash bg breathe first (0–15% = hold)
        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.15, 1.0, curve: Curves.easeInOut),
        );
        // Subtle bloom: login scales 0.97 → 1.0 as it appears
        final scale = Tween<double>(begin: 0.97, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
          ),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DawerSplashScreen(onFinished: _onSplashFinished);
  }
}
