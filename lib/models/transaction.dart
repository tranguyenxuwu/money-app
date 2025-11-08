// lib/models/transaction.dart
class Transaction {
  final int id;
  final int amount; // Số tiền (ví dụ: 50000)
  final String? note;
  final String? category;
  final String direction; // 'in' hoặc 'out'
  final DateTime createdAt;
  // Bạn có thể thêm các trường khác như status, updated_at nếu cần

  Transaction({
    required this.id,
    required this.amount,
    this.note,
    this.category,
    required this.direction,
    required this.createdAt,
  });

  // Getter tiện ích để dùng cho widget
  bool get isIncome {
    return direction == 'in';
  }

  // Hàm factory để chuyển đổi Map từ sqflite thành đối tượng Transaction
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      note: map['note'],
      category: map['category'],
      direction: map['direction'],
      // CSDL lưu là TEXT (ISO8601 string), parse thành DateTime
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}