import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:money_app/models/transaction.dart';
import 'package:money_app/screens/dbhelper.dart';
import 'package:money_app/screens/transaction_interface/add_transaction_screen.dart';
import 'package:money_app/widgets/format_currency.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  // Hàm xử lý "Delete"
  Future<void> _deleteTransaction(BuildContext context) async {
    // 1. Hiển thị hộp thoại xác nhận
    final bool? didConfirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Conformation?'),
        content: Text('Are you sure to delete this transaction?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop(false); // Trả về false
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.of(ctx).pop(true); // Trả về true
            },
          ),
        ],
      ),
    );

    // 2. Nếu người dùng xác nhận
    if (didConfirm == true) {
      try {
        await DBHelper.deleteTransaction(transaction.id);
        if (context.mounted) {
          // Đóng màn hình chi tiết
          Navigator.of(context).pop();
        }
      } catch (e) {
        print("Lỗi khi xóa: $e");
        // Hiển thị lỗi
      }
    }
  }

  // Hàm xử lý "Update"
  void _editTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Truyền giao dịch hiện tại qua màn hình Sửa
        builder: (ctx) => AddTransactionScreen(transactionToEdit: transaction),
      ),
    ).then((_) {
      // Sau khi màn hình Sửa đóng, chúng ta đóng luôn màn hình Chi tiết
      // để quay về màn hình Danh sách (nơi nó sẽ tự động refresh)
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // --- SỬA LOGIC TIỀN TỆ Ở ĐÂY ---
    final String formattedAmount;
    if (transaction.isIncome) {
      // Gọi với showSign: true để có dấu '+'
      formattedAmount = formatCurrency(transaction.amount, showSign: true);
    } else {
      // Gọi bình thường và tự thêm dấu '-'
      formattedAmount = "-${formatCurrency(transaction.amount)}";
    }
    // --- KẾT THÚC SỬA ---

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết giao dịch'),
        backgroundColor: const Color(0xFF00D09E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hiển thị số tiền lớn
            Text(
              formattedAmount, // <-- Dùng biến đã định dạng
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: transaction.isIncome ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.category),
                      title: Text('Category'),
                      subtitle: Text(
                        transaction.category ?? 'N/A',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.notes),
                      title: Text('Note'),
                      subtitle: Text(
                        transaction.note ?? 'N/A',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Date'),
                      subtitle: Text(
                        DateFormat('MMMM d, yyyy - H:mm').format(transaction.createdAt),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Spacer(), // Đẩy nút xuống dưới

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút Update
                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('Update'),
                  onPressed: () => _editTransaction(context), // <-- Kích hoạt lại
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),

                // Nút Delete
                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text('Delete'),
                  onPressed: () => _deleteTransaction(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}