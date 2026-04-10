import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order.dart';
import '../shared/order_card.dart';
import '../shared/order_tracking_card.dart';

class RecyclingHomeView extends StatefulWidget {
  final String userName;
  const RecyclingHomeView({super.key, required this.userName});

  @override
  State<RecyclingHomeView> createState() => _RecyclingHomeViewState();
}

class _RecyclingHomeViewState extends State<RecyclingHomeView> {
  int _currentTab = 0;
  bool _isOpen = true;

  final List<Order> _incoming = Order.mockCompanyIncoming();
  final List<Order> _jobs = Order.mockCompanyJobs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _HomeTab(
            userName: widget.userName,
            isOpen: _isOpen,
            onToggleOpen: (v) => setState(() => _isOpen = v),
            incoming: _incoming,
            jobs: _jobs,
          ),
          _OrdersTab(incoming: _incoming, jobs: _jobs),
          _ProfileTab(userName: widget.userName),
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
              _NavItem(icon: Icons.receipt_long_rounded, label: 'الطلبات', isSelected: _currentTab == 1, onTap: () => setState(() => _currentTab = 1)),
              _NavItem(icon: Icons.business_rounded, label: 'حسابي', isSelected: _currentTab == 2, onTap: () => setState(() => _currentTab = 2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final String userName;
  final bool isOpen;
  final ValueChanged<bool> onToggleOpen;
  final List<Order> incoming;
  final List<Order> jobs;

  const _HomeTab({
    required this.userName,
    required this.isOpen,
    required this.onToggleOpen,
    required this.incoming,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    final Order? tracked = incoming
        .where((o) =>
            o.status == OrderStatus.inTransit && o.driverName != null)
        .firstOrNull;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        if (tracked != null)
          SliverToBoxAdapter(child: OrderTrackingCard(order: tracked)),
        SliverToBoxAdapter(child: _buildStatsRow()),
        SliverToBoxAdapter(child: _buildPostJobCard(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'الشحنات القادمة',
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrderCard(
                  order: incoming[i],
                  mode: OrderCardMode.companyIncoming,
                ),
              ),
              childCount: incoming.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'وظائف التجميع النشطة',
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
                  order: jobs[i],
                  mode: OrderCardMode.companyJob,
                ),
              ),
              childCount: jobs.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 28),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: const Icon(Icons.recycling_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'شركة إعادة تدوير',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Open/closed toggle
              GestureDetector(
                onTap: () => onToggleOpen(!isOpen),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? Colors.green.shade300
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOpen ? Colors.white : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOpen ? 'مفتوح للاستلام' : 'مغلق مؤقتاً',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final inTransitCount =
        incoming.where((o) => o.status == OrderStatus.inTransit).length;
    final totalWeight = incoming.fold<double>(
        0, (sum, o) => sum + (o.weightKg ?? 0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(child: _StatCard(value: '${incoming.length}', label: 'شحنات اليوم', icon: Icons.local_shipping_rounded, color: AppColors.statusInTransitText)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${totalWeight.toStringAsFixed(0)}كغ', label: 'الوزن الكلي', icon: Icons.scale_rounded, color: AppColors.accentAmber)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${jobs.length}', label: 'وظائف نشطة', icon: Icons.work_rounded, color: AppColors.statusCompletedText)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '$inTransitCount', label: 'سائقون قيد التنفيذ', icon: Icons.directions_car_rounded, color: const Color(0xFF7C3AED))),
        ],
      ),
    );
  }

  Widget _buildPostJobCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPostJobSheet(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          color: const Color(0xFFD4EBAB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF3D7A1F).withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3D7A1F).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_circle_outline_rounded,
                  color: Color(0xFF14401F), size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'نشر وظيفة تجميع',
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF14401F),
                    ),
                  ),
                  Text(
                    'أطلب من سائق جمع المخلفات من منطقة محددة',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF14401F).withValues(alpha: 0.7),
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

  void _showPostJobSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _PostJobSheet(),
    );
  }
}

// ── Post Job Bottom Sheet ─────────────────────────────────────────────────────

class _PostJobSheet extends StatefulWidget {
  const _PostJobSheet();

  @override
  State<_PostJobSheet> createState() => _PostJobSheetState();
}

class _PostJobSheetState extends State<_PostJobSheet> {
  final _areaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final Set<WasteType> _selected = {};

  final List<(WasteType, IconData)> _categories = const [
    (WasteType.paper, Icons.newspaper_rounded),
    (WasteType.plastic, Icons.local_drink_rounded),
    (WasteType.metal, Icons.hardware_rounded),
    (WasteType.glass, Icons.wine_bar_rounded),
    (WasteType.electronics, Icons.devices_rounded),
    (WasteType.organic, Icons.eco_rounded),
  ];

  @override
  void dispose() {
    _areaCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              'نشر وظيفة تجميع جديدة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'أنواع المخلفات المطلوبة *',
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
              children: _categories.map((entry) {
                final (type, icon) = entry;
                final isSel = _selected.contains(type);
                return GestureDetector(
                  onTap: () => setState(
                      () => isSel ? _selected.remove(type) : _selected.add(type)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFF14401F)
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
                            color: isSel
                                ? Colors.white
                                : const Color(0xFF404943),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(icon,
                            size: 15,
                            color: isSel
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
              'منطقة الجمع *',
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
                controller: _areaCtrl,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                    fontSize: 14, color: const Color(0xFF191C1B)),
                decoration: InputDecoration(
                  hintText: 'مثال: الرابية، عمّان',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  hintText: 'كميّة تقريبية، وقت التسليم...',
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
                onPressed: (_selected.isNotEmpty && _areaCtrl.text.isNotEmpty)
                    ? () => Navigator.pop(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14401F),
                  disabledBackgroundColor:
                      const Color(0xFF14401F).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'نشر الوظيفة',
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
  final List<Order> incoming;
  final List<Order> jobs;

  const _OrdersTab({required this.incoming, required this.jobs});

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
                _OrderList(orders: incoming, mode: OrderCardMode.companyIncoming),
                _OrderList(orders: jobs, mode: OrderCardMode.companyJob),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final OrderCardMode mode;

  const _OrderList({required this.orders, required this.mode});

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

// ── Profile Tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final String userName;
  const _ProfileTab({required this.userName});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    24, MediaQuery.of(context).padding.top + 28, 24, 32),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.recycling_rounded,
                          size: 44, color: Colors.white),
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
                        'شركة إعادة تدوير',
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
              _ProfileTile(icon: Icons.verified_rounded, label: 'الترخيص التجاري', value: 'تم التحقق ✓'),
              _ProfileTile(icon: Icons.location_on_rounded, label: 'منطقة الخدمة', value: 'عمّان، الزرقاء، إربد'),
              _ProfileTile(icon: Icons.local_shipping_rounded, label: 'إجمالي الشحنات', value: '٢٣٤ شحنة'),
              _ProfileTile(icon: Icons.scale_rounded, label: 'الوزن الكلي المعالج', value: '١٢,٤٠٠ كغ'),
              _ProfileTile(icon: Icons.phone_rounded, label: 'رقم التواصل', value: '+962 6X XXX XXXX'),
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
              color: const Color(0xFF14401F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF14401F)),
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
              fontSize: 13,
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 9,
              color: const Color(0xFF717973),
            ),
          ),
        ],
      ),
    );
  }
}

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
                  ? const Color(0xFF14401F).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF14401F)
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
                  ? const Color(0xFF14401F)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
