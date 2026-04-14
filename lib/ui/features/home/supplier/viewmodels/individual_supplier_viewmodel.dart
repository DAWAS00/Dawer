import '../../../../../data/models/user.dart';
import 'base_supplier_viewmodel.dart';

class IndividualSupplierViewModel extends BaseSupplierViewModel {
  IndividualSupplierViewModel(super.store);

  @override
  User get defaultUser => const User(
        id: 'SUP-IND-001',
        name: 'مورد دوّر',
        role: 'مورد فردي',
        address: 'شارع الجامعة، عمّان',
        points: 120,
        totalOrders: 18,
        isVerified: true,
      );

  @override
  String get listingIdPrefix => 'IND-';
}
