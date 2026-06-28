import '../../core/result/result.dart';
import '../../data/models/hub.dart';

/// Read-only gateway for collection hubs.
/// Only the admin dashboard (via service_role) can create/update/delete hubs.
/// The app reads them so drivers can select a dropoff target.
abstract interface class IHubRepository {
  /// Returns all active hubs ordered by creation date.
  Future<AppResult<List<Hub>>> fetchActiveHubs();
}

/// No-op implementation used when Supabase is unavailable or in tests
/// that don't exercise hub functionality.
final class NoOpHubRepository implements IHubRepository {
  const NoOpHubRepository();

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async => const Success([]);
}
