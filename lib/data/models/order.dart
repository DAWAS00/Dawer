enum OrderType { pickup, collection }
enum OrderStatus { pending, accepted, inTransit, completed, cancelled }
enum WasteType { paper, plastic, metal, glass, electronics, organic }

extension WasteTypeLabel on WasteType {
  String get label {
    switch (this) {
      case WasteType.paper:
        return 'ورق';
      case WasteType.plastic:
        return 'بلاستيك';
      case WasteType.metal:
        return 'معادن';
      case WasteType.glass:
        return 'زجاج';
      case WasteType.electronics:
        return 'إلكترونيات';
      case WasteType.organic:
        return 'عضوي';
    }
  }
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.accepted:
        return 'تم القبول';
      case OrderStatus.inTransit:
        return 'في الطريق';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }
}

class Order {
  final String id;
  final OrderType type;
  final List<WasteType> wasteTypes;
  final String pickupAddress;
  final String dropoffAddress;
  final OrderStatus status;
  final String? driverName;
  final String? driverPhone;
  final double? driverRating;
  final String? driverVehicle;
  final String? driverVehicleModel;
  final String? driverVehicleColor;
  final String? driverLicensePlate;
  final String? driverVehiclePhotoPath;
  final String? supplierName;
  final double reward;
  final double? weightKg;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final String? eta;
  final double? distanceKm;
  final String? proofImagePath;
  final double? paidAmount;

  const Order({
    required this.id,
    required this.type,
    required this.wasteTypes,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.reward,
    required this.createdAt,
    this.acceptedAt,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.driverVehicle,
    this.driverVehicleModel,
    this.driverVehicleColor,
    this.driverLicensePlate,
    this.driverVehiclePhotoPath,
    this.supplierName,
    this.weightKg,
    this.eta,
    this.distanceKm,
    this.proofImagePath,
    this.paidAmount,
  });

