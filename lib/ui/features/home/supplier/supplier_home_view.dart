import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order.dart';
import '../../../../ui/features/auth/viewmodels/login_viewmodel.dart';
import '../shared/order_card.dart';
import '../shared/order_tracking_card.dart';

class SupplierHomeView extends StatefulWidget {
  final String userName;
  final SupplierType supplierType;

  const SupplierHomeView({
    super.key,
    required this.userName,
    required this.supplierType,
  });

  @override
  State<SupplierHomeView> createState() => _SupplierHomeViewState();
}

class _SupplierHomeViewState extends State<SupplierHomeView> {
  int _currentTab = 0;
  final List<Order> _active = Order.mockSupplierActive();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _HomeTab(
            userName: widget.userName,
            supplierType: widget.supplierType,
            active: _active,
          ),
          _OrdersTab(orders: _active),
          _ProfileTab(
            userName: widget.userName,
            supplierType: widget.supplierType,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'الرئيسية', isSelected: _currentTab == 0, onTap: () => setState(() => _currentTab = 0)),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'طلباتي', isSelected: _currentTab == 1, onTap: () => setState(() => _currentTab = 1)),
              _NavItem(icon: Icons.person_rounded, label: 'حسابي', isSelected: _currentTab == 2, onTap: () => setState(() => _currentTab = 2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  final String userName;
  final SupplierType supplierType;
  final List<Order> active;

  const _HomeTab({
    required this.userName,
    required this.supplierType,
    required this.active,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  WasteType? _selectedWasteType;

  final List<(WasteType, IconData)> _wasteCategories = const [
    (WasteType.paper, Icons.newspaper_rounded),
    (WasteType.plastic, Icons.local_drink_rounded),
    (WasteType.metal, Icons.hardware_rounded),
    (WasteType.glass, Icons.wine_bar_rounded),
    (WasteType.electronics, Icons.devices_rounded),
    (WasteType.organic, Icons.eco_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final Order? tracked = widget.active
        .where((o) =>
            o.status == OrderStatus.inTransit && o.driverName != null)
        .firstOrNull;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        if (tracked != null)
          SliverToBoxAdapter(child: OrderTrackingCard(order: tracked)),
        SliverToBoxAdapter(child: _buildPickupActionCard(context)),
        SliverToBoxAdapter(child: _buildWasteCategoriesSection()),
        if (widget.active.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'طلباتي النشطة',
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderCard(
                    order: widget.active[i],
                    mode: OrderCardMode.supplierActive,
                  ),
                ),
                childCount: widget.active.length,
              ),
            ),
          ),
        ] else
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isStore = widget.supplierType == SupplierType.storeBusiness;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E5C35), Color(0xFF2D8052)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 28),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Icon(
              isStore ? Icons.storefront_rounded : Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً، ${widget.userName.split(' ').first}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                isStore ? 'مورد متجر' : 'مورد فردي',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Points badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amberContainer.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '١٢٠',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentAmber,
                  ),
                ),
                Text(
                  'نقطة',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: AppColors.accentAmber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupActionCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNewRequestSheet(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06402B), Color(0xFF0F6B43)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_box_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'طلب استلام',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'اطلب سائقاً لاستلام مخلفاتك الآن',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'نوع المخلفات',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: _wasteCategories.map((entry) {
              final (type, icon) = entry;
              final isSelected = _selectedWasteType == type;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedWasteType = isSelected ? null : type;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF06402B) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.label,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF404943),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF717973),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showNewRequestSheet(BuildContext context) {
    // ignore: use_null_aware_elements
    final selectedTypes = <WasteType>{if (_selectedWasteType != null) _selectedWasteType!};

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _NewRequestSheet(
        preselected: selectedTypes,
        allCategories: _wasteCategories,
      ),
    );
  }
}

// ── New Pickup Request Bottom Sheet ──────────────────────────────────────────

class _NewRequestSheet extends StatefulWidget {
  final Set<WasteType> preselected;
  final List<(WasteType, IconData)> allCategories;

  const _NewRequestSheet({
    required this.preselected,
    required this.allCategories,
  });

  @override
  State<_NewRequestSheet> createState() => _NewRequestSheetState();
}

class _NewRequestSheetState extends State<_NewRequestSheet> {
  late Set<WasteType> _selected;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.preselected);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'طلب استلام جديد',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'اختر أنواع المخلفات وأضف تفاصيل الطلب',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF717973),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'نوع المخلفات *',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: widget.allCategories.map((entry) {
                final (type, icon) = entry;
                final isSelected = _selected.contains(type);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected ? _selected.remove(type) : _selected.add(type);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF06402B)
                          : const Color(0xFFF2F4F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type.label,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF404943),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(icon,
                            size: 15,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF717973)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'ملاحظات (اختياري)',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6E9E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                    fontSize: 14, color: const Color(0xFF191C1B)),
                decoration: InputDecoration(
                  hintText: 'مثال: الكميّة تقريباً ٢٠ كيس...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _selected.isNotEmpty
                    ? () => Navigator.pop(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
                  disabledBackgroundColor:
                      const Color(0xFF06402B).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'إرسال الطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Orders Tab ────────────────────────────────────────────────────────────────

class _OrdersTab extends StatelessWidget {
  final List<Order> orders;
  const _OrdersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 16),
            child: Text(
              'طلباتي',
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrderCard(
                  order: orders[i],
                  mode: OrderCardMode.supplierActive,
                ),
              ),
              childCount: orders.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;

  const _ProfileTab({required this.userName, required this.supplierType});

  @override
  Widget build(BuildContext context) {
    final isStore = supplierType == SupplierType.storeBusiness;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E5C35), Color(0xFF2D8052)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    24, MediaQuery.of(context).padding.top + 28, 24, 32),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      child: Icon(
                        isStore
                            ? Icons.storefront_rounded
                            : Icons.person_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isStore ? 'مورد متجر / مطعم' : 'مورد فردي',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ProfileTile(icon: Icons.star_rounded, label: 'نقاط التدوير', value: '١٢٠ نقطة'),
              _ProfileTile(icon: Icons.recycling_rounded, label: 'إجمالي الطلبات', value: '١٨ طلب'),
              _ProfileTile(icon: Icons.badge_rounded, label: 'الهوية', value: 'تم التحقق ✓'),
              _ProfileTile(icon: Icons.phone_rounded, label: 'رقم الهاتف', value: '+962 7X XXX XXXX'),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E5C35).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1E5C35)),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF404943),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared nav ────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1E5C35).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF1E5C35)
                  : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF1E5C35)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
