import 'package:flutter/material.dart';
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

  static const _items = [
    (Icons.home_rounded, 'الرئيسية'),
    (Icons.storefront_rounded, 'السوق'),
    (Icons.receipt_long_rounded, 'طلباتي'),
    (Icons.person_rounded, 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
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
              for (int i = 0; i < _items.length; i++)
                SupplierNavItem(
                  icon: _items[i].$1,
                  label: _items[i].$2,
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
