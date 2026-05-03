/// Abstraction over GPS-publishing behaviour. The real implementation
/// ([LocationPublisher]) uses Geolocator + Supabase. Tests inject a
/// no-op or recording fake so they never need device permissions.
abstract interface class ILocationPublisher {
  Future<void> start(String orderId);
  Future<void> stop();
}
