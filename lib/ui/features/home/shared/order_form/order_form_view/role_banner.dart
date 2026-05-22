part of '../order_form_view.dart';

class _RoleBanner extends StatelessWidget {
  final SupplierType supplierType;
  final String userName;

  const _RoleBanner({required this.supplierType, required this.userName});

  @override
  Widget build(BuildContext context) {
    final isRestaurant = supplierType == SupplierType.storeBusiness;
    final roleLabel = isRestaurant ? 'مطعم / منشأة' : 'مورد فردي';
    final roleIcon = isRestaurant ? Icons.restaurant_rounded : Icons.person_rounded;
    final color = isRestaurant ? const Color(0xFF1E40AF) : const Color(0xFF06402B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'مرحباً، $userName',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819)),
                ),
                const SizedBox(height: 2),
                Text(
                  'أنت تقدّم طلباً بصفة مورد — يمكن تغيير الدور من الحساب',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: const Color(0xFF717973)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(roleLabel,
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(width: 5),
              Icon(roleIcon, color: Colors.white, size: 13),
            ]),
          ),
        ],
      ),
    );
  }
}
