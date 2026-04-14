import '../../../../../data/models/user.dart';
import 'base_supplier_viewmodel.dart';

class SupplierHomeViewModel extends BaseSupplierViewModel {
  SupplierHomeViewModel(super.store);

  @override
  User get defaultUser => const User(
        id: 'SUP-7821',
        name: 'مورد دوّر',
        role: 'مورد',
        address: 'شارع الجامعة، عمّان',
        points: 120,
        totalOrders: 18,
        isVerified: true,
      );

  @override
  String get listingIdPrefix => 'SUP-MKT-';
}
