import 'package:flutter/material.dart';
import '../../../../../l10n/l10n.dart';
import 'supplier_nav_item.dart';

/// Shared bottom navigation bar used by both [SupplierHomeView] and
/// [IndividualSupplierHomeView]. Accepts [currentTab] and [onTabChanged]
/// so it has no direct ViewModel dependency.
class SupplierBottomNav extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  const SupplierBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.home_rounded, l10n.navHome),
      (Icons.storefront_rounded, l10n.navMarket),
      (Icons.receipt_long_rounded, l10n.navMyOrders),
      (Icons.person_rounded, l10n.navProfile),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                SupplierNavItem(
                  icon: items[i].$1,
                  label: items[i].$2,
                  isSelected: currentTab == i,
                  onTap: () => onTabChanged(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
