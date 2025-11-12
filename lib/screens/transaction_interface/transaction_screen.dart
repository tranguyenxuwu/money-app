import 'package:flutter/material.dart';

import 'package:money_app/screens/dbhelper.dart'; // <-- Đường dẫn tới file DBHelper
import 'package:money_app/models/transaction.dart'; // <-- Import model
import '../analysis_interface/analysis_screen.dart'; // Giữ import cho Show
import 'package:money_app/widgets/transaction_item.dart';

enum TransactionFilter { all, income, expense }

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  TransactionFilter _selectedFilter = TransactionFilter.all;

  // Danh sách này sẽ chứa dữ liệu từ CSDL
  List<Transaction> _allTransactions = []; // <-- Dùng model Transaction
  bool _isLoading = true; // Biến trạng thái loading

  @override
  void initState() {
    super.initState();
    _fetchTransactions(); // Gọi hàm để tải dữ liệu từ CSDL
  }

  // Hàm gọi CSDL dùng DBHelper
  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });

    try {
      // 1. Gọi hàm getAllTransactions từ DBHelper
      final List<Map<String, dynamic>> dataMap =
      await DBHelper.getAllTransactions();

      // 2. Chuyển List<Map> thành List<Transaction> (ĐÚNG)
      final List<Transaction> loadedTransactions = dataMap.map((itemMap) {
        // Chỉ tạo đối tượng dữ liệu Transaction, KHÔNG build widget
        return Transaction.fromMap(itemMap);
      }).toList();

      setState(() {
        // Gán List<Transaction> cho List<Transaction> (ĐÚNG)
        _allTransactions = loadedTransactions;
        _isLoading = false; // Tải xong
        print('Đã tải thành công: ${loadedTransactions.length} giao dịch.');
      });
    } catch (error) {
      // --- ĐÃ SỬA LỖI Ở ĐÂY ---
      print('Lỗi nghiêm trọng khi fetchTransactions: $error');
      setState(() {
        _isLoading = false; // <-- Rất quan trọng: Tắt loading dù có lỗi
      });
      // --- KẾT THÚC SỬA ---
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Logic lọc giờ sẽ dùng _allTransactions (List<Transaction>)
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
                    children: const [
                      _BalanceItem(
                        title: "Total Balance",
                        amount: "\$7,783.00",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                            money: "\$4,120.00",
                            isExpense: false,
                          ),
                        ),
                      ),
                    ),
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
                            // --- ĐÃ SỬA LỖI ĐƯỜNG DẪN ---
                            imageSrc: "assets/images/expenses.png", // <-- Đã xóa "./"
                            title: "Expense",
                            money: "\$4,120.00",
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
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F9), // Màu nền trắng xám
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator()) // Hiển thị loading
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Dùng .map để biến List<Transaction> thành List<TransactionItem>
                    Column(
                      // Dùng danh sách đã lọc (filteredList)
                      children: filteredList.map((tx) {
                        // Đây là nơi bạn ánh xạ dữ liệu
                        return _buildTransactionItem(tx);
                      }).toList(),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM HELPER ĐỂ ÁNH XẠ DATA ---
  Widget _buildTransactionItem(Transaction tx) {
    // 1. Logic cho Icon và Color
    IconData categoryIcon = Icons.attach_money; // Mặc định
    Color categoryColor = Color(0xFF6CB5FD); // Mặc định

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
    // (Thêm các category khác của bạn ở đây)

    // 2. Logic định dạng tiền tệ (ví dụ)
    // (Bạn nên dùng package 'intl' để làm việc này tốt hơn)
    String formattedAmount = "\$${(tx.amount / 100).toStringAsFixed(2)}"; // Giả sử amount là cent (5000)

    // Nếu là expense (isIncome = false), thêm dấu trừ
    if (!tx.isIncome) {
      formattedAmount = "${formattedAmount}";
    }

    // 3. Logic định dạng thời gian (ví dụ)
    String formattedTime = "${tx.createdAt.hour}:${tx.createdAt.minute.toString().padLeft(2, '0')} - ${tx.createdAt.day} Thg${tx.createdAt.month}";


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

// (Class _BalanceItem giữ nguyên)
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