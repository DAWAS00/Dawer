import 'package:flutter/material.dart';

/// Screen-width-based layout helpers for adaptive spacing and grid decisions.
///
/// Usage via [BuildContext] extension:
/// ```dart
/// final layout = context.layout;
/// padding: EdgeInsets.symmetric(horizontal: layout.hPad),
/// ```
class AppLayout {
  const AppLayout._(this._width);
  final double _width;

  static AppLayout of(BuildContext context) =>
      AppLayout._(MediaQuery.sizeOf(context).width);

  /// Horizontal page padding: 16 on small screens, 20 standard, 24 wide.
  double get hPad {
    if (_width < 360) return 16.0;
    if (_width < 400) return 20.0;
    return 24.0;
  }

  /// True for screens narrower than 360 px (small budget phones).
  bool get isSmall => _width < 360;

  /// True for screens 600+ px (tablets / foldables in landscape).
  bool get isWide => _width >= 600;

  /// Max cross-axis tile extent for a responsive marketplace grid.
  /// Returns half the usable width on wide screens, full width on phones.
  double get marketMaxExtent => (_width - hPad * 2 - 8) / (isWide ? 2 : 1);
}

extension AppLayoutContext on BuildContext {
  AppLayout get layout => AppLayout.of(this);
}
