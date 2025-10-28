import 'package:flutter/material.dart';
import '../dbhelper.dart'; // Added import for DBHelper

/// Tạo danh sách tin nhắn mẫu ban đầu từ DB, chèn nếu chưa có
Future<List<Map<String, dynamic>>> getInitialMessages() async {
  final dbMessages = await DBHelper.getRecentMessages(
    limit: 200,
  ); // increase to retrieve more messages
  if (dbMessages.isEmpty) {
    return [];
  }
  return dbMessages.map((msg) {
    final isMe = msg['direction'] == 'in';
    final category = msg['category'] as String?;
    final amount = msg['amount'] as int?;
    final createdAt = msg['created_at'] as String?;
    final status = msg['status'] as String?;
    return {
      'isMe': isMe,
      'text': msg['text'],
      'id': msg['id'],
      'direction':
          msg['direction'], // preserve DB direction so UI can show arrows
      'created_at': createdAt,
      'status': status,
      // don't mark DB-loaded messages as 'isPreloaded' — they are real persisted messages
      if (!isMe) ...{
        'action': category ?? 'khác',
        'info': amount != null ? '$amount VND' : (msg['text'] as String? ?? ''),
        'result': status == 'linked' ? 'Đã liên kết' : 'Thành công.',
      },
    };
  }).toList();
}

/// Phân tích số tiền và lý do từ chuỗi đầu vào, hỗ trợ đơn vị 'k' cho nghìn
Map<String, dynamic>? parseAmount(String input) {
  final match = RegExp(
    r'(.*?)(\d+)(k?)',
    caseSensitive: false,
  ).firstMatch(input.trim());
  if (match != null) {
    String reason = match.group(1)?.trim() ?? '';
    int num = int.parse(match.group(2)!);
    if (match.group(3) == 'k') {
      num *= 1000;
    }
    return {'reason': reason, 'amount': num};
  }
  return null;
}

/// Từ điển từ khoá để đoán danh mục
const Map<String, List<String>> _categoryKeywords = {
  'ăn uống': [
    'ăn',
    'uống',
    'cơm',
    'phở',
    'bún',
    'cà phê',
    'trà sữa',
    'nhậu',
    'bánh',
    'kẹo',
    'an',
    'uong',
    'com',
    'pho',
    'bun',
    'ca phe',
    'tra sua',
    'nhau',
    'banh',
    'keo',
  ],
  'di chuyển': [
    'xe',
    'xăng',
    'bus',
    'grab',
    'taxi',
    'gửi xe',
    'vé',
    'đi lại',
    'xang',
    'gui xe',
    'di lai',
  ],
  'hoá đơn': [
    'điện',
    'nước',
    'internet',
    'net',
    'truyền hình',
    'cáp',
    'gas',
    'điện thoại',
    'dien',
    'nuoc',
    'truyen hinh',
    'dien thoai',
    'mạng',
    'mang',
  ],
  'sức khoẻ': [
    'khám',
    'thuốc',
    'bệnh viện',
    'nha khoa',
    'y tế',
    'kham',
    'benh vien',
  ],
  'mua sắm': [
    'mua',
    'sắm',
    'quần áo',
    'giày',
    'đồ',
    'tạp hoá',
    'thời trang',
    'quan ao',
    'giay',
    'tap hoa',
    'thoi trang',
  ],
  'giải trí': [
    'xem phim',
    'chơi game',
    'game',
    'du lịch',
    'vé xem phim',
    'concert',
    'choi game',
    'du lich',
    've xem phim',
  ],
  'vay mượn': ['vay', 'mượn', 'trả nợ', 'đòi nợ', 'tra no', 'doi no', 'muon'],
  'đăng ký': ['spotify', 'netflix', 'youtube premium', 'vieon', 'fpt play'],
};

/// Đoán danh mục từ nội dung tin nhắn
String guessCategory(String text) {
  final lowerText = text.toLowerCase();
  for (final entry in _categoryKeywords.entries) {
    final category = entry.key;
    final keywords = entry.value;
    if (keywords.any((keyword) => lowerText.contains(keyword))) {
      return category;
    }
  }
  return 'khác'; // Danh mục mặc định
}

/// Đoán hướng giao dịch (in/out) dựa trên danh mục
String guessDirection(String category) {
  const incomeCategories = [
    'vay mượn',
  ]; // Categories typically associated with "in"
  return incomeCategories.contains(category) ? 'in' : 'out';
}

/// Gửi tin nhắn và xử lý phản hồi, lưu vào DB
Future<void> sendMessage(
  List<Map<String, dynamic>> messages,
  String text,
  void Function(VoidCallback) setState,
  bool mounted, {
  VoidCallback?
  onMessageAdded, // optional callback the UI can use to scroll / react after messages are added
}) async {
  if (text.isEmpty) return;

  // Insert user message into DB
  final msgId = await DBHelper.insertMessage(text: text, direction: 'in');

  setState(() {
    // Thêm tin nhắn của user (also keep direction & created_at to mirror DB row)
    messages.add({
      'isMe': true,
      'text': text,
      'id': msgId,
      'direction': 'in',
      'created_at': DateTime.now().toIso8601String(),
    });
  });

  if (onMessageAdded != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onMessageAdded());
  }

  // Giả lập delay xử lý và trả về card action
  Future.delayed(const Duration(milliseconds: 500), () async {
    if (!mounted) return;
    final parsed = parseAmount(text);
    if (parsed != null) {
      final reason = parsed['reason'] as String;
      final amount = parsed['amount'] as int;
      final displayReason = reason.isNotEmpty ? reason : 'Chi tiêu';
      final guessedCategory = guessCategory(text);
      final guessedDirection = guessDirection(
        guessedCategory,
      ); // Guess direction

      // Insert transaction into DB
      final txnId = await DBHelper.insertTransaction(
        amount: amount,
        note: displayReason,
        category: guessedCategory,
        direction: guessedDirection, // Save guessed direction
      );
      // Insert bot response message (persisted)
      final botMsgId = await DBHelper.insertMessage(
        text: '$displayReason: $amount VND',
        direction: 'out', // Set direction for the message
        amount: amount,
        category: guessedCategory,
        txnId: txnId,
      );
      if (mounted) {
        setState(() {
          messages.add({
            'isMe': false,
            'action':
                guessedCategory, // Use guessed category as the action text
            'info': '$amount VND',
            'result': 'Thành công.',
            'id': botMsgId,
            'direction': 'out',
            'created_at': DateTime.now().toIso8601String(),
          });
        });
        if (onMessageAdded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onMessageAdded());
        }
      }
    } else {
      // keep warnings ephemeral (do not persist) — still notify UI so it can scroll
      if (mounted) {
        setState(() {
          messages.add({
            'isMe': false,
            'action': 'Cảnh báo',
            'info': 'Không tìm thấy số tiền trong tin nhắn.',
            'result': 'Vui lòng nhập số tiền',
            'isWarning': true,
            'direction': 'out',
            'created_at': DateTime.now().toIso8601String(),
          });
        });
        if (onMessageAdded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onMessageAdded());
        }
        // Xóa cảnh báo sau 10 giây (in-memory only)
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              messages.removeWhere((msg) => msg['isWarning'] == true);
            });
          }
        });
      }
    }
  });
}

/// Lọc tin nhắn dựa trên trạng thái hiển thị mẫu
List<Map<String, dynamic>> filterMessages(
  List<Map<String, dynamic>> messages,
  bool showPreloaded,
) {
  return messages
      .where((msg) => showPreloaded || !(msg['isPreloaded'] ?? false))
      .toList();
}
