import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_proof.freezed.dart';
part 'order_proof.g.dart';

@freezed
class OrderProof with _$OrderProof {
  const factory OrderProof({
    required String imagePath,
    required DateTime capturedAt,
    required double lat,
    required double lng,
    required String checksum,
  }) = _OrderProof;

  factory OrderProof.fromJson(Map<String, dynamic> json) => _$OrderProofFromJson(json);
}
