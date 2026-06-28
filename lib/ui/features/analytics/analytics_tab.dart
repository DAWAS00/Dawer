import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order/order.dart';
import '../../../domain/repositories/i_report_request_repository.dart';
import 'analytics_viewmodel.dart';
export 'analytics_viewmodel.dart' show HeroMetric, TrendPoint, WasteShare;
import 'models/analytics_period.dart';
import 'widgets/activity_statement_list.dart';
import 'widgets/analytics_hero_card.dart';
import 'widgets/kpi_card.dart';
import 'widgets/kpi_grid.dart';
import 'widgets/material_timeline_chart.dart';
import 'widgets/milestone_strip.dart';
import 'widgets/period_selector.dart';
import 'widgets/report_center_section.dart';
import 'widgets/trend_chart.dart';
import 'widgets/waste_type_breakdown.dart';

/// Which metric the hero card leads with.
///
/// (Re-exported alias so older imports keep working.)
typedef HeroMetricAlias = HeroMetric;

/// A role-specific KPI card definition for the 2×2 grid's optional 4th slot.
class RoleKpi {
  const RoleKpi({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.delta,
    this.deltaPositive,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String? delta;
  final bool? deltaPositive;
}

/// Root widget for the Analytics tab. Role-configured via [heroMetric] and
/// [roleKpi]; otherwise identical across roles.
class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({
    super.key,
    required this.userId,
    required this.allOrders,
    required this.reportRepository,
    this.heroMetric = HeroMetric.earnings,
    this.roleKpi,
    this.showMilestones = true,
    this.showReportCenter = false,
  });

  final String userId;
  final List<Order> allOrders;
  final IReportRequestRepository reportRepository;

  /// Which metric the hero card and trend chart lead with.
  final HeroMetric heroMetric;

  /// Role-specific 4th KPI (e.g. active jobs for recycling co, avg reward
  /// for driver/supplier). When null, a default "طلبات مكتملة" card is used.
  final RoleKpi? roleKpi;

  final bool showMilestones;
  final bool showReportCenter;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsViewModel(orders: allOrders),
      child: _AnalyticsTabBody(
        userId: userId,
        reportRepository: reportRepository,
        heroMetric: heroMetric,
        roleKpi: roleKpi,
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
    required this.heroMetric,
    required this.roleKpi,
    required this.showMilestones,
    required this.showReportCenter,
  });

  final String userId;
  final IReportRequestRepository reportRepository;
  final HeroMetric heroMetric;
  final RoleKpi? roleKpi;
  final bool showMilestones;
  final bool showReportCenter;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    final theme = Theme.of(context);
    final range = vm.period.dateRange();

    // ── Hero data ────────────────────────────────────────────────────────
    final heroValue =
        heroMetric == HeroMetric.earnings ? vm.totalEarnings : vm.totalWeightKg;
    final heroLabel = heroMetric == HeroMetric.earnings
        ? 'إجمالي الأرباح · ${vm.period.arabicLabel}'
        : 'إجمالي الوزن المعالج · ${vm.period.arabicLabel}';
    String heroFormatter(double v) => heroMetric == HeroMetric.earnings
        ? '${v.toStringAsFixed(1)} د.أ'
        : '${v.toStringAsFixed(0)} كغ';
    final heroDelta = heroMetric == HeroMetric.earnings
        ? vm.deltaEarningsPct
        : vm.deltaWeightPct;
    final heroColor =
        heroMetric == HeroMetric.earnings ? Colors.white : Colors.white;
    final sparkPoints =
        vm.dailySeries(heroMetric).map((p) => p.value).toList();

    // ── 2×2 grid cards ───────────────────────────────────────────────────
    final gridCards = <Widget>[
      KpiCard(
        value: '${vm.totalWeightKg.toStringAsFixed(0)} كغ',
        label: 'وزن معالج',
        icon: Icons.scale_rounded,
        color: const Color(0xFF2563EB),
        delta: vm.deltaWeightPct == null
            ? null
            : '${vm.deltaWeightPct!.toStringAsFixed(0)}%',
        deltaPositive: (vm.deltaWeightPct ?? 0) >= 0,
      ),
      KpiCard(
        value: '${vm.estimatedCo2Kg.toStringAsFixed(0)} كغ',
        label: 'CO₂ وُفِّر',
        icon: Icons.eco_rounded,
        color: const Color(0xFF16A34A),
      ),
      KpiCard(
        value: '${vm.orderCount}',
        label: 'طلبات مكتملة',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF7C3AED),
        delta: vm.deltaOrdersPct == null
            ? null
            : '${vm.deltaOrdersPct!.toStringAsFixed(0)}%',
        deltaPositive: (vm.deltaOrdersPct ?? 0) >= 0,
      ),
      KpiCard(
        value: roleKpi?.value ?? '${vm.avgRewardPerOrder.toStringAsFixed(1)} د.أ',
        label: roleKpi?.label ?? 'متوسط الربح/طلب',
        icon: roleKpi?.icon ?? Icons.payments_rounded,
        color: roleKpi?.color ?? const Color(0xFFD97706),
        delta: roleKpi?.delta,
        deltaPositive: roleKpi?.deltaPositive,
      ),
    ];

    // ── Trend chart color matches the hero metric ────────────────────────
    final trendColor = heroMetric == HeroMetric.earnings
        ? AppColors.primaryGreen
        : const Color(0xFF2563EB);

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

              // ── Hero ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnalyticsHeroCard(
                  value: heroValue,
                  label: heroLabel,
                  formatter: heroFormatter,
                  sparkPoints: sparkPoints,
                  deltaPct: heroDelta,
                  accentColor: heroColor,
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

              const SizedBox(height: 24),

              // ── KPI grid ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: KpiGrid(children: gridCards),
              ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

              const SizedBox(height: 28),

              // ── Trend ──────────────────────────────────────────────────
              _SectionHeader(title: 'الاتجاه'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TrendChart(
                  series: vm.dailySeries(heroMetric),
                  color: trendColor,
                ),
              ),

              const SizedBox(height: 28),

              // ── Waste breakdown ────────────────────────────────────────
              _SectionHeader(title: 'توزيع المواد'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: WasteTypeBreakdown(breakdown: vm.wasteBreakdown),
              ),

              const SizedBox(height: 28),

              // ── Gantt timeline (secondary) ─────────────────────────────
              _SectionHeader(title: 'الجدول الزمني'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MaterialTimelineChart(
                  orders: vm.ganttOrders,
                  periodStart: range.start,
                  periodEnd: range.end,
                ),
              ),

              const SizedBox(height: 24),

              // ── Activity ───────────────────────────────────────────────
              _SectionHeader(title: 'سجل النشاط'),
              ActivityStatementList(orders: vm.filteredOrders),

              const SizedBox(height: 24),

              // ── Milestones (driver/supplier) ───────────────────────────
              if (showMilestones) ...[
                MilestoneStrip(
                  totalOrders: vm.orderCount,
                  totalWeightKg: vm.totalWeightKg,
                  totalEarnings: vm.totalEarnings,
                ),
                const SizedBox(height: 24),
              ],

              // ── Report center (supplier/recycling) ─────────────────────
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ),
    );
  }
}
