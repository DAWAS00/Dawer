import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DawerSplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final String logoAsset;

  const DawerSplashScreen({
    super.key,
    this.onFinished,
    this.logoAsset = 'assets/images/AppLogo.png',
  });

  @override
  State<DawerSplashScreen> createState() => _DawerSplashScreenState();
}

class _DawerSplashScreenState extends State<DawerSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  static const double _dur = 4.0;

  static const double _cx = 540;
  static const double _cy = 808;
  static const double _badgeW = 660;
  static const double _badgeH = 526;
  static const double _boxL = _cx - _badgeW / 2;
  static const double _boxT = _cy - _badgeH / 2;

  static const List<_Item> _items = [
    _Item(Icons.water_drop, Color(0xFF3B82F6), -0.65, 222, 78, 0.10),
    _Item(Icons.eco, Color(0xFF7FCF8E), -2.35, 238, 86, 0.24),
    _Item(Icons.chair, Color(0xFFD8A24A), 2.55, 206, 80, 0.40),
    _Item(Icons.inventory_2, Color(0xFFC8860A), 0.95, 250, 72, 0.56),
    _Item(Icons.newspaper, Color(0xFFDCE6DF), 3.02, 172, 66, 0.70),
  ];

  @override
  void initState() {
    super.initState();
    _c =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 4000),
        )..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onFinished?.call();
        });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static double _c01(double t) => t.clamp(0.0, 1.0);
  static double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
  static double _easeInQuad(double t) => t * t;
  static double _easeInOutCubic(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF06402B), Color(0xFF04331F), Color(0xFF002819)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 1080,
              height: 1920,
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final t = _c.value * _dur;
                  return Stack(
                    children: [
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(0, -0.24),
                              radius: 0.9,
                              colors: [Color(0x47145A3C), Color(0x0006402B)],
                            ),
                          ),
                        ),
                      ),
                      _glow(t),
                      ..._items.map((it) => _buildItem(it, t)),
                      _logo(t),
                      _tagline(t),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glow(double t) {
    final gather = _c01((t - 1.0) / 0.7);
    final halo = _c01((t - 1.5) / 1.2);
    double pulse = 0;
    if (t >= 2.5 && t <= 3.1) pulse = math.sin(((t - 2.5) / 0.6) * math.pi);
    final size = 360 + 360 * _easeOutCubic(halo) + 80 * pulse;
    final opacity = (0.18 * gather + 0.34 * halo + 0.18 * pulse).clamp(
      0.0,
      1.0,
    );
    return Positioned(
      left: _cx,
      top: _cy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x8C5ED0B4),
                  Color(0x472E8052),
                  Color(0x0006402B),
                ],
                stops: [0.0, 0.38, 0.7],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(_Item it, double t) {
    const fallEnd0 = 0.62, recStart = 1.28, recEnd = 1.92;
    final fallStart = it.delay;
    final fallEnd = it.delay + fallEnd0;
    if (t < fallStart || t >= recEnd) return const SizedBox.shrink();

    final restDX = math.cos(it.angle) * it.radius;
    final restDY = math.sin(it.angle) * it.radius;

    double dx, dy, scale, opacity, rotDeg;

    if (t < fallEnd) {
      final p = _easeOutCubic(_c01((t - fallStart) / fallEnd0));
      dx = restDX;
      dy = (restDY - 200) + 200 * p;
      scale = 0.55 + 0.45 * p;
      opacity = _c01(p * 1.6);
      rotDeg = -55 * (1 - p);
    } else if (t < recStart) {
      final f = t - fallEnd;
      dx = restDX;
      dy = restDY + math.sin(f * 3.2 + it.angle) * 7;
      scale = 1;
      opacity = 1;
      rotDeg = math.sin(f * 2.4 + it.angle) * 5;
    } else {
      final p = _easeInOutCubic(_c01((t - recStart) / (recEnd - recStart)));
      final a = it.angle + 2.1 * p;
      final r = it.radius * (1 - p);
      dx = math.cos(a) * r;
      dy = math.sin(a) * r;
      scale = 1 - 0.85 * p;
      opacity = 1 - _easeInQuad(_c01((p - 0.45) / 0.55));
      rotDeg = 220 * p;
    }

    return Positioned(
      left: _cx + dx,
      top: _cy + dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: rotDeg * math.pi / 180,
            child: Transform.scale(
              scale: scale,
              child: Icon(it.icon, size: it.size, color: it.color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo(double t) {
    const revealStart = 1.45, revealEnd = 2.7;
    final sweepP = _c01((t - revealStart) / (revealEnd - revealStart));
    if (sweepP <= 0) return const SizedBox.shrink();

    final sweepFrac = _easeInOutCubic(sweepP).clamp(0.001, 0.999);
    final settle = _easeOutCubic(_c01((t - revealStart) / 1.1));
    final scale = 0.86 + 0.14 * settle;
    final rotDeg = (1 - settle) * -14;

    return Positioned(
      left: _boxL,
      top: _boxT,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(rotDeg * math.pi / 180)
          ..scaleByDouble(scale, scale, 1.0, 1.0),
        child: SizedBox(
          width: _badgeW,
          height: _badgeH,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => SweepGradient(
              center: const Alignment(0, -0.02),
              startAngle: 0,
              endAngle: 2 * math.pi,
              transform: const GradientRotation(-math.pi / 2),
              colors: const [
                Colors.white,
                Colors.white,
                Colors.transparent,
                Colors.transparent,
              ],
              stops: [0.0, sweepFrac, sweepFrac, 1.0],
            ).createShader(rect),
            child: Image.asset(widget.logoAsset, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _tagline(double t) {
    final inP = _easeOutCubic(_c01((t - 3.0) / 0.7));
    final ty = (1 - inP) * 26;
    final lineP = _easeOutCubic(_c01((t - 3.05) / 0.6));
    final dawerO = _c01((t - 3.25) / 0.5);

    return Positioned(
      left: 0,
      right: 0,
      top: _cy + _badgeH / 2 + 70,
      child: Opacity(
        opacity: inP,
        child: Transform.translate(
          offset: Offset(0, ty),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'حوّل النفايات إلى قيمة',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(
                  fontSize: 58,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 26),
              Opacity(
                opacity: dawerO,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60 * lineP,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      'DAWER',
                      style: GoogleFonts.dmSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 11,
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      width: 60 * lineP,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final Color color;
  final double angle;
  final double radius;
  final double size;
  final double delay;
  const _Item(
    this.icon,
    this.color,
    this.angle,
    this.radius,
    this.size,
    this.delay,
  );
}