  Order copyWith({
    String? id,
    OrderType? type,
    List<WasteType>? wasteTypes,
    String? pickupAddress,
    String? dropoffAddress,
    OrderStatus? status,
    String? driverName,
    String? driverPhone,
    double? driverRating,
    String? driverVehicle,
    String? driverVehicleModel,
    String? driverVehicleColor,
    String? driverLicensePlate,
    String? driverVehiclePhotoPath,
    String? supplierName,
    double? reward,
    double? weightKg,
    DateTime? createdAt,
    DateTime? acceptedAt,
    String? eta,
    double? distanceKm,
    String? proofImagePath,
    double? paidAmount,
  }) {
    return Order(
      id: id ?? this.id,
      type: type ?? this.type,
      wasteTypes: wasteTypes ?? this.wasteTypes,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverRating: driverRating ?? this.driverRating,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      driverVehicleModel: driverVehicleModel ?? this.driverVehicleModel,
      driverVehicleColor: driverVehicleColor ?? this.driverVehicleColor,
      driverLicensePlate: driverLicensePlate ?? this.driverLicensePlate,
      driverVehiclePhotoPath: driverVehiclePhotoPath ?? this.driverVehiclePhotoPath,
      supplierName: supplierName ?? this.supplierName,
      reward: reward ?? this.reward,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      eta: eta ?? this.eta,
      distanceKm: distanceKm ?? this.distanceKm,
      proofImagePath: proofImagePath ?? this.proofImagePath,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }

  static List<Order> mockAvailableForDriver() => [
        Order(
          id: 'ORD-001',
          type: OrderType.pickup,
          wasteTypes: [WasteType.paper, WasteType.plastic],
          pickupAddress: 'شارع الملكة نور، الجبيهة',
          dropoffAddress: 'شركة الأفق الخضراء، الزرقاء',
          status: OrderStatus.pending,
          reward: 8.5,
          distanceKm: 3.2,
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          supplierName: 'مطعم الأصيل',
        ),
        Order(
          id: 'ORD-002',
          type: OrderType.collection,
          wasteTypes: [WasteType.metal, WasteType.glass],
          pickupAddress: 'منطقة الوحدات، عمّان',
          dropoffAddress: 'شركة الإعادة الوطنية، صويلح',
          status: OrderStatus.pending,
          reward: 12.0,
          distanceKm: 5.8,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          supplierName: 'محل البقالة الكبير',
        ),
        Order(
          id: 'ORD-003',
          type: OrderType.pickup,
          wasteTypes: [WasteType.electronics],
          pickupAddress: 'شارع المدينة المنورة، عمّان',
          dropoffAddress: 'مركز تدوير التقنية، الأردن',
          status: OrderStatus.pending,
          reward: 18.0,
          distanceKm: 7.1,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          supplierName: 'أحمد العلي',
        ),
      ];

  static Order? mockActiveDriverOrder() => Order(
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

  static List<Order> mockDriverHistory() => [
        Order(
          id: 'ORD-H01',
          type: OrderType.pickup,
          wasteTypes: [WasteType.plastic],
          pickupAddress: 'شارع الحمزة، عمّان',
          dropoffAddress: 'شركة الأفق الخضراء',
          status: OrderStatus.completed,
          reward: 7.5,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          acceptedAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        ),
        Order(
          id: 'ORD-H02',
          type: OrderType.collection,
          wasteTypes: [WasteType.metal],
          pickupAddress: 'العبدلي، عمّان',
          dropoffAddress: 'مركز إعادة التدوير',
          status: OrderStatus.completed,
          reward: 11.0,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          acceptedAt: DateTime.now().subtract(const Duration(days: 2, minutes: 40)),
        ),
      ];

  static List<Order> mockSupplierActive() => [
        Order(
          id: 'SUP-001',
          type: OrderType.pickup,
          wasteTypes: [WasteType.paper, WasteType.plastic],
          pickupAddress: 'عنواني الحالي',
          dropoffAddress: 'أقرب مركز تدوير',
          status: OrderStatus.inTransit,
          reward: 0,
          eta: '١٢ دقيقة',
          distanceKm: 2.1,
          createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
          acceptedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          driverName: 'خالد محمد',
          driverPhone: '0791234567',
          driverRating: 4.9,
          driverVehicle: 'بيك آب',
        ),
        Order(
          id: 'SUP-002',
          type: OrderType.pickup,
          wasteTypes: [WasteType.glass],
          pickupAddress: 'عنواني الحالي',
          dropoffAddress: 'أقرب مركز تدوير',
          status: OrderStatus.pending,
          reward: 0,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

  static List<Order> mockCompanyIncoming() => [
        Order(
          id: 'INC-001',
          type: OrderType.pickup,
          wasteTypes: [WasteType.paper, WasteType.plastic],
          pickupAddress: 'مطعم الأصيل، الجبيهة',
          dropoffAddress: 'شركتنا',
          status: OrderStatus.inTransit,
          reward: 8.5,
          weightKg: 45.0,
          eta: '٨ دقائق',
          distanceKm: 3.4,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          acceptedAt: DateTime.now().subtract(const Duration(minutes: 20)),
          driverName: 'أحمد يوسف',
          driverPhone: '0799876543',
          driverRating: 4.7,
          driverVehicle: 'شاحنة صغيرة',
        ),
        Order(
          id: 'INC-002',
          type: OrderType.collection,
          wasteTypes: [WasteType.metal],
          pickupAddress: 'محل قطع الغيار، الزرقاء',
          dropoffAddress: 'شركتنا',
          status: OrderStatus.accepted,
          reward: 15.0,
          weightKg: 80.0,
          eta: '٢٥ دقيقة',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          acceptedAt: DateTime.now().subtract(const Duration(minutes: 45)),
          driverName: 'سالم عبدالله',
        ),
      ];

  static List<Order> mockCompanyJobs() => [
        Order(
          id: 'JOB-001',
          type: OrderType.collection,
          wasteTypes: [WasteType.plastic, WasteType.paper],
          pickupAddress: 'منطقة الرابية، عمّان',
          dropoffAddress: 'مستودعنا الرئيسي',
          status: OrderStatus.pending,
          reward: 20.0,
          weightKg: 100.0,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Order(
          id: 'JOB-002',
          type: OrderType.collection,
          wasteTypes: [WasteType.electronics],
          pickupAddress: 'مجمع الإلكترونيات، الصويفية',
          dropoffAddress: 'مستودعنا الرئيسي',
          status: OrderStatus.accepted,
          reward: 35.0,
          weightKg: 60.0,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          acceptedAt: DateTime.now().subtract(const Duration(hours: 22)),
          driverName: 'محمد فارس',
        ),
      ];
}
