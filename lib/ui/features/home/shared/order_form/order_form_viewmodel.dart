import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user_role.dart';
import '../../../../../data/services/market_ai_service.dart';
import '../controllers/post_market_controller.dart';

enum OrderMode { pickup, marketplace }

class OrderFormData {
  final List<WasteType> wasteTypes;
  final WasteForm wasteForm;
  final WeightCategory weightCategory;
  final List<String> images;
  final double? pickupLat;
  final double? pickupLng;
  final String pickupAddressLabel;
  final String? notes;
  final PickupTarget pickupTarget;
  final bool isMarketplace;
  final String? establishmentName;
  final String? contactPhone;
  final double? itemPrice;

  const OrderFormData({
    required this.wasteTypes,
    required this.wasteForm,
    required this.weightCategory,
    required this.images,
    required this.pickupAddressLabel,
    required this.pickupTarget,
    required this.isMarketplace,
    this.pickupLat,
    this.pickupLng,
    this.notes,
    this.establishmentName,
    this.contactPhone,
    this.itemPrice,
  });
}

class OrderFormViewModel extends ChangeNotifier {
  final SupplierType supplierType;
  final PostMarketController ai;

  OrderFormViewModel({required this.supplierType}) : ai = PostMarketController();

  // ── Step ──────────────────────────────────────────────────────────────────
  int _step = 0;
  int get step => _step;

  // ── Step 1 ────────────────────────────────────────────────────────────────
  final Set<WasteType> wasteTypes = {};
  WasteForm? wasteForm;
  WeightCategory? weightCategory;
  final List<String> images = [];
  bool showTypeError = false;

  // ── Step 2 ────────────────────────────────────────────────────────────────
  OrderMode mode = OrderMode.pickup;
  double? pickupLat;
  double? pickupLng;
  PickupTarget pickupTarget = PickupTarget.company;
  final TextEditingController notesCtrl = TextEditingController();

  // ── Step 3 ────────────────────────────────────────────────────────────────
  final TextEditingController establishmentCtrl = TextEditingController();
  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();

  // ── Validation ────────────────────────────────────────────────────────────
  Map<String, String> errors = {};

  // ── Derived ───────────────────────────────────────────────────────────────
  bool get isRestaurant => supplierType == SupplierType.storeBusiness;
  bool get isMarketplace => mode == OrderMode.marketplace;
  bool get hasLocation => pickupLat != null;
  String? resolvedAddress;
  bool resolvingAddress = false;

  String get addressLabel => resolvedAddress ??
      (hasLocation
          ? '${pickupLat!.toStringAsFixed(4)}° | ${pickupLng!.toStringAsFixed(4)}°'
          : 'الموقع المحدد');

  double get deliveryFee => 2.0 + switch (weightCategory) {
    WeightCategory.light   => 0.0,
    WeightCategory.medium  => 1.5,
    WeightCategory.heavy   => 4.0,
    WeightCategory.veryHeavy => 8.0,
    null                   => 0.0,
  };

  // ── Mutators ──────────────────────────────────────────────────────────────
  void toggleWasteType(WasteType t) {
    wasteTypes.contains(t) ? wasteTypes.remove(t) : wasteTypes.add(t);
    if (wasteTypes.isNotEmpty) showTypeError = false;
    notifyListeners();
  }

  void setWasteForm(WasteForm? f) { wasteForm = f; notifyListeners(); }
  void setWeightCategory(WeightCategory? c) { weightCategory = c; notifyListeners(); }
  void addImage(String p) { images.add(p); notifyListeners(); }
  void removeImage(int i) { images.removeAt(i); if (images.isEmpty) ai.clearAnalysis(); notifyListeners(); }
  void setMode(OrderMode m) { mode = m; notifyListeners(); }
  void setPickupTarget(PickupTarget t) { pickupTarget = t; notifyListeners(); }
  void setLocation(double lat, double lng) {
    pickupLat = lat; pickupLng = lng;
    resolvedAddress = null;
    resolvingAddress = true;
    errors.remove('location');
    notifyListeners();
  }

  void setAddress(String? address) {
    resolvedAddress = address;
    resolvingAddress = false;
    notifyListeners();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  bool advance() {
    if (!validateStep(_step)) return false;
    if (_step < 2) { _step++; notifyListeners(); }
    return true;
  }

  void goBack() { if (_step > 0) { _step--; notifyListeners(); } }

  // ── Validation ────────────────────────────────────────────────────────────
  bool validateStep(int s) {
    errors = {};
    if (s == 0 && wasteTypes.isEmpty) {
      errors['wasteTypes'] = 'يرجى اختيار نوع المخلفات';
      showTypeError = true;
    }
    if (s == 1 && !hasLocation) {
      errors['location'] = 'يرجى تحديد موقع الاستلام';
    }
    if (s == 2) {
      if (isRestaurant && establishmentCtrl.text.trim().length < 2) {
        errors['establishment'] = 'يرجى إدخال اسم المنشأة (٢ أحرف على الأقل)';
      }
      final rawPrice = priceCtrl.text.trim();
      if (rawPrice.isNotEmpty) {
        final p = double.tryParse(rawPrice);
        if (p == null || p < 0 || p > 9999) errors['price'] = 'يرجى إدخال سعر صحيح (٠–٩٩٩٩)';
      }
    }
    notifyListeners();
    return errors.isEmpty;
  }

  // ── AI result ─────────────────────────────────────────────────────────────
  List<String> applyAiResult(MarketAiResult result) {
    final filled = <String>[];
    if (result.wasteTypes.isNotEmpty) {
      wasteTypes.clear(); wasteTypes.addAll(result.wasteTypes); filled.add('نوع المخلفات');
    }
    if (result.wasteForm != null) { wasteForm = result.wasteForm; filled.add('حالة المخلفات'); }
    if (result.weightCategory != null) { weightCategory = result.weightCategory; filled.add('الكمية'); }
    if (result.approxPriceJd != null) { priceCtrl.text = result.approxPriceJd!.toStringAsFixed(2); filled.add('السعر'); }
    if (result.note != null && result.note!.isNotEmpty) { notesCtrl.text = result.note!; filled.add('الملاحظات'); }
    notifyListeners();
    return filled;
  }

  // ── Build data ────────────────────────────────────────────────────────────
  OrderFormData buildData() => OrderFormData(
    wasteTypes: wasteTypes.toList(),
    wasteForm: wasteForm ?? WasteForm.mixed,
    weightCategory: weightCategory ?? WeightCategory.light,
    images: List.from(images),
    pickupLat: pickupLat,
    pickupLng: pickupLng,
    pickupAddressLabel: addressLabel,
    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    pickupTarget: pickupTarget,
    isMarketplace: isMarketplace,
    establishmentName: isRestaurant && establishmentCtrl.text.trim().isNotEmpty
        ? establishmentCtrl.text.trim() : null,
    contactPhone: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim(),
    itemPrice: double.tryParse(priceCtrl.text.trim()),
  );

  @override
  void dispose() {
    ai.dispose();
    notesCtrl.dispose();
    establishmentCtrl.dispose();
    contactCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }
}
