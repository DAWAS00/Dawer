// ── RiderProximityState ───────────────────────────────────────────────────────
//
// Sealed class modelling "how close is the rider to a key location?"
// This is purely frontend state — computed by [RiderProximityViewModel] from
// GPS coordinates. No backend is involved at this layer.
//
// Backend extension: persist arrival timestamps to Supabase
//   `order_proximity_events` table when ready.

/// How far the rider is from a notable point in the active order.
sealed class RiderProximityState {
  const RiderProximityState();
}

/// Rider is not yet near either pickup or drop-off.
final class ProximityIdle extends RiderProximityState {
  const ProximityIdle();
}

/// Rider arrived within [kNearThresholdMeters] of the pickup point.
/// The 10-minute wait window and chat are both unlocked at this state.
final class NearPickup extends RiderProximityState {
  final DateTime arrivedAt;
  final Duration elapsed;

  const NearPickup({required this.arrivedAt, required this.elapsed});

  /// True once 10 minutes have elapsed since arrival.
  bool get waitExpired => elapsed.inMinutes >= 10;

  /// Remaining wait time (clamped to zero).
  Duration get remaining {
    final rem = const Duration(minutes: 10) - elapsed;
    return rem.isNegative ? Duration.zero : rem;
  }

  NearPickup tick(Duration tickInterval) =>
      NearPickup(arrivedAt: arrivedAt, elapsed: elapsed + tickInterval);
}

/// Rider is in-transit and arrived within [kNearThresholdMeters] of the
/// customer's drop-off location. Chat remains unlocked.
final class NearDropoff extends RiderProximityState {
  final DateTime arrivedAt;
  const NearDropoff({required this.arrivedAt});
}

/// Threshold distance in metres that counts as "near".
const double kNearThresholdMeters = 200.0;
