import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../shared/order_card.dart';

class RecyclingOrdersTab extends StatelessWidget {
  final List<Order> incoming;
  final List<Order> jobs;

  const RecyclingOrdersTab({
    super.key,
    required this.incoming,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                _RecyclingOrderList(orders: incoming, mode: OrderCardMode.companyIncoming),
                _RecyclingOrderList(orders: jobs, mode: OrderCardMode.companyJob),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecyclingOrderList extends StatelessWidget {
  final List<Order> orders;
  final OrderCardMode mode;

  const _RecyclingOrderList({required this.orders, required this.mode});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: orders.length,
      separatorBuilder: (context, sep) => const SizedBox(height: 12),
      itemBuilder: (_, i) => OrderCard(order: orders[i], mode: mode),
    );
  }
}
