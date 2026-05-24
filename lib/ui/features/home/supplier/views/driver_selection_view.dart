import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../common/green_button.dart';
import '../viewmodels/supplier_home_viewmodel.dart';

enum SelectionState { searching, browsing, confirmed }

class DriverSelectionView extends StatefulWidget {
  final Order order;

  const DriverSelectionView({super.key, required this.order});

  @override
  State<DriverSelectionView> createState() => _DriverSelectionViewState();
}

class _DriverSelectionViewState extends State<DriverSelectionView>
    with SingleTickerProviderStateMixin {
  SelectionState _state = SelectionState.searching;
  late AnimationController _pulseController;

  final List<User> _mockDrivers = [
    const User(
      id: 'DRV-001',
      name: 'أحمد صالح',
      role: 'driver',
      rating: 4.9,
      vehicleModel: 'تويوتا هايلكس',
      vehicleColor: 'أبيض',
      licensePlate: '١٢-٣٤٥٦',
      phone: '٠٧٩١٢٣٤٥٦٧',
    ),
    const User(
      id: 'DRV-002',
      name: 'سامر علي',
      role: 'driver',
      rating: 4.7,
      vehicleModel: 'ميتسوبيشي L200',
      vehicleColor: 'فضي',
      licensePlate: '٥٥-٧٨٩٠',
      phone: '٠٧٨٩٨٧٦٥٤٣',
    ),
    const User(
      id: 'DRV-003',
      name: 'محمود حسن',
      role: 'driver',
      rating: 4.8,
      vehicleModel: 'فورد F-150',
      vehicleColor: 'أسود',
      licensePlate: '٩٩-١١٢٢',
      phone: '٠٧٧١١٢٢٣٣٤',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onAssign(User driver) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildConfirmationDialog(ctx, driver),
    );
  }

  void _confirmSelection(User driver, SupplierHomeViewModel vm) {
    vm.assignDriver(widget.order.id, driver);
    setState(() => _state = SelectionState.confirmed);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SupplierHomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _state == SelectionState.searching
            ? _buildSearchingState()
            : _buildBrowsingState(vm),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        _state == SelectionState.searching ? 'جاري البحث عن سائق' : 'اختر سائقاً',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: const Color(0xFF002819),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF717973)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (_state == SelectionState.browsing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.statusActiveBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${_mockDrivers.length} متاحين',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusActiveText,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchingState() {
    return Column(
      key: const ValueKey('searching'),
      children: [
        const SizedBox(height: 60),
        _buildPulseAnimation(),
        const SizedBox(height: 40),
        Text(
          'جاري إيجاد أقرب سائق لك',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF002819),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'عادةً يستغرق هذا أقل من دقيقة',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: AppColors.mutedText,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildOrderSummaryMini(),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => setState(() => _state = SelectionState.browsing),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'اختر سائقاً بنفسك',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<SupplierHomeViewModel>().cancelOrder(widget.order.id);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'إلغاء الطلب',
                  style: GoogleFonts.cairo(color: AppColors.mutedText),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPulseAnimation() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          painter: PulsePainter(_pulseController.value),
          child: Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 60,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummaryMini() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.recycling_rounded, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.wasteTypes.map((e) => e.name).join('، '),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.order.pickupAddress,
                  style: GoogleFonts.cairo(fontSize: 12, color: AppColors.mutedText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowsingState(SupplierHomeViewModel vm) {
    return Column(
      key: const ValueKey('browsing'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: const Color(0xFFD4EBAB).withValues(alpha: 0.3),
          child: Center(
            child: Text(
              'السائقين المتاحين القريبين منك',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _mockDrivers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildDriverCard(_mockDrivers[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(User driver) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEBF4EE),
                child: Text(
                  driver.name[0],
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          driver.name,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star_rounded, color: AppColors.accentAmber, size: 18),
                        Text(
                          driver.rating.toString(),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentAmber,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${driver.vehicleModel} • ${driver.vehicleColor}',
                      style: GoogleFonts.cairo(fontSize: 12, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF4EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '١.٢ كم',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المكافأة المتوقعة',
                    style: GoogleFonts.cairo(fontSize: 10, color: AppColors.mutedText),
                  ),
                  Text(
                    '${widget.order.reward > 0 ? widget.order.reward : 5.0} د.أ',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentAmber,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
                child: GreenButton(
                  text: 'اختر هذا السائق',
                  onPressed: () => _onAssign(driver),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDialog(BuildContext context, User driver) {
    final vm = context.read<SupplierHomeViewModel>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFEBF4EE),
              child: Text(
                driver.name[0],
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تم التعيين!',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تم تعيين ${driver.name} لاستلام طلبك. ستحصل على إشعار عند وصوله.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            GreenButton(
              text: 'متابعة الطلب',
              onPressed: () {
                 _confirmSelection(driver, vm);
                 Navigator.of(context).pop(); // pop view
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PulsePainter extends CustomPainter {
  final double animationValue;

  PulsePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    for (int i = 1; i <= 3; i++) {
      final double progress = (animationValue + (i / 3)) % 1;
      final double opacity = 1 - progress;
      final double radius = baseRadius + (progress * 80);

      final paint = Paint()
        ..color = AppColors.primaryGreen.withValues(alpha: opacity * 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(PulsePainter oldDelegate) => true;
}
