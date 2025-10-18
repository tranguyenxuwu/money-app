import 'package:flutter/material.dart';
import '../dbhelper.dart';  // Added import for DBHelper

/// Tạo danh sách tin nhắn mẫu ban đầu từ DB, chèn nếu chưa có
Future<List<Map<String, dynamic>>> getInitialMessages() async {
  final dbMessages = await DBHelper.getRecentMessages(limit: 5);
  if (dbMessages.isEmpty) {
    // Removed insertion of greeting messages for debugging
    return [];
  }
  return dbMessages.reversed.map((msg) {
    final isMe = msg['direction'] == 'in';
    return {
      'isMe': isMe,
      'text': msg['text'],
      'isPreloaded': false,
      'id': msg['id'],
      if (!isMe) ...{
        'action': 'Giao dịch',
        'info': msg['text'],
        'result': 'Đã lưu thành công',
      }
    };
  }).toList();
}

/// Phân tích số tiền và lý do từ chuỗi đầu vào, hỗ trợ đơn vị 'k' cho nghìn
Map<String, dynamic>? parseAmount(String input) {
  final match = RegExp(r'(.*?)(\d+)(k?)', caseSensitive: false).firstMatch(input.trim());
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

/// Gửi tin nhắn và xử lý phản hồi, lưu vào DB
Future<void> sendMessage(List<Map<String, dynamic>> messages, String text, void Function(VoidCallback) setState, bool mounted) async {
  if (text.isEmpty) return;

  // Insert user message into DB
  final msgId = await DBHelper.insertMessage(text: text, direction: 'in');

  setState(() {
    // Thêm tin nhắn của user
    messages.add({'isMe': true, 'text': text, 'id': msgId});
  });

  // Giả lập delay xử lý và trả về card action
  Future.delayed(const Duration(milliseconds: 500), () async {
    if (!mounted) return;
    final parsed = parseAmount(text);
    if (parsed != null) {
      final reason = parsed['reason'] as String;
      final amount = parsed['amount'] as int;
      final displayReason = reason.isNotEmpty ? reason : 'Chi tiêu';
      // Insert transaction into DB
      final txnId = await DBHelper.insertTransaction(amount: -amount, note: displayReason);  // Negative for expense
      // Insert bot response message
      final botMsgId = await DBHelper.insertMessage(text: '$displayReason: $amount VND', direction: 'out', parsedAmount: amount, txnId: txnId);
      if (mounted) {
        setState(() {
          messages.add({
            'isMe': false,
            'action': 'Giao dịch',
            'info': '$displayReason: $amount VND',
            'result': 'Thành công.',
            'id': botMsgId,
          });
        });
      }
    } else {
      // Không insert warning vào DB, chỉ thêm vào list
      if (mounted) {
        setState(() {
          messages.add({
            'isMe': false,
            'action': 'Cảnh báo',
            'info': 'Không tìm thấy số tiền trong tin nhắn.',
            'result': 'Vui lòng nhập số tiền',
            'isWarning': true,
          });
        });
        // Xóa cảnh báo sau 10 giây
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
List<Map<String, dynamic>> filterMessages(List<Map<String, dynamic>> messages, bool showPreloaded) {
  return messages.where((msg) => showPreloaded || !(msg['isPreloaded'] ?? false)).toList();
}
