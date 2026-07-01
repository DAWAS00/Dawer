import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend_integration_locally/local_store.dart';
import '../core/services/app_lang_notifier.dart';
import '../core/services/app_theme_notifier.dart';
import '../core/services/supabase_service.dart';
import '../data/chat/mock_chat_repository.dart';
import '../data/chat/supabase_chat_repository.dart';
import '../data/repositories/mock_auth_repository.dart';
import '../data/repositories/supabase_auth_repository.dart';
import '../data/repositories/supabase_file_storage_repository.dart';
import '../data/repositories/supabase_hub_repository.dart';
import '../data/repositories/supabase_order_repository.dart';
import '../data/repositories/supabase_reservation_repository.dart';
import '../data/repositories/supabase_wallet_repository.dart';
import '../data/services/app_order_store.dart';
import '../data/services/fcm_notification_service.dart';
import '../data/services/mock_signup_orchestrator.dart';
import '../data/services/signup_orchestrator.dart';
import '../data/services/user_signup_service.dart';
import '../domain/chat/repositories/i_chat_repository.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_file_storage_repository.dart';
import '../domain/repositories/i_hub_repository.dart';
import '../domain/repositories/i_order_repository.dart';
import '../domain/repositories/i_reservation_repository.dart';
import '../domain/repositories/i_wallet_repository.dart';
import '../domain/services/i_notification_service.dart';
import '../domain/services/i_signup_orchestrator.dart';
import '../domain/repositories/i_report_request_repository.dart';
import '../data/repositories/mock_report_request_repository.dart';
import '../data/repositories/supabase_report_request_repository.dart';
import '../ui/features/auth/viewmodels/login_viewmodel.dart';

/// Builds the full provider list for [DawerApp].
///
/// [useSupabase] — true when Supabase initialised successfully from .env.local.
/// [mockAuth]    — true to keep MockAuthRepository (phone OTP not required).
// ignore: strict_raw_type
List buildProviders({
  required SharedPreferences prefs,
  required LocalStore localStore,
  required bool useSupabase,
  required bool mockAuth,
}) {
  return [
    // ── Infrastructure ─────────────────────────────────────────────────────
    Provider<LocalStore>.value(value: localStore),

    Provider<INotificationService>(
      create: (_) => FcmNotificationService.instance,
    ),

    // ── Data repositories ───────────────────────────────────────────────────
    Provider<IFileStorageRepository>(
      create: (_) => useSupabase
          ? SupabaseFileStorageRepository()
          : const NoOpFileStorageRepository(),
    ),

    Provider<IOrderRepository>(
      create: (_) => useSupabase
          ? SupabaseOrderRepository(SupabaseService.client)
          : const NoOpOrderRepository(),
    ),

    Provider<IWalletRepository>(
      create: (_) => useSupabase
          ? SupabaseWalletRepository(SupabaseService.client)
          : const NoOpWalletRepository(),
    ),

    Provider<IHubRepository>(
      create: (_) => useSupabase
          ? SupabaseHubRepository(SupabaseService.client)
          : const NoOpHubRepository(),
    ),

    Provider<IReservationRepository>(
      create: (_) => useSupabase
          ? SupabaseReservationRepository(SupabaseService.client)
          : const NoOpReservationRepository(),
    ),

    Provider<IChatRepository>(
      create: (_) => useSupabase
          ? SupabaseChatRepository(SupabaseService.client)
          : MockChatRepository(),
    ),

    // ── Auth ────────────────────────────────────────────────────────────────
    Provider<IAuthRepository>(
      create: (_) => (useSupabase && !mockAuth)
          ? SupabaseAuthRepository(SupabaseService.client, localStore)
          : MockAuthRepository(),
    ),

    // ── App-level state ─────────────────────────────────────────────────────
    ChangeNotifierProvider(
      create: (ctx) => AppOrderStore(
        store: localStore,
        remote: ctx.read<IOrderRepository>(),
        wallet: ctx.read<IWalletRepository>(),
        skipMockSeed: useSupabase,
      ),
    ),

    ChangeNotifierProvider(create: (_) => AppThemeNotifier(prefs)),
    ChangeNotifierProvider(create: (_) => AppLangNotifier(prefs)),

    // ── Services ────────────────────────────────────────────────────────────
    Provider<UserSignUpService>(
      create: (ctx) => UserSignUpService(
        authRepository: ctx.read<IAuthRepository>(),
        fileStorage: ctx.read<IFileStorageRepository>(),
      ),
    ),

    Provider<ISignupOrchestrator>(
      create: (ctx) => (useSupabase && !mockAuth)
          ? SupabaseSignupOrchestrator(
              authRepository: ctx.read<IAuthRepository>(),
              fileStorage: ctx.read<IFileStorageRepository>(),
              client: SupabaseService.client,
            )
          : MockSignupOrchestrator(
              authRepository: ctx.read<IAuthRepository>(),
              fileStorage: ctx.read<IFileStorageRepository>(),
            ),
    ),

    // ── Report requests ─────────────────────────────────────────────────────
    Provider<IReportRequestRepository>(
      create: (_) => useSupabase
          ? SupabaseReportRequestRepository(SupabaseService.client)
          : MockReportRequestRepository(),
    ),

    // ── ViewModels ──────────────────────────────────────────────────────────
    ChangeNotifierProvider<LoginViewModel>(
      create: (ctx) => LoginViewModel(
        authRepository: ctx.read<IAuthRepository>(),
      ),
    ),
  ];
}
