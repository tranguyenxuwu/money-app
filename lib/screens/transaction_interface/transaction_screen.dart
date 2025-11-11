import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'package:money_app/screens/dbhelper.dart'; // <-- Đường dẫn tới file DBHelper
import 'package:money_app/models/transaction.dart'; // <-- Import model
import '../analysis_interface/analysis_screen.dart'; // <-- Import cho Show
import 'package:money_app/widgets/transaction_item.dart';

enum TransactionFilter { all, income, expense }

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  TransactionFilter _selectedFilter = TransactionFilter.all;

  // --- BIẾN STATE ---
  List<Transaction> _allTransactions = [];
  bool _isLoading = true;

  int _totalBalance = 0;
  int _totalIncome = 0;
  int _totalExpense = 0;

  // --- KẾT THÚC BIẾN STATE ---

  @override
  void initState() {
    super.initState();
    _fetchData(); // <-- Đổi tên hàm
  }

  // --- HÀM TẢI DỮ LIỆU ---
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy tháng hiện tại (ví dụ: '2025-11')
      final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

      // Chạy 3 câu query CSDL song song để tăng tốc
      final results = await Future.wait([
        DBHelper.getAllTransactions(), // (Bạn có thể lọc theo tháng nếu muốn)
        DBHelper.getTotalIncome(currentMonth),
        DBHelper.getTotalSpent(currentMonth),
      ]);

      // 1. Lấy danh sách giao dịch
      final List<Map<String, dynamic>> dataMap =
          results[0] as List<Map<String, dynamic>>;
      final List<Transaction> loadedTransactions = dataMap
          .map((itemMap) => Transaction.fromMap(itemMap))
          .toList();

      // 2. Lấy tổng thu nhập
      final int income = results[1] as int;

      // 3. Lấy tổng chi tiêu
      final int expense = results[2] as int;

      setState(() {
        _allTransactions = loadedTransactions;
        _totalIncome = income;
        _totalExpense = expense;
        _totalBalance = income - expense; // Tính toán số dư
        _isLoading = false;

        print('Đã tải thành công: ${loadedTransactions.length} giao dịch.');
        print('Thu nhập T${currentMonth}: $income');
        print('Chi tiêu T${currentMonth}: $expense');
      });
    } catch (error) {
      print('Lỗi nghiêm trọng khi _fetchData: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- HÀM HELPER MỚI ĐỂ ĐỊNH DẠNG TIỀN TỆ ---
  // Dựa theo logic cũ của bạn (chia 100)
  String _formatCurrency(int amountInCents, {bool showSign = false}) {
    double amount = amountInCents / 100.0;
    // Dùng NumberFormat để định dạng tiền tệ chuẩn hơn (ví dụ: $15,000.00)
    final format = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    String formatted = format.format(amount);

    if (showSign) {
      if (amount > 0) {
        return '+${format.format(amount)}';
      } else if (amount < 0) {
        return format.format(amount); // NumberFormat tự xử lý dấu trừ
      }
      // Fallback cho số 0
      return format.format(amount);
    }

    // Nếu không show sign và số là âm (cho expense), bỏ dấu trừ
    if (amount < 0) {
      return format.format(amount * -1);
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // (Logic lọc danh sách giữ nguyên)
    final List<Transaction> filteredList;
    if (_selectedFilter == TransactionFilter.income) {
      filteredList = _allTransactions.where((tx) => tx.isIncome).toList();
    } else if (_selectedFilter == TransactionFilter.expense) {
      filteredList = _allTransactions.where((tx) => !tx.isIncome).toList();
    } else {
      filteredList = _allTransactions;
    }

    return SafeArea(
      child: Column(
        children: [
          // --- PHẦN 1: HEADER ---
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Header Text ===
                Center(
                  child: const Text(
                    "Transaction",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // === Balance Section ===
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hiển thị số dư đã tính toán
                      _BalanceItem(
                        title: "Total Balance",
                        amount: _formatCurrency(_totalBalance, showSign: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // === Income Box ===
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter =
                              _selectedFilter == TransactionFilter.income
                              ? TransactionFilter.all
                              : TransactionFilter.income;
                        });
                      },
                      child: Container(
                        // (style container giữ nguyên)
                        width: 171,
                        height: 101,
                        decoration: ShapeDecoration(
                          color: _selectedFilter == TransactionFilter.income
                              ? Color.fromARGB(255, 188, 248, 195)
                              : const Color(0xFFF1FFF3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.89),
                            side: _selectedFilter == TransactionFilter.income
                                ? BorderSide(color: Colors.green, width: 2)
                                : BorderSide.none,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(top: 10),
                          child: Show(
                            imageSrc: "assets/images/income.png",
                            title: "Income",
                            money: _formatCurrency(
                              _totalIncome,
                            ), // <-- Dữ liệu động
                            isExpense: false,
                          ),
                        ),
                      ),
                    ),

                    // === Expense Box ===
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter =
                              _selectedFilter == TransactionFilter.expense
                              ? TransactionFilter.all
                              : TransactionFilter.expense;
                        });
                      },
                      child: Container(
                        // (style container giữ nguyên)
                        width: 171,
                        height: 101,
                        decoration: ShapeDecoration(
                          color: _selectedFilter == TransactionFilter.expense
                              ? Color.fromARGB(255, 255, 201, 201)
                              : const Color(0xFFF1FFF3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.89),
                            side: _selectedFilter == TransactionFilter.expense
                                ? BorderSide(color: Colors.red, width: 2)
                                : BorderSide.none,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(top: 10),
                          child: Show(
                            imageSrc: "assets/images/expenses.png",
                            title: "Expense",
                            money: _formatCurrency(
                              _totalExpense,
                            ), // <-- Dữ liệu động
                            isExpense: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // === PHẦN 2: NỘI DUNG NỀN TRẮNG BO GÓC ===
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 24, // Trừ padding
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // --- Logic hiển thị (Loading / Rỗng / Có dữ liệu) ---
                          if (_isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (filteredList.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 64.0,
                                ),
                                child: Text(
                                  _allTransactions.isEmpty
                                      ? "Chưa có giao dịch nào."
                                      : "Không có giao dịch nào khớp.",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                // 1. Nhóm danh sách đã lọc theo tháng
                                ...groupBy(
                                  filteredList,
                                  (Transaction tx) => DateFormat(
                                    'yyyy-MM',
                                  ).format(tx.createdAt),
                                ).entries.map((entry) {
                                  // entry.key là "2025-11"
                                  // entry.value là List<Transaction> cho tháng đó

                                  // Lấy tháng (ví dụ: "Tháng 11 2025")
                                  final monthHeader = DateFormat(
                                    'MMMM yyyy',
                                  ).format(entry.value.first.createdAt);

                                  // Trả về một Column cho mỗi tháng
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 2. Tiêu đề tháng (giống "April")
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 24.0,
                                          bottom: 8.0,
                                        ),
                                        child: Text(
                                          monthHeader,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 3. Danh sách các giao dịch
                                      Column(
                                        children: entry.value.map((tx) {
                                          return _buildTransactionItem(tx);
                                        }).toList(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),

                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM HELPER ĐỂ ÁNH XẠ DATA (Giữ nguyên) ---
  Widget _buildTransactionItem(Transaction tx) {
    // 1. Logic cho Icon và Color
    IconData categoryIcon = Icons.attach_money;
    Color categoryColor = Color(0xFF6CB5FD);

    if (tx.category == 'groceries') {
      categoryIcon = Icons.shopping_bag_outlined;
      categoryColor = Color(0xFF3299FF);
    } else if (tx.category == 'rent') {
      categoryIcon = Icons.vpn_key_outlined;
      categoryColor = Color(0xFF0068FF);
    } else if (tx.category == 'salary') {
      categoryIcon = Icons.wallet_outlined;
      categoryColor = Color(0xFF6CB5FD);
    } else if (tx.category == "food") {
      categoryIcon = Icons.fastfood;
      categoryColor = Color(0xFF6CB5FD);
    } else if (tx.category == "transport") {
      categoryIcon = Icons.emoji_transportation;
    }

    // 2. Logic định dạng tiền tệ
    String formattedAmount = _formatCurrency(tx.amount); // Dùng helper mới
    if (!tx.isIncome) {
      formattedAmount = "-$formattedAmount"; // Thêm dấu trừ cho chi tiêu
    }

    // 3. Logic định dạng thời gian
    String formattedTime =
        "${tx.createdAt.hour}:${tx.createdAt.minute.toString().padLeft(2, '0')} - ${tx.createdAt.day} Thg${tx.createdAt.month}";

    // --- Trả về widget ---
    return TransactionItem(
      color: categoryColor,
      category: tx.category ?? 'Other',
      note: tx.note ?? '',
      time: formattedTime,
      amount: formattedAmount,
      isIncome: tx.isIncome,
      icon: categoryIcon,
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String title;
  final String amount;

  const _BalanceItem({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 357,
      height: 75,
      decoration: ShapeDecoration(
        color: const Color(0xFFF1FFF2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF093030),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
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
