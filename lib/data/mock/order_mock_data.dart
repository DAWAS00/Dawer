import '../models/order.dart';
import 'order_seed_market_items.dart';
import 'order_seed_orders.dart';

/// First-launch seed data for the Dawer order store.
///
/// Keeps the public API (`OrderMockData.seedOrders()`,
/// `OrderMockData.seedMarketItems()`) stable while delegating to per-dataset
/// files so no single file becomes unwieldy.
class OrderMockData {
  OrderMockData._();

  static List<Order> seedOrders() => buildSeedOrders();
  static List<Order> seedMarketItems() => buildSeedMarketItems();
}
