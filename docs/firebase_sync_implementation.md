# Firebase Automatic Sync Implementation

## Tổng quan (Overview)

Hệ thống tự động đồng bộ dữ liệu giữa Firebase Firestore và SQLite local database đã được triển khai. Mỗi khi người dùng mở app, dữ liệu từ Firebase sẽ được tải về và ghi đè lên database local. Mỗi khi có thay đổi (thêm, sửa, xóa giao dịch), dữ liệu sẽ tự động được sync lên Firebase.

## Các thay đổi chính (Main Changes)

### 1. **SyncService Enhancement** (`lib/services/sync_service.dart`)

Đã thêm các phương thức mới:

#### `downloadDataFromFirebase()`
- Tải toàn bộ dữ liệu từ Firebase Firestore (transactions, messages, budgets)
- Chuyển đổi Firestore Timestamp về ISO8601 string
- Xóa dữ liệu local và ghi đè bằng dữ liệu từ Firebase
- Được gọi tự động khi app khởi động và user đã đăng nhập

#### `syncSingleTransactionToFirebase(transaction)`
- Đồng bộ một giao dịch đơn lẻ lên Firebase
- Được gọi tự động sau mỗi lần insert hoặc update transaction
- Chuyển đổi DateTime string thành Firestore Timestamp

#### `deleteTransactionFromFirebase(transactionId)`
- Xóa một giao dịch khỏi Firebase
- Được gọi tự động khi xóa transaction ở local

### 2. **DBHelper Updates** (`lib/screens/dbhelper.dart`)

#### Thêm import SyncService
```dart
import 'package:money_app/services/sync_service.dart';
```

#### Sửa đổi Database Initialization
- **Trước**: Database luôn bị ghi đè từ assets mỗi lần mở app
- **Sau**: Chỉ copy từ assets nếu database chưa tồn tại
- **Lý do**: Cho phép Firebase sync data được lưu trữ lâu dài

#### Thêm các phương thức mới:

##### `clearAllData()`
- Xóa toàn bộ dữ liệu local (transactions, messages, budgets)
- Dùng cho việc chuẩn bị trước khi tải dữ liệu từ Firebase

##### `bulkInsertTransactions(List<Map<String, dynamic>>)`
- Chèn nhiều transactions cùng lúc
- Sử dụng batch operations để tối ưu performance

##### `bulkInsertMessages(List<Map<String, dynamic>>)`
- Chèn nhiều messages cùng lúc

##### `bulkInsertBudgets(List<Map<String, dynamic>>)`
- Chèn nhiều budgets cùng lúc

##### `getTransactionById(int id)`
- Lấy một transaction theo ID
- Dùng để sync sau khi insert/update

#### Cập nhật các phương thức transaction operations:

##### `insertTransaction()`
- **Thêm**: Auto-sync lên Firebase sau khi insert thành công
```dart
final transaction = await getTransactionById(id);
if (transaction != null) {
  SyncService.syncSingleTransactionToFirebase(transaction);
}
```

##### `updateTransaction()`
- **Thêm**: Auto-sync lên Firebase sau khi update thành công

##### `deleteTransaction()`
- **Thêm**: Auto-sync deletion lên Firebase

### 3. **Main.dart Updates** (`lib/main.dart`)

#### Thêm import SyncService
```dart
import 'package:money_app/services/sync_service.dart';
```

#### Thêm FutureBuilder cho Firebase Sync
- Khi user đăng nhập, hiển thị loading screen "Syncing data from Firebase..."
- Tự động gọi `SyncService.downloadDataFromFirebase()`
- Sau khi sync xong (thành công hay thất bại), hiển thị HomeScreen

```dart
if (snapshot.hasData) {
  return FutureBuilder<bool>(
    future: SyncService.downloadDataFromFirebase(),
    builder: (context, syncSnapshot) {
      if (syncSnapshot.connectionState == ConnectionState.waiting) {
        return LoadingScreen with "Syncing data from Firebase...";
      }
      return const HomeScreen();
    },
  );
}
```

## Luồng hoạt động (Workflow)

### Khi mở app:
1. User đăng nhập thành công
2. App hiển thị loading screen "Syncing data from Firebase..."
3. `SyncService.downloadDataFromFirebase()` được gọi
4. Tải transactions, messages, budgets từ Firebase
5. Xóa dữ liệu local cũ
6. Ghi đè bằng dữ liệu mới từ Firebase
7. Hiển thị HomeScreen

