import 'local_store.dart';

/// Current auth schema version. Increment when the shape of the persisted
/// auth data changes in a breaking way.
const int kAuthSchemaVersion = 2;

/// Runs one-shot migrations over the local data store to bring the on-disk
/// layout up to [kAuthSchemaVersion]. Idempotent — safe to call on every
/// app launch.
///
/// v1 → v2: OTP era → password era. Legacy user rows have no `password_hash`
/// and cannot log in, so we wipe them (and the current session) and reset the
/// first-launch flag so the seed orders will be regenerated on next boot.
Future<void> runAuthMigrations(LocalStore store) async {
  var version = store.authSchemaVersion;

  if (version < 2) {
    await store.clearAllUsers();
    await store.clearCurrentUserId();
    await store.resetFirstLaunch();
    version = 2;
    await store.setAuthSchemaVersion(version);
  }

  // Future migrations (v2 → v3, …) go here.
}
