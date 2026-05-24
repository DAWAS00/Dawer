import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../domain/failures/app_failure.dart';
import '../../../../../domain/requests/create_pickup_request.dart';
import '../../shared/viewmodels/base_supplier_viewmodel.dart';

class RestaurantHomeViewModel extends BaseSupplierViewModel {
  RestaurantHomeViewModel(super.store);

  // ── Pickup submit state ────────────────────────────────────────────────────

  bool _isSubmittingPickup = false;
  AppFailure? _pickupSubmitError;
  Order? _lastCreatedOrder;

  bool get isSubmittingPickup => _isSubmittingPickup;
  AppFailure? get pickupSubmitError => _pickupSubmitError;
  Order? get lastCreatedOrder => _lastCreatedOrder;

  Future<bool> submitPickupRequest(CreatePickupRequest request) async {
    _isSubmittingPickup = true;
    _pickupSubmitError = null;
    notifyListeners();

    final result = store.submitPickupRequest(
      request,
      supplierName: user.name,
    );

    result.fold(
      onSuccess: (order) {
        _lastCreatedOrder = order;
        _pickupSubmitError = null;
      },
      onFailure: (failure) {
        _pickupSubmitError = failure;
      },
    );

    _isSubmittingPickup = false;
    notifyListeners();
    return result.isSuccess;
  }

  @override
  User get defaultUser => const User(
        id: 'SUP-7821',
        name: 'مطعم دوّر',
        role: 'مورد',
        address: 'شارع الجامعة، عمّان',
        points: 120,
        totalOrders: 18,
        isVerified: true,
      );

  @override
  String get listingIdPrefix => 'SUP-MKT-';

  @override
  int get listingTtlDays => 30;

  @override
  bool get isBusiness => true;
}
