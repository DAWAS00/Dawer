import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/entities/earnings/earnings_summary.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../viewmodels/earnings_viewmodel.dart';
import '../../../common/green_button.dart';
import '../widgets/earnings_summary_card.dart';
import '../widgets/earnings_trend_chart.dart';
import '../widgets/earnings_trip_tile.dart';

class EarningsDashboardView extends StatefulWidget {
  /// [useScaffold] = true when navigated to via router (standalone page).
  /// Set false when embedded as a tab so it doesn't double-wrap with Scaffold.
  final bool useScaffold;
  const EarningsDashboardView({super.key, this.useScaffold = true});

  @override
  State<EarningsDashboardView> createState() => _EarningsDashboardViewState();
}

class _EarningsDashboardViewState extends State<EarningsDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final riderId =
          context.read<IAuthRepository>().currentSession?.userId ?? '';
      context.read<EarningsViewModel>().init(riderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EarningsViewModel>(
      builder: (context, vm, _) {
        final body = switch (vm.state) {
          Idle() ||
          Loading() => const Center(child: CircularProgressIndicator()),
          Failed(:final failure) => Center(child: Text(failure.message)),
          Loaded(:final data) => _buildDashboard(data, vm),
        };
        if (!widget.useScaffold) return body;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: body,
        );
      },
    );
  }

  Widget _buildDashboard(EarningsSummary summary, EarningsViewModel vm) {
    final showBack = widget.useScaffold && Navigator.of(context).canPop();

    return RefreshIndicator(
      onRefresh: vm.fetchEarnings,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: context.dt.surface,
            foregroundColor: context.dt.onSurface,
            automaticallyImplyLeading: false,
            leading: showBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  )
                : null,
            title: const Text('أرباحي'),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: vm.fetchEarnings,
                tooltip: 'تحديث البيانات',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMetricsGrid(summary),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('اتجاه الأرباح'),
                  const SizedBox(height: 12),
                  EarningsTrendChart(trend: summary.earningsTrend),
                  const SizedBox(height: 24),
                  _sectionTitle('النشاط الأخير'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EarningsTripTile(trip: summary.recentTrips[i]),
                ),
                childCount: summary.recentTrips.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  GreenButton(
                    text: 'تحميل تقرير الأداء',
                    onPressed: () => vm.generateReport(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(EarningsSummary s) {
    final cards = [
      EarningsSummaryCard(
        title: 'إجمالي الأرباح',
        value: '${s.totalEarnings.toStringAsFixed(2)} د.أ',
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.primaryGreen,
      ),
      EarningsSummaryCard(
        title: 'المسافة',
        value: '${s.totalDistance.toStringAsFixed(1)} كم',
        icon: Icons.directions_bike_outlined,
        color: AppColors.accentAmber,
      ),
      EarningsSummaryCard(
        title: 'عدد الرحلات',
        value: '${s.totalTrips}',
        icon: Icons.local_shipping_outlined,
        color: AppColors.primaryGreen,
      ),
      EarningsSummaryCard(
        title: 'متوسط الأرباح',
        value: '${s.averageEarningsPerTrip.toStringAsFixed(2)} د.أ',
        icon: Icons.trending_up_rounded,
        color: Colors.blueAccent,
      ),
    ];

    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(color: AppColors.primaryGreen),
    );
  }
}
