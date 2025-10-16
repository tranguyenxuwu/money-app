import 'package:flutter/material.dart';

/// Tạo danh sách tin nhắn mẫu ban đầu
List<Map<String, dynamic>> getInitialMessages() {
  return List.generate(
    15,
    (i) => i.isEven
        ? {'isMe': true, 'text': 'Yêu cầu $i', 'isPreloaded': true}
        : {
            'isMe': false,
            'action': 'Giao dịch',
            'info': 'Ăn uống - 99000 VND',
            'result': 'Thành công',
            'isPreloaded': true,
          },
  );
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

/// Gửi tin nhắn và xử lý phản hồi
void sendMessage(List<Map<String, dynamic>> messages, String text, void Function(VoidCallback) setState, bool mounted) {
  if (text.isEmpty) return;

  setState(() {
    // Thêm tin nhắn của user
    messages.add({'isMe': true, 'text': text});
  });

  // Giả lập delay xử lý và trả về card action
  Future.delayed(const Duration(milliseconds: 500), () {
    if (!mounted) return;
    final parsed = parseAmount(text);
    setState(() {
      if (parsed != null) {
        final reason = parsed['reason'] as String;
        final amount = parsed['amount'] as int;
        final displayReason = reason.isNotEmpty ? reason : 'Chi tiêu';
        messages.add({
          'isMe': false,
          'action': 'Giao dịch',
          'info': '$displayReason: $amount VND',
          'result': 'Thành công.',
        });
      } else {
        messages.add({

          'isMe': false,
          'action': 'Cảnh báo',
          'info': 'Không tìm thấy số tiền trong tin nhắn.',
          'result': 'Vui lòng nhập số tiền',
          'isWarning': true,
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
    });
  });
}

/// Lọc tin nhắn dựa trên trạng thái hiển thị mẫu
List<Map<String, dynamic>> filterMessages(List<Map<String, dynamic>> messages, bool showPreloaded) {
  return messages.where((msg) => showPreloaded || !(msg['isPreloaded'] ?? false)).toList();
}
