# Tài liệu cơ sở dữ liệu cục bộ

Tài liệu này mô tả cách ứng dụng quản lý cơ sở dữ liệu SQLite cục bộ dựa trên file asset và lớp `DBHelper`.

## Tổng quan

* Theo `DBHelper`, file cơ sở dữ liệu mẫu được đóng gói trong asset `assets/data/money_app.sqlite`. Đảm bảo đường dẫn này được khai báo trong `pubspec.yaml` (hiện tại repo chứa file `assets/database.sqlite`, cần đổi tên hoặc cập nhật asset tương ứng trước khi build).
* Khi ứng dụng chạy lần đầu, file asset sẽ được sao chép vào thư mục tài liệu của ứng dụng dưới tên `money_app.sqlite`.
* Lớp `DBHelper` (`lib/screens/dbhelper.dart`) chịu trách nhiệm khởi tạo, nâng cấp và cung cấp các hàm thao tác với cơ sở dữ liệu.
* Toàn bộ thao tác đều sử dụng package [`sqflite`](https://pub.dev/packages/sqflite).

## Quy trình khởi tạo

1. `DBHelper.database` là getter bất đồng bộ trả về một thể hiện `Database` được lưu trong biến tĩnh `_db`.
2. Nếu cơ sở dữ liệu chưa được mở, `_initDb()` sẽ được gọi:
   * Xác định đường dẫn thư mục tài liệu của ứng dụng bằng `getApplicationDocumentsDirectory()`.
   * Xây dựng đường dẫn tới file `money_app.sqlite` trong thư mục đó.
   * Nếu file chưa tồn tại, ứng dụng cố gắng sao chép nội dung từ asset `assets/data/money_app.sqlite`. Nếu việc sao chép thất bại (ví dụ asset thiếu), ứng dụng sẽ tạo file trống để tránh lỗi.
3. Cơ sở dữ liệu được mở với `openDatabase` (phiên bản 1). Mỗi lần mở sẽ gọi `_runMigrations` nhằm đảm bảo cấu trúc bảng mới nhất.

## Migrations và cấu trúc bảng

`_runMigrations` tạo các bảng nếu chưa tồn tại. Dưới đây là cấu trúc chi tiết:

### Bảng `transactions`

| Cột | Kiểu | Ràng buộc | Mô tả |
| --- | ---- | --------- | ----- |
| `id` | INTEGER | PRIMARY KEY | Khoá chính tự tăng. |
| `amount` | INTEGER | NOT NULL | Số tiền của giao dịch (đơn vị: VND). |
| `note` | TEXT | — | Ghi chú mô tả giao dịch. |
| `category` | TEXT | DEFAULT 'other' | Phân loại giao dịch. |
| `direction` | TEXT | DEFAULT 'out', CHECK (direction IN ('in','out')) | Hướng dòng tiền (`in` = thu, `out` = chi). |
| `status` | TEXT | DEFAULT 'success', CHECK (status IN ('success','pending','failed','info')) | Trạng thái xử lý của giao dịch. |
| `created_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Thời điểm tạo bản ghi (ISO 8601). |
| `updated_at` | TEXT | — | Thời điểm cập nhật cuối. |

### Bảng `messages`

| Cột | Kiểu | Ràng buộc | Mô tả |
| --- | ---- | --------- | ----- |
| `id` | INTEGER | PRIMARY KEY | Khoá chính tự tăng. |
| `text` | TEXT | NOT NULL | Nội dung tin nhắn. |
| `direction` | TEXT | DEFAULT 'out', CHECK (direction IN ('in','out')) | Người gửi (`in` = người dùng, `out` = hệ thống). |
| `created_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Thời gian nhận/gửi tin nhắn. |
| `amount` | INTEGER | — | Số tiền trích xuất từ tin nhắn (nếu có). |
| `category` | TEXT | — | Phân loại được suy ra. |
| `status` | TEXT | DEFAULT 'new', CHECK (status IN ('new','parsed','linked')) | Trạng thái xử lý NLP. |
| `txn_id` | INTEGER | FOREIGN KEY → `transactions(id)` ON DELETE SET NULL | Liên kết với giao dịch đã tạo. |

Các chỉ số (index) được tạo để tối ưu truy vấn:

* `idx_msg_created` trên `messages(created_at)`.
* `idx_msg_txn` trên `messages(txn_id)`.

### Bảng `budgets`

| Cột | Kiểu | Ràng buộc | Mô tả |
| --- | ---- | --------- | ----- |
| `month_yyyymm` | INTEGER | PRIMARY KEY cùng với `category` | Tháng áp dụng (định dạng `YYYYMM`). |
| `category` | TEXT | PRIMARY KEY cùng với `month_yyyymm` | Nhóm chi tiêu. |
| `limit_vnd` | INTEGER | NOT NULL, CHECK (limit_vnd >= 0) | Hạn mức chi tiêu theo tháng. |

## API tiện ích trong `DBHelper`

`DBHelper` cung cấp các phương thức tĩnh để thao tác dữ liệu:

### Giao dịch (`transactions`)

* `getAllTransactions()` – Lấy toàn bộ giao dịch, sắp xếp theo `created_at DESC`.
* `getTransactionsByMonth(String ym)` – Lọc giao dịch theo tháng (`ym` dạng `YYYY-MM`).
* `getTotalSpent(String ym)` – Tính tổng chi (`direction = 'out'`) trong tháng.
* `insertTransaction({amount, note, category, direction, status, createdAt})` – Thêm giao dịch mới, trả về `id` được tạo.

### Tin nhắn (`messages`)

* `insertMessage({text, direction, amount, category, status, txnId, createdAt})` – Lưu tin nhắn mới.
* `linkMessageToTxn({messageId, txnId})` – Cập nhật `txn_id` và `status = 'linked'` cho tin nhắn.
* `getRecentMessages({limit = 200})` – Lấy danh sách tin nhắn theo thứ tự thời gian tăng dần.
* `getMessagesWithTxn({limit = 50})` – Lấy tin nhắn cùng thông tin giao dịch liên quan (JOIN `transactions`).

## Quy ước lưu dữ liệu thời gian

Tất cả trường thời gian được lưu dưới dạng chuỗi ISO 8601 (`DateTime.toIso8601String()`), giúp thuận tiện cho việc so sánh và chuyển đổi múi giờ khi hiển thị.

## Lưu ý khi chỉnh sửa schema

* Khi thay đổi schema, cập nhật logic trong `_runMigrations` để đảm bảo các bảng/cột mới được tạo khi người dùng nâng cấp ứng dụng.
* Nếu cần dữ liệu mẫu, cập nhật file asset gốc trùng với đường dẫn `assets/data/money_app.sqlite` mà `DBHelper` sử dụng.
* Kiểm tra kỹ các ràng buộc `CHECK` và `FOREIGN KEY` để đảm bảo dữ liệu hợp lệ.

