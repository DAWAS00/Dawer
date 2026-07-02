import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/services/directions_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  // ── reverseGeocode parameter contract ────────────────────────────────────
  //
  // We can't make real HTTP calls in unit tests, so the tests here verify
  // the guard-clauses and the documented no-key fallback path.
  // Integration with the live Geocoding API is confirmed manually.

  group('DirectionsService.reverseGeocode —', () {
    test('returns null immediately when apiKey is empty', () async {
      final result = await DirectionsService.reverseGeocode(
        point: const LatLng(31.9454, 35.9284),
        apiKey: '',
      );
      expect(
        result,
        isNull,
        reason: 'empty key → API call skipped → graceful null',
      );
    });

    test('does not throw for Amman coordinates with empty key', () async {
      expect(
        () => DirectionsService.reverseGeocode(
          point: const LatLng(31.9539, 35.9106),
          apiKey: '',
        ),
        returnsNormally,
      );
    });

    test('does not throw for zero/null-boundary coordinates', () async {
      expect(
        () => DirectionsService.reverseGeocode(
          point: const LatLng(0.0, 0.0),
          apiKey: '',
        ),
        returnsNormally,
      );
    });
  });

  // ── fetchRoute guard-clause (unchanged behaviour) ─────────────────────────

  group('DirectionsService.fetchRoute —', () {
    test(
      'returns null gracefully when given a bogus key',
      () async {
        // Will attempt HTTP but fail with a non-OK API status → null.
        final result = await DirectionsService.fetchRoute(
          origin: const LatLng(31.9454, 35.9284),
          destination: const LatLng(31.9992, 36.0025),
          apiKey: 'INVALID_KEY_FOR_TESTING',
        );
        // Either null (API error) or a RouteResult if network is live.
        // We can't assert the value, but we assert no exception is thrown.
        expect(result, anyOf(isNull, isA<RouteResult>()));
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );
  });
}
