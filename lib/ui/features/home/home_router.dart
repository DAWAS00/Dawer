import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user_role.dart';
import '../../../data/services/app_order_store.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import 'driver/driver_home_view.dart';
import 'supplier/supplier_home_view.dart';
import 'supplier/individual_supplier_home_view.dart';
import 'recycling/recycling_home_view.dart';

/// Role-dispatching shell widget.
///
/// Reads [IAuthRepository.currentSession] from Provider — no constructor
/// params needed. This allows go_router to navigate to `/home` without
/// threading role/supplierType through route arguments.
class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<IAuthRepository>();
    final session = authRepo.currentSession;

    // Configure the remote order stream filter once per home-shell mount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (session != null) {
        context.read<AppOrderStore>().configureForUser(session.userId, session.role);
      }
    });

    if (session == null) {
      // Guard: session should always exist when /home is reachable.
      // Sprint 2 adds a go_router redirect so this branch is unreachable in prod.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = session.role;
    final supplierType = session.supplierType ?? SupplierType.individual;
    final userName = session.userName;
    final aiCategories = session.categories;

    return switch (role) {
      UserRole.driver => DriverHomeView(
          userName: userName,
          aiSuggestedCategories: aiCategories,
        ),
      UserRole.supplier => switch (supplierType) {
          SupplierType.individual => IndividualSupplierHomeView(
              userName: userName,
              aiSuggestedCategories: aiCategories,
            ),
          SupplierType.storeBusiness => SupplierHomeView(
              userName: userName,
              supplierType: supplierType,
              aiSuggestedCategories: aiCategories,
            ),
        },
      UserRole.recyclingCo => RecyclingHomeView(
          userName: userName,
          aiSuggestedCategories: aiCategories,
        ),
    };
  }
}
