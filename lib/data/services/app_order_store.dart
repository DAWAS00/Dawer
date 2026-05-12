import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/result/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../domain/requests/create_pickup_request.dart';
import '../local/local_store.dart';
import '../mock/order_mock_data.dart';
import '../models/order.dart';
import '../models/order_json.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import 'fee_calculator.dart';

// Domain-grouped action/view extensions live in sibling `part` files so each
// stays focused and every file in this library can freely access the private
// state (`_orders`, `_activeOrderId`, `_remote`, …).
part 'app_order_store/driver_actions.dart';
part 'app_order_store/supplier_actions.dart';
part 'app_order_store/collection_job_actions.dart';
part 'app_order_store/collection_sale_actions.dart';
part 'app_order_store/marketplace_actions.dart';

/// Singleton shared order store — the single source of truth for all orders
/// across Driver, Supplier, and Recycling Company roles.
///
/// Provided at app root via [ChangeNotifierProvider]. All three home-view VMs
/// accept this store in their constructor and addListener to it so their own
/// [notifyListeners] fires whenever the store changes.
class AppOrderStore extends ChangeNotifier {
  AppOrderStore({
    LocalStore? store,
    IOrderRepository? remote,
  })  : _store = store,
        _remote = remote ?? const NoOpOrderRepository() {
    _bootstrap();
  }

  final LocalStore? _store;
  final IOrderRepository _remote;
  StreamSubscription<List<Order>>? _remoteSub;

  // ── Error state ────────────────────────────────────────────────────────

  AppFailure? get lastError => _lastError;

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // ── State ──────────────────────────────────────────────────────────────

  /// All regular orders — pickup requests (from suppliers) and collection jobs
  /// (posted by recycling companies). This is the canonical list.
  late List<Order> _orders;

  /// ID of the order currently active for our mock driver session.
  String? _activeOrderId;

  /// IDs of orders completed by this driver. Loaded from [LocalStore] on
  /// bootstrap and persisted on every [completeOrder] call.
  late List<String> _driverCompletedIds;

  /// Last error captured by [_pushRemote].
  AppFailure? _lastError;

  // ── Bootstrap & persistence ────────────────────────────────────────────

  void _bootstrap() {
    final store = _store;
    if (store == null) {
      _driverCompletedIds = [];
      _orders = [
        ...OrderMockData.seedOrders(),
        ...OrderMockData.seedMarketItems(),
      ];
    } else {
      _driverCompletedIds = store.readDriverHistory();
      if (store.isFirstLaunch) {
        _orders = [
          ...OrderMockData.seedOrders(),
          ...OrderMockData.seedMarketItems(),
        ];
        store.writeOrders(_orders.map((o) => o.toJson()).toList());
        store.markFirstLaunchDone();
      } else {
        _orders = store.readOrders().map(orderFromJson).toList();
        final oldMarket = store.readMarket().map(orderFromJson).toList();
        for (final m in oldMarket) {
          if (!_orders.any((o) => o.id == m.id)) {
            _orders.add(m.copyWith(isMarketplaceShared: true));
          }
        }
      }
    }

    // Subscribe to remote order updates. The default NoOpOrderRepository
    // emits nothing, so seed-only / test paths are unaffected.
    _remoteSub = _remote.watchOrders().listen(
      (remoteOrders) {
        if (remoteOrders.isEmpty) return;
        for (final o in remoteOrders) {
          final idx = _orders.indexWhere((existing) => existing.id == o.id);
          if (idx >= 0) {
            _orders[idx] = o;
          } else {
            _orders.insert(0, o);
          }
        }
        notifyListeners();
      },
      onError: (Object e) => AppLogger.error('AppOrderStore', e),
    );
  }

  @override
  void dispose() {
    _remoteSub?.cancel();
    super.dispose();
  }

  /// Re-subscribe the remote stream using a role-scoped filter.
  /// Call this once from [HomeRouter] after the user's session is established.
  void configureForUser(String userId, UserRole role) {
    _remoteSub?.cancel();
    _remoteSub = _remote.watchOrdersForUser(userId, role).listen(
      (remoteOrders) {
        if (remoteOrders.isEmpty) return;
        for (final o in remoteOrders) {
          final idx = _orders.indexWhere((existing) => existing.id == o.id);
          if (idx >= 0) {
            _orders[idx] = o;
          } else {
            _orders.insert(0, o);
          }
        }
        notifyListeners();
      },
      onError: (Object e) => AppLogger.error('AppOrderStore', e),
    );
  }

  Future<void> _persistOrders() async {
    final store = _store;
    if (store == null) return;
    await store.writeOrders(_orders.map((o) => o.toJson()).toList());
  }

  @override
  void notifyListeners() {
    // Auto-persist on every mutation. Fire-and-forget — a write failure does
    // not block UI updates.
    // ignore: discarded_futures
    _persistOrders();
    super.notifyListeners();
  }

  // ── Remote write helper ────────────────────────────────────────────────

  /// Awaits a remote write and lifts any failure into [_lastError] so widgets
  /// can react via [lastError]. Successes are silent.
  Future<void> _pushRemote(Future<AppResult<void>> op) async {
    final result = await op;
    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) {
        _lastError = failure;
        notifyListeners();
      },
    );
  }
}
