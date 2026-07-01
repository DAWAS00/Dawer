import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../data/services/app_order_store.dart';
import '../../../domain/failures/app_failure.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../auth/viewmodels/login_viewmodel.dart';
import '../chatbot/dawa_assistant_host.dart';
import 'driver/driver_home_view.dart';
import 'supplier/individual_supplier_home_view.dart';
import 'recycling/recycling_home_view.dart';
import 'restaurant/restaurant_home_view.dart';

/// Routes to the role-specific home shell once authenticated.
///
/// Also wires two cross-cutting concerns that apply to every home shell:
///   1. Configures the remote order stream filter for the current user (post-frame).
///   2. Listens to [AppOrderStore.lastError] and surfaces failed remote writes
///      as a dismissible SnackBar — without this, a failed order push/accept/
///      transition is silent (the store captures the error but nothing rendered it).
class HomeRouter extends StatefulWidget {
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
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  @override
  void initState() {
    super.initState();
    // Listen for remote-write failures and surface them to the user.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final store = context.read<AppOrderStore>();
      store.addListener(_onStoreChanged);
      // Surface an error that was set before this listener was attached.
      if (store.lastError != null) _showErrorSnackBar(store.lastError!);
    });
  }

  @override
  void dispose() {
    // removeListener is safe even if addListener never ran.
    final store = Provider.of<AppOrderStore>(context, listen: false);
    store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (!mounted) return;
    final store = context.read<AppOrderStore>();
    final err = store.lastError;
    if (err != null) _showErrorSnackBar(err);
  }

  void _showErrorSnackBar(AppFailure failure) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final message = failure.message;
    // Clear so the same error isn't re-shown on the next notifyListeners().
    context.read<AppOrderStore>().clearError();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('تعذّر حفظ التغيير: $message'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Configure the remote order stream filter once per home-shell mount.
    // Must run post-frame so Provider lookups are stable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = context.read<IAuthRepository>().currentSession;
      if (session != null) {
        context.read<AppOrderStore>().configureForUser(session.userId, session.role);
      }
    });

    final Widget shell = switch (widget.role) {
      UserRole.driver => DriverHomeView(
          userName: widget.userName,
          aiSuggestedCategories: widget.aiSuggestedCategories,
        ),
      UserRole.supplier => switch (widget.supplierType) {
          SupplierType.individual => IndividualSupplierHomeView(
              userName: widget.userName,
              aiSuggestedCategories: widget.aiSuggestedCategories,
            ),
          SupplierType.storeBusiness => RestaurantHomeView(
              userName: widget.userName,
              supplierType: widget.supplierType,
              aiSuggestedCategories: widget.aiSuggestedCategories,
            ),
        },
      UserRole.recyclingCo => RecyclingHomeView(
          userName: widget.userName,
          aiSuggestedCategories: widget.aiSuggestedCategories,
        ),
    };

    // Global Dawa-assistant bubble — same entry point for every role.
    return DawaAssistantHost(child: shell);
  }
}
