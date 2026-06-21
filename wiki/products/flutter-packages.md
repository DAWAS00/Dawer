---
name: flutter-packages
description: Key Flutter packages used in Dwaar — purpose, version, and usage notes
metadata:
  type: product
---

# Flutter Packages

## State & Architecture

| Package | Version | Use |
|---|---|---|
| `provider` | ^6.1.5 | MVVM ChangeNotifier pattern; app-root MultiProvider |
| `freezed` + `freezed_annotation` | ^2.5.8 / ^2.4.4 | Immutable models with copyWith; Order model |
| `json_serializable` + `json_annotation` | ^6.9.0 / ^4.9.0 | JSON serialization for freezed models |
| `signals_flutter` | ^6.1.1 | Reactive signals (available; usage scope limited) |
| `flutter_hooks` | ^0.21.0 | React-style hooks for stateful widgets |

## Supabase & Backend

| Package | Version | Use |
|---|---|---|
| `supabase_flutter` | ^2.8.4 | Auth, Realtime, Postgres, Storage |
| `flutter_dotenv` | ^5.2.1 | `.env.local` config loading |
| `shared_preferences` | ^2.5.3 | Theme + language persistence |

## Maps & Location

| Package | Version | Use |
|---|---|---|
| `google_maps_flutter` | ^2.10.0 | Live tracking map in order details |
| `geolocator` | ^13.0.2 | GPS position, geofence check |
| `geocoding` | ^3.0.0 | Address → lat/lng conversion |
| `permission_handler` | ^11.3.1 | Location permission requests |

## AI & Camera

| Package | Version | Use |
|---|---|---|
| `google_generative_ai` | ^0.4.6 | Gemini API (text + vision) |
| `google_mlkit_image_labeling` | ^0.13.0 | On-device image labeling |
| `image_picker` | ^1.2.1 | Camera / gallery photo selection |
| `image_cropper` | ^8.0.2 | Crop identity/vehicle photos |

## Push Notifications

| Package | Version | Use |
|---|---|---|
| `firebase_core` | ^3.8.0 | Firebase initialization |
| `firebase_messaging` | ^15.1.5 | FCM push notifications |
| `flutter_local_notifications` | ^18.0.1 | Local notification display |

## UI

| Package | Version | Use |
|---|---|---|
| `google_fonts` | ^6.2.0 | Cairo font for Arabic |
| `flutter_animate` | ^4.5.2 | Animations (shimmer, transitions) |
| `shimmer` | ^3.0.0 | Loading skeleton shimmer |
| `skeletonizer` | ^2.1.3 | Skeleton loading wrappers |
| `lottie` | ^3.1.2 | Lottie animation files |
| `fl_chart` | ^0.69.0 | Earnings charts |
| `smooth_page_indicator` | ^1.2.0 | Wizard step dots |
| `animated_toggle_switch` | ^0.8.7 | Toggle switches |
| `lucide_icons_flutter` | ^3.1.14 | Icon set |
| `gap` | ^3.0.1 | Spacing widget |
| `intl_phone_field` | ^3.2.0 | Phone number input with country code |
| `pinput` | ^5.0.2 | OTP 6-digit input |
| `cached_network_image` | ^3.4.1 | Network image caching |
| `device_preview` | ^1.2.0 | Device preview (dev only) |

## Files & Sharing

| Package | Version | Use |
|---|---|---|
| `pdf` | ^3.11.1 | PDF report generation (service written, not wired) |
| `path_provider` | ^2.1.5 | File system paths |
| `share_plus` | ^10.1.4 | Share PDF/files |
| `url_launcher` | ^6.3.2 | Open maps, phone calls |
| `crypto` | ^3.0.7 | Hashing utilities |
| `path` | ^1.9.0 | Path manipulation |

## Unused / Planned

| Package | Status |
|---|---|
| `go_router: ^14.0.0` | In pubspec; **zero usage** in live code. All nav is imperative. |
| `faker: ^2.2.0` | Used in seed data generation |

## Related Pages

- [[concepts/app-architecture]]
- [[products/supabase]]
- [[products/gemini-ai]]
