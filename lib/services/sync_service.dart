import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_app/screens/dbhelper.dart';

class SyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Downloads all data from Firestore and overwrites the local SQLite database
  static Future<bool> downloadDataFromFirebase() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("[SyncService] ERROR: Download failed because user is not logged in.");
      return false;
    }
    print("[SyncService] Starting download for user: ${user.uid}");

    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);

      // 1. Download Transactions
      final transactionsSnapshot = await userDocRef.collection('transactions').get();
      final List<Map<String, dynamic>> transactions = [];
      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        // Convert Firestore Timestamp back to ISO8601 string
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }
        transactions.add(data);
      }
      print("[SyncService] Downloaded ${transactions.length} transactions.");

      // 2. Download Messages
      final messagesSnapshot = await userDocRef.collection('messages').get();
      final List<Map<String, dynamic>> messages = [];
      for (final doc in messagesSnapshot.docs) {
        final data = doc.data();
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        messages.add(data);
      }
      print("[SyncService] Downloaded ${messages.length} messages.");

      // 3. Download Budgets
      final budgetsSnapshot = await userDocRef.collection('budgets').get();
      final List<Map<String, dynamic>> budgets = [];
      for (final doc in budgetsSnapshot.docs) {
        budgets.add(doc.data());
      }
      print("[SyncService] Downloaded ${budgets.length} budgets.");

      // 4. Clear local database and insert downloaded data
      await DBHelper.clearAllData();
      if (transactions.isNotEmpty) {
        await DBHelper.bulkInsertTransactions(transactions);
      }
      if (messages.isNotEmpty) {
        await DBHelper.bulkInsertMessages(messages);
      }
      if (budgets.isNotEmpty) {
        await DBHelper.bulkInsertBudgets(budgets);
      }

      print("[SyncService] SUCCESS: Data downloaded and saved to local database.");
      return true;
    } catch (e) {
      print("================================================================");
      print("[SyncService] CRITICAL ERROR: Failed to download data from Firebase.");
      print("Error Details: $e");
      print("================================================================");
      return false;
    }
  }

  /// Uploads a single transaction to Firestore immediately
  static Future<bool> syncSingleTransactionToFirebase(Map<String, dynamic> transaction) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("[SyncService] ERROR: Cannot sync transaction - user not logged in.");
      return false;
    }

    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final transactionRef = userDocRef.collection('transactions').doc(transaction['id'].toString());

      final firestoreData = Map<String, dynamic>.from(transaction);
      if (firestoreData['created_at'] is String) {
        firestoreData['created_at'] = Timestamp.fromDate(DateTime.parse(firestoreData['created_at']));
      }
      if (firestoreData['updated_at'] != null && firestoreData['updated_at'] is String) {
        firestoreData['updated_at'] = Timestamp.fromDate(DateTime.parse(firestoreData['updated_at']));
      }

      await transactionRef.set(firestoreData);
      print("[SyncService] Transaction ${transaction['id']} synced to Firebase.");
      return true;
    } catch (e) {
      print("[SyncService] ERROR: Failed to sync transaction to Firebase: $e");
      return false;
    }
  }

  /// Deletes a single transaction from Firestore
  static Future<bool> deleteTransactionFromFirebase(int transactionId) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("[SyncService] ERROR: Cannot delete transaction - user not logged in.");
      return false;
    }

    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      await userDocRef.collection('transactions').doc(transactionId.toString()).delete();
      print("[SyncService] Transaction $transactionId deleted from Firebase.");
      return true;
    } catch (e) {
      print("[SyncService] ERROR: Failed to delete transaction from Firebase: $e");
      return false;
    }
  }

  /// Fetches all data from the local SQLite database (transactions, messages, budgets)
  /// and uploads it to corresponding collections in Firestore.
  static Future<bool> syncAllDataToFirebase() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("[SyncService] ERROR: Sync failed because user is not logged in.");
      return false;
    }
    print("[SyncService] Starting full sync for user: ${user.uid}");

    final localTransactions = await DBHelper.getAllTransactions();
    final localMessages = await DBHelper.getAllMessages();
    final localBudgets = await DBHelper.getAllBudgets();

    if (localTransactions.isEmpty && localMessages.isEmpty && localBudgets.isEmpty) {
      print("[SyncService] No local data to sync.");
      return false;
    }

    final WriteBatch batch = _firestore.batch();
    final userDocRef = _firestore.collection('users').doc(user.uid);

    // 1. Sync Transactions
    if (localTransactions.isNotEmpty) {
      print("[SyncService] Found ${localTransactions.length} transactions to sync.");
      final CollectionReference transactionsRef = userDocRef.collection('transactions');
      for (final map in localTransactions) {
        final docRef = transactionsRef.doc(map['id'].toString());
        // Create a mutable copy to modify
        final firestoreMap = Map<String, dynamic>.from(map);
        // Convert DateTime strings to Timestamps for Firestore
        if (firestoreMap['created_at'] is String) {
          firestoreMap['created_at'] = Timestamp.fromDate(DateTime.parse(firestoreMap['created_at']));
        }
        if (firestoreMap['updated_at'] != null && firestoreMap['updated_at'] is String) {
           firestoreMap['updated_at'] = Timestamp.fromDate(DateTime.parse(firestoreMap['updated_at']));
        }
        batch.set(docRef, firestoreMap);
      }
    }

    // 2. Sync Messages
    if (localMessages.isNotEmpty) {
      print("[SyncService] Found ${localMessages.length} messages to sync.");
      final CollectionReference messagesRef = userDocRef.collection('messages');
      for (final map in localMessages) {
        final docRef = messagesRef.doc(map['id'].toString());
        final firestoreMap = Map<String, dynamic>.from(map);
        if (firestoreMap['created_at'] is String) {
          firestoreMap['created_at'] = Timestamp.fromDate(DateTime.parse(firestoreMap['created_at']));
        }
        batch.set(docRef, firestoreMap);
      }
    }

    // 3. Sync Budgets
    if (localBudgets.isNotEmpty) {
      print("[SyncService] Found ${localBudgets.length} budgets to sync.");
      final CollectionReference budgetsRef = userDocRef.collection('budgets');
      for (final map in localBudgets) {
        // Create a stable ID for budgets, e.g., "202305_food"
        final docId = "${map['month_yyyymm']}_${map['category']}";
        final docRef = budgetsRef.doc(docId);
        batch.set(docRef, map);
      }
    }

    // Ensure the user document exists and update sync timestamp
    batch.set(userDocRef, {'lastSynced': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    // Commit the batch
    try {
      await batch.commit();
      print("[SyncService] SUCCESS: Batch commit completed.");
      return true;
    } catch (e) {
      print("================================================================");
      print("[SyncService] CRITICAL ERROR: Failed to commit batch to Firebase.");
      print("Error Details: $e");
      print("================================================================");
      return false;
    }
  }
}


