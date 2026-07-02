import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/waste_type_icons.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../data/models/order/order.dart' show WasteType, WasteTypeLabel, VehicleTypeLabel;
import '../../../../data/models/user_role.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../../home/home_router.dart';
import '../controllers/signup_controller.dart';
import '../viewmodels/vehicle_registration_viewmodel.dart';
import 'widgets/onboarding_shared_widgets.dart';
import 'widgets/vehicle_registration_scan_section.dart';

/// Screen 4 of the signup flow: role-specific details (vehicle, categories, location).
///
/// Receives the [SignupController] from Screen 3 and the [AuthSession] so it can
/// navigate to HomeRouter on completion. Screen 4 is non-blocking — users may
/// skip and complete their profile later.
class SignupRoleDetailsScreen extends StatelessWidget {
  final SignupController controller;
  final AuthSession session;

  const SignupRoleDetailsScreen({
    super.key,
    required this.controller,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // .value = don't dispose; controller lifecycle is owned by Screen 3's provider.
        ChangeNotifierProvider.value(value: controller),
        ChangeNotifierProvider(create: (_) => VehicleRegistrationViewModel()),
      ],
      child: _RoleDetailsBody(session: session),
    );
  }
}

class _RoleDetailsBody extends StatefulWidget {
  final AuthSession session;
  const _RoleDetailsBody({required this.session});

  @override
  State<_RoleDetailsBody> createState() => _RoleDetailsBodyState();
}

class _RoleDetailsBodyState extends State<_RoleDetailsBody> {
  final _plateController = TextEditingController();
  final _addressController = TextEditingController();
  Set<WasteType> _selectedTypes = {};
  bool _isLocating = false;

  SignupController get _ctrl => context.read<SignupController>();

