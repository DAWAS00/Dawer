// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_data_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartnerDataRequestImpl _$$PartnerDataRequestImplFromJson(
  Map<String, dynamic> json,
) => _$PartnerDataRequestImpl(
  id: json['id'] as String,
  companyName: json['companyName'] as String,
  contactName: json['contactName'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  message: json['message'] as String,
  status:
      $enumDecodeNullable(_$PartnerDataRequestStatusEnumMap, json['status']) ??
      PartnerDataRequestStatus.pending,
  requestedAt: DateTime.parse(json['requestedAt'] as String),
);

Map<String, dynamic> _$$PartnerDataRequestImplToJson(
  _$PartnerDataRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyName': instance.companyName,
  'contactName': instance.contactName,
  'email': instance.email,
  'phone': instance.phone,
  'message': instance.message,
  'status': _$PartnerDataRequestStatusEnumMap[instance.status]!,
  'requestedAt': instance.requestedAt.toIso8601String(),
};

const _$PartnerDataRequestStatusEnumMap = {
  PartnerDataRequestStatus.pending: 'pending',
  PartnerDataRequestStatus.contacted: 'contacted',
  PartnerDataRequestStatus.closed: 'closed',
};
