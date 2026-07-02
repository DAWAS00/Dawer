import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../../../../l10n/l10n.dart';
import 'friendly_role_card.dart';

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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF191C1B),
          ),
        ),
        const SizedBox(height: 24),
        FriendlyRoleCard(
          icon: LucideIcons.truck,
          title: l10n.roleDriverTitle,
          subtitle: l10n.roleDriverSubtitle,
          isSelected: viewModel.selectedRole == UserRole.driver,
          onTap: () => viewModel.selectRole(UserRole.driver),
        ),
        const SizedBox(height: 12),
        FriendlyRoleCard(
          icon: LucideIcons.package,
          title: l10n.roleSupplierTitle,
          subtitle: l10n.roleSupplierSubtitle,
          isSelected: viewModel.selectedRole == UserRole.supplier,
          onTap: () => viewModel.selectRole(UserRole.supplier),
        ),
        const SizedBox(height: 12),
        FriendlyRoleCard(
          icon: LucideIcons.factory,
          title: l10n.roleRecyclingCoTitle,
          subtitle: l10n.roleRecyclingCoSubtitle,
          isSelected: viewModel.selectedRole == UserRole.recyclingCo,
          onTap: () => viewModel.selectRole(UserRole.recyclingCo),
        ),
      ],
    );
  }
}
