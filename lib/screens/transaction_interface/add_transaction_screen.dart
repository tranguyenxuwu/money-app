import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:money_app/models/transaction.dart';
import 'package:money_app/screens/dbhelper.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transactionToEdit;
  final String? defaultCategory;

  const AddTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.defaultCategory,
  });


  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Biến điều khiển cho form
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();

  // Biến trạng thái
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String _transactionType = 'out';
  bool _isEditMode = false; // <-- Thêm biến để biết là đang Sửa hay Thêm

  final List<String> _categories = [
    'food',
    'transport',
    'entertainment',
    'bills',
    'salary',
    'other',
    'groceries',
    'rent',
  ];

  // --- SỬA initState ĐỂ DÙNG VNĐ ---
  @override
  void initState() {
    super.initState();

    // Kiểm tra xem có phải là Sửa Giao Dịch không
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _isEditMode = true;

      // Điền (pre-fill) dữ liệu vào form
      _noteController.text = tx.note ?? '';
      // SỬA Ở ĐÂY: Hiển thị số VNĐ (ví dụ: 50000)
      _amountController.text = tx.amount.toString();
      _selectedDate = tx.createdAt;
      _selectedCategory = tx.category;
      _transactionType = tx.direction;
    }
    else if (widget.defaultCategory != null) {
      // Nếu là THÊM MỚI và có category mặc định
      _selectedCategory = widget.defaultCategory;
    }
  }
  // --- KẾT THÚC initState ---

  // --- Hàm hiển thị Date Picker (Giữ nguyên) ---
  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // --- HÀM _submitData (ĐÃ SỬA SANG VNĐ) ---
  Future<void> _submitData() async {
    // 1. Kiểm tra validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Lấy dữ liệu
    final note = _noteController.text;

    // SỬA Ở ĐÂY: Đọc số VNĐ
    final amountText =
    _amountController.text.replaceAll('₫', '').replaceAll(',', '').replaceAll('.', ''); // Xóa dấu phẩy, chấm, ký hiệu
    final amountDouble = double.tryParse(amountText) ?? 0.0;
    final amountInt = amountDouble.toInt(); // Chuyển thành số nguyên

    if (amountInt <= 0 || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount and category.')),
      );
      return;
    }

    // --- SỬA LOGIC THỜI GIAN ---
    DateTime finalTimestamp;

    if (_isEditMode) {
      // Nếu là Sửa, ta kết hợp NGÀY đã chọn với GIỜ GỐC
      final originalTime = widget.transactionToEdit!.createdAt;
      finalTimestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        originalTime.hour, // Giữ giờ, phút, giây gốc
        originalTime.minute,
        originalTime.second,
      );
    } else {
      // Nếu là Thêm mới, kết hợp NGÀY đã chọn với GIỜ HIỆN TẠI
      final now = DateTime.now();
      finalTimestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );
    }
    // --- KẾT THÚC SỬA ---

    try {
      // 3. Gọi DBHelper
      if (_isEditMode) {
        // --- CHẠY LOGIC UPDATE ---
        await DBHelper.updateTransaction(
          id: widget.transactionToEdit!.id, // <-- Cần ID
          amount: amountInt, // <-- Dùng số VNĐ
          note: note,
          category: _selectedCategory!,
          direction: _transactionType,
          createdAt: finalTimestamp, // <-- Sử dụng timestamp đã sửa
        );
      } else {
        // --- CHẠY LOGIC INSERT (NHƯ CŨ) ---
        await DBHelper.insertTransaction(
          amount: amountInt, // <-- Dùng số VNĐ
          note: note,
          category: _selectedCategory!,
          direction: _transactionType,
          createdAt: finalTimestamp,
        );
      }

      // 4. Quay lại màn hình trước
      if (mounted) {
        Navigator.of(context).pop(); // Đóng màn hình Add/Edit
      }
    } catch (e) {
      print('Lỗi khi lưu giao dịch: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save transaction: $e')),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Tên Tiêu đề và Nút bấm động ---
    final title = _isEditMode
        ? 'Edit Transaction'
        : (_transactionType == 'out' ? 'Add Expense' : 'Add Income');
    final saveButtonText = _isEditMode ? 'Update' : 'Save';

    return Scaffold(
      // 1. App Bar
      appBar: AppBar(
        title: Text(title), // <-- Dùng tiêu đề động
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. Segmented Button (Toggle Income/Expense)
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'out', label: Text('Expense')),
                  ButtonSegment(value: 'in', label: Text('Income')),
                ],
                selected: {_transactionType},
                // Vô hiệu hóa nút này khi đang Sửa (không cho đổi 'in'/'out')
                onSelectionChanged: _isEditMode
                    ? null
                    : (Set<String> newSelection) {
                  setState(() {
                    _transactionType = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 6, 172, 131),
                  foregroundColor: Colors.white,
                  selectedForegroundColor: Color(0xFF00D09E),
                  selectedBackgroundColor: Colors.white,
                ),
              ),
            ),

            // 3. Form bo góc
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Date Field (Code giữ nguyên) ---
                    Text('Date', style: TextStyle(color: Colors.grey[700])),
                    TextFormField(
                      controller: TextEditingController(
                        text: DateFormat('MMMM d, yyyy').format(_selectedDate),
                      ),
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_month),
                          onPressed: _presentDatePicker,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Category Field (Code giữ nguyên) ---
                    Text('Category', style: TextStyle(color: Colors.grey[700])),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: Text('Select the category'),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) =>
                      value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 20),

                    // --- Amount Field (ĐÃ SỬA SANG VNĐ) ---
                    Text('Amount', style: TextStyle(color: Colors.grey[700])),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        suffixText: 'VNĐ', // <-- Thêm VNĐ
                        hintText: '0',
                      ),
                      keyboardType:
                      TextInputType.number, // Đổi sang số nguyên
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (int.tryParse(value.replaceAll(',', '').replaceAll('.', '')) ==
                            null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- Note Field (Code giữ nguyên) ---
                    Text('Note', style: TextStyle(color: Colors.grey[700])),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Dinner with friends',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a note';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // --- Save Button (Code đã sửa) ---
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                          padding: EdgeInsets.symmetric(
                              horizontal: 80, vertical: 15),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        child: Text(saveButtonText), // <-- Dùng text động
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}