### Khi thêm giao dịch mới:
1. User nhập thông tin và bấm Save
2. `DBHelper.insertTransaction()` được gọi
3. Transaction được lưu vào SQLite local
4. Tự động gọi `SyncService.syncSingleTransactionToFirebase()`
5. Transaction được upload lên Firebase Firestore
6. User quay lại màn hình danh sách

### Khi sửa giao dịch:
1. User chỉnh sửa thông tin và bấm Update
2. `DBHelper.updateTransaction()` được gọi
3. Transaction được cập nhật trong SQLite local
4. Tự động gọi `SyncService.syncSingleTransactionToFirebase()`
5. Transaction được cập nhật trên Firebase Firestore

### Khi xóa giao dịch:
1. User xác nhận xóa
2. `DBHelper.deleteTransaction()` được gọi
3. Transaction được xóa khỏi SQLite local
4. Tự động gọi `SyncService.deleteTransactionFromFirebase()`
5. Transaction được xóa khỏi Firebase Firestore

## Cấu trúc dữ liệu trên Firebase

```
Firestore Collection Structure:
/users/{userId}/
  ├─ transactions/{transactionId}
  │   ├─ id: int
  │   ├─ amount: int
  │   ├─ note: string
  │   ├─ category: string
  │   ├─ direction: string ('in' | 'out')
  │   ├─ status: string
  │   ├─ created_at: Timestamp
  │   └─ updated_at: Timestamp (optional)
  │
  ├─ messages/{messageId}
  │   ├─ id: int
  │   ├─ text: string
  │   ├─ direction: string
  │   ├─ created_at: Timestamp
  │   └─ ...
  │
  └─ budgets/{budgetId}
      ├─ month_yyyymm: int
      ├─ category: string
      ├─ limit_vnd: int
      └─ ...
```

## Xử lý lỗi (Error Handling)

- Tất cả các operations đều có try-catch
- Lỗi được log ra console với prefix `[SyncService]`
- Nếu sync thất bại, app vẫn hoạt động bình thường với dữ liệu local
- User không bị gián đoạn trải nghiệm khi có lỗi network

## Tối ưu hóa (Optimizations)

1. **Batch Operations**: Sử dụng Firestore batch writes để upload nhiều documents cùng lúc
2. **Conflict Resolution**: Sử dụng `ConflictAlgorithm.replace` khi bulk insert
3. **Async Operations**: Sync operations chạy async, không block UI thread
4. **Single Source of Truth**: Firebase là nguồn dữ liệu chính, local DB chỉ là cache

## Testing

### Test Case 1: Đăng nhập lần đầu
- Đăng nhập với tài khoản mới
- Verify: Loading screen xuất hiện
- Verify: Dữ liệu từ Firebase được tải về
- Verify: HomeScreen hiển thị đúng dữ liệu

### Test Case 2: Thêm giao dịch
- Thêm một transaction mới
- Verify: Transaction xuất hiện trong list
- Verify: Transaction được upload lên Firebase (check Firestore console)

### Test Case 3: Sửa giao dịch
- Sửa một transaction
- Verify: Thay đổi được lưu local
- Verify: Thay đổi được sync lên Firebase

### Test Case 4: Xóa giao dịch
- Xóa một transaction
- Verify: Transaction biến mất khỏi list
- Verify: Transaction bị xóa khỏi Firebase

### Test Case 5: Multi-device sync
- Thêm transaction trên device A
- Đăng xuất và đăng nhập lại trên device B
- Verify: Transaction từ device A xuất hiện trên device B

## Lưu ý quan trọng (Important Notes)

1. **Authentication Required**: User phải đăng nhập để sync hoạt động
2. **Network Required**: Cần kết nối internet để sync
3. **Firestore Rules**: Đảm bảo Firestore security rules cho phép user đọc/ghi dữ liệu của mình
4. **Data Migration**: Khi deploy lần đầu, dữ liệu local cũ sẽ bị ghi đè bởi dữ liệu từ Firebase

## Future Improvements

1. **Offline Support**: Implement offline queue để retry khi có network trở lại
2. **Conflict Resolution**: Xử lý conflicts khi cùng transaction được sửa trên nhiều devices
3. **Incremental Sync**: Chỉ sync những thay đổi mới thay vì download toàn bộ
4. **Sync Status Indicator**: Hiển thị icon sync status trên UI
5. **Manual Sync**: Thêm nút "Refresh" để user có thể trigger sync thủ công

