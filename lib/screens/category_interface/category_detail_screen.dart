import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:money_app/models/transaction.dart';
import 'package:money_app/screens/dbhelper.dart';
import 'package:money_app/screens/transaction_interface/transaction_detail_screen.dart';
import 'package:money_app/widgets/format_currency.dart';
import 'package:money_app/widgets/transaction_item.dart';
// --- THÊM IMPORT CHO ADD SCREEN ---
import 'package:money_app/screens/transaction_interface/add_transaction_screen.dart';


class CategoryDetailScreen extends StatefulWidget {
  final String categoryName; // Ví dụ: "food", "transport"

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  bool _isLoading = true;
  List<Transaction> _transactions = [];

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
      final String currentYear = DateFormat('yyyy').format(DateTime.now());
      final dataMap = await DBHelper.getTransactionsByCategory(
        widget.categoryName,
        currentYear,
      );

      final List<Transaction> loadedTransactions =
      dataMap.map((itemMap) => Transaction.fromMap(itemMap)).toList();

      setState(() {
        _transactions = loadedTransactions;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tải chi tiết category: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- THÊM HÀM MỚI ---
  // Hàm này sẽ mở màn hình Add, tự động điền category
  void _addTransactionForCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(
          // Truyền category hiện tại sang
          defaultCategory: widget.categoryName,
        ),
      ),
    ).then((_) {
      // Tải lại dữ liệu khi quay về
      _fetchData();
    });
  }
  // --- KẾT THÚC THÊM HÀM ---

  // --- (Các hàm helper _viewTransactionDetails và _buildTransactionItem giữ nguyên) ---
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
      categoryColor = Color(0xFF6CB5FD);
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
    // (Thêm các category khác nếu cần)

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
  // --- Kết thúc hàm Helper ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Viết hoa chữ cái đầu
          widget.categoryName[0].toUpperCase() + widget.categoryName.substring(1),
        ),
        backgroundColor: const Color(0xFF00D09E),
      ),
      backgroundColor: const Color(0xFFF1FFF3),

      // --- THÊM NÚT FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransactionForCategory, // Gọi hàm mới
        backgroundColor: const Color(0xFF00D09E),
        child: const Icon(Icons.add),
      ),
      // --- KẾT THÚC THÊM NÚT ---

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? const Center(
        child: Text(
          'Không có giao dịch nào cho mục này.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- (Logic nhóm theo tháng giữ nguyên) ---
          ...groupBy(
            _transactions,
                (Transaction tx) =>
                DateFormat('yyyy-MM').format(tx.createdAt),
          ).entries.map((entry) {
            final monthHeader = DateFormat('MMMM yyyy')
                .format(entry.value.first.createdAt);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.only(top: 24.0, bottom: 8.0),
                  child: Text(
                    monthHeader,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
                // Danh sách giao dịch của tháng đó
                Column(
                  children: entry.value.map((tx) {
                    return _buildTransactionItem(tx);
                  }).toList(),
                ),
              ],
            );
          }).toList(),
          // --- Kết thúc Logic nhóm theo tháng ---
        ],
      ),
    );
  }
}