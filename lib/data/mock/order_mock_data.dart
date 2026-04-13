import '../models/order.dart';

class OrderMockData {
  // ── Marketplace items ─────────────────────────────────────────────────────

  static List<Order> marketItems() => [
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
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          supplierName: 'مطعم الديوان',
          supplierNotes:
              'أجهزة مطبخ قديمة بحالة جيدة، تشمل خلاط كهربائي وفرن ميكروويف ومجموعة أواني طهي. جميعها تعمل بشكل صحيح ومناسبة لإعادة الاستخدام أو إعادة التدوير.',
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
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          supplierName: 'شركة الأمل للأثاث',
          supplierNotes:
              'طاولات وكراسي مكتبية — ١٢ قطعة بحالة ممتازة. مناسبة لإعادة الاستخدام في المكاتب أو الفصول الدراسية. تحتاج إلى سيارة بيك أب لنقلها.',
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
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          supplierName: 'كراج أبو خالد',
          supplierNotes:
              'زيت محركات مستعمل — ٤ جالونات محكمة الإغلاق. صالح للتكرير وإعادة المعالجة الصناعية. يُرجى الاستلام في أقرب وقت.',
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
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          supplierName: 'سوبرماركت الخير',
          supplierNotes:
              'مواد ورقية وبلاستيكية مفروزة ومضغوطة، جاهزة للتسليم الفوري. تشمل كراتين وعبوات بلاستيكية نظيفة.',
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
              'إطارات سيارات مستعملة — ٢٠ قطعة بمقاسات متنوعة. مناسبة للتدوير الصناعي أو إعادة التصنيع. تحتاج شاحنة متوسطة للنقل.',
          images: [
            'https://picsum.photos/seed/mkt005a/600/400',
            'https://picsum.photos/seed/mkt005b/600/400',
          ],
        ),
      ];

  // ── Driver ────────────────────────────────────────────────────────────────

  static List<Order> availableForDriver() => [
        Order(id: 'ORD-001', type: OrderType.pickup, wasteTypes: [WasteType.paper, WasteType.plastic], pickupAddress: 'شارع الملكة نور، الجبيهة', dropoffAddress: 'شركة الأفق الخضراء، الزرقاء', status: OrderStatus.pending, reward: 8.5, distanceKm: 3.2, createdAt: DateTime.now().subtract(const Duration(minutes: 12)), supplierName: 'مطعم الأصيل'),
        Order(id: 'ORD-002', type: OrderType.collection, wasteTypes: [WasteType.metal, WasteType.glass], pickupAddress: 'منطقة الوحدات، عمّان', dropoffAddress: 'شركة الإعادة الوطنية، صويلح', status: OrderStatus.pending, reward: 12.0, distanceKm: 5.8, createdAt: DateTime.now().subtract(const Duration(minutes: 5)), supplierName: 'محل البقالة الكبير'),
        Order(id: 'ORD-003', type: OrderType.pickup, wasteTypes: [WasteType.electronics], pickupAddress: 'شارع المدينة المنورة، عمّان', dropoffAddress: 'مركز تدوير التقنية، الأردن', status: OrderStatus.pending, reward: 18.0, distanceKm: 7.1, createdAt: DateTime.now().subtract(const Duration(hours: 1)), supplierName: 'أحمد العلي'),
      ];

  static Order? activeDriverOrder() => Order(
        id: 'ORD-000',
        type: OrderType.pickup,
        wasteTypes: [WasteType.paper],
        pickupAddress: 'شارع الجامعة، عمّان',
        dropoffAddress: 'شركة التدوير الذكي، خلدا',
        status: OrderStatus.inTransit,
        reward: 9.0,
        distanceKm: 2.4,
        eta: '٨ دقائق',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        acceptedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        supplierName: 'محمد خالد',
        driverPhone: '0791234567',
        driverRating: 4.8,
        driverVehicle: 'بيك آب',
      );

  static List<Order> driverHistory() => [
        Order(id: 'ORD-H01', type: OrderType.pickup, wasteTypes: [WasteType.plastic], pickupAddress: 'شارع الحمزة، عمّان', dropoffAddress: 'شركة الأفق الخضراء', status: OrderStatus.completed, reward: 7.5, createdAt: DateTime.now().subtract(const Duration(days: 1)), acceptedAt: DateTime.now().subtract(const Duration(days: 1, hours: 1))),
        Order(id: 'ORD-H02', type: OrderType.collection, wasteTypes: [WasteType.metal], pickupAddress: 'العبدلي، عمّان', dropoffAddress: 'مركز إعادة التدوير', status: OrderStatus.completed, reward: 11.0, createdAt: DateTime.now().subtract(const Duration(days: 2)), acceptedAt: DateTime.now().subtract(const Duration(days: 2, minutes: 40))),
      ];

  // ── Supplier ──────────────────────────────────────────────────────────────

  static List<Order> supplierActive() => [
        Order(id: 'SUP-001', type: OrderType.pickup, wasteTypes: [WasteType.paper, WasteType.plastic], pickupAddress: 'عنواني الحالي', dropoffAddress: 'أقرب مركز تدوير', status: OrderStatus.inTransit, reward: 0, eta: '١٢ دقيقة', distanceKm: 2.1, createdAt: DateTime.now().subtract(const Duration(minutes: 18)), acceptedAt: DateTime.now().subtract(const Duration(minutes: 12)), driverName: 'خالد محمد', driverPhone: '0791234567', driverRating: 4.9, driverVehicle: 'بيك آب'),
        Order(id: 'SUP-002', type: OrderType.pickup, wasteTypes: [WasteType.glass], pickupAddress: 'عنواني الحالي', dropoffAddress: 'أقرب مركز تدوير', status: OrderStatus.pending, reward: 0, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
      ];

  // ── Company ───────────────────────────────────────────────────────────────

  static List<Order> companyIncoming() => [
        Order(id: 'INC-001', type: OrderType.pickup, wasteTypes: [WasteType.paper, WasteType.plastic], pickupAddress: 'مطعم الأصيل، الجبيهة', dropoffAddress: 'شركتنا', status: OrderStatus.inTransit, reward: 8.5, weightKg: 45.0, eta: '٨ دقائق', distanceKm: 3.4, createdAt: DateTime.now().subtract(const Duration(minutes: 30)), acceptedAt: DateTime.now().subtract(const Duration(minutes: 20)), driverName: 'أحمد يوسف', driverPhone: '0799876543', driverRating: 4.7, driverVehicle: 'شاحنة صغيرة'),
        Order(id: 'INC-002', type: OrderType.collection, wasteTypes: [WasteType.metal], pickupAddress: 'محل قطع الغيار، الزرقاء', dropoffAddress: 'شركتنا', status: OrderStatus.accepted, reward: 15.0, weightKg: 80.0, eta: '٢٥ دقيقة', createdAt: DateTime.now().subtract(const Duration(hours: 1)), acceptedAt: DateTime.now().subtract(const Duration(minutes: 45)), driverName: 'سالم عبدالله'),
      ];

  static List<Order> companyJobs() => [
        Order(id: 'JOB-001', type: OrderType.collection, wasteTypes: [WasteType.plastic, WasteType.paper], pickupAddress: 'منطقة الرابية، عمّان', dropoffAddress: 'مستودعنا الرئيسي', status: OrderStatus.pending, reward: 20.0, weightKg: 100.0, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
        Order(id: 'JOB-002', type: OrderType.collection, wasteTypes: [WasteType.electronics], pickupAddress: 'مجمع الإلكترونيات، الصويفية', dropoffAddress: 'مستودعنا الرئيسي', status: OrderStatus.accepted, reward: 35.0, weightKg: 60.0, createdAt: DateTime.now().subtract(const Duration(days: 1)), acceptedAt: DateTime.now().subtract(const Duration(hours: 22)), driverName: 'محمد فارس'),
      ];
}
