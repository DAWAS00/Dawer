import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Central semantic design-token class.
///
/// Usage — access via the [BuildContext] extension:
///
/// ```dart
/// // In any widget build() method:
/// final dt = context.dt;
///
/// Container(
///   color: dt.surface,          // card / sheet background
///   child: Text('Hello',
///     style: TextStyle(color: dt.onSurface),
///   ),
/// )
/// ```
///
/// All neutral/structural colors (surfaces, text, borders) live here.
/// Brand colors (primaryGreen, accentAmber, status badges) stay in
/// [AppColors] because they appear on intentionally colored backgrounds
/// and do not need to flip between themes.
class AppTokens extends ThemeExtension<AppTokens> {
  /// Whether the app is currently in dark mode.
  final bool isDark;

  // ── Surface / Background ──────────────────────────────────────────────────

  /// Card background, bottom-sheet background, dialog background.
  /// Light: white  |  Dark: shamrock-1200
  final Color surface;

  /// Secondary container: input fields, chips, icon circles, tag backgrounds.
  /// Light: #F2F4F2  |  Dark: shamrock-1100
  final Color surfaceVariant;

  /// Page/scaffold background (between cards).
  /// Light: #F4F6F5  |  Dark: shamrock-1300
  final Color scaffold;

  // ── Text / Foreground ─────────────────────────────────────────────────────

  /// High-emphasis text and icons on a [surface] background.
  /// Light: #002819  |  Dark: #F0F7F2
  final Color onSurface;

  /// Medium-emphasis text (labels, secondary info).
  /// Light: #404943  |  Dark: #B8D4C0
  final Color onSurfaceVariant;

  /// Low-emphasis text: hints, captions, placeholders.
  /// Light: #717973  |  Dark: #94A3B8
  final Color onSurfaceMuted;

  // ── Border / Divider ──────────────────────────────────────────────────────

  /// Card outlines, input borders, list dividers.
  /// Light: #E6E9E7  |  Dark: shamrock-1000
  final Color border;

  // ── Shadow ────────────────────────────────────────────────────────────────

  /// Box-shadow base color (apply your own opacity).
  /// Always black — adjust alpha per component.
  final Color shadow;

  // ── Constructor ───────────────────────────────────────────────────────────

  const AppTokens({
    required this.isDark,
    required this.surface,
    required this.surfaceVariant,
    required this.scaffold,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onSurfaceMuted,
    required this.border,
    required this.shadow,
  });

  // ── Singletons ────────────────────────────────────────────────────────────

  static const AppTokens light = AppTokens(
    isDark: false,
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF2F4F2),
    scaffold: Color(0xFFF4F6F5),
    onSurface: Color(0xFF002819),
    onSurfaceVariant: Color(0xFF404943),
    onSurfaceMuted: Color(0xFF717973),
    border: Color(0xFFE6E9E7),
    shadow: Colors.black,
  );

  static const AppTokens dark = AppTokens(
    isDark: true,
    surface: AppColors.shamrock1200,
    surfaceVariant: AppColors.shamrock1100,
    scaffold: AppColors.shamrock1300,
    onSurface: Color(0xFFF0F7F2),
    onSurfaceVariant: Color(0xFFB8D4C0),
    onSurfaceMuted: Color(0xFF94A3B8),
    border: AppColors.shamrock1000,
    shadow: Colors.black,
  );

  // ── ThemeExtension Methods ────────────────────────────────────────────────

  @override
  ThemeExtension<AppTokens> copyWith({
    bool? isDark,
    Color? surface,
    Color? surfaceVariant,
    Color? scaffold,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? onSurfaceMuted,
    Color? border,
    Color? shadow,
  }) {
    return AppTokens(
      isDark: isDark ?? this.isDark,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      scaffold: scaffold ?? this.scaffold,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ThemeExtension<AppTokens> lerp(covariant ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      isDark: t < 0.5 ? isDark : other.isDark,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }

  // ── Factory ───────────────────────────────────────────────────────────────

  /// Returns the correct [AppTokens] for the current [BuildContext] theme.
  static AppTokens of(BuildContext context) {
    return Theme.of(context).extension<AppTokens>() ?? (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }
}

/// Convenience extension — use [context.dt] anywhere inside a [Widget].
extension AppTokensX on BuildContext {
  /// Design tokens for the current theme.
  ///
  /// Example:
  /// ```dart
  /// color: context.dt.surface
  /// style: TextStyle(color: context.dt.onSurface)
  /// ```
  AppTokens get dt => AppTokens.of(this);
}

