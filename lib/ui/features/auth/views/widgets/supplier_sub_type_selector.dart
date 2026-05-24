import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../../../../l10n/l10n.dart';

class SupplierSubTypeSelector extends StatelessWidget {
  const SupplierSubTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Section label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l10n.supplierTypeLabel,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Two-card grid
          Row(
            children: [
              // Individual card
              Expanded(
                child: _buildTypeCard(
                  context: context,
                  label: l10n.supplierTypeIndividual,
                  icon: Icons.person_outline_rounded,
                  type: SupplierType.individual,
                  isSelected: viewModel.supplierType == SupplierType.individual,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeCard(
                  context: context,
                  label: l10n.supplierTypeStore,
                  icon: Icons.storefront_rounded,
                  type: SupplierType.storeBusiness,
                  isSelected: viewModel.supplierType == SupplierType.storeBusiness,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required SupplierType type,
    required bool isSelected,
  }) {
    final viewModel = context.read<LoginViewModel>();

    return GestureDetector(
      onTap: () => viewModel.setSupplierType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF06402B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFF06402B).withValues(alpha: 0.1),
                  width: 2,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF06402B).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? Colors.white : const Color(0xFF06402B),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF06402B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
