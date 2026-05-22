import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeedDialFab extends StatefulWidget {
  final VoidCallback onMarket;
  final VoidCallback? onPickup;

  const SpeedDialFab({
    super.key,
    required this.onMarket,
    this.onPickup,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  void _invoke(VoidCallback action) {
    setState(() => _open = false);
    _ctrl.reverse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_open) ...[
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: _miniButton(
                icon: Icons.storefront_rounded,
                label: 'نشر في السوق',
                color: const Color(0xFF1E40AF),
                onTap: () => _invoke(widget.onMarket),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (widget.onPickup != null) ...[
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: _miniButton(
                  icon: Icons.recycling_rounded,
                  label: 'طلب استلام',
                  color: const Color(0xFF06402B),
                  onTap: () => _invoke(widget.onPickup!),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
        FloatingActionButton.extended(
          heroTag: 'speed_dial_main',
          onPressed: _toggle,
          backgroundColor: const Color(0xFF06402B),
          elevation: 4,
          icon: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
          label: Text(
            _open ? 'إغلاق' : 'إجراء سريع',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
