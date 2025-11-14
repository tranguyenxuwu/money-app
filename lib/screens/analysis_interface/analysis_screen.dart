import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:money_app/screens/dbhelper.dart';
import 'package:money_app/widgets/format_currency.dart';
import 'package:money_app/screens/analysis_interface/search_screen.dart';


class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final Color incomeColor = const Color(0xFF00D09E);
  final Color expenseColor = const Color(0xFF0068FF);

  // --- (Biến State đã được cập nhật) ---
  bool _isLoading = true;
  int _totalBalance = 0;
  int _totalIncome = 0;
  int _totalExpense = 0;

  // --- SỬA Ở ĐÂY: Dùng DateTime để lưu năm ---
  DateTime _selectedDate = DateTime.now(); // Lưu ngày (và năm) đang chọn
  String _displayYearName = ""; // Tên năm
  // --- KẾT THÚC SỬA ---

  // --- THÊM STATE CHO BIỂU ĐỒ (DÙNG SỐ TIỀN ĐẦY ĐỦ) ---
  List<double> _monthlyIncome = List.filled(12, 0.0);
  List<double> _monthlyExpense = List.filled(12, 0.0);
  double _chartMaxY = 5000000.0; // Mặc định là 5 Triệu
  // --- KẾT THÚC THÊM STATE ---

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- HÀM TẢI DỮ LIỆU (ĐÃ SỬA) ---
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // --- SỬA Ở ĐÂY: Dùng _selectedDate thay vì now ---
      final String currentYear = DateFormat('yyyy').format(_selectedDate);
      final String displayYear = currentYear;
      // --- KẾT THÚC SỬA ---

      final results = await Future.wait([
        DBHelper.getTotalIncomeByYear(currentYear),
        DBHelper.getTotalSpentByYear(currentYear),
        DBHelper.getMonthlySummaries(currentYear),
      ]);

      // 1. Xử lý Tổng header
      final int income = results[0] as int;
      final int expense = results[1] as int;

      // 2. Xử lý Dữ liệu biểu đồ
      final List<Map<String, dynamic>> monthlyData =
      results[2] as List<Map<String, dynamic>>;

      List<double> tempIncome = List.filled(12, 0.0);
      List<double> tempExpense = List.filled(12, 0.0);
      double maxDataValue = 0.0; // Biến tìm giá trị lớn nhất

      for (var row in monthlyData) {
        int monthIndex = int.parse(row['month']) - 1;

        double incomeDouble = (row['totalIncome'] as int).toDouble();
        double expenseDouble = (row['totalExpense'] as int).toDouble();

        tempIncome[monthIndex] = incomeDouble;
        tempExpense[monthIndex] = expenseDouble;

        // Tìm giá trị lớn nhất mới
        if (incomeDouble > maxDataValue) maxDataValue = incomeDouble;
        if (expenseDouble > maxDataValue) maxDataValue = expenseDouble;
      }

      // 3. Tính toán maxY cho biểu đồ (làm tròn lên 5 Triệu gần nhất)
      double newMaxY = (maxDataValue / 5000000).ceil() * 5000000;
      if (newMaxY <= maxDataValue) {
        newMaxY += 5000000;
      }
      // Đảm bảo maxY tối thiểu là 5M
      if (newMaxY < 5000000) {
        newMaxY = 5000000;
      }

      // Debug logging
      print('Analysis Data Loaded:');
      print('Year: $displayYear');
      print('Total Income: $income, Total Expense: $expense');
      print('Max Data Value: $maxDataValue, Chart MaxY: $newMaxY');
      print('Monthly Income: $tempIncome');
      print('Monthly Expense: $tempExpense');

      setState(() {
        // Gán dữ liệu cho Header
        _totalIncome = income;
        _totalExpense = expense;
        _totalBalance = income - expense;
        _displayYearName = displayYear;

        // Gán dữ liệu cho Biểu đồ
        _monthlyIncome = tempIncome;
        _monthlyExpense = tempExpense;
        _chartMaxY = newMaxY;

        _isLoading = false;
      });
    } catch (error) {
      print('Lỗi khi tải dữ liệu Analysis: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- THÊM HÀM MỚI: HIỂN THỊ BỘ CHỌN NĂM ---
  Future<void> _presentYearPicker() async {
    // Hiển thị hộp thoại chọn năm
    final DateTime? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chọn năm"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2020), // Năm bắt đầu
              lastDate: DateTime(2100), // Năm kết thúc
              selectedDate: _selectedDate,
              onChanged: (DateTime dateTime) {
                // Khi người dùng chọn, đóng hộp thoại và trả về giá trị
                Navigator.of(context).pop(dateTime);
              },
            ),
          ),
        );
      },
    );

    // Nếu người dùng đã chọn một năm MỚI
    if (picked != null && picked.year != _selectedDate.year) {
      setState(() {
        _selectedDate = picked; // Cập nhật năm
      });
      _fetchData(); // Tải lại dữ liệu cho năm mới
    }
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const SearchTransactionScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // ... (Hàm build và Header giữ nguyên)
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return SafeArea(
      bottom: false,
      child:
      // PHẦN NỀN: Toàn bộ nội dung cuộn được
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === PHẦN 1: HEADER (GIỐNG HOME) ===
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
                    "Analysis",
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
                          padding: const EdgeInsets.only(top: 10),
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
                          padding: const EdgeInsets.only(top: 10),
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
                    // Phần Chart giữ nguyên
                    _buildChartCard(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM _buildChartCard (ĐÃ SỬA NÚT LỊCH) ---
  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F3E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Income & Expenses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(onPressed: _navigateToSearch, icon: const Icon(Icons.search)),
                  // --- SỬA Ở ĐÂY ---
                  IconButton(
                    onPressed: _presentYearPicker, // <-- Gọi hàm chọn năm
                    icon: const Icon(Icons.calendar_today),
                  ),
                  // --- KẾT THÚC SỬA ---
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Bọc bằng SingleChildScrollView để cuộn ngang
          _isLoading
              ? const SizedBox(
                  height: 250.0,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    // 2. Cung cấp chiều cao và chiều rộng CỐ ĐỊNH
                    height: 250.0,
                    width: 600.0,
                    child: BarChart(mainBarChart()),
                  ),
                ),
        ],
      ),
    );
  }
  // --- KẾT THÚC HÀM ---


  // --- (Hàm mainBarChart, getTitles, showingGroups, makeGroupData giữ nguyên) ---
  BarChartData mainBarChart() {
    return BarChartData(
      // SỬA: Dùng maxY động (ví dụ: 20000000.0)
      maxY: _chartMaxY,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          getTooltipColor: (group) => Colors.grey,
          tooltipMargin: 10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String monthName;
            switch (group.x) {
              case 0: monthName = 'January'; break;
              case 1: monthName = 'February'; break;
              case 2: monthName = 'March'; break;
              case 3: monthName = 'April'; break;
              case 4: monthName = 'May'; break;
              case 5: monthName = 'June'; break;
              case 6: monthName = 'July'; break;
              case 7: monthName = 'August'; break;
              case 8: monthName = 'September'; break;
              case 9: monthName = 'October'; break;
              case 10: monthName = 'November'; break;
              case 11: monthName = 'December'; break;
              default:
                throw Error();
            }

            // SỬA: Định dạng VNĐ đầy đủ cho tooltip
            final format = NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
              decimalDigits: 0,
            );

            return BarTooltipItem(
              '$monthName\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: format.format(rod.toY), // Hiển thị VNĐ đầy đủ
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            // SỬA: Dùng interval động (ví dụ: 5000000)
            interval: (_chartMaxY / 4).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              // Ẩn nhãn 0 và nhãn trên cùng (maxY)
              if (value == 0 || value >= _chartMaxY) return const Text('');

              // SỬA: Hiển thị "M" (Triệu) hoặc "k" (Nghìn)
              String label;
              if (value >= 1000000) {
                label = '${(value / 1000000).toStringAsFixed(0)}M';
              } else {
                label = '${(value / 1000).toStringAsFixed(0)}k';
              }
              return Text(label, style: const TextStyle(fontSize: 10));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: showingGroups(), // <-- Sẽ gọi hàm showingGroups
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final text = (value.toInt() >= 0 && value.toInt() < months.length)
        ? months[value.toInt()]
        : '';
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: Text(text, style: style),
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(12, (i) {
    // Lấy dữ liệu từ state (đã được tính bằng số tiền đầy đủ)
    final double income = _monthlyIncome[i];
    final double expense = _monthlyExpense[i];
    return makeGroupData(i, income, expense);
  });

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    const double width = 8;
    return BarChartGroupData(
      x: x,
      barsSpace: 4,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: incomeColor,
          width: width,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: y2,
          color: expenseColor,
          width: width,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

// --- (Class _BalanceItem giữ nguyên) ---
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

// (Class Show giữ nguyên)
class Show extends StatelessWidget {
  const Show({
    super.key,
    required this.imageSrc,
    required this.title,
    required this.money,
    required this.isExpense,
  });

  final String imageSrc;
  final String title;
  final String money;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imageSrc.replaceFirst("./", "")), // Đã sửa lỗi đường dẫn
        Text(title),
        Text(
          money,
          style: TextStyle(
            color: isExpense ? Color.fromRGBO(0, 104, 255, 100) : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}