import 'package:flutter/material.dart';

class LaserScanner extends StatefulWidget {
  final double height;
  final Color color;

  const LaserScanner({
    super.key,
    required this.height,
    this.color = const Color(0xFF4ADE80),
  });

  @override
  State<LaserScanner> createState() => _LaserScannerState();
}

class _LaserScannerState extends State<LaserScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: widget.height * _controller.value,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // The Laser Line
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: widget.color,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.8),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // The Fading Trail
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.color.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
