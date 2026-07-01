import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../data/models/user.dart';
import '../../../../../l10n/l10n.dart';
import 'package:dwaar/ui/common/map/route_map_view.dart';
import '../../../../features/auth/viewmodels/login_viewmodel.dart';
import '../viewmodels/marketplace_viewmodel.dart';
import '../../recycling/widgets/edit_collection_job_sheet.dart';
import 'accept_collection_job_sheet.dart';

/// Full-screen detail page for a collection job.
/// Roles:
///   - driver        → "قبول الوظيفة" button
///   - job owner     → "تعديل" + "حذف" buttons
///   - all others    → read-only
class CollectionJobDetailView extends StatefulWidget {
  final Order job;
  final UserRole role;
  final String? currentUserName;
  final User? currentDriver;
  final void Function(Order? sale)? onAccepted;

  const CollectionJobDetailView({
    super.key,
    required this.job,
    required this.role,
    this.currentUserName,
    this.currentDriver,
    this.onAccepted,
  });

  @override
  State<CollectionJobDetailView> createState() =>
      _CollectionJobDetailViewState();
}

class _CollectionJobDetailViewState extends State<CollectionJobDetailView> {
  late Order _job;
  bool _hasAccepted = false;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.currentUserName != null) {
      _hasAccepted = context
          .read<MarketplaceViewModel>()
          .hasAcceptedJob(_job.id, widget.currentUserName!);
    }
  }

  bool get _isOwner =>
      widget.role == UserRole.recyclingCo &&
      _job.supplierName == widget.currentUserName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dt.scaffold,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_job.pickupLat != null && _job.dropoffLat != null) ...
                    [_buildMapSection(), const SizedBox(height: 16)],
                  if (_job.isEdited) _buildEditedBanner(),
                  _buildCompanyCard(),
                  const SizedBox(height: 16),
                  _buildWasteTypesCard(),
                  const SizedBox(height: 16),
                  _buildPricingCard(),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildActionBar(context),
    );
  }

  Widget _buildMapSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: RouteMapView(
        pickupLat: _job.pickupLat!,
        pickupLng: _job.pickupLng!,
        dropoffLat: _job.dropoffLat!,
        dropoffLng: _job.dropoffLng!,
        height: 180,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Text(
          context.l10n.collectionJobTitle,
          style: GoogleFonts.cairo(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditedBanner() {
    final timeLabel = _job.editedAt != null ? _formatAge(context, _job.editedAt!) : '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                context.l10n.collectionJobEditedAt(timeLabel),
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF92400E)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_rounded,
                  size: 16, color: Color(0xFF92400E)),
            ],
          ),
          if (_job.editNote != null && _job.editNote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _job.editNote!,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                  fontSize: 12, color: const Color(0xFFB45309)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyCard() {
    return _DetailCard(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatAge(context, _job.createdAt),
                style: GoogleFonts.cairo(
                    fontSize: 11, color: context.dt.onSurfaceMuted),
              ),
              Text(
                _job.id,
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: context.dt.onSurfaceMuted),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _job.supplierName ?? context.l10n.collectionJobRecyclingCoLabel,
                style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.dt.onSurface),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4EBAB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.collectionJobRecyclingCoLabel,
                  style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF14401F)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 24,
            backgroundColor:
                const Color(0xFF14401F).withValues(alpha: 0.08),
            child: const Icon(Icons.recycling_rounded,
                size: 24, color: Color(0xFF14401F)),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTypesCard() {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SectionTitle(
              icon: Icons.category_rounded, label: context.l10n.collectionJobRequiredMaterials),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: _job.wasteTypes
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4EBAB).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t.label,
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF14401F))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: context.dt.onSurfaceMuted),
              const SizedBox(width: 4),
              Text(
                _job.pickupAddress,
                style: GoogleFonts.cairo(
                    fontSize: 12, color: context.dt.onSurfaceMuted),
              ),
              const Spacer(),
              Text(context.l10n.collectionJobCollectionArea,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.dt.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    final price = _job.pricePerKg ?? _job.itemPrice;
    final model = _job.paymentModel;
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SectionTitle(
              icon: Icons.payments_rounded, label: context.l10n.collectionJobPricingTitle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (model != null) ...[
                _Chip(
                    label: model.label,
                    icon: model == PaymentModel.perKg
                        ? Icons.scale_rounded
                        : Icons.payments_rounded,
                    color: const Color(0xFF14401F)),
                const SizedBox(width: 12),
              ],
              if (price != null) ...[
                Text(
                  '$price ${model?.unitLabelFor(Localizations.localeOf(context)) ?? context.l10n.orderCurrencyJD}',
                  style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF14401F)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.monetization_on_rounded,
                    size: 18, color: Color(0xFF14401F)),
              ],
            ],
          ),
          if (_job.minQuantityKg != null &&
              model == PaymentModel.perKg) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _Chip(
                  label: context.l10n.collectionJobMinQtyChip(_job.minQuantityKg!.toStringAsFixed(0)),
                  icon: Icons.scale_rounded,
                  color: const Color(0xFF7C3AED)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    if (_job.jobDescription == null || _job.jobDescription!.isEmpty) {
      return const SizedBox.shrink();
    }
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SectionTitle(
              icon: Icons.description_rounded, label: context.l10n.collectionJobDescTitle),
          const SizedBox(height: 10),
          Text(
            _job.jobDescription!,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
                fontSize: 14,
                color: context.dt.onSurfaceVariant,
                height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    if (_job.status != OrderStatus.pending && !_isOwner) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
      color: context.dt.surface,
      child: Row(
        children: [
          if (_isOwner) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showEditSheet(context),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text(context.l10n.edit,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF14401F),
                  side: const BorderSide(color: Color(0xFF14401F)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_rounded, size: 16),
                label: Text(context.l10n.collectionJobDeleteTitle,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF991B1B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else if (_hasAccepted) ...[
            _buildAlreadyAcceptedBanner(),
          ] else if ((widget.role == UserRole.driver ||
                  widget.role == UserRole.supplier) &&
              widget.currentUserName != null &&
              _job.status == OrderStatus.pending) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _acceptJob(context),
                icon: Icon(
                    widget.role == UserRole.driver
                        ? Icons.check_circle_rounded
                        : Icons.handshake_rounded,
                    size: 18),
                label: Text(
                    widget.role == UserRole.driver
                        ? context.l10n.collectionJobAcceptButton
                        : context.l10n.collectionJobAcceptSellButton,
                    style: GoogleFonts.cairo(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14401F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final vm = context.read<MarketplaceViewModel>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => EditCollectionJobSheet(
        job: _job,
        onUpdate: ({
          required List<WasteType> wasteTypes,
          required PaymentModel paymentModel,
          required double price,
          required String collectionArea,
          required String jobDescription,
          double? minQuantityKg,
          String? editNote,
        }) {
          final updated = vm.updateCollectionJob(
            jobId: _job.id,
            companyName: widget.currentUserName ?? '',
            wasteTypes: wasteTypes,
            collectionArea: collectionArea,
            jobDescription: jobDescription,
            paymentModel: paymentModel,
            price: price,
            minQuantityKg: minQuantityKg,
            editNote: editNote,
          );
          if (updated != null) setState(() => _job = updated);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.collectionJobDeleteTitle,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right),
        content: Text(context.l10n.collectionJobDeleteConfirm,
            style: GoogleFonts.cairo(), textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF991B1B)),
            onPressed: () {
              final vm = context.read<MarketplaceViewModel>();
              vm.deleteCollectionJob(_job.id, widget.currentUserName ?? '');
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(context.l10n.delete,
                style: GoogleFonts.cairo(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyAcceptedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF14401F), size: 18),
          const SizedBox(width: 8),
          Text(context.l10n.collectionJobAccepted,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14401F))),
        ],
      ),
    );
  }

  void _acceptJob(BuildContext context) {
    if (widget.currentUserName == null) return;
    if (widget.role == UserRole.supplier) {
      AcceptCollectionJobSheet.show(
        context,
        job: _job,
        onConfirm: (deliveryMethod, transactionType) =>
            _doAccept(context, deliveryMethod: deliveryMethod, transactionType: transactionType),
      );
    } else {
      _doAccept(context);
    }
  }

  void _doAccept(
    BuildContext context, {
    CollectionDeliveryMethod? deliveryMethod,
    CollectionTransactionType? transactionType,
  }) {
    final vm = context.read<MarketplaceViewModel>();
    final error = vm.acceptCollectionJob(
      _job.id,
      widget.currentUserName!,
      deliveryMethod: deliveryMethod,
      transactionType: transactionType,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: const Color(0xFF991B1B),
      ));
    } else {
      if (!mounted) return;
      final newSale = widget.currentUserName != null
          ? context.read<MarketplaceViewModel>().latestCollectionSaleFor(widget.currentUserName!)
          : null;
      Navigator.of(context).pop();
      widget.onAccepted?.call(newSale);
    }
  }

  String _formatAge(BuildContext ctx, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final l10n = ctx.l10n;
    if (diff.inDays > 0) return l10n.timeAgoDays(diff.inDays);
    if (diff.inHours > 0) return l10n.timeAgoHours(diff.inHours);
    return l10n.timeAgoMinutes(diff.inMinutes);
  }
}

// ── Private helper widgets ────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final Widget child;
  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dt.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: context.dt.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.dt.onSurfaceVariant)),
        const SizedBox(width: 6),
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Chip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(width: 4),
          Icon(icon, size: 13, color: color),
        ],
      ),
    );
  }
}
