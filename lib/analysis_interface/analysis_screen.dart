import 'dart:ffi';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_app/home_interface/home_screen.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  final Color incomeColor = const Color(0xFF00D09E);
  final Color expenseColor = const Color(0xFF0068FF);

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
                        _buildChartCard(),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Show(
                              imageSrc: "./assets/images/income.png",
                              title: "Income",
                              money: "\$4,120.00",
                              isExpense: false,
                            ),
                            Show(
                              imageSrc: "./assets/images/expenses.png",
                              title: "Expenses",
                              money: "\$100.000",
                              isExpense: true,
                            ),
                          ],
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
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: BarChart(mainBarChart())),
        ],
      ),
    );
  }

  BarChartData mainBarChart() {
    return BarChartData(
      maxY: 16,
      barTouchData: BarTouchData(
        // SỬA LỖI Ở ĐÂY: Thay thế `getTooltipItem` bằng `tooltipBuilder`
        touchTooltipData: BarTouchTooltipData(
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          getTooltipColor: (group) => Colors.grey,
          tooltipMargin: 10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x) {
              case 0:
                weekDay = 'Monday';
                break;
              case 1:
                weekDay = 'Tuesday';
                break;
              case 2:
                weekDay = 'Wednesday';
                break;
              case 3:
                weekDay = 'Thursday';
                break;
              case 4:
                weekDay = 'Friday';
                break;
              case 5:
                weekDay = 'Saturday';
                break;
              case 6:
                weekDay = 'Sunday';
                break;
              default:
                throw Error();
            }
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toString(),
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
            reservedSize: 38,
            interval: 5,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const Text('');
              return Text(
                '${value.toInt()}k',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: showingGroups(),
    );
  }

  // Widget cho tiêu đề trục X (các ngày trong tuần)
  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: Text(days[value.toInt()], style: style),
    );
  }

  // Hàm tạo dữ liệu cho các cột (với 2 thanh mỗi cột)
  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
    // Dữ liệu mẫu
    final double income = [8.0, 10.0, 14.0, 7.0, 15.0, 12.0, 9.0][i];
    final double expense = [7.0, 8.0, 5.0, 6.0, 11.0, 9.0, 7.0][i];
    return makeGroupData(i, income, expense);
  });

  // Hàm helper để tạo một nhóm dữ liệu cột (với 2 thanh)
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
        Image.asset(imageSrc),
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
