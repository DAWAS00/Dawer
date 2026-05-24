import '../../models/order.dart';

/// Geographically realistic mock orders centered around Amman, Jordan.
/// Used to test proximity filtering and multi-order batching.
class AmmanOrdersSeed {
  static List<Order> seed() {
    final now = DateTime.now();

    return [
      // Cluster A: Jabal Amman (Central) - Anchor Potential
      Order(
        id: 'AMM-A01',
        type: OrderType.pickup,
        wasteTypes: [WasteType.plastic, WasteType.paper],
        pickupAddress: 'شارع الرينبو، جبل عمان',
        dropoffAddress: 'مركز تدوير وسط البلد',
        status: OrderStatus.pending,
        reward: 4.5,
        createdAt: now.subtract(const Duration(hours: 1)),
        pickupLat: 31.9515,
        pickupLng: 35.9120,
        supplierName: 'أحمد علي',
        weightCategory: WeightCategory.light,
      ),
      Order(
        id: 'AMM-A02',
        type: OrderType.pickup,
        wasteTypes: [WasteType.glass],
        pickupAddress: 'الدوار الأول، جبل عمان',
        dropoffAddress: 'مركز تدوير وسط البلد',
        status: OrderStatus.pending,
        reward: 3.8,
        createdAt: now.subtract(const Duration(minutes: 45)),
        pickupLat: 31.9525,
        pickupLng: 35.9150, // ~300m from A01
        supplierName: 'ليلى سليم',
        weightCategory: WeightCategory.light,
      ),
      Order(
        id: 'AMM-A03',
        type: OrderType.pickup,
        wasteTypes: [WasteType.metal],
        pickupAddress: 'شارع خرفان، جبل عمان',
        dropoffAddress: 'مركز تدوير وسط البلد',
        status: OrderStatus.pending,
        reward: 5.2,
        createdAt: now.subtract(const Duration(minutes: 30)),
        pickupLat: 31.9490,
        pickupLng: 35.9100, // ~400m from A01
        supplierName: 'عمر خالد',
        weightCategory: WeightCategory.medium,
      ),

      // Cluster B: Abdoun (South-West) - ~3km from Cluster A
      Order(
        id: 'AMM-B01',
        type: OrderType.pickup,
        wasteTypes: [WasteType.electronics],
        pickupAddress: 'عبدون الشمالي، قرب السفارة البريطانية',
        dropoffAddress: 'مصنع إعادة التدوير الحديث',
        status: OrderStatus.pending,
        reward: 7.5,
        createdAt: now.subtract(const Duration(hours: 2)),
        pickupLat: 31.9350,
        pickupLng: 35.8950,
        supplierName: 'سارة مراد',
        weightCategory: WeightCategory.medium,
      ),
      Order(
        id: 'AMM-B02',
        type: OrderType.pickup,
        wasteTypes: [WasteType.plastic],
        pickupAddress: 'قرب تاج مول، عبدون',
        dropoffAddress: 'مصنع إعادة التدوير الحديث',
        status: OrderStatus.pending,
        reward: 4.0,
        createdAt: now.subtract(const Duration(minutes: 15)),
        pickupLat: 31.9320,
        pickupLng: 35.8920,
        supplierName: 'مريم يوسف',
        weightCategory: WeightCategory.light,
      ),

      // Cluster C: University of Jordan (North) - ~8km from Cluster A
      Order(
        id: 'AMM-C01',
        type: OrderType.pickup,
        wasteTypes: [WasteType.paper, WasteType.plastic],
        pickupAddress: 'البوابة الرئيسية، الجامعة الأردنية',
        dropoffAddress: 'مستودع تدوير صويلح',
        status: OrderStatus.pending,
        reward: 6.0,
        createdAt: now.subtract(const Duration(hours: 3)),
        pickupLat: 32.0150,
        pickupLng: 35.8750,
        supplierName: 'د. سامر',
        weightCategory: WeightCategory.heavy,
      ),
      Order(
        id: 'AMM-C02',
        type: OrderType.pickup,
        wasteTypes: [WasteType.plastic],
        pickupAddress: 'شارع الجامعة، طلوع نيفين',
        dropoffAddress: 'مستودع تدوير صويلح',
        status: OrderStatus.pending,
        reward: 3.5,
        createdAt: now.subtract(const Duration(minutes: 50)),
        pickupLat: 32.0100,
        pickupLng: 35.8700,
        supplierName: 'مطعم أبو جبارة',
        weightCategory: WeightCategory.medium,
      ),

      // Cluster D: Zarqa (Far East) - ~25km from Cluster A
      Order(
        id: 'AMM-D01',
        type: OrderType.pickup,
        wasteTypes: [WasteType.metal],
        pickupAddress: 'الزرقاء الجديدة، شارع 36',
        dropoffAddress: 'مكب تدوير الزرقاء',
        status: OrderStatus.pending,
        reward: 12.0,
        createdAt: now.subtract(const Duration(hours: 5)),
        pickupLat: 32.0650,
        pickupLng: 36.0850,
        supplierName: 'شركة النور',
        weightCategory: WeightCategory.heavy,
      ),
    ];
  }
}
