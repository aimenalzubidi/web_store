import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;
  final bool hasPendingOrders;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
    this.hasPendingOrders = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo / Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.storefront, color: Colors.white, size: 32),
              SizedBox(width: 10),
              Text(
                'لوحة الإدارة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          _SidebarItem(
            icon: Icons.inventory_2_outlined,
            title: 'المنتجات',
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          _SidebarItem(
            icon: Icons.shopping_cart_outlined,
            title: 'الطلبات',
            isSelected: selectedIndex == 1,
            showBadge: hasPendingOrders,
            onTap: () => onItemSelected(1),
          ),
          _SidebarItem(
            icon: Icons.receipt_long_outlined,
            title: 'الفواتير',
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),

          const Spacer(),
          const Divider(color: Colors.white24),
          _SidebarItem(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            isSelected: false,
            onTap: onLogout,
            isDanger: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDanger;
  final bool showBadge;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isDanger = false,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.primary.withOpacity(0.5))
              : null,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isDanger
                      ? AppColors.danger
                      : (isSelected ? AppColors.primary : Colors.white70),
                ),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isDanger
                    ? AppColors.danger
                    : (isSelected ? Colors.white : Colors.white70),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
