import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedStatusText extends StatefulWidget {
  final List<String> phrases;
  final TextStyle? style;
  final Duration interval;

  const AnimatedStatusText({
    super.key,
    required this.phrases,
    this.style,
    this.interval = const Duration(seconds: 2),
  });

  @override
  State<AnimatedStatusText> createState() => _AnimatedStatusTextState();
}

class _AnimatedStatusTextState extends State<AnimatedStatusText> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.phrases.length > 1) {
      _timer = Timer.periodic(widget.interval, (timer) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.phrases.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.phrases.isEmpty) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        widget.phrases[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        style: widget.style ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }
}
