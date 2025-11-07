import 'package:flutter/material.dart';
import 'package:money_app/screens/analysis_interface/analysis_screen.dart';
import 'package:money_app/widgets/navigation_bar_bottom.dart';
import 'package:money_app/screens/chat_interface/chat_interface.dart';
import 'package:money_app/screens/transaction_interface/transaction_screen.dart';
import 'package:money_app/widgets/transaction_item.dart';

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
    AnalysisScreen(),   // Index 1: Analysis
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
                        const TransactionItem(
                          color: Color(0xFF6CB5FD),
                          category: "Salary",
                          note: "Monthly1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111",
                          time: "18:27 - April 30",
                          amount: "\$4,000.00",
                          isIncome: true,
                          icon: Icons.wallet_outlined,
                        ),
                        const TransactionItem(
                          color: Color(0xFF3299FF),
                          category: "Groceries",
                          note: "Pantry",
                          time: "17:00 - April 24",
                          amount: "-\$100.00",
                          isIncome: false,
                          icon: Icons.shopping_bag_outlined,
                        ),
                        const TransactionItem(
                          color: Color(0xFF0068FF),
                          category: "Rent",
                          note: "Rent",
                          time: "8:30 - April 15",
                          amount: "-\$674.40",
                          isIncome: false,
                          icon: Icons.vpn_key_outlined,
                        ),
                        const TransactionItem(
                          color: Color(0xFF0068FF),
                          category: "Rent",
                          note: "Rent",
                          time: "8:30 - April 15",
                          amount: "-\$674.40",
                          isIncome: false,
                          icon: Icons.vpn_key_outlined,
                        ),
                        const TransactionItem(
                          color: Color(0xFF0068FF),
                          category: "Rent",
                          note: "Rent",
                          time: "8:30 - April 15",
                          amount: "-\$674.40",
                          isIncome: false,
                          icon: Icons.vpn_key_outlined,
                        ),

                        // THÊM KHOẢNG TRỐNG để nội dung không bị che bởi nav bar
                        const SizedBox(height: 10),
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