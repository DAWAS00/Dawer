import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_request.freezed.dart';
part 'report_request.g.dart';

enum ReportTemplate { weeklySummary, monthlyInvoice, co2Certificate, esgReport }

extension ReportTemplateLabel on ReportTemplate {
  String get arabicLabel => switch (this) {
    ReportTemplate.weeklySummary => 'ملخص أسبوعي',
    ReportTemplate.monthlyInvoice => 'فاتورة شهرية',
    ReportTemplate.co2Certificate => 'شهادة CO₂',
    ReportTemplate.esgReport => 'تقرير ESG',
  };

  String get arabicDescription => switch (this) {
    ReportTemplate.weeklySummary => 'ملخص نشاط الأسبوع المحدد',
    ReportTemplate.monthlyInvoice => 'فاتورة تفصيلية بالضريبة',
    ReportTemplate.co2Certificate => 'شهادة التأثير البيئي المعتمدة',
    ReportTemplate.esgReport => 'تقرير الاستدامة السنوي',
  };
}

enum ReportStatus { pending, processing, ready }

extension ReportStatusLabel on ReportStatus {
  String get arabicLabel => switch (this) {
    ReportStatus.pending => 'بانتظار المعالجة',
    ReportStatus.processing => 'جاري المعالجة',
    ReportStatus.ready => 'جاهز',
  };
}

@freezed
class ReportRequest with _$ReportRequest {
  const factory ReportRequest({
    required String id,
    required String userId,
    required ReportTemplate template,
    required DateTime requestedAt,
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default(ReportStatus.pending) ReportStatus status,
    String? downloadUrl,
  }) = _ReportRequest;

  factory ReportRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportRequestFromJson(json);
}
