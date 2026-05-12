import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/models/user_role.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../domain/failures/app_failure.dart';
import '../../../../../domain/requests/create_pickup_request.dart';
import 'base_supplier_viewmodel.dart';

class SupplierHomeViewModel extends BaseSupplierViewModel {
  SupplierHomeViewModel(super.store);

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
        name: 'مورد دوّر',
        role: UserRole.supplier,
        address: 'شارع الجامعة، عمّان',
        points: 120,
        totalOrders: 18,
        isVerified: true,
      );

  @override
  String get listingIdPrefix => 'SUP-MKT-';
}
