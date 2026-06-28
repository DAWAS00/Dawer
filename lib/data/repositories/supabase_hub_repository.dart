import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_hub_repository.dart';
import '../models/hub.dart';

/// Reads active hubs from the Supabase `public.hubs` table.
/// The table is managed (written) by the admin dashboard via service_role.
/// This repository is strictly read-only — it only calls SELECT.
final class SupabaseHubRepository implements IHubRepository {
  SupabaseHubRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async {
    try {
      final response = await _client
          .from('hubs')
          .select()
          .eq('active', true)
          .order('created_at', ascending: true);

      final hubs = (response as List<dynamic>)
          .map((row) => Hub.fromJson(row as Map<String, dynamic>))
          .toList();

      return Success(hubs);
    } on PostgrestException catch (e) {
      return Failure(NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure(message: e.toString()));
    }
  }
}
