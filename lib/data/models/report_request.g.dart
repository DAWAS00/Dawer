// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportRequestImpl _$$ReportRequestImplFromJson(Map<String, dynamic> json) =>
    _$ReportRequestImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      template: $enumDecode(_$ReportTemplateEnumMap, json['template']),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      status:
          $enumDecodeNullable(_$ReportStatusEnumMap, json['status']) ??
          ReportStatus.pending,
      downloadUrl: json['downloadUrl'] as String?,
    );

Map<String, dynamic> _$$ReportRequestImplToJson(_$ReportRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'template': _$ReportTemplateEnumMap[instance.template]!,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'status': _$ReportStatusEnumMap[instance.status]!,
      'downloadUrl': instance.downloadUrl,
    };

const _$ReportTemplateEnumMap = {
  ReportTemplate.weeklySummary: 'weeklySummary',
  ReportTemplate.monthlyInvoice: 'monthlyInvoice',
  ReportTemplate.co2Certificate: 'co2Certificate',
  ReportTemplate.esgReport: 'esgReport',
};

const _$ReportStatusEnumMap = {
  ReportStatus.pending: 'pending',
  ReportStatus.processing: 'processing',
  ReportStatus.ready: 'ready',
};
