import 'package:flutter/material.dart';
import '../auth/viewmodels/login_viewmodel.dart';
import 'driver/driver_home_view.dart';
import 'supplier/supplier_home_view.dart';
import 'supplier/individual_supplier_home_view.dart';
import 'recycling/recycling_home_view.dart';

class HomeRouter extends StatelessWidget {
  final UserRole role;
  final SupplierType supplierType;
  final String userName;

  const HomeRouter({
    super.key,
    required this.role,
    required this.supplierType,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return switch (role) {
      UserRole.driver => DriverHomeView(userName: userName),
      UserRole.supplier => switch (supplierType) {
          SupplierType.individual => IndividualSupplierHomeView(userName: userName),
          SupplierType.storeBusiness => SupplierHomeView(
              userName: userName,
              supplierType: supplierType,
            ),
        },
      UserRole.recyclingCo => RecyclingHomeView(userName: userName),
    };
  }
}