  Future<void> _detectLocation() async {
    // Capture locale before any async gap (clean-code: no context use across awaits).
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    setState(() => _isLocating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.signupLocationPermissionDenied,
                style: GoogleFonts.cairo()),
          ));
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String addressText = '';
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          addressText = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join(isAr ? '، ' : ', ');
        }
      } catch (_) {
        // Reverse geocode failed — store coords only, address stays empty.
      }

      _ctrl.setLocation(pos.latitude, pos.longitude,
          addressText.isNotEmpty ? addressText : null);
      if (addressText.isNotEmpty && mounted) {
        _addressController.text = addressText;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.signupLocationError(e.toString()),
              style: GoogleFonts.cairo()),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _navigateHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeRouter(
          role: widget.session.role,
          supplierType: widget.session.supplierType ?? SupplierType.individual,
          userName: widget.session.userName,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _submit() async {
    _ctrl.setCategories(_selectedTypes.map((t) => t.name).toList());

    // Capture navigator before the async gap.
    final navigator = Navigator.of(context);
    final session = widget.session;

    final ok = await _ctrl.submitRoleDetails();
    if (!mounted) return;
    if (ok) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeRouter(
            role: session.role,
            supplierType: session.supplierType ?? SupplierType.individual,
            userName: session.userName,
          ),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _pickRegistrationDoc(ImageSource source) async {
    final picker = ImagePicker();
    final vm = context.read<VehicleRegistrationViewModel>();
    final xfile = await picker.pickImage(source: source, imageQuality: 90);
    if (xfile == null) return;
    await vm.analyzeDocument(File(xfile.path));
  }

  @override
  void dispose() {
    _plateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<SignupController>();
    final isDriver = controller.role == UserRole.driver;
    final isSupplier = controller.role == UserRole.supplier;

    return PopScope(
      // Disable back swipe/button — user has already created their account.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _navigateHome();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: _navigateHome,
            tooltip: l10n.navHome,
          ),
          title: Text(l10n.signupTitle, style: GoogleFonts.cairo()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: context.dt.onSurface,
          actions: [
            TextButton(
              onPressed: _navigateHome,
              child: Text(
                l10n.signupSkip,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF717973),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator (step 2/2).
                Row(
                  children: [
                    _StepDot(done: true),
                    const Expanded(child: Divider(thickness: 2, color: Color(0xFF06402B))),
                    _StepDot(done: false, active: true),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.signupIdentityLabel, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF06402B))),
                    Text(l10n.signupRoleDetailsLabel, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF06402B))),
                  ],
                ),
                const SizedBox(height: 24),

                // Header.
                Text(
                  _headerTitle(l10n, controller.role),
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF191C1B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _headerSubtitle(l10n, controller.role),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: const Color(0xFF717973),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Driver branch ──────────────────────────────────────────────
                if (isDriver) ...[
                  OnboardingSectionCard(
                    title: l10n.signupVehicleInfoTitle,
                    icon: Icons.directions_car_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Vehicle plate (required, LTR).
                        _PlateField(
                          controller: _plateController,
                          error: controller.fieldErrors['vehiclePlate'],
                          onChanged: (v) => _ctrl.vehiclePlate = v,
                        ),
                        const SizedBox(height: 20),

                        // AI registration scan (optional).
                        VehicleRegistrationScanSection(
                          onPick: _pickRegistrationDoc,
                          onReset: () => context.read<VehicleRegistrationViewModel>().reset(),
                          onConfirm: (data) {
                            _ctrl.setVehicleData(
                              model: data.model ?? '',
                              color: data.color ?? '',
                              type: data.vehicleType,
                              chemicalPermit: data.hasChemicalPermit,
                              plate: data.plateNumber,
                            );
                            // Auto-fill plate text field if scan extracted one.
                            if (data.plateNumber != null && _plateController.text.isEmpty) {
                              _plateController.text = data.plateNumber!;
                            }
                          },
                        ),

                        // Show auto-filled data chips after scan confirm.
                        if (controller.vehicleType != null) ...[
                          const SizedBox(height: 16),
                          _AutoFilledChips(controller: controller),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Supplier & Recycling Co branches: categories ───────────────
                if (isSupplier || controller.role == UserRole.recyclingCo) ...[
                  OnboardingSectionCard(
                    title: isSupplier
                        ? l10n.signupYourWasteTypes
                        : l10n.signupAcceptedWasteTypes,
                    icon: Icons.recycling_rounded,
                    subtitle: l10n.signupSelectOneOrMore,
                    child: _WasteTypeChips(
                      selected: _selectedTypes,
                      onToggle: (type) {
                        setState(() {
                          if (_selectedTypes.contains(type)) {
                            _selectedTypes = {..._selectedTypes}..remove(type);
                          } else {
                            _selectedTypes = {..._selectedTypes, type};
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Location (all roles, optional) ────────────────────────────
                OnboardingSectionCard(
                  title: l10n.signupLocationTitle,
                  icon: Icons.location_on_rounded,
                  subtitle: l10n.signupLocationSubtitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _isLocating ? null : _detectLocation,
                        child: _isLocating
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6E9E7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFC0C9C1)),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF06402B),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(l10n.signupLocating,
                                        style: GoogleFonts.cairo(
                                            fontSize: 13,
                                            color: const Color(0xFF404943))),
                                  ],
                                ),
                              )
                            : OnboardingLocationTile(
                                lat: controller.addressLat,
                                lng: controller.addressLng,
                              ),
                      ),
                      const SizedBox(height: 12),
                      OnboardingInputField(
                        controller: _addressController,
                        label: l10n.signupLocationPreciseLabel,
                        hint: l10n.signupLocationPreciseHint,
                        isRequired: false,
                        onChanged: (v) => _ctrl.address = v,
                      ),
                    ],
                  ),
                ),

                // Top-level error.
                if (controller.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      controller.error!,
                      style: GoogleFonts.cairo(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                GreenButton(
                  text: l10n.signupSaveAndComplete,
                  onPressed: _submit,
                  isLoading: controller.isSubmitting,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.isSubmitting ? null : _navigateHome,
                  child: Text(
                    l10n.signupSkipCompleteLater,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF717973),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Microcopy.
                Text(
                  l10n.signupUpdateAnytime,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF717973),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _headerTitle(AppLocalizations l10n, UserRole role) => switch (role) {
    UserRole.driver => l10n.signupRoleDriverHeading,
    UserRole.supplier => l10n.signupRoleSupplierHeading,
    UserRole.recyclingCo => l10n.signupRoleRecyclingHeading,
  };

  String _headerSubtitle(AppLocalizations l10n, UserRole role) => switch (role) {
    UserRole.driver => l10n.signupRoleDriverBody,
    UserRole.supplier => l10n.signupRoleSupplierBody,
    UserRole.recyclingCo => l10n.signupRoleRecyclingBody,
  };
}

// ── Vehicle plate field (LTR-forced) ──────────────────────────────────────────

class _PlateField extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  const _PlateField({
    required this.controller,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.signupPlateNumberLabel,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFDE047)),
              ),
              child: Text(
                l10n.signupPlateNumberHint,
                style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF713F12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: error != null ? Colors.red.shade50 : const Color(0xFFE6E9E7),
            borderRadius: BorderRadius.circular(12),
            border: error != null ? Border.all(color: Colors.red.shade300) : null,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              onChanged: onChanged,
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'e.g.  12 A B C',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(Icons.directions_car_rounded, color: Color(0xFF06402B)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: GoogleFonts.cairo(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

// ── Auto-filled vehicle data chips (shown after scan confirm) ─────────────────

class _AutoFilledChips extends StatelessWidget {
  final SignupController controller;
  const _AutoFilledChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (controller.vehicleType != null)
          _InfoChip(
            icon: Icons.local_shipping_rounded,
            label: controller.vehicleType!.label,
            color: const Color(0xFF06402B),
          ),
        if (controller.vehicleModel.isNotEmpty)
          _InfoChip(
            icon: Icons.directions_car_outlined,
            label: controller.vehicleModel,
          ),
        if (controller.vehicleColor.isNotEmpty)
          _InfoChip(
            icon: Icons.palette_outlined,
            label: controller.vehicleColor,
          ),
        if (controller.hasChemicalPermit)
          _InfoChip(
            icon: Icons.verified_rounded,
            label: l10n.vehicleScanChemicalPermit,
            color: const Color(0xFF059669),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF404943),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Waste type chip multi-selector ────────────────────────────────────────────

class _WasteTypeChips extends StatelessWidget {
  final Set<WasteType> selected;
  final ValueChanged<WasteType> onToggle;

  const _WasteTypeChips({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WasteTypeIcons.all.map((pair) {
        final type = pair.$1;
        final icon = pair.$2;
        final isSelected = selected.contains(type);
        return GestureDetector(
          onTap: () => onToggle(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF06402B)
                  : const Color(0xFFE6E9E7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF06402B)
                    : const Color(0xFFC0C9C1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : const Color(0xFF717973),
                ),
                const SizedBox(width: 6),
                Text(
                  type.label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : const Color(0xFF404943),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Progress step dot ─────────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  final bool done;
  final bool active;

  const _StepDot({required this.done, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || active ? const Color(0xFF06402B) : const Color(0xFFE6E9E7),
        border: Border.all(
          color: active ? const Color(0xFF06402B) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Icon(
        done && !active ? Icons.check_rounded : Icons.circle,
        size: done && !active ? 16 : 8,
        color: done || active ? Colors.white : const Color(0xFFC0C9C1),
      ),
    );
  }
}
