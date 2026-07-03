import '../../core/result/result.dart';
import '../../data/models/hub.dart';

/// Read-only gateway for collection hubs.
/// Only the admin dashboard (via service_role) can create/update/delete hubs.
/// The app reads them so drivers can select a dropoff target.
abstract interface class IHubRepository {
  /// Returns all active hubs ordered by creation date.
  Future<AppResult<List<Hub>>> fetchActiveHubs();

  /// Watch active hubs in real-time.
  Stream<List<Hub>> watchActiveHubs();
}

/// A read-only repository dummy used for local testing and runs
/// that don't exercise hub functionality. Returns mock hubs.
final class NoOpHubRepository implements IHubRepository {
  const NoOpHubRepository();

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async => Success(_mockHubs);

  @override
  Stream<List<Hub>> watchActiveHubs() => Stream.value(_mockHubs);

  static final List<Hub> _mockHubs = [
    Hub(
      id: 'c0000000-0000-0000-0000-000000000001',
      name: 'Hub Al-Sweifieh',
      address: 'Sweifieh Commercial District, Amman',
      lat: 31.944000,
      lng: 35.871000,
      active: true,
      capacityKg: 1200.0,
      currentLoad: const {
        'cookingOil': 312,
        'plastic': 156,
        'paper': 94,
        'electronics': 37,
      },
      schedule: 'weekly',
      nextShipmentDate: '2026-06-27',
      lastShipmentDate: '2026-06-20',
      status: 'collecting',
      createdAt: DateTime.parse('2026-06-20T00:00:00Z'),
    ),
    Hub(
      id: 'c0000000-0000-0000-0000-000000000002',
      name: 'Hub Downtown',
      address: 'Al-Balad, Downtown Amman',
      lat: 31.952000,
      lng: 35.934000,
      active: true,
      capacityKg: 800.0,
      currentLoad: const {
        'cookingOil': 520,
        'plastic': 88,
        'paper': 42,
        'electronics': 18,
      },
      schedule: 'weekly',
      nextShipmentDate: '2026-06-27',
      lastShipmentDate: '2026-06-20',
      status: 'ready',
      createdAt: DateTime.parse('2026-06-20T00:00:00Z'),
    ),
  ];
}
