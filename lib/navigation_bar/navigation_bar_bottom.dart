import 'package:flutter/material.dart';
import 'package:money_app/services/sync_service.dart';

class NavigationBarBottom extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIconTap;

  const NavigationBarBottom({super.key, required this.selectedIndex, required this.onIconTap});

  @override
  State<NavigationBarBottom> createState() => _NavigationBarBottomState();
}

class _NavigationBarBottomState extends State<NavigationBarBottom> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial sync when the app starts
    print("[AppLifecycle] Initial sync triggered.");
    _syncData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print("[AppLifecycle] App resumed, triggering sync.");
      _syncData();
    }
  }

  void _syncData() {
    // This is an automatic background sync, so we don't show a snackbar.
    // The service itself will print logs.
    SyncService.syncAllDataToFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return SafeArea(
      bottom: true,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: width * 0.08),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavIcon(
              icon: Icons.home_filled,
              active: widget.selectedIndex == 0,
              onTap: () => widget.onIconTap(0),
            ),
            _NavIcon(
              icon: Icons.bar_chart_rounded,
              active: widget.selectedIndex == 1,
              onTap: () => widget.onIconTap(1),
            ),
            _NavIcon(
              icon: Icons.swap_horiz_rounded,
              active: widget.selectedIndex == 2,
              onTap: () => widget.onIconTap(2),
            ),
            _NavIcon(
              icon: Icons.account_balance_wallet_outlined,
              active: widget.selectedIndex == 3,
              onTap: () => widget.onIconTap(3),
            ),
            _NavIcon(
              icon: Icons.person_outline,
              active: widget.selectedIndex == 4,
              onTap: () => widget.onIconTap(4),
            ),
          ],
        ),
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
