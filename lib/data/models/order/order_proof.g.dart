// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderProofImpl _$$OrderProofImplFromJson(Map<String, dynamic> json) =>
    _$OrderProofImpl(
      imagePath: json['imagePath'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      checksum: json['checksum'] as String,
    );

Map<String, dynamic> _$$OrderProofImplToJson(_$OrderProofImpl instance) =>
    <String, dynamic>{
      'imagePath': instance.imagePath,
      'capturedAt': instance.capturedAt.toIso8601String(),
      'lat': instance.lat,
      'lng': instance.lng,
      'checksum': instance.checksum,
    };
