import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:money_app/models/transaction.dart';
import 'package:money_app/screens/analysis_interface/analysis_screen.dart';
import 'package:money_app/screens/dbhelper.dart';
import 'package:money_app/widgets/navigation_bar_bottom.dart';
import 'package:money_app/screens/transaction_interface/transaction_screen.dart';
import 'package:money_app/widgets/transaction_item.dart';
import 'package:money_app/screens/user_interface/user_interface.dart';
import 'package:money_app/screens/category_interface/category_screen.dart';
import 'package:money_app/screens/transaction_interface/transaction_detail_screen.dart';
import 'package:money_app/screens/chat_interface/chat_interface.dart';
import 'package:money_app/widgets/format_currency.dart';

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
    AnalysisScreen(), // Index 1: Analysis
    TransactionScreen(), // Index 2: Transaction
    CategoryScreen(), // Index 3: Categories
    UserInterfaceScreen(), // Index 4: Profile
  ];

  void _onIconTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBarBottom(
        selectedIndex: _selectedIndex,
        onIconTap: _onIconTap,
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String screenName;

  const PlaceholderScreen({super.key, required this.screenName});

  @override
  Widget build(BuildContext context) {
    // (Code PlaceholderScreen giữ nguyên)
    return Scaffold(
      appBar: AppBar(
        title: Text(screenName),
        backgroundColor: const Color(0xFF00D09E),
      ),
      body: Center(
        child: Text(
          'This is the $screenName screen.',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  // --- (Biến State và các hàm helper giữ nguyên) ---
  bool _isLoading = true;
  int _totalBalance = 0;
  int _totalIncome = 0;
  int _totalExpense = 0;
  String _displayMonthName = ""; // Tên tháng
  List<Transaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final String currentMonth = DateFormat('yyyy-MM').format(now);
      final String displayMonth = DateFormat('MMMM yyyy').format(now);

      final results = await Future.wait([
        DBHelper.getTransactionsByMonth(currentMonth),
        DBHelper.getTotalIncome(currentMonth),
        DBHelper.getTotalSpent(currentMonth),
      ]);

      final List<Map<String, dynamic>> dataMap =
          results[0] as List<Map<String, dynamic>>;
      final List<Transaction> allTransactions = dataMap
          .map((itemMap) => Transaction.fromMap(itemMap))
          .toList();

      final int income = results[1] as int;
      final int expense = results[2] as int;

      setState(() {
        _recentTransactions = allTransactions.take(5).toList();
        _totalIncome = income;
        _totalExpense = expense;
        _totalBalance = income - expense;
        _displayMonthName = displayMonth; // Gán tên tháng
        _isLoading = false;
      });
    } catch (error) {
      print('Lỗi khi tải dữ liệu Dashboard: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _viewTransactionDetails(Transaction tx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => TransactionDetailScreen(transaction: tx),
      ),
    ).then((_) {
      _fetchData();
    });
  }

  Widget _buildTransactionItem(Transaction tx) {
    IconData categoryIcon = Icons.attach_money;
    Color categoryColor = Color(0xFF6CB5FD);

    if (tx.category == 'food') {
      categoryIcon = Icons.fastfood;
    } else if (tx.category == 'salary') {
      categoryIcon = Icons.wallet_outlined;
    } else if (tx.category == "transport") {
      categoryIcon = Icons.emoji_transportation;
    } else if (tx.category == "other") {
      categoryIcon = Icons.more_horiz;
    } else if (tx.category == "bills") {
      categoryIcon = Icons.receipt;
    } else if (tx.category == "entertainment") {
      categoryIcon = Icons.sports_esports;
    }

    String formattedAmount = formatCurrency(tx.amount);
    if (!tx.isIncome) {
      formattedAmount = "-$formattedAmount";
    }

    String formattedTime =
        "${tx.createdAt.hour}:${tx.createdAt.minute.toString().padLeft(2, '0')} - ${tx.createdAt.day} Thg${tx.createdAt.month}";

    return GestureDetector(
      onTap: () => _viewTransactionDetails(tx),
      child: TransactionItem(
        color: categoryColor,
        category: tx.category ?? 'Other',
        note: tx.note ?? '',
        time: formattedTime,
        amount: formattedAmount,
        isIncome: tx.isIncome,
        icon: categoryIcon,
      ),
    );
  }

  // --- KẾT THÚC HÀM HELPER ---

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning'; // Từ 0:00 đến 11:59
    } else if (hour < 17) {
      return 'Good Afternoon'; // Từ 12:00 đến 16:59
    } else {
      return 'Good Evening'; // Từ 17:00 đến 23:59
    }
  }

  // <-- HÀM ĐIỀU HƯỚNG CHAT -->
  void _navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const ChatInterfaceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final greeting = _getGreeting();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === PHẦN 1: HEADER MÀU XANH (ĐÃ SỬA LẠI) ===
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Header Text (Giữ nguyên) ===
                const Text(
                  "Hi, Welcome Back",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  greeting,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // --- TOTAL BALANCE ---
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _BalanceItem(
                          title: "Total Balance ($_displayMonthName)",
                          amount: formatCurrency(_totalBalance, showSign: true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // INCOME && EXPENSE BOX
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    // --- Income Box ---
                    Expanded(
                      child: Container(
                        height: 101,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF1FFF3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.89),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(top: 10),
                          child: Show(
                            imageSrc: "assets/images/income.png",
                            title: "Income",
                            money: formatCurrency(_totalIncome),
                            isExpense: false,
                          ),
                        ),
                      ),
                    ),

                    // --- Expense Box ---
                    Expanded(
                      child: Container(
                        height: 101,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF1FFF3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.89),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(top: 10),
                          child: Show(
                            imageSrc: "assets/images/expenses.png",
                            title: "Expense",
                            money: formatCurrency(_totalExpense),
                            isExpense: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),

          // === PHẦN 2: NỘI DUNG NỀN TRẮNG BO GÓC (Giữ nguyên) ===
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F9), // Màu nền trắng xám
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              // Dùng ClipRRect để đảm bảo nút FAB bị cắt theo góc bo
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
                // Dùng Stack để xếp chồng nội dung và nút
                child: Stack(
                  children: [
                    // --- LỚP 1: NỘI DUNG CUỘN (Như cũ) ---
                    SingleChildScrollView(
                      // Tăng padding dưới để không bị FAB che
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recent Transactions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (_recentTransactions.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32.0,
                                ),
                                child: Text(
                                  "Không có giao dịch nào trong tháng này.",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: _recentTransactions.map((tx) {
                                return _buildTransactionItem(tx);
                              }).toList(),
                            ),
                        ],
                      ),
                    ),

                    // --- LỚP 2: NÚT CHAT ---
                    Positioned(
                      bottom: 24, // Cách đáy 24
                      right: 24, // Cách phải 24
                      child: FloatingActionButton(
                        onPressed: _navigateToChat,
                        backgroundColor: const Color(0xFF00D09E),
                        child: const Icon(Icons.chat_bubble_outline),
                      ),
                    ),
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

  // Xóa 'amountColor' vì nó được tích hợp trong widget mới
  const _BalanceItem({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: ShapeDecoration(
        color: const Color(0xFFF1FFF2), // Màu nền xanh nhạt
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bọc Text bằng FittedBox để tự động co chữ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title, // Ví dụ: "Total Balance (November 2025)"
                style: TextStyle(
                  color: const Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: const Color(0xFF093030),
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
