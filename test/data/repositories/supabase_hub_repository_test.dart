import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/hub.dart';
import 'package:dwaar/domain/repositories/i_hub_repository.dart';
import 'package:dwaar/core/result/result.dart';

class _FakeHubRepository implements IHubRepository {
  final List<Hub> _hubs;
  _FakeHubRepository(this._hubs);

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async => Success(_hubs);

  @override
  Stream<List<Hub>> watchActiveHubs() => Stream.value(_hubs);
}

void main() {
  group('IHubRepository contract', () {
    test('fetchActiveHubs returns a List<Hub> on success', () async {
      final hub = Hub(
        id: 'h1',
        name: 'Hub A',
        address: 'Sweifieh',
        lat: 31.944,
        lng: 35.871,
        active: true,
        capacityKg: 1000,
        currentLoad: {
          'cookingOil': 0,
          'plastic': 0,
          'paper': 0,
          'electronics': 0,
        },
        schedule: 'weekly',
        nextShipmentDate: null,
        lastShipmentDate: null,
        status: 'collecting',
        createdAt: DateTime(2026, 6, 26),
      );

      final repo = _FakeHubRepository([hub]);
      final result = await repo.fetchActiveHubs();

      result.fold(
        onSuccess: (hubs) {
          expect(hubs, hasLength(1));
          expect(hubs.first.name, 'Hub A');
          expect(hubs.first.active, isTrue);
        },
        onFailure: (f) => fail('Expected success, got: $f'),
      );
    });

    test('fetchActiveHubs returns empty list when no active hubs', () async {
      final repo = _FakeHubRepository([]);
      final result = await repo.fetchActiveHubs();
      result.fold(
        onSuccess: (hubs) => expect(hubs, isEmpty),
        onFailure: (f) => fail('Expected success'),
      );
    });
  });
}
