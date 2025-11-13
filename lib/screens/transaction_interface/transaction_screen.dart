import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:money_app/screens/dbhelper.dart'; // <-- Đường dẫn tới file DBHelper
import 'package:money_app/models/transaction.dart'; // <-- Import model
import '../analysis_interface/analysis_screen.dart'; // <-- Import cho Show
import 'package:money_app/widgets/transaction_item.dart';
import 'package:money_app/screens/transaction_interface/add_transaction_screen.dart';
import 'package:money_app/screens/transaction_interface/transaction_detail_screen.dart';

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
  DateTime _currentDisplayDate = DateTime.now(); // "Tháng đang xem"
  String _displayMonthName = ""; // Tên tháng để hiển thị
  // --- KẾT THÚC BIẾN STATE ---

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- HÀM TẢI DỮ LIỆU (ĐÃ SỬA) ---
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // --- SỬA LOGIC LẤY THÁNG ---
      // Lấy thông tin từ "tháng đang xem"
      final String currentMonth = DateFormat('yyyy-MM').format(_currentDisplayDate);
      final String displayMonth = DateFormat('MMMM yyyy').format(_currentDisplayDate);

      // Chạy 3 câu query CSDL song song
      final results = await Future.wait([
        DBHelper.getTransactionsByMonth(currentMonth),
        DBHelper.getTotalIncome(currentMonth),
        DBHelper.getTotalSpent(currentMonth),
      ]);

      // 1. Lấy danh sách giao dịch
      final List<Map<String, dynamic>> dataMap =
      results[0] as List<Map<String, dynamic>>;
      final List<Transaction> loadedTransactions =
      dataMap.map((itemMap) => Transaction.fromMap(itemMap)).toList();

      // 2. Lấy tổng thu nhập
      final int income = results[1] as int;

      // 3. Lấy tổng chi tiêu
      final int expense = results[2] as int;

      setState(() {
        _allTransactions = loadedTransactions;
        _totalIncome = income;
        _totalExpense = expense;
        _totalBalance = income - expense;
        _displayMonthName = displayMonth; // <-- Gán tên tháng
        _isLoading = false;

        print(
            'Đã tải thành công: ${loadedTransactions.length} giao dịch cho tháng $currentMonth.');
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

  // --- THÊM HÀM MỚI: ĐỔI THÁNG ---
  void _changeMonth(int amount) {
    setState(() {
      _currentDisplayDate = DateTime(
        _currentDisplayDate.year,
        _currentDisplayDate.month + amount,
        1, // Set về ngày 1 để tránh lỗi 31/30
      );
    });
    _fetchData(); // Tải lại dữ liệu cho tháng mới
  }

  // --- (Hàm _formatCurrency giữ nguyên) ---
  String _formatCurrency(int amountInCents, {bool showSign = false}) {
    double amount = amountInCents / 100.0;
    final format = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    String formatted = format.format(amount);

    if (showSign) {
      if (amount > 0) {
        return '+${format.format(amount)}';
      } else if (amount < 0) {
        return format.format(amount);
      }
      return format.format(amount);
    }
    if (amount < 0) {
      return format.format(amount * -1);
    }
    return formatted;
  }

  // --- (Hàm _addTransaction giữ nguyên) ---
  void _addTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => AddTransactionScreen()),
    ).then((_) {
      print('Đang làm mới dữ liệu sau khi thêm...');
      _fetchData();
    });
  }

  // --- THÊM LẠI HÀM ĐÃ MẤT ---
  void _viewTransactionDetails(Transaction tx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => TransactionDetailScreen(transaction: tx),
      ),
    ).then((_) {
      // Tự động làm mới danh sách khi quay lại
      print('Đang làm mới dữ liệu sau khi xem chi tiết...');
      _fetchData();
    });
  }
  // --- KẾT THÚC THÊM HÀM ---

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

    return Scaffold(
      backgroundColor: Color(0xFF00D09E),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        backgroundColor: Color(0xFF00D09E),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
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

                  // --- BỘ CHỌN THÁNG ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: Colors.black54, size: 20),
                        onPressed: () => _changeMonth(-1), // <-- Nút lùi
                      ),
                      Text(
                        _displayMonthName, // <-- Hiển thị tên tháng
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios,
                            color: Colors.black54, size: 20),
                        onPressed: () => _changeMonth(1), // <-- Nút tiến
                      ),
                    ],
                  ),
                  // --- KẾT THÚC BỘ CHỌN THÁNG ---

                  const SizedBox(height: 16), // Thêm khoảng cách

                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _BalanceItem(
                            // Bỏ tên tháng ở đây, vì đã có ở trên
                            title: "Total Balance",
                            amount:
                            _formatCurrency(_totalBalance, showSign: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- ĐIỀN LẠI GESTUREDETECTOR (INCOME) ---
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
                              ),
                              isExpense: false,
                            ),
                          ),
                        ),
                      ),
                      // --- ĐIỀN LẠI GESTUREDETECTOR (EXPENSE) ---
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
                              ),
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
                          minHeight: constraints.maxHeight - 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            if (_isLoading)
                              Center(child: CircularProgressIndicator())
                            else if (filteredList.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 64.0,
                                  ),
                                  child: Text(
                                    // Sửa thông báo rỗng
                                    "Không có giao dịch nào cho tháng này.",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            else
                            // --- SỬA LOGIC HIỂN THỊ LIST ---
                            // Bỏ groupBy vì ta chỉ hiển thị 1 tháng
                              Column(
                                children: filteredList.map((tx) {
                                  return _buildTransactionItem(tx);
                                }).toList(),
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
      ),
    );
  }

  // --- HÀM HELPER ĐỂ ÁNH XẠ DATA (ĐÃ THÊM LẠI GESTUREDETECTOR) ---
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
    } else if (tx.category == "other") {
      categoryIcon = Icons.more_horiz;
    } else if (tx.category == "bills") {
      categoryIcon = Icons.receipt;
    } else if (tx.category == "entertainment") {
      categoryIcon = Icons.sports_esports;
    }

    // 2. Logic định dạng tiền tệ
    String formattedAmount = _formatCurrency(tx.amount); // Dùng helper mới
    if (!tx.isIncome) {
      formattedAmount = "-$formattedAmount"; // Thêm dấu trừ cho chi tiêu
    }

    // 3. Logic định dạng thời gian
    String formattedTime =
        "${tx.createdAt.hour}:${tx.createdAt.minute.toString().padLeft(2, '0')} - ${tx.createdAt.day} Thg${tx.createdAt.month}";

    // --- Trả về widget (Đã bọc lại) ---
    return GestureDetector(
      onTap: () => _viewTransactionDetails(tx), // <-- Gọi hàm điều hướng
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
}

// --- CLASS _BalanceItem (ĐÃ SỬA LẠI) ---
class _BalanceItem extends StatelessWidget {
  final String title;
  final String amount;

  const _BalanceItem({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 357, // <-- XÓA WIDTH CỨNG
      height: 75,
      decoration: ShapeDecoration(
        color: const Color(0xFFF1FFF2),
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
                title, // <-- Giờ đây nó sẽ nhận "Total Balance (November 2025)"
                style: TextStyle(
                  color: const Color(0xFF093030),
                  fontSize: 15, // Cỡ chữ gốc
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