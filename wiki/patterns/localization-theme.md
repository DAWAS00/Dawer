---
name: localization-theme
description: Arabic-first bilingual setup, ARB files, l10n usage pattern, light/dark theme tokens, and AppColors
metadata:
  type: pattern
---

# Localization & Theme

## Bilingual Setup

Arabic is the template language. Both `app_ar.arb` and `app_en.arb` live in `lib/l10n/`.

Generated output: `lib/l10n/generated/app_localizations*.dart` — never edit these directly.

```bash
# Regenerate after editing .arb files:
flutter gen-l10n
# Also runs automatically on: flutter pub get
```

## Usage in UI

```dart
// Extension in lib/l10n/l10n.dart
context.l10n.someKey      // ← always use this
'hardcoded Arabic'         // ← avoid; add to .arb instead
```

Direction follows locale automatically via `AppLangNotifier`. The app correctly RTL-flips on Arabic.

## Language Toggle

`AppLangNotifier` → `SharedPreferences`-backed. `LangPickerSheet` widget for user selection. `ThemeModeSheet` for dark/light.

## Theme

`lib/core/theme/app_theme.dart` — `AppTheme.lightTheme` + `AppTheme.darkTheme`

`lib/core/theme/app_tokens.dart` — spacing, radius, elevation constants

## Color Tokens (`AppColors`)

`lib/core/constants/app_colors.dart`

**Never use raw hex in UI.** Always reference `AppColors.<token>`. Key tokens:

| Token | Usage |
|---|---|
| `AppColors.primary` | Green — brand primary |
| `AppColors.accent` | Secondary accent |
| `AppColors.surface` | Card backgrounds |
| `AppColors.background` | Page backgrounds |
| `AppColors.textPrimary` | Main text |
| `AppColors.textSecondary` | Muted text |
| `AppColors.error` | Error states |

## Font

Google Fonts Cairo — used for Arabic text throughout. Applied at theme level.

## Forced Portrait

`SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` in `main()`. No landscape layout support.

## Wizard Style Tokens

`lib/ui/features/home/supplier/widgets/wizard/wizard_style_tokens.dart` — spacing/color tokens scoped to the supplier pickup wizard. Follow same pattern (tokens not magic numbers) for new wizard steps.

## Related Pages

- [[concepts/app-architecture]]
- [[patterns/mvvm-provider]]
