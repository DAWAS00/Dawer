import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../../../../l10n/l10n.dart';

class RoleSelectionGrid extends StatelessWidget {
  const RoleSelectionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.roleSelectTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF191C1B),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRoleCard(
              context: context,
              title: l10n.roleDriver,
              icon: Icons.local_shipping_rounded,
              role: UserRole.driver,
              isSelected: viewModel.selectedRole == UserRole.driver,
            ),
            const SizedBox(width: 12),
            _buildRoleCard(
              context: context,
              title: l10n.roleSupplier,
              icon: Icons.inventory_2_rounded,
              role: UserRole.supplier,
              isSelected: viewModel.selectedRole == UserRole.supplier,
            ),
            const SizedBox(width: 12),
            _buildRoleCard(
              context: context,
              title: l10n.roleRecyclingCo,
              icon: Icons.recycling_rounded,
              role: UserRole.recyclingCo,
              isSelected: viewModel.selectedRole == UserRole.recyclingCo,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required UserRole role,
    required bool isSelected,
  }) {
    final viewModel = context.read<LoginViewModel>();

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.selectRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 106,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF06402B) : const Color(0xFFC3EAC4),
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF06402B).withValues(alpha: 0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: const Color(0xFFB8EFD0).withValues(alpha: 0.3),
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF002819) : Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : const Color(0xFF2D4E33),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF2D4E33),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
