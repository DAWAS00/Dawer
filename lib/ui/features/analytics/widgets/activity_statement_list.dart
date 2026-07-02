import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/order/order.dart';
import 'activity_row.dart';

class ActivityStatementList extends StatelessWidget {
  const ActivityStatementList({
    super.key,
    required this.orders,
    this.emptyMessage = 'لا توجد طلبات مكتملة في هذه الفترة',
  });

  final List<Order> orders;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 8),
              Text(
                emptyMessage,
                style: GoogleFonts.cairo(color: const Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
      itemBuilder: (context, i) => ActivityRow(order: orders[i]),
    );
  }
}
