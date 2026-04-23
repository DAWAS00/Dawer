import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Central helper for launching Google Maps via deep link with a robust
/// fallback chain: native Google Maps app (iOS scheme) → universal web URL
/// (opens the Google Maps app on Android if installed, otherwise the default
/// browser) → Play Store / App Store dialog.
///
/// All user-facing copy is passed in by the caller so the helper stays
/// locale-agnostic and testable.
class MapLauncher {
  MapLauncher._();

  // ── URL builders ────────────────────────────────────────────────────────────

  /// Universal web URL — opens driving directions from origin → destination.
  /// Works cross-platform and transparently launches the Google Maps app
  /// when available.
  static Uri directionsWeb({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&travelmode=driving',
    );
  }

  /// iOS-specific Google Maps URL scheme for directions. Returns [null] on
  /// non-iOS platforms so callers can skip it.
  static Uri? directionsIosScheme({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    if (!Platform.isIOS) return null;
    return Uri.parse(
      'comgooglemaps://?saddr=$originLat,$originLng'
      '&daddr=$destLat,$destLng&directionsmode=driving',
    );
  }

  /// Universal web URL to view a single point.
  static Uri placeWeb({required double lat, required double lng}) {
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
  }

  /// Opens Google Maps at the Google Maps landing page — used when the user
  /// has no known coordinates yet and wants to browse/pick on the map.
  static Uri mapsLanding() => Uri.parse('https://www.google.com/maps');

  static Uri get playStore => Uri.parse(
    'https://play.google.com/store/apps/details?id=com.google.android.apps.maps',
  );
  static Uri get appStore =>
      Uri.parse('https://apps.apple.com/app/google-maps/id585027354');

  // ── Launch actions ──────────────────────────────────────────────────────────

  /// Open driving directions from pickup to drop-off in Google Maps.
  /// Shows a localized Play/App Store dialog if no handler is available.
  static Future<void> openDirections({
    required BuildContext context,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String storeDialogTitle,
    required String storeDialogBody,
    required String storeDialogOpenLabel,
    required String storeDialogCancelLabel,
  }) async {
    final ios = directionsIosScheme(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
    if (ios != null && await _tryLaunch(ios)) return;

    final web = directionsWeb(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
    if (await _tryLaunch(web)) return;

    if (!context.mounted) return;
    await _showStoreDialog(
      context,
      title: storeDialogTitle,
      body: storeDialogBody,
      openLabel: storeDialogOpenLabel,
      cancelLabel: storeDialogCancelLabel,
    );
  }

  /// Open Google Maps at a single point.
  static Future<void> openPlace({
    required BuildContext context,
    required double lat,
    required double lng,
    required String storeDialogTitle,
    required String storeDialogBody,
    required String storeDialogOpenLabel,
    required String storeDialogCancelLabel,
  }) async {
    final uri = placeWeb(lat: lat, lng: lng);
    if (await _tryLaunch(uri)) return;

    if (!context.mounted) return;
    await _showStoreDialog(
      context,
      title: storeDialogTitle,
      body: storeDialogBody,
      openLabel: storeDialogOpenLabel,
      cancelLabel: storeDialogCancelLabel,
    );
  }

  /// Open Google Maps with no pre-filled coordinates so the user can search
  /// for a place. Used by the location picker flow.
  static Future<void> openMapsForPicking({
    required BuildContext context,
    required String storeDialogTitle,
    required String storeDialogBody,
    required String storeDialogOpenLabel,
    required String storeDialogCancelLabel,
  }) async {
    final uri = mapsLanding();
    if (await _tryLaunch(uri)) return;

    if (!context.mounted) return;
    await _showStoreDialog(
      context,
      title: storeDialogTitle,
      body: storeDialogBody,
      openLabel: storeDialogOpenLabel,
      cancelLabel: storeDialogCancelLabel,
    );
  }

  // ── Internal ────────────────────────────────────────────────────────────────

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      if (!await canLaunchUrl(uri)) return false;
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<void> _showStoreDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String openLabel,
    required String cancelLabel,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dctx);
              final uri = Platform.isIOS ? appStore : playStore;
              await _tryLaunch(uri);
            },
            child: Text(openLabel),
          ),
        ],
      ),
    );
  }
}
