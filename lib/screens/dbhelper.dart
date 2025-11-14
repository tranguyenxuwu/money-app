import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'money_app.sqlite');

    // Luôn ghi đè DB từ assets để đảm bảo dữ liệu mới nhất cho dev
    try {
      await Directory(dirname(dbPath)).create(recursive: true);
      final data = await rootBundle.load('assets/database.sqlite');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(dbPath).writeAsBytes(bytes, flush: true);
      print("Database is overwritten with asset file.");
    } catch (e) {
      print("Error overwriting database: $e");
      // fallback: tạo rỗng nếu copy lỗi
      await Directory(dirname(dbPath)).create(recursive: true);
      await File(dbPath).writeAsBytes(const [], flush: true);
    }

    final db = await openDatabase(
      dbPath,
      version: 1,
      onOpen: (db) async {
        await _runMigrations(db);
      },
    );
    return db;
  }

  static Future<void> _runMigrations(Database db) async {
    // Tạo bảng messages nếu chưa có
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
        id         INTEGER PRIMARY KEY,
        text       TEXT NOT NULL,
        direction  TEXT NOT NULL DEFAULT 'out' CHECK (direction IN ('in','out')),
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        amount     INTEGER,
        category   TEXT,
        status     TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new','parsed','linked')),
        txn_id     INTEGER REFERENCES transactions(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_msg_created ON messages(created_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_msg_txn ON messages(txn_id)',
    );

    // (Tuỳ chọn) đảm bảo bảng transactions tồn tại nếu DB assets quá tối giản
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions(
        id         INTEGER PRIMARY KEY,
        amount     INTEGER NOT NULL,
        note       TEXT,
        category   TEXT DEFAULT 'other',
        direction  TEXT DEFAULT 'out' CHECK (direction IN ('in', 'out')),
        status     TEXT NOT NULL DEFAULT 'success' CHECK (status IN ('success','pending','failed','info')),
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT
      )
    ''');

    // Tạo bảng budgets nếu chưa có
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        month_yyyymm INTEGER NOT NULL,
        category     TEXT    NOT NULL,
        limit_vnd    INTEGER NOT NULL,
        PRIMARY KEY (month_yyyymm, category),
        CHECK (limit_vnd >= 0)
      )
    ''');
  }

  // ===== Transactions APIs =====

  static Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    final results = await db.query('transactions', orderBy: 'created_at DESC');
    print('[DBHelper] Found ${results.length} transactions in local DB.');
    return results;
  }

  static Future<List<Map<String, dynamic>>> getAllMessages() async {
    final db = await database;
    final results = await db.query('messages', orderBy: 'created_at DESC');
    print('[DBHelper] Found ${results.length} messages in local DB.');
    return results;
  }

  static Future<List<Map<String, dynamic>>> getAllBudgets() async {
    final db = await database;
    final results = await db.query('budgets');
    print('[DBHelper] Found ${results.length} budgets in local DB.');
    return results;
  }

  static Future<List<Map<String, dynamic>>> getTransactionsByMonth(
    String ym,
  ) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT * FROM transactions
      WHERE strftime('%Y-%m', created_at) = ?
      ORDER BY created_at DESC
    ''',
      [ym],
    );
  }

  static Future<int> getTotalSpent(String ym) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
      SELECT SUM(amount) AS spent
      FROM transactions
      WHERE direction = 'out' AND strftime('%Y-%m', created_at) = ?
    ''',
      [ym],
    );
    return (res.first['spent'] ?? 0) as int;
  }

  static Future<int> getTotalIncome(String ym) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
      SELECT SUM(amount) AS income
      FROM transactions
      WHERE direction = 'in' AND strftime('%Y-%m', created_at) = ?
    ''',
      [ym],
    );
    // Dùng 'income' thay vì 'spent'
    return (res.first['income'] ?? 0) as int;
  }

  // --- THÊM HÀM MỚI: LẤY TỔNG THU NHẬP THEO NĂM ---
  static Future<int> getTotalIncomeByYear(String yyyy) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE direction = 'in' AND strftime('%Y', created_at) = ?
    ''',
      [yyyy], // Lọc theo 'YYYY'
    );
    return (res.first['total'] ?? 0) as int;
  }

  // --- THÊM HÀM MỚI: LẤY TỔNG CHI TIÊU THEO NĂM ---
  static Future<int> getTotalSpentByYear(String yyyy) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE direction = 'out' AND strftime('%Y', created_at) = ?
    ''',
      [yyyy], // Lọc theo 'YYYY'
    );
    return (res.first['total'] ?? 0) as int;
  }

  /// Lấy tổng thu nhập và chi tiêu cho mỗi tháng của một năm
  static Future<List<Map<String, dynamic>>> getMonthlySummaries(String yyyy) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT 
        strftime('%m', created_at) AS month, -- '01', '02', etc.
        SUM(CASE WHEN direction = 'in' THEN amount ELSE 0 END) AS totalIncome,
        SUM(CASE WHEN direction = 'out' THEN amount ELSE 0 END) AS totalExpense
      FROM transactions
      WHERE strftime('%Y', created_at) = ?
      GROUP BY month
      ORDER BY month ASC
    ''',
      [yyyy],
    );
  }

  /// Tìm kiếm giao dịch dựa trên các điều kiện
  static Future<List<Map<String, dynamic>>> searchTransactions({
    String? direction,
    String? category,
    DateTime? date,
  }) async {
    final db = await database;

    // Xây dựng câu query động
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (direction != null) {
      whereClauses.add('direction = ?');
      whereArgs.add(direction);
    }
    if (category != null) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }
    if (date != null) {
      // Lọc theo YYYY-MM-DD
      whereClauses.add("strftime('%Y-%m-%d', created_at) = ?");
      whereArgs.add(DateFormat('yyyy-MM-dd').format(date));
    }

    // Nối các điều kiện
    String whereString = whereClauses.isEmpty
        ? '' // Không có điều kiện
        : 'WHERE ${whereClauses.join(' AND ')}';

    final query = '''
      SELECT * FROM transactions 
      $whereString 
      ORDER BY created_at DESC
    ''';

    print('Đang chạy query: $query với args: $whereArgs');
    return db.rawQuery(query, whereArgs);
  }

  static Future<int> insertTransaction({
    required int amount,
    required String note,
    String category = 'other',
    String direction = 'out', // Added direction parameter
    String status = 'success',
    DateTime? createdAt,
  }) async {
    final db = await database;
    return db.insert('transactions', {
      'amount': amount,
      'note': note,
      'category': category,
      'direction': direction, // Save direction
      'status': status,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    });
  }

  static Future<int> updateTransaction({
    required int id,
    required int amount,
    required String note,
    String category = 'other',
    String direction = 'out',
    String status = 'success',
    required DateTime createdAt,
  }) async {
    final db = await database;
    return db.update(
      'transactions',
      {
        'amount': amount,
        'note': note,
        'category': category,
        'direction': direction,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== Messages APIs =====

  /// Lưu tin nhắn (direction: 'in' = user, 'out' = app/bot)
  static Future<int> insertMessage({
    required String text,
    String direction = 'in',
    int? amount,
    String? category,
    String status = 'new',
    int? txnId,
    DateTime? createdAt,
  }) async {
    final db = await database;
    return db.insert('messages', {
      'text': text,
      'direction': direction,
      'amount': amount,
      'category': category,
      'status': status,
      'txn_id': txnId,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    });
  }

  /// Link tin nhắn với một transaction (khi đã tạo giao dịch)
  static Future<int> linkMessageToTxn({
    required int messageId,
    required int txnId,
  }) async {
    final db = await database;
    return db.update(
      'messages',
      {'txn_id': txnId, 'status': 'linked'},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Lấy N tin nhắn mới nhất
  static Future<List<Map<String, dynamic>>> getRecentMessages({
    int limit = 200,
  }) async {
    final db = await database;
    return db.query(
      'messages',
      orderBy: 'created_at ASC', // Retrieve messages in chronological order
      limit: limit,
    );
  }

  /// Lấy tin nhắn kèm transaction (nếu có)
  static Future<List<Map<String, dynamic>>> getMessagesWithTxn({
    int limit = 50,
  }) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT m.*, t.amount AS txn_amount, t.category AS txn_category, t.account AS txn_account
      FROM messages m
      LEFT JOIN transactions t ON t.id = m.txn_id
      ORDER BY m.created_at DESC
      LIMIT ?
    ''',
      [limit],
    );
  }
}
