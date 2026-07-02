import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order/order_proof.dart';
import 'location_service.dart';

class ProofBuilder {
  static final _locationService = LocationService();

  /// Builds an [OrderProof] from [imageFile] and [weightKg].
  /// GPS is best-effort — falls back to (0, 0) if unavailable.
  static Future<OrderProof> build({
    required XFile imageFile,
    required double weightKg,
  }) async {
    ({double lat, double lng})? pos;
    try {
      pos = await _locationService.getCurrentLocation();
    } catch (_) {
      pos = null;
    }
    final bytes = await File(imageFile.path).readAsBytes();
    final checksum = sha256.convert(bytes).toString();
    return OrderProof(
      imagePath: imageFile.path,
      capturedAt: DateTime.now(),
      lat: pos?.lat ?? 0.0,
      lng: pos?.lng ?? 0.0,
      checksum: checksum,
      weightKg: weightKg,
    );
  }

  /// Uploads [imageFile] to Supabase Storage under
  /// `proof-photos/{uid}/{orderId}/{proofType}.jpg` and returns the public URL.
  ///
  /// [proofType] is 'pickup' or 'dropoff'.
  /// Throws if the user is not authenticated or the upload fails.
  static Future<String> upload({
    required XFile imageFile,
    required String orderId,
    required String proofType,
  }) async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated — cannot upload proof');

    final path = 'proof-photos/$uid/$orderId/$proofType.jpg';
    final bytes = await File(imageFile.path).readAsBytes();

    await client.storage
        .from('proof-photos')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return client.storage.from('proof-photos').getPublicUrl(path);
  }
}
