import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final Color color;
  final String category;
  final String note;
  final String time;
  final String amount;
  final bool isIncome;
  final IconData icon;

  const TransactionItem({
    super.key,
    required this.color,
    required this.category,
    required this.note,
    required this.time,
    required this.amount,
    required this.isIncome,
    this.icon = Icons.attach_money,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsetsGeometry.only(right: 20),
                  child: Text(
                    note,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Tối đa 1 dòng
                  ),
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? const Color(0xFF00D09E) : Colors.redAccent,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
