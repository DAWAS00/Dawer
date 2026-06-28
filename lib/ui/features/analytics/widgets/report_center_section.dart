import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/report_request.dart';
import '../../../../domain/repositories/i_report_request_repository.dart';
import '../../../../core/constants/app_colors.dart';
import 'report_template_card.dart';

class ReportCenterSection extends StatefulWidget {
  const ReportCenterSection({
    super.key,
    required this.userId,
    required this.repository,
    required this.periodStart,
    required this.periodEnd,
  });

  final String userId;
  final IReportRequestRepository repository;
  final DateTime periodStart;
  final DateTime periodEnd;

  @override
  State<ReportCenterSection> createState() => _ReportCenterSectionState();
}

class _ReportCenterSectionState extends State<ReportCenterSection> {
  ReportTemplate? _submitting;
  List<ReportRequest> _submitted = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final result = await widget.repository.fetchRequests(widget.userId);
    result.fold(
      onSuccess: (requests) => setState(() => _submitted = requests),
      onFailure: (_) {},
    );
  }

  Future<void> _request(ReportTemplate template) async {
    setState(() => _submitting = template);
    final result = await widget.repository.submitRequest(
      userId: widget.userId,
      template: template,
      periodStart: widget.periodStart,
      periodEnd: widget.periodEnd,
    );
    result.fold(
      onSuccess: (req) {
        setState(() {
          _submitted = [req, ..._submitted];
          _submitting = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'تم إرسال طلب التقرير ✓',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      onFailure: (_) => setState(() => _submitting = null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'طلب تقرير',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ),
        ...ReportTemplate.values.map((t) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: ReportTemplateCard(
                template: t,
                isLoading: _submitting == t,
                onRequest: () => _request(t),
              ),
            )),
        if (_submitted.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'الطلبات السابقة',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
          ),
          ..._submitted.map((r) => _SubmittedRequestRow(request: r)),
        ],
      ],
    );
  }
}

class _SubmittedRequestRow extends StatelessWidget {
  const _SubmittedRequestRow({required this.request});
  final ReportRequest request;

  Color get _statusColor => switch (request.status) {
        ReportStatus.pending => const Color(0xFFD97706),
        ReportStatus.processing => const Color(0xFF2563EB),
        ReportStatus.ready => const Color(0xFF16A34A),
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              request.template.arabicLabel,
              style: GoogleFonts.cairo(fontSize: 12),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              request.status.arabicLabel,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
