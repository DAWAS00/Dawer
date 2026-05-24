import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DataPulseOverlay extends StatefulWidget {
  final bool active;
  const DataPulseOverlay({super.key, required this.active});

  @override
  State<DataPulseOverlay> createState() => _DataPulseOverlayState();
}

class _DataPulseOverlayState extends State<DataPulseOverlay> {
  final List<(_PulseItem, int)> _items = [];
  Timer? _timer;
  int _counter = 0;

  static const List<String> _phrases = [
    '[STAMP_DETECTED]',
    '[ID_MATCH: 98%]',
    '[DECODING_BIO]',
    '[SECURE_PAPER_OK]',
    '[CRYPTO_HASH_VALID]',
    '[AI_LIVENESS: PASS]',
  ];

  @override
  void didUpdateWidget(DataPulseOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _startEmitting();
    } else if (!widget.active && oldWidget.active) {
      _stopEmitting();
    }
  }

  void _startEmitting() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      final phrase = _phrases[_counter % _phrases.length];
      final alignment = _getAlignment(_counter);
      final id = _counter++;

      setState(() {
        _items.add((_PulseItem(phrase: phrase, alignment: alignment), id));
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _items.removeWhere((item) => item.$2 == id);
          });
        }
      });
    });
  }

  void _stopEmitting() {
    _timer?.cancel();
    _timer = null;
  }

  Alignment _getAlignment(int index) {
    const list = [
      Alignment(-0.7, -0.7),
      Alignment(0.7, -0.5),
      Alignment(-0.5, 0.5),
      Alignment(0.6, 0.8),
      Alignment(0.0, 0.0),
      Alignment(-0.8, 0.2),
    ];
    return list[index % list.length];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _items.map((item) => item.$1).toList(),
    );
  }
}

class _PulseItem extends StatelessWidget {
  final String phrase;
  final Alignment alignment;

  const _PulseItem({required this.phrase, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          return Opacity(
            opacity: value * (1.0 - (value > 0.8 ? (value - 0.8) * 5 : 0)),
            child: Transform.scale(
              scale: 0.8 + (value * 0.2),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.5)),
          ),
          child: Text(
            phrase,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4ADE80),
            ),
          ),
        ),
      ),
    );
  }
}
