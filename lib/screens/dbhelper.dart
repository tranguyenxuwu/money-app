import 'dart:io';
import 'package:flutter/services.dart';
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

    // Copy từ assets nếu chưa có
    final exists = await databaseExists(dbPath);
    if (!exists) {
      try {
        await Directory(dirname(dbPath)).create(recursive: true);
        final data = await rootBundle.load('assets/data/money_app.sqlite');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        // fallback: tạo rỗng nếu copy lỗi (hiếm)
        await Directory(dirname(dbPath)).create(recursive: true);
        await File(dbPath).writeAsBytes(const [], flush: true);
      }
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
        id             INTEGER PRIMARY KEY,
        text           TEXT NOT NULL,
        direction      TEXT NOT NULL DEFAULT 'in' CHECK (direction IN ('in','out')),
        created_at     TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        parsed_amount  INTEGER,
        category_guess TEXT,
        account_guess  TEXT,
        status         TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new','parsed','linked')),
        txn_id         INTEGER REFERENCES transactions(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_msg_created ON messages(created_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_msg_txn ON messages(txn_id)');

    // (Tuỳ chọn) đảm bảo bảng transactions tồn tại nếu DB assets quá tối giản
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions(
        id INTEGER PRIMARY KEY,
        amount INTEGER NOT NULL,
        note TEXT,
        category TEXT DEFAULT 'other',
        account TEXT DEFAULT 'Cash',
        status TEXT NOT NULL DEFAULT 'success' CHECK (status IN ('success','pending','failed','info')),
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_created  ON transactions (created_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_category ON transactions (category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_account  ON transactions (account)');
  }

  // ===== Transactions APIs =====

  static Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return db.query('transactions', orderBy: 'created_at DESC');
  }

  static Future<List<Map<String, dynamic>>> getTransactionsByMonth(String ym) async {
    final db = await database;
    return db.rawQuery('''
      SELECT * FROM transactions
      WHERE strftime('%Y-%m', created_at) = ?
      ORDER BY created_at DESC
    ''', [ym]);
  }

  static Future<int> getTotalSpent(String ym) async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT SUM(-amount) AS spent
      FROM transactions
      WHERE amount < 0 AND strftime('%Y-%m', created_at) = ?
    ''', [ym]);
    return (res.first['spent'] ?? 0) as int;
  }

  static Future<int> insertTransaction({
    required int amount,
    required String note,
    String category = 'other',
    String account = 'Cash',
    String status = 'success',
    DateTime? createdAt,
  }) async {
    final db = await database;
    return db.insert('transactions', {
      'amount': amount,
      'note': note,
      'category': category,
      'account': account,
      'status': status,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    });
  }

  // ===== Messages APIs =====

  /// Lưu tin nhắn (direction: 'in' = user, 'out' = app/bot)
  static Future<int> insertMessage({
    required String text,
    String direction = 'in',
    int? parsedAmount,
    String? categoryGuess,
    String? accountGuess,
    String status = 'new',
    int? txnId,
    DateTime? createdAt,
  }) async {
    final db = await database;
    return db.insert('messages', {
      'text': text,
      'direction': direction,
      'parsed_amount': parsedAmount,
      'category_guess': categoryGuess,
      'account_guess': accountGuess,
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
  static Future<List<Map<String, dynamic>>> getRecentMessages({int limit = 50}) async {
    final db = await database;
    return db.query(
      'messages',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  /// Lấy tin nhắn kèm transaction (nếu có)
  static Future<List<Map<String, dynamic>>> getMessagesWithTxn({int limit = 50}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT m.*, t.amount AS txn_amount, t.category AS txn_category, t.account AS txn_account
      FROM messages m
      LEFT JOIN transactions t ON t.id = m.txn_id
      ORDER BY m.created_at DESC
      LIMIT ?
    ''', [limit]);
  }
}