import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_app/screens/dbhelper.dart';

class SyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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


