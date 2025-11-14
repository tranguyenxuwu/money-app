import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:money_app/screens/dbhelper.dart';
import 'package:money_app/widgets/format_currency.dart';
import 'package:money_app/screens/analysis_interface/analysis_screen.dart';
import 'package:money_app/screens/category_interface/category_detail_screen.dart';

// --- 1. TẠO MODEL CHO CATEGORY ---
class Category {
  final String name;
  final IconData icon;

  const Category({required this.name, required this.icon});
}

// --- 2. TẠO DANH SÁCH CATEGORY  ---
final List<Category> categories = [
  Category(name: 'Food', icon: Icons.fastfood_outlined),
  Category(name: 'Transport', icon: Icons.directions_bus_outlined),
  Category(name: 'Medicine', icon: Icons.medication_outlined),
  Category(name: 'Groceries', icon: Icons.shopping_bag_outlined),
  Category(name: 'Rent', icon: Icons.vpn_key_outlined),
  Category(name: 'Gifts', icon: Icons.card_giftcard_outlined),
  Category(name: 'Salary', icon: Icons.wallet_outlined),
  Category(name: 'Entertainment', icon: Icons.sports_esports),
  Category(name: 'Other', icon: Icons.more_horiz),
];
// --- KẾT THÚC ---

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // --- (Biến State và các hàm helper giữ nguyên) ---
  bool _isLoading = true;
  int _totalBalance = 0;
  int _totalIncome = 0;
  int _totalExpense = 0;
  String _displayYearName = ""; // Tên năm

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- (Hàm tải dữ liệu giữ nguyên) ---
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final String currentYear = DateFormat('yyyy').format(now);
      final String displayYear = currentYear;

      final results = await Future.wait([
        DBHelper.getTotalIncomeByYear(currentYear),
        DBHelper.getTotalSpentByYear(currentYear),
      ]);

      final int income = results[0] as int;
      final int expense = results[1] as int;

      setState(() {
        // Gán dữ liệu cho Header
        _totalIncome = income;
        _totalExpense = expense;
        _totalBalance = income - expense;
        _displayYearName = displayYear;
        _isLoading = false;
      });
    } catch (error) {
      print('Lỗi khi tải dữ liệu CategoryScreen: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCategoryTapped(Category category) {
    // Xử lý nút "More"
    if (category.name == 'More') {
      // TODO: Hiển thị hộp thoại hoặc màn hình thêm/sửa category
      print("Nhấn vào More");
      return; // Dừng lại
    }

    // Điều hướng đến màn hình chi tiết
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CategoryDetailScreen(
          // Truyền tên category bằng chữ thường (để khớp CSDL)
          categoryName: category.name.toLowerCase(),
        ),
      ),
    );
  }

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
          // === PHẦN 1: HEADER (GIỐNG ANALYSIS) ===
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
                    "Categories",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _BalanceItem(
                          title: "Total Balance ($_displayYearName)",
                          amount:
                          formatCurrency(_totalBalance, showSign: true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(width: 16), // Khoảng cách
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
              ],
            ),
          ),

          // === PHẦN 2: NỘI DUNG CATEGORIES (ĐÃ SỬA) ===
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF1FFF3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              // --- SỬA: DÙNG GridView ---
              child: GridView.builder(
                padding: const EdgeInsets.all(24.0),
                // Cấu hình lưới 3 cột
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 cột
                  crossAxisSpacing: 20, // Khoảng cách ngang
                  mainAxisSpacing: 20, // Khoảng cách dọc
                ),
                itemCount: categories.length, // Số lượng item
                itemBuilder: (context, index) {
                  final category = categories[index];
                  // Trả về widget cho mỗi ô
                  return _CategoryItem(
                    icon: category.icon,
                    label: category.name,
                    onTap: () => _onCategoryTapped(category),
                  );
                },
              ),
              // --- KẾT THÚC SỬA ---
            ),
          ),
        ],
      ),
    );
  }
}

// --- (Helper class _BalanceItem giữ nguyên) ---
class _BalanceItem extends StatelessWidget {
  final String title;
  final String amount;

  const _BalanceItem({
    required this.title,
    required this.amount,
  });

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
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


// --- 3. THÊM WIDGET MỚI CHO Ô CATEGORY ---
class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF59B8DA).withOpacity(0.6), // Màu xanh nhạt
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}