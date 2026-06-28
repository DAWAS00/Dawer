import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/models/user.dart';
import 'package:dwaar/ui/features/home/home_router.dart';
import 'package:dwaar/domain/requests/create_pickup_request.dart';

class DevTestingPanel extends StatelessWidget {
  const DevTestingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      left: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        onPressed: () => _showPanel(context),
        child: const Icon(Icons.bug_report_rounded),
      ),
    );
  }

  void _showPanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _DevTestingPanelSheet(),
    );
  }
}

class _DevTestingPanelSheet extends StatefulWidget {
  const _DevTestingPanelSheet();

  @override
  State<_DevTestingPanelSheet> createState() => _DevTestingPanelSheetState();
}

class _DevTestingPanelSheetState extends State<_DevTestingPanelSheet> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppOrderStore>();
    final activeOrder = store.driverActiveOrder ?? 
        store.orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).firstOrNull ??
        store.orders.firstOrNull;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.bug_report_rounded, color: Colors.red),
                Text(
                  'لوحة تحكم المطورين (Dev Panel)',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            
            // --- Switch Roles Section ---
            Text('تغيير دور المستخدم:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roleButton(context, 'سائق', UserRole.driver, null),
                _roleButton(context, 'مورد (فرد)', UserRole.supplier, SupplierType.individual),
                _roleButton(context, 'مسترجع (شركة)', UserRole.recyclingCo, null),
              ],
            ),
            const SizedBox(height: 20),

            // --- Inject Orders ---
            Text('توليد طلبات اختبارية:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt_rounded),
              label: Text('حقن طلب معلق (Inject Pending Order)', style: GoogleFonts.cairo()),
              onPressed: () {
                store.submitPickupRequest(
                  CreatePickupRequest(
                    supplierId: 'dev-supp-123',
                    wasteTypes: [WasteType.plastic, WasteType.paper],
                    wasteForm: WasteForm.solid,
                    weightCategory: WeightCategory.light,
                    pickupAddress: 'عمان، شارع مكة',
                    pickupLat: 31.9753,
                    pickupLng: 35.8562,
                    dropoffLat: 31.9992,
                    dropoffLng: 36.0025,
                  ),
                  supplierName: 'مورد تجريبي',
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حقن طلب اختبار معلق بنجاح!')),
                );
              },
            ),
            const SizedBox(height: 20),

            // --- Order lifecycle actions ---
            if (activeOrder != null) ...[
              Text(
                'الطلب النشط المحدد: #${activeOrder.id.length > 6 ? activeOrder.id.substring(0, 6) : activeOrder.id} (${activeOrder.status.name})',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (activeOrder.status == OrderStatus.pending)
                    _actionButton('تأكيد القبول (Force Accept)', () {
                      const devDriver = User(
                        id: 'dev-driver-999',
                        name: 'سائق تجريبي (Dev)',
                        role: 'سائق',
                      );
                      store.acceptOrder(activeOrder.id, devDriver);
                    }),
                  if (activeOrder.status == OrderStatus.accepted)
                    _actionButton('الوصول للاستلام (Arrived Pickup)', () {
                      store.markArrivedAtPickup(activeOrder.id);
                    }),
                  if (activeOrder.status == OrderStatus.arrivedAtPickup) ...[
                    _actionButton('مورد متاح (Supplier Available)', () {
                      store.handleSupplierAvailable(activeOrder.id);
                    }),
                    _actionButton('مورد غير متاح (Supplier Unavailable)', () {
                      store.handleSupplierUnavailable(activeOrder.id);
                    }),
                  ],
                  if (activeOrder.status == OrderStatus.inTransit)
                    _actionButton('الوصول للتسليم (Arrived Dropoff)', () {
                      store.markArrivedAtDropoff(activeOrder.id);
                    }),
                  if (activeOrder.status == OrderStatus.arrivedAtDropoff)
                    _actionButton('إكمال التوصيل (Force Complete)', () {
                      store.completeOrder(activeOrder.copyWith(weightKg: 15.0));
                    }),
                  if (activeOrder.status == OrderStatus.pending || activeOrder.status == OrderStatus.accepted)
                    _actionButton('إلغاء الطلب (Force Cancel)', () {
                      store.cancelOrder(activeOrder.id);
                    }, color: Colors.red),
                ],
              ),
            ] else
              Text(
                'لا يوجد طلب نشط حالياً للتحكم به.',
                style: GoogleFonts.cairo(fontStyle: FontStyle.italic, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context, String label, UserRole role, SupplierType? type) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeRouter(
              role: role,
              supplierType: type ?? SupplierType.individual,
              userName: '$label (تجريبي)',
            ),
          ),
          (route) => false,
        );
      },
      child: Text(label, style: GoogleFonts.cairo(fontSize: 12)),
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
      child: Text(label, style: GoogleFonts.cairo(fontSize: 12)),
    );
  }
}
