import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order/order.dart';
import '../../../domain/repositories/i_report_request_repository.dart';
import '../../../core/constants/app_colors.dart';
import 'analytics_viewmodel.dart';
import 'models/analytics_period.dart';
import 'widgets/kpi_strip.dart';
import 'widgets/period_selector.dart';
import 'widgets/activity_statement_list.dart';
import 'widgets/material_timeline_chart.dart';
import 'widgets/milestone_grid.dart';
import 'widgets/report_center_section.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({
    super.key,
    required this.userId,
    required this.allOrders,
    required this.reportRepository,
    this.showMilestones = true,
    this.showReportCenter = false,
  });

  final String userId;
  final List<Order> allOrders;
  final IReportRequestRepository reportRepository;
  final bool showMilestones;
  final bool showReportCenter;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsViewModel(orders: allOrders),
      child: _AnalyticsTabBody(
        userId: userId,
        reportRepository: reportRepository,
        showMilestones: showMilestones,
        showReportCenter: showReportCenter,
      ),
    );
  }
}

class _AnalyticsTabBody extends StatelessWidget {
  const _AnalyticsTabBody({
    required this.userId,
    required this.reportRepository,
    required this.showMilestones,
    required this.showReportCenter,
  });

  final String userId;
  final IReportRequestRepository reportRepository;
  final bool showMilestones;
  final bool showReportCenter;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    final theme = Theme.of(context);
    final range = vm.period.dateRange();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          title: Text(
            'تقاريري',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  PeriodSelector(
                    selected: vm.period,
                    onChanged: vm.setPeriod,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              KpiStrip(
                earningsJd: vm.totalEarnings,
                weightKg: vm.totalWeightKg,
                co2Kg: vm.estimatedCo2Kg,
                orderCount: vm.orderCount,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  'الجدول الزمني',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MaterialTimelineChart(
                  orders: vm.ganttOrders,
                  periodStart: range.start,
                  periodEnd: range.end,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'سجل النشاط',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              ActivityStatementList(orders: vm.filteredOrders),
              const SizedBox(height: 24),
              if (showMilestones) ...[
                MilestoneGrid(
                  totalOrders: vm.orderCount,
                  totalWeightKg: vm.totalWeightKg,
                  totalEarnings: vm.totalEarnings,
                ),
                const SizedBox(height: 24),
              ],
              if (showReportCenter) ...[
                const Divider(height: 1),
                const SizedBox(height: 20),
                ReportCenterSection(
                  userId: userId,
                  repository: reportRepository,
                  periodStart: range.start,
                  periodEnd: range.end,
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
