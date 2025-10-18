import 'package:flutter/material.dart';

class NavigationBarBottom extends StatelessWidget {
  final int selectedIndex;
  // ValueChanged<int> nhận giá trị callback kiểu int
  final ValueChanged<int> onIconTap;

  const NavigationBarBottom({super.key, required this.selectedIndex, required this.onIconTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: width * 0.08),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.home_filled,
            active: selectedIndex == 0,
            onTap: () => onIconTap(0),
          ),
          _NavIcon(
            icon: Icons.bar_chart_rounded,
            active: selectedIndex == 1,
            onTap: () => onIconTap(1),
          ),
          _NavIcon(
            icon: Icons.swap_horiz_rounded,
            active: selectedIndex == 2,
            onTap: () => onIconTap(2),
          ),
          _NavIcon(
            icon: Icons.account_balance_wallet_outlined,
            active: selectedIndex == 3,
            onTap: () => onIconTap(3),
          ),
          _NavIcon(
            icon: Icons.person_outline,
            active: selectedIndex == 4,
            onTap: () => onIconTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _NavIcon({
    this.active = false,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00D09E) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.grey[600]),
      ),
    );
  }
}
