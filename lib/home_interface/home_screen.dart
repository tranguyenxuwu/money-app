import 'package:flutter/material.dart';
import 'package:money_app/navigation_bar/navigation_bar_bottom.dart';
import 'package:money_app/screens/chat_interface/chat_interface.dart';
import 'package:money_app/transaction_interface/transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với các tab
  static const List<Widget> _screens = <Widget>[
    DashboardContent(), // Index 0: Home
    ChatInterfaceScreen(),   // Index 1: Analysis/Chat
    TransactionScreen(), // Index 2: Transaction
    // PlaceholderScreen(screenName: 'Categories'), // Index 3: Categories
    // PlaceholderScreen(screenName: 'Profile'),    // Index 4: Profile
  ];

  void _onIconTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      // Body sẽ thay đổi dựa trên `_selectedIndex`
      body: _screens[_selectedIndex],
      // Sử dụng widget NavigationBarBottom đã được tách riêng
      bottomNavigationBar: NavigationBarBottom(
        selectedIndex: _selectedIndex,
        onIconTap: _onIconTap, // Truyền hàm callback xuống
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return SafeArea(
      bottom: false,
      child:
          // PHẦN NỀN: Toàn bộ nội dung cuộn được
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === PHẦN 1: HEADER MÀU XANH ===
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Header Text ===
                    const Text(
                      "Hi, Welcome Back",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Good Morning",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // === Balance Section ===
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _BalanceItem(
                            title: "Total Balance",
                            amount: "\$7,783.00",
                            amountColor: Colors.white,
                          ),
                          VerticalDivider(
                            color: Colors.white54,
                            width: 20,
                            thickness: 1,
                            indent: 5,
                            endIndent: 5,
                          ),
                          _BalanceItem(
                            title: "Total Expense",
                            amount: "-\$1,187.40",
                            amountColor: Color(0xFF0068FF),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === Progress Bar ===
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 0.3, // 30%
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF052224),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "30%",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "30% of your expenses, looks good.",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // === PHẦN 2: NỘI DUNG NỀN TRẮNG BO GÓC ===
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F7F9), // Màu nền trắng xám
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Widget TransactionFilter
                        const TransactionFilter(),

                        const SizedBox(height: 24),

                        const SizedBox(height: 16),
                        const _TransactionItem(
                          color: Color(0xFF6CB5FD),
                          title: "Salary",
                          subtitle: "Monthly",
                          time: "18:27 - April 30",
                          amount: "\$4,000.00",
                          isIncome: true,
                          icon: Icons.wallet_outlined,
                        ),
                        const _TransactionItem(
                          color: Color(0xFF3299FF),
                          title: "Groceries",
                          subtitle: "Pantry",
                          time: "17:00 - April 24",
                          amount: "-\$100.00",
                          isIncome: false,
                          icon: Icons.shopping_bag_outlined,
                        ),
                        const _TransactionItem(
                          color: Color(0xFF0068FF),
                          title: "Rent",
                          subtitle: "Rent",
                          time: "8:30 - April 15",
                          amount: "-\$674.40",
                          isIncome: false,
                          icon: Icons.vpn_key_outlined,
                        ),
                        // THÊM KHOẢNG TRỐNG để nội dung không bị che bởi nav bar
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

// =========================================================
// === WIDGET MỚI: DÀNH CHO NHÓM NÚT LỌC GIAO DỊCH ===
// =========================================================

// Enum để định nghĩa các khoảng thời gian lọc
enum FilterPeriod { daily, weekly, monthly }

// Widget chính, có trạng thái riêng để quản lý nút nào đang được chọn
class TransactionFilter extends StatefulWidget {
  const TransactionFilter({super.key});

  @override
  State<TransactionFilter> createState() => _TransactionFilterState();
}

class _TransactionFilterState extends State<TransactionFilter> {
  // Biến trạng thái để theo dõi mục được chọn, mặc định là Monthly
  FilterPeriod _selectedPeriod = FilterPeriod.monthly;

  // Hàm cập nhật trạng thái khi một nút được nhấn
  void _onFilterTap(FilterPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F3E6), // Màu nền xanh lá nhạt
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _FilterButton(
            text: "Daily",
            isSelected: _selectedPeriod == FilterPeriod.daily,
            onTap: () => _onFilterTap(FilterPeriod.daily),
          ),
          _FilterButton(
            text: "Weekly",
            isSelected: _selectedPeriod == FilterPeriod.weekly,
            onTap: () => _onFilterTap(FilterPeriod.weekly),
          ),
          _FilterButton(
            text: "Monthly",
            isSelected: _selectedPeriod == FilterPeriod.monthly,
            onTap: () => _onFilterTap(FilterPeriod.monthly),
          ),
        ],
      ),
    );
  }
}

// Widget phụ, tái sử dụng cho từng nút bấm trong bộ lọc
class _FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00D09E) : Colors.transparent,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String title;
  final String amount;
  final Color amountColor;

  const _BalanceItem({
    required this.title,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              title == "Total Balance"
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final String amount;
  final bool isIncome;
  final IconData icon;

  const _TransactionItem({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.amount,
    required this.isIncome,
    this.icon = Icons.attach_money,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? const Color(0xFF00D09E) : Colors.redAccent,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
