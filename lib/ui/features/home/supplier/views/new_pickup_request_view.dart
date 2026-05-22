import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../data/models/order.dart';
import '../../../../../domain/requests/create_pickup_request.dart';
import '../../../../common/green_button.dart';
import '../../../../common/map/location_picker_screen.dart';
import '../viewmodels/supplier_home_viewmodel.dart';
import 'driver_selection_view.dart';
import '../../../../../data/services/location_service.dart';
import '../../../../../data/services/market_ai_service.dart';
import '../../shared/controllers/post_market_controller.dart';
import '../widgets/image_picker_grid.dart';

part 'new_pickup_request_view/location_sections.dart';
part 'new_pickup_request_view/mode_selector.dart';
part 'new_pickup_request_view/photo_section.dart';
part 'new_pickup_request_view/submit_bar.dart';
part 'new_pickup_request_view/waste_sections.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NewPickupRequestView — full-screen pickup order form
// ─────────────────────────────────────────────────────────────────────────────

enum _OrderMode { pickup, marketplace }

class NewPickupRequestView extends StatefulWidget {
  const NewPickupRequestView({super.key});

  @override
  State<NewPickupRequestView> createState() => _NewPickupRequestViewState();
}

class _NewPickupRequestViewState extends State<NewPickupRequestView> {
  // ── Form State ─────────────────────────────────────────────────────────────
  final Set<WasteType> _selectedTypes = {};
  WasteForm? _wasteForm;
  WeightCategory? _weightCategory;
  PickupTarget _pickupTarget = PickupTarget.company;
  double? _pickedLat;
  double? _pickedLng;
  String? _pickedAddress;
  final List<String> _images = [];
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _showTypeError = false;
  _OrderMode _mode = _OrderMode.pickup;

  // ── AI & Location Services ────────────────────────────────────────────────
  late final PostMarketController _ai;
  final _locationService = LocationService();
  bool _resolvingAddress = false;

  @override
  void initState() {
    super.initState();
    _ai = PostMarketController();
    _ai.addListener(_onAiStateChanged);
  }

  @override
  void dispose() {
    _ai.removeListener(_onAiStateChanged);
    _ai.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onAiStateChanged() => setState(() {});

  void _updateState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  double get _deliveryFee {
    const baseFee = 2.0;
    return baseFee +
        switch (_weightCategory) {
          WeightCategory.light => 0.0,
          WeightCategory.medium => 1.5,
          WeightCategory.heavy => 4.0,
          WeightCategory.veryHeavy => 8.0,
          null => 0.0,
        };
  }

  String get _pickupAddressLabel {
    if (_pickedAddress != null && _pickedAddress!.isNotEmpty) {
      return _pickedAddress!;
    }
    if (_pickedLat != null && _pickedLng != null) {
      return 'خط العرض: ${_pickedLat!.toStringAsFixed(4)} | خط الطول: ${_pickedLng!.toStringAsFixed(4)}';
    }
    return 'الموقع المحدد';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            children: [
              _buildModeSelector(),
              _buildPhotoSection(),
              _buildSection1WasteTypes(),
              _buildSection2WasteForm(),
              _buildSection3WeightCategory(),
              _buildSection4Location(),
              if (_mode == _OrderMode.pickup) _buildSection5PickupTarget(),
              _buildSection6Price(),
              _buildSection7Notes(),
              _buildDeliveryFeeCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSubmitBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'طلب استلام جديد',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: const Color(0xFF002819),
        ),
      ),
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: Color(0xFF717973),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionCard — white card wrapper for each form section
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? subtitle;

  const _SectionCard({required this.title, required this.child, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: const Color(0xFF9CA3AF))),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
