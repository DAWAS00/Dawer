import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/views/login_view.dart';
import '../../../../l10n/l10n.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF06402B),
              Color(0xFF002819),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle noise texture overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/texture.png'),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),
            ),

            // Main centered content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Card
                      Image.asset(
                        'assets/images/LoginScreenPhoto.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.eco_rounded,
                          size: 56,
                          color: Color(0xFF06402B),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App name
                      Text(
                        'دوّر',
                        style: GoogleFonts.cairo(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Latin subtitle
                      Text(
                        'DAWAR',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Container(
                        width: 192,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),

                      // Tagline
                      Text(
                        context.l10n.appTagline,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom pagination dots
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(opacity: 0.4),
                  const SizedBox(width: 8),
                  _dot(opacity: 1.0),
                  const SizedBox(width: 8),
                  _dot(opacity: 0.4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot({required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
