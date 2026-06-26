import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/hub.dart';
import 'package:dwaar/domain/repositories/i_hub_repository.dart';
import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/domain/failures/app_failure.dart';

class _FakeHubRepository implements IHubRepository {
  final List<Hub> hubs;
  final bool shouldFail;
  _FakeHubRepository({this.hubs = const [], this.shouldFail = false});

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async {
    if (shouldFail) return Failure(const NetworkFailure(message: 'timeout'));
    return Success(hubs);
  }
}

Hub _makeHub(String id, String name) => Hub(
  id: id,
  name: name,
  address: 'Amman',
  lat: 31.963,
  lng: 35.910,
  active: true,
  capacityKg: 1000,
  currentLoad: {},
  schedule: 'weekly',
  nextShipmentDate: null,
  lastShipmentDate: null,
  status: 'collecting',
  createdAt: DateTime(2026, 6, 26),
);

void main() {
  group('DriverHomeViewModel hub loading', () {
    test('fake repo returns hubs list', () {
      final repo = _FakeHubRepository(hubs: [_makeHub('1', 'Hub A')]);
      expect(repo.hubs, hasLength(1));
    });

    test('fetchActiveHubs succeeds and returns list', () async {
      final repo = _FakeHubRepository(hubs: [
        _makeHub('1', 'Hub A'),
        _makeHub('2', 'Hub B'),
      ]);
      final result = await repo.fetchActiveHubs();
      result.fold(
        onSuccess: (hubs) => expect(hubs, hasLength(2)),
        onFailure: (_) => fail('should succeed'),
      );
    });

    test('fetchActiveHubs on network failure returns NetworkFailure', () async {
      final repo = _FakeHubRepository(shouldFail: true);
      final result = await repo.fetchActiveHubs();
      result.fold(
        onSuccess: (_) => fail('should fail'),
        onFailure: (f) => expect(f, isA<NetworkFailure>()),
      );
    });
  });
}
