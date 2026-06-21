import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/order/order.dart';
import '../../shared/order_card.dart';
import '../../shared/views/collection_sale_detail_view.dart';

class RecyclingOrdersTab extends StatefulWidget {
  final List<Order> incoming;
  final List<Order> jobs;
  final List<Order> Function(String jobId) salesForJob;

  const RecyclingOrdersTab({
    super.key,
    required this.incoming,
    required this.jobs,
    required this.salesForJob,
  });

  @override
  State<RecyclingOrdersTab> createState() => _RecyclingOrdersTabState();
}

class _RecyclingOrdersTabState extends State<RecyclingOrdersTab> {
  String _filterIncomingStatus    = 'الكل';
  String _filterIncomingType      = 'الكل';
  String _filterJobsHasAcceptors  = 'الكل';
  String _filterJobsPayment       = 'الكل';

  @override
  Widget build(BuildContext context) {
    // ── Derived filtered lists ────────────────────────────────────────────
    final wasteLabels = <String>{};
    for (final o in widget.incoming) {
      for (final t in o.wasteTypes) { wasteLabels.add(t.label); }
    }
    final incomingWasteChips = ['الكل', ...wasteLabels.toList()..sort()];

    final filteredIncoming = widget.incoming.where((o) {
      final statusOk = switch (_filterIncomingStatus) {
        'تم القبول' => o.status == OrderStatus.accepted,
        'في الطريق' => o.status == OrderStatus.inTransit,
        _           => true,
      };
      final typeOk = _filterIncomingType == 'الكل' ||
          o.wasteTypes.any((t) => t.label == _filterIncomingType);
      return statusOk && typeOk;
    }).toList();

    final filteredJobs = widget.jobs.where((o) {
      final hasAcceptors = widget.salesForJob(o.id).isNotEmpty;
      final acceptorOk = switch (_filterJobsHasAcceptors) {
        'لديه ملتزمون'    => hasAcceptors,
        'لا يوجد ملتزمون' => !hasAcceptors,
        _                  => true,
      };
      final paymentOk = switch (_filterJobsPayment) {
        'مبلغ ثابت' => o.paymentModel == PaymentModel.flatFee,
        'بالكيلو'   => o.paymentModel == PaymentModel.perKg,
        _           => true,
      };
      return acceptorOk && paymentOk;
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'الطلبات',
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: const Color(0xFF14401F),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF717973),
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.cairo(),
              tabs: const [
                Tab(text: 'الشحنات القادمة'),
                Tab(text: 'وظائف التجميع'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              children: [
                // ── Tab 1 — الشحنات القادمة ───────────────────────────────
                Column(
                  children: [
                    _filterRow(
                      chips: ['الكل', 'تم القبول', 'في الطريق'],
                      selected: _filterIncomingStatus,
                      onSelected: (v) =>
                          setState(() => _filterIncomingStatus = v),
                    ),
                    _filterRow(
                      chips: incomingWasteChips,
                      selected: _filterIncomingType,
                      onSelected: (v) =>
                          setState(() => _filterIncomingType = v),
                    ),
                    Expanded(
                      child: _RecyclingOrderList(
                        orders: filteredIncoming,
                        mode: OrderCardMode.companyIncoming,
                      ),
                    ),
                  ],
                ),
                // ── Tab 2 — وظائف التجميع ────────────────────────────────
                Column(
                  children: [
                    _filterRow(
                      chips: ['الكل', 'لديه ملتزمون', 'لا يوجد ملتزمون'],
                      selected: _filterJobsHasAcceptors,
                      onSelected: (v) =>
                          setState(() => _filterJobsHasAcceptors = v),
                    ),
                    _filterRow(
                      chips: ['الكل', 'مبلغ ثابت', 'بالكيلو'],
                      selected: _filterJobsPayment,
                      onSelected: (v) =>
                          setState(() => _filterJobsPayment = v),
                    ),
                    Expanded(
                      child: _RecyclingOrderList(
                        orders: filteredJobs,
                        mode: OrderCardMode.companyJob,
                        salesForJob: widget.salesForJob,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow({
    required List<String> chips,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: chips.map((chip) {
            final isSelected = chip == selected;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => onSelected(chip),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF06402B)
                        : const Color(0xFFF2F4F2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF06402B)
                          : const Color(0xFFE6E9E7),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    chip,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? Colors.white : const Color(0xFF404943),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RecyclingOrderList extends StatelessWidget {
  final List<Order> orders;
  final OrderCardMode mode;
  final List<Order> Function(String jobId)? salesForJob;

  const _RecyclingOrderList({
    required this.orders,
    required this.mode,
    this.salesForJob,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final order = orders[i];
        if (mode == OrderCardMode.companyJob && salesForJob != null) {
          final sales = salesForJob!(order.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OrderCard(order: order, mode: mode),
              if (sales.isNotEmpty) _buildAcceptorSection(ctx, sales),
            ],
          );
        }
        return OrderCard(order: order, mode: mode);
      },
    );
  }

  Widget _buildAcceptorSection(BuildContext context, List<Order> sales) {
    const maxShown = 3;
    final shown = sales.length <= maxShown ? sales : sales.sublist(0, maxShown);
    final overflow = sales.length - maxShown;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'الملتزمون (${sales.length})',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF717973),
            ),
          ),
          const SizedBox(height: 6),
          ...shown.map((sale) => _buildAcceptorRow(context, sale)),
          if (overflow > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+$overflow آخر',
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF717973),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAcceptorRow(BuildContext context, Order sale) {
    Color chipBg(OrderStatus s) => switch (s) {
          OrderStatus.pending => const Color(0xFFFEF3C7),
          OrderStatus.accepted || OrderStatus.arrivedAtPickup => const Color(0xFFD1FAE5),
          OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => const Color(0xFFDBEAFE),
          OrderStatus.completed => const Color(0xFFDCFCE7),
          OrderStatus.cancelled => const Color(0xFFFEE2E2),
        };
    Color chipText(OrderStatus s) => switch (s) {
          OrderStatus.pending => const Color(0xFFC8860A),
          OrderStatus.accepted || OrderStatus.arrivedAtPickup => const Color(0xFF1E5C35),
          OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => const Color(0xFF1E40AF),
          OrderStatus.completed => const Color(0xFF166534),
          OrderStatus.cancelled => const Color(0xFF991B1B),
        };

    final dateStr = DateFormatter.date(sale.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F4),
        border: Border.all(color: const Color(0xFFD1FAE5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CollectionSaleDetailView(sale: sale),
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'عرض التفاصيل',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF1E5C35),
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sale.supplierName ?? '',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: chipBg(sale.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      sale.status.label,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: chipText(sale.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
