import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/app_order_store.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../auth/viewmodels/login_viewmodel.dart';
import 'driver/driver_home_view.dart';
import 'supplier/supplier_home_view.dart';
import 'supplier/individual_supplier_home_view.dart';
import 'recycling/recycling_home_view.dart';

class HomeRouter extends StatelessWidget {
  final UserRole role;
  final SupplierType supplierType;
  final String userName;
  final List<String> aiSuggestedCategories;

  const HomeRouter({
    super.key,
    required this.role,
    required this.supplierType,
    required this.userName,
    this.aiSuggestedCategories = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Configure the remote order stream filter once per home-shell mount.
    // Must run post-frame so Provider lookups are stable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<IAuthRepository>().currentSession;
      if (session != null) {
        context.read<AppOrderStore>().configureForUser(session.userId, session.role);
      }
    });

    return switch (role) {
      UserRole.driver => DriverHomeView(
          userName: userName,
          aiSuggestedCategories: aiSuggestedCategories,
        ),
      UserRole.supplier => switch (supplierType) {
          SupplierType.individual => IndividualSupplierHomeView(
              userName: userName,
              aiSuggestedCategories: aiSuggestedCategories,
            ),
          SupplierType.storeBusiness => SupplierHomeView(
              userName: userName,
              supplierType: supplierType,
              aiSuggestedCategories: aiSuggestedCategories,
            ),
        },
      UserRole.recyclingCo => RecyclingHomeView(
          userName: userName,
          aiSuggestedCategories: aiSuggestedCategories,
        ),
    };
  }
}
