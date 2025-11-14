import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app/models/transaction.dart'; // <-- THÊM
import 'package:money_app/screens/dbhelper.dart'; // <-- THÊM
import 'package:money_app/widgets/format_currency.dart'; // <-- THÊM
import 'package:money_app/widgets/transaction_item.dart'; // <-- THÊM
import 'package:money_app/screens/transaction_interface/transaction_detail_screen.dart'; // <-- THÊM

class SearchTransactionScreen extends StatefulWidget {
  const SearchTransactionScreen({super.key});

  @override
  State<SearchTransactionScreen> createState() =>
      _SearchTransactionScreenState();
}

class _SearchTransactionScreenState extends State<SearchTransactionScreen> {
  // Biến trạng thái cho form
  DateTime? _selectedDate;
  String? _selectedCategory;
  // 'all', 'in', 'out'
  String _transactionType = 'all';

  // --- THÊM STATE CHO KẾT QUẢ ---
  bool _isLoading = false;
  List<Transaction> _searchResults = [];
  bool _hasSearched = false; // Biến để biết đã tìm kiếm lần nào chưa
  // --- KẾT THÚC THÊM STATE ---

  // Danh sách category (lấy từ các file khác của bạn)
  final List<String> _categories = [
    'food',
    'transport',
    'entertainment',
    'bills',
    'salary',
    'other',
    'groceries',
    'rent',
  ];

  // --- Hàm hiển thị Date Picker ---
  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // --- SỬA HÀM NÀY: Hàm xử lý khi nhấn "Search" ---
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true; // Đánh dấu đã tìm kiếm
      _searchResults = []; // Xóa kết quả cũ
    });

    try {
      // Gọi DBHelper với các giá trị, (null nếu là "all")
      final List<Map<String, dynamic>> dataMap =
      await DBHelper.searchTransactions(
        direction: _transactionType == 'all' ? null : _transactionType,
        category: _selectedCategory,
        date: _selectedDate,
      );

      // Chuyển Map thành List<Transaction>
      final List<Transaction> results =
      dataMap.map((itemMap) => Transaction.fromMap(itemMap)).toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tìm kiếm: $e");
      setState(() {
        _isLoading = false;
      });
      // Hiển thị lỗi
    }
  }
  // --- KẾT THÚC SỬA ---

  // --- THÊM CÁC HÀM HELPER (COPY TỪ TRANSACTION_SCREEN) ---
  void _viewTransactionDetails(Transaction tx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => TransactionDetailScreen(transaction: tx),
      ),
    ).then((_) {
      // Tải lại tìm kiếm khi quay lại (tùy chọn)
      _performSearch();
    });
  }

  Widget _buildTransactionItem(Transaction tx) {
    IconData categoryIcon = Icons.attach_money;
    Color categoryColor = Color(0xFF6CB5FD);

    // (Bạn có thể copy/paste logic icon từ TransactionScreen nếu muốn)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search transaction'),
        backgroundColor: const Color(0xFF00D09E), // Màu xanh
      ),
      // --- SỬA: BỌC BẰNG SingleChildScrollView ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Income/Expense/All ---
                const Text(
                  'Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'in', label: Text('Income')),
                    ButtonSegment(value: 'out', label: Text('Expense')),
                  ],
                  selected: {_transactionType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _transactionType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // --- 2. Category ---
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Tất cả danh mục'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All category'),
                    ),
                    ..._categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList()
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // --- 3. Date ---
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: TextEditingController(
                    text: _selectedDate == null
                        ? 'Select one day'
                        : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                  ),
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: _presentDatePicker,
                    ),
                    // Thêm nút xóa ngày
                    prefixIcon: _selectedDate != null ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                        });
                      },
                    ) : null,
                  ),
                ),
                const SizedBox(height: 40),

                // --- 4. Nút Search ---
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _performSearch, // Vô hiệu hóa khi đang tải
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D09E),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                // --- 5. HIỂN THỊ KẾT QUẢ ---
                const SizedBox(height: 24),
                Divider(),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_hasSearched && _searchResults.isEmpty)
                // Nếu đã tìm nhưng không có kết quả
                  const Center(
                    child: Text(
                      'Không tìm thấy giao dịch nào.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                else
                // Hiển thị danh sách kết quả
                  ListView.builder(
                    shrinkWrap: true, // Quan trọng khi lồng trong SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của ListView
                    itemCount: _searchResults.length,
                    itemBuilder: (ctx, index) {
                      return _buildTransactionItem(_searchResults[index]);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}