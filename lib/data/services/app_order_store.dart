import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/user.dart';

/// Singleton shared order store — the single source of truth for all orders
/// across Driver, Supplier, and Recycling Company roles.
///
/// Provided at app root via [ChangeNotifierProvider]. All three home-view VMs
/// accept this store in their constructor and addListener to it so their own
/// [notifyListeners] fires whenever the store changes.
class AppOrderStore extends ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────

  /// All regular orders — pickup requests (from suppliers) and collection jobs
  /// (posted by recycling companies). This is the canonical list.
  final List<Order> _orders = _initialOrders();

  /// Marketplace items — materials listed for purchase/claim.
  final List<Order> _market = _initialMarketItems();

  /// ID of the order currently active for our mock driver session.
  String? _activeOrderId;

  /// IDs of orders completed by our mock driver (their personal history).
  final List<String> _driverCompletedIds = ['ORD-H01', 'ORD-H02'];

  // ─────────────────────────────────────────────────────────────────────────
  // Driver views
  // ─────────────────────────────────────────────────────────────────────────

  /// Pending orders available for the driver to accept (no driver yet).
  List<Order> get driverFeed => _orders
      .where((o) =>
          o.status == OrderStatus.pending && o.id != _activeOrderId)
      .toList();

  /// The driver's currently active order (null when not on a trip).
  Order? get driverActiveOrder => _activeOrderId == null
      ? null
      : _orders.where((o) => o.id == _activeOrderId).firstOrNull;

  /// Orders the driver has completed in this session (+ seed history).
  List<Order> get driverHistory => _orders
      .where((o) => _driverCompletedIds.contains(o.id))
      .toList();

  bool get driverHasActiveOrder => _activeOrderId != null;

  // ─────────────────────────────────────────────────────────────────────────
  // Supplier views
  // ─────────────────────────────────────────────────────────────────────────

  /// All orders submitted by a specific supplier (by name, mock-only).
  List<Order> supplierOrdersFor(String supplierName) => _orders
      .where((o) =>
          o.supplierName == supplierName && o.type == OrderType.pickup)
      .toList();

  // ─────────────────────────────────────────────────────────────────────────
  // Recycling Company views
  // ─────────────────────────────────────────────────────────────────────────

  /// Pickup orders heading to the company (accepted or inTransit).
  List<Order> get companyIncoming => _orders
      .where((o) =>
          o.type == OrderType.pickup &&
          (o.status == OrderStatus.accepted ||
              o.status == OrderStatus.inTransit))
      .toList();

  /// Collection jobs posted by the company.
  List<Order> get companyJobs =>
      _orders.where((o) => o.type == OrderType.collection).toList();

  // ─────────────────────────────────────────────────────────────────────────
  // Marketplace views
  // ─────────────────────────────────────────────────────────────────────────

  List<Order> get marketItems => List.unmodifiable(_market);

  // ─────────────────────────────────────────────────────────────────────────
  // Driver actions
  // ─────────────────────────────────────────────────────────────────────────

  /// Accept an available order. Returns an error string on failure.
  String? acceptOrder(String orderId, User driver) {
    if (_activeOrderId != null) {
      return 'لا يمكنك قبول طلب جديد. يرجى إتمام الطلب الحالي أولاً.';
    }
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return 'الطلب غير موجود';
    final order = _orders[idx];
    if (order.status != OrderStatus.pending) return 'هذا الطلب لم يعد متاحاً';

    _orders[idx] = order.copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      eta: 'جاري الحساب...',
      driverName: driver.name,
      driverPhone: driver.phone,
      driverRating: driver.rating,
      driverVehicle: driver.vehicleModel,
      driverVehicleModel: driver.vehicleModel,
      driverVehicleColor: driver.vehicleColor,
      driverLicensePlate: driver.licensePlate,
      driverVehiclePhotoPath: driver.vehiclePhotoPath,
    );
    _activeOrderId = orderId;
    notifyListeners();
    return null;
  }

  /// Complete the active order (driver marks delivered).
  void completeOrder(Order completedOrder) {
    final idx = _orders.indexWhere((o) => o.id == completedOrder.id);
    if (idx == -1) return;
    _orders[idx] = completedOrder.copyWith(status: OrderStatus.completed);
    if (_activeOrderId == completedOrder.id) {
      _driverCompletedIds.add(completedOrder.id);
      _activeOrderId = null;
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Supplier actions
  // ─────────────────────────────────────────────────────────────────────────

  /// Create a new pickup request (supplier posts waste for collection).
  Order createPickupRequest({
    required List<WasteType> wasteTypes,
    required String supplierName,
    String pickupAddress = 'عنواني الحالي',
    String dropoffAddress = 'أقرب مركز تدوير',
    String? notes,
    List<String> images = const [],
    double? estimatedWeightKg,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    PickupTarget? pickupTarget,
    double? itemPrice,
  }) {
    final orderId =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final fee = _calculateFee(weightCategory);
    final order = Order(
      id: orderId,
      type: OrderType.pickup,
      wasteTypes: wasteTypes,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: OrderStatus.pending,
      reward: 0,
      createdAt: DateTime.now(),
      supplierName: supplierName,
      supplierNotes: notes,
      images: images,
      estimatedWeightKg: estimatedWeightKg,
      wasteForm: wasteForm,
      weightCategory: weightCategory,
      deliveryFee: fee,
      pickupTarget: pickupTarget,
      itemPrice: itemPrice,
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  /// Cancel a pending order.
  String? cancelOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return 'الطلب غير موجود';
    final order = _orders[idx];
    if (order.status != OrderStatus.pending) {
      return 'لا يمكن إلغاء هذا الطلب لأنه قيد التنفيذ بالفعل';
    }
    _orders[idx] = order.copyWith(status: OrderStatus.cancelled);
    notifyListeners();
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Company actions
  // ─────────────────────────────────────────────────────────────────────────

  /// Post a new collection job (company requests material pickup).
  Order createCollectionJob({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    required String companyName,
    String dropoffAddress = 'منشأة التدوير',
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double reward = 0,
    double? itemPrice,
  }) {
    final orderId =
        'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final order = Order(
      id: orderId,
      type: OrderType.collection,
      wasteTypes: wasteTypes,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: OrderStatus.pending,
      reward: reward,
      createdAt: DateTime.now(),
      supplierName: companyName,
      supplierNotes: notes,
      wasteForm: wasteForm,
      weightCategory: weightCategory,
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Marketplace actions
  // ─────────────────────────────────────────────────────────────────────────

  void addMarketListing(Order order) {
    _market.insert(0, order);
    notifyListeners();
  }

  void removeMarketListing(String orderId) {
    final idx = _market.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    if (_market[idx].status != OrderStatus.pending) return;
    _market[idx] = _market[idx].copyWith(status: OrderStatus.cancelled);
    notifyListeners();
  }

  List<Order> myMarketListings(String publisherName) => _market
      .where((o) =>
          o.supplierName == publisherName &&
          (o.status == OrderStatus.pending ||
              o.status == OrderStatus.accepted ||
              o.status == OrderStatus.inTransit))
      .toList();

  Order? claimMarketItem(String orderId, User driver) {
    final idx = _market.indexWhere((o) => o.id == orderId);
    if (idx == -1) return null;
    if (_market[idx].status != OrderStatus.pending) return null;
    final claimed = _market[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      driverName: driver.name,
      driverPhone: driver.phone,
      driverRating: driver.rating,
      driverVehicleModel: driver.vehicleModel,
      driverVehicleColor: driver.vehicleColor,
      driverLicensePlate: driver.licensePlate,
    );
    _market[idx] = claimed;
    notifyListeners();
    return claimed;
  }

  Order? purchaseMarketItem({
    required String orderId,
    required bool selfPickup,
    String? dropoffAddress,
    double deliveryFee = 0,
  }) {
    final idx = _market.indexWhere((o) => o.id == orderId);
    if (idx == -1) return null;
    if (_market[idx].status != OrderStatus.pending) return null;
    if (!selfPickup &&
        (dropoffAddress == null || dropoffAddress.trim().isEmpty)) {
      return null;
    }
    final purchased = _market[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      dropoffAddress: selfPickup ? 'استلام من السوق' : dropoffAddress!,
      deliveryFee: selfPickup ? 0 : deliveryFee,
    );
    _market[idx] = purchased;
    notifyListeners();
    return purchased;
  }

  Order? receiveAtFacility(String orderId, String facilityAddress) {
    final idx = _market.indexWhere((o) => o.id == orderId);
    if (idx == -1) return null;
    if (_market[idx].status != OrderStatus.pending) return null;
    final received = _market[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      dropoffAddress: facilityAddress,
    );
    _market[idx] = received;
    notifyListeners();
    return received;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  static double _calculateFee(WeightCategory? cat) {
    const base = 2.0;
    return base +
        switch (cat) {
          WeightCategory.light => 0.0,
          WeightCategory.medium => 1.5,
          WeightCategory.heavy => 4.0,
          WeightCategory.veryHeavy => 8.0,
          null => 0.0,
        };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Initial mock data  (replaces the role-split lists in OrderMockData)
  // ─────────────────────────────────────────────────────────────────────────

  static List<Order> _initialOrders() => [
        // ── Our supplier's orders (مورد دوّر) ──────────────────────────────
        // ORD-S01: accepted, driver خالد assigned → visible to supplier + company
        Order(
          id: 'ORD-S01',
          type: OrderType.pickup,
          wasteTypes: [WasteType.paper, WasteType.plastic],
          pickupAddress: 'شارع الجامعة، عمّان',
          dropoffAddress: 'شركة دوّر للتدوير',
          status: OrderStatus.inTransit,
          supplierName: 'مورد دوّر',
          driverName: 'خالد محمد',
          driverPhone: '0791234567',
          driverRating: 4.9,
          driverVehicle: 'بيك آب',
          reward: 8.5,
          weightKg: 45.0,
          distanceKm: 2.1,
          eta: '١٢ دقيقة',
          createdAt:
              DateTime.now().subtract(const Duration(minutes: 18)),
          acceptedAt:
              DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        // ORD-S02: pending → visible to supplier + in driver feed
        Order(
          id: 'ORD-S02',
          type: OrderType.pickup,
          wasteTypes: [WasteType.glass],
          pickupAddress: 'شارع الجامعة، عمّان',
          dropoffAddress: 'أقرب مركز تدوير',
          status: OrderStatus.pending,
          supplierName: 'مورد دوّر',
          reward: 0,
          distanceKm: 2.1,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),

        // ── External pending pickups (driver feed) ─────────────────────────
        Order(
          id: 'ORD-001',
          type: OrderType.pickup,
          wasteTypes: [WasteType.paper, WasteType.plastic],
          pickupAddress: 'شارع الملكة نور، الجبيهة',
          dropoffAddress: 'شركة الأفق الخضراء، الزرقاء',
          status: OrderStatus.pending,
          supplierName: 'مطعم الأصيل',
          reward: 8.5,
          distanceKm: 3.2,
          createdAt:
              DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        Order(
          id: 'ORD-002',
          type: OrderType.pickup,
          wasteTypes: [WasteType.metal, WasteType.glass],
          pickupAddress: 'منطقة الوحدات، عمّان',
          dropoffAddress: 'شركة الإعادة الوطنية، صويلح',
          status: OrderStatus.pending,
          supplierName: 'محل البقالة الكبير',
          reward: 12.0,
          distanceKm: 5.8,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Order(
          id: 'ORD-003',
          type: OrderType.pickup,
          wasteTypes: [WasteType.electronics],
          pickupAddress: 'شارع المدينة المنورة، عمّان',
          dropoffAddress: 'مركز تدوير التقنية، الأردن',
          status: OrderStatus.pending,
          supplierName: 'أحمد العلي',
          reward: 18.0,
          distanceKm: 7.1,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),

        // ── Company incoming (other driver, already accepted) ──────────────
        Order(
          id: 'INC-001',
          type: OrderType.pickup,
          wasteTypes: [WasteType.metal],
          pickupAddress: 'محل قطع الغيار، الزرقاء',
          dropoffAddress: 'شركة دوّر للتدوير',
          status: OrderStatus.accepted,
          supplierName: 'محل قطع الغيار',
          driverName: 'سالم عبدالله',
          driverPhone: '0795555555',
          driverRating: 4.6,
          reward: 15.0,
          weightKg: 80.0,
          distanceKm: 6.2,
          eta: '٢٥ دقيقة',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          acceptedAt:
              DateTime.now().subtract(const Duration(minutes: 45)),
        ),

        // ── Company collection jobs ────────────────────────────────────────
        Order(
          id: 'JOB-001',
          type: OrderType.collection,
          wasteTypes: [WasteType.plastic, WasteType.paper],
          pickupAddress: 'منطقة الرابية، عمّان',
          dropoffAddress: 'شركة دوّر للتدوير',
          status: OrderStatus.pending,
          reward: 20.0,
          weightKg: 100.0,
          distanceKm: 4.5,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Order(
          id: 'JOB-002',
          type: OrderType.collection,
          wasteTypes: [WasteType.electronics],
          pickupAddress: 'مجمع الإلكترونيات، الصويفية',
          dropoffAddress: 'شركة دوّر للتدوير',
          status: OrderStatus.accepted,
          driverName: 'محمد فارس',
          driverPhone: '0799001122',
          driverRating: 4.7,
          reward: 35.0,
          weightKg: 60.0,
          distanceKm: 3.8,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          acceptedAt:
              DateTime.now().subtract(const Duration(hours: 22)),
        ),

        // ── Driver history seeds (completed by our mock driver) ────────────
        Order(
          id: 'ORD-H01',
          type: OrderType.pickup,
          wasteTypes: [WasteType.plastic],
          pickupAddress: 'شارع الحمزة، عمّان',
          dropoffAddress: 'شركة الأفق الخضراء',
          status: OrderStatus.completed,
          reward: 7.5,
          distanceKm: 3.1,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          acceptedAt: DateTime.now()
              .subtract(const Duration(days: 1, hours: 1)),
        ),
        Order(
          id: 'ORD-H02',
          type: OrderType.collection,
          wasteTypes: [WasteType.metal],
          pickupAddress: 'العبدلي، عمّان',
          dropoffAddress: 'مركز إعادة التدوير',
          status: OrderStatus.completed,
          reward: 11.0,
          distanceKm: 2.9,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          acceptedAt: DateTime.now()
              .subtract(const Duration(days: 2, minutes: 40)),
        ),
      ];

  static List<Order> _initialMarketItems() => [
        Order(
          id: 'MKT-001',
          type: OrderType.pickup,
          wasteTypes: [WasteType.metal, WasteType.electronics],
          pickupAddress: 'شارع الملك عبدالله، عمّان',
          dropoffAddress: '',
          status: OrderStatus.pending,
          pickupTarget: PickupTarget.riderBuy,
          itemPrice: 15.0,
          reward: 0,
          weightCategory: WeightCategory.medium,
          wasteForm: WasteForm.solid,
          distanceKm: 4.2,
          createdAt:
              DateTime.now().subtract(const Duration(hours: 2)),
          supplierName: 'مطعم الديوان',
          supplierNotes:
              'أجهزة مطبخ قديمة بحالة جيدة، تشمل خلاط كهربائي وفرن ميكروويف ومجموعة أواني طهي.',
          images: [
            'https://picsum.photos/seed/mkt001a/600/400',
            'https://picsum.photos/seed/mkt001b/600/400',
            'https://picsum.photos/seed/mkt001c/600/400',
          ],
        ),
        Order(
          id: 'MKT-002',
          type: OrderType.pickup,
          wasteTypes: [WasteType.furniture],
          pickupAddress: 'الصويفية، عمّان',
          dropoffAddress: '',
          status: OrderStatus.pending,
          pickupTarget: PickupTarget.riderBuy,
          itemPrice: 25.0,
          reward: 0,
          weightCategory: WeightCategory.heavy,
          wasteForm: WasteForm.solid,
          distanceKm: 8.5,
          createdAt:
              DateTime.now().subtract(const Duration(hours: 5)),
          supplierName: 'شركة الأمل للأثاث',
          supplierNotes:
              'طاولات وكراسي مكتبية — ١٢ قطعة بحالة ممتازة. تحتاج إلى سيارة بيك أب.',
          images: [
            'https://picsum.photos/seed/mkt002a/600/400',
            'https://picsum.photos/seed/mkt002b/600/400',
          ],
        ),
        Order(
          id: 'MKT-003',
          type: OrderType.pickup,
          wasteTypes: [WasteType.oil],
          pickupAddress: 'منطقة الوحدات، عمّان',
          dropoffAddress: '',
          status: OrderStatus.pending,
          pickupTarget: PickupTarget.riderBuy,
          itemPrice: 8.0,
          reward: 0,
          weightCategory: WeightCategory.medium,
          wasteForm: WasteForm.liquid,
          distanceKm: 3.1,
          createdAt:
              DateTime.now().subtract(const Duration(hours: 8)),
          supplierName: 'كراج أبو خالد',
          supplierNotes:
              'زيت محركات مستعمل — ٤ جالونات محكمة الإغلاق. صالح للتكرير.',
          images: [
            'https://picsum.photos/seed/mkt003a/600/400',
          ],
        ),
        Order(
          id: 'MKT-004',
          type: OrderType.pickup,
          wasteTypes: [WasteType.paper, WasteType.plastic],
          pickupAddress: 'الجبيهة، شارع الجامعة',
          dropoffAddress: '',
          status: OrderStatus.pending,
          pickupTarget: PickupTarget.riderBuy,
          itemPrice: 3.5,
          reward: 0,
          weightCategory: WeightCategory.light,
          wasteForm: WasteForm.mixed,
          distanceKm: 5.7,
          createdAt:
              DateTime.now().subtract(const Duration(minutes: 45)),
          supplierName: 'سوبرماركت الخير',
          supplierNotes:
              'مواد ورقية وبلاستيكية مفروزة ومضغوطة، جاهزة للتسليم الفوري.',
          images: [
            'https://picsum.photos/seed/mkt004a/600/400',
            'https://picsum.photos/seed/mkt004b/600/400',
          ],
        ),
        Order(
          id: 'MKT-005',
          type: OrderType.pickup,
          wasteTypes: [WasteType.tires, WasteType.rubber],
          pickupAddress: 'طريق المطار، عمّان',
          dropoffAddress: '',
          status: OrderStatus.pending,
          pickupTarget: PickupTarget.riderBuy,
          itemPrice: 20.0,
          reward: 0,
          weightCategory: WeightCategory.veryHeavy,
          wasteForm: WasteForm.solid,
          distanceKm: 12.3,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          supplierName: 'محل إطارات الشرق',
          supplierNotes:
              'إطارات سيارات مستعملة — ٢٠ قطعة بمقاسات متنوعة. تحتاج شاحنة متوسطة.',
          images: [
            'https://picsum.photos/seed/mkt005a/600/400',
            'https://picsum.photos/seed/mkt005b/600/400',
          ],
        ),
      ];
}
