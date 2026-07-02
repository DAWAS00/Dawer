import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/l10n.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../features/auth/viewmodels/login_viewmodel.dart';
import '../viewmodels/marketplace_viewmodel.dart';
import '../views/collection_job_detail_view.dart';
import 'collection_job_card.dart';

/// Sliver section listing all pending collection jobs from recycling companies.
/// Drivers see a "قبول الوظيفة" button; other roles see "عرض التفاصيل".
class CollectionJobsSection extends StatelessWidget {
  final List<Order> jobs;
  final UserRole role;
  final MarketplaceViewModel vm;
  final User? currentDriver;
  final String? currentUserName;
  final void Function(Order? sale)? onJobAccepted;

  const CollectionJobsSection({
    super.key,
    required this.jobs,
    required this.role,
    required this.vm,
    this.currentDriver,
    this.currentUserName,
    this.onJobAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _buildSectionHeader(context)),
        if (jobs.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyState(context))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CollectionJobCard(
                    job: jobs[index],
                    showClaimButton: role == UserRole.driver,
                    onTap: () => _openDetail(context, jobs[index]),
                    onClaim: role == UserRole.driver && currentDriver != null
                        ? () => _claimJob(context, jobs[index].id)
                        : null,
                  ),
                ),
                childCount: jobs.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${jobs.length}',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E40AF),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              l10n.marketJobsFromCompanies,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E40AF),
              ),
            ),
          ),
          const Spacer(),
          Text(
            l10n.marketSegmentJobs,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                size: 32,
                color: Color(0xFF1E40AF),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.marketNoJobs,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.marketNoJobsBody,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF9CA3AF),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Order job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: CollectionJobDetailView(
            job: job,
            role: role,
            currentUserName: currentUserName,
            currentDriver: currentDriver,
            onAccepted: onJobAccepted,
          ),
        ),
      ),
    );
  }

  void _claimJob(BuildContext context, String jobId) {
    if (currentDriver == null) return;
    final error = vm.claimCollectionJob(jobId, currentDriver!);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
    }
  }
}
