import '../../../../../data/models/user.dart';
import '../../shared/viewmodels/base_supplier_viewmodel.dart';

class RestaurantHomeViewModel extends BaseSupplierViewModel {
  RestaurantHomeViewModel(super.store);



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
