import 'package:intl/intl.dart';

String formatCurrency(int amount, {bool showSign = false}) {
  // 1. Chuyển sang double (KHÔNG CHIA 100)
  double amountDouble = amount.toDouble();

  // 2. Dùng locale 'vi_VN' và ký hiệu '₫'
  final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  String formatted = format.format(amountDouble);

  if (showSign) {
    if (amount > 0) {
      return '+${format.format(amountDouble)}';
    } else if (amount < 0) {
      return format.format(amountDouble); // Tự xử lý dấu trừ
    }
    return format.format(amountDouble);
  }

  // Nếu không show sign và số là âm (cho expense), bỏ dấu trừ
  if (amount < 0) {
    return format.format(amountDouble * -1);
  }
  return formatted;
}