# HƯỚNG DẪN SỬ DỤNG MONEY APP

<div align="center">

![Money App](assets/images/income.png)

**Ứng dụng quản lý tài chính cá nhân thông minh**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/money-app)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green.svg)](https://github.com/yourusername/money-app)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg)](https://flutter.dev)

📅 **Phiên bản**: 1.0.0 | **Ngày cập nhật**: 14/11/2025

</div>

---

## 📋 Mục lục

- [Giới thiệu](#-giới-thiệu)
- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Tính năng chính](#-tính-năng-chính)
- [Cài đặt](#-cài-đặt)
- [Hướng dẫn sử dụng](#-hướng-dẫn-sử-dụng)
  - [Đăng ký/Đăng nhập](#1-đăng-ký--đăng-nhập)
  - [Trang chủ (Home)](#2-trang-chủ-home)
  - [Quản lý giao dịch (Transactions)](#3-quản-lý-giao-dịch-transactions)
  - [Phân tích (Analysis)](#4-phân-tích-analysis)
  - [Danh mục (Categories)](#5-danh-mục-categories)
  - [Chatbot thông minh](#6-chatbot-thông-minh-chat)
  - [Hồ sơ cá nhân (Profile)](#7-hồ-sơ-cá-nhân-profile)
- [Khởi động nhanh](#-khởi-động-nhanh-quick-start)
- [Đồng bộ dữ liệu](#-đồng-bộ-dữ-liệu)
- [Xử lý sự cố](#-xử-lý-sự-cố)
- [Câu hỏi thường gặp](#-câu-hỏi-thường-gặp-faq)
- [Hỗ trợ](#-hỗ-trợ)

---

## 🎯 Giới thiệu

**Money App** là ứng dụng quản lý tài chính cá nhân hiện đại, giúp bạn:

✅ Theo dõi thu chi hàng ngày dễ dàng  
✅ Phân tích chi tiêu thông minh  
✅ Nhập giao dịch nhanh bằng Chatbot AI  
✅ Đồng bộ dữ liệu đa thiết bị  
✅ Bảo mật cao với Firebase Authentication  

---

## 📱 Yêu cầu hệ thống

### Android
- **Phiên bản**: Android 8.0 (API 26) trở lên
- **RAM**: Tối thiểu 2GB
- **Dung lượng trống**: ≥ 200 MB

### iOS *(sắp ra mắt)*
- **Phiên bản**: iOS 13.0 trở lên
- **Dung lượng trống**: ≥ 200 MB

### Kết nối mạng
- Wi-Fi hoặc 4G/5G cho đăng nhập và đồng bộ
- Có thể sử dụng offline (dữ liệu lưu cục bộ)

---

## ✨ Tính năng chính

### 🔐 Xác thực người dùng
- Đăng nhập/Đăng ký với Email & Password
- Xác thực an toàn qua Firebase Authentication
- Chế độ "Bỏ qua" để trải nghiệm nhanh

### 💰 Quản lý giao dịch
- **Thêm/Sửa/Xóa** giao dịch dễ dàng
- Phân loại **Thu (Income)** và **Chi (Expense)**
- Gắn nhãn danh mục: food, transport, entertainment, bills, salary, groceries, rent, other
- Ghi chú chi tiết cho mỗi giao dịch
- Lọc theo tháng/năm

### 📊 Phân tích thông minh
- Biểu đồ trực quan theo năm
- Thống kê thu/chi tổng hợp
- Tìm kiếm nhanh giao dịch
- Báo cáo chi tiết theo danh mục

### 🤖 Chatbot AI
- Nhập giao dịch bằng **ngôn ngữ tự nhiên**
- Ví dụ: *"Ăn cơm 30k"* → Tự động tạo giao dịch
- Tiết kiệm thời gian, nhanh chóng

### 📂 Quản lý danh mục
- Tùy chỉnh danh mục theo nhu cầu
- Thêm/Sửa/Xóa danh mục dễ dàng

### ☁️ Đồng bộ đám mây
- Lưu trữ cục bộ với **SQLite**
- Đồng bộ lên **Firebase/Firestore** khi bật
- Bảo vệ dữ liệu khi đổi thiết bị

---

## 📥 Cài đặt

### Cách 1: Cài từ APK (Khuyến nghị)

1. Tải file APK từ [Releases](https://github.com/yourusername/money-app/releases)
2. Bật **"Cài đặt từ nguồn không xác định"** trong cài đặt Android
3. Mở file APK và nhấn **Install**
4. Chờ cài đặt hoàn tất và mở ứng dụng

### Cách 2: Chạy từ mã nguồn (Dành cho Developer)

```bash
# 1. Clone repository
git clone https://github.com/yourusername/money-app.git
cd money-app

# 2. Cài đặt dependencies
flutter pub get

# 3. Chạy ứng dụng
flutter run
```

**Yêu cầu:**
- Flutter SDK 3.0+
- Android Studio / Xcode
- Thiết bị thật hoặc emulator

---

## 📖 Hướng dẫn sử dụng

### 1. Đăng ký / Đăng nhập

#### 🆕 Đăng ký tài khoản mới

1. Mở ứng dụng lần đầu
2. Nhấn **"Sign up"**
3. Nhập thông tin:
   - **Email**: địa chỉ email hợp lệ
   - **Password**: mật khẩu tối thiểu 6 ký tự
4. Nhấn **"Sign up"** để hoàn tất

#### 🔑 Đăng nhập

1. Nhấn **"Log in"**
2. Nhập **Email** và **Password**
3. Nhấn **"Log in"**

#### ⚡ Bỏ qua đăng nhập (Quick Start)

- Nhấn **"Skip"** để sử dụng ngay
- ⚠️ **Lưu ý**: Dữ liệu chỉ lưu cục bộ, không đồng bộ đám mây

---

### 2. Trang chủ (Home)

<div align="center">
  <img src="assets/images/income.png" width="300" alt="Home Screen">
</div>

#### Chức năng chính:

📌 **Recent Transactions** - Hiển thị giao dịch gần đây  
🎯 **FAB Button** - Nút nổi để mở Chatbot nhanh  

#### Thao tác:

- Vuốt qua trái/phải để xem các giao dịch
- Nhấn vào giao dịch để xem chi tiết
- Nhấn **FAB (biểu tượng chat)** để mở Chatbot

---

### 3. Quản lý giao dịch (Transactions)

<div align="center">
  <img src="assets/images/expenses.png" width="300" alt="Transactions">
</div>

#### ➕ Thêm giao dịch mới

1. Nhấn nút **"+"** hoặc **"Add Transaction"**
2. Điền thông tin:
   - **Amount** (Số tiền): Nhập số tiền
   - **Direction**: Chọn **In (Thu)** hoặc **Out (Chi)**
   - **Category**: Chọn danh mục (food, transport, ...)
   - **Note**: Ghi chú (không bắt buộc)
   - **Time**: Chọn ngày giờ
3. Nhấn **"Save"**

#### ✏️ Sửa giao dịch

1. Nhấn vào giao dịch cần sửa
2. Chọn **"Edit"**
3. Thay đổi thông tin
4. Nhấn **"Update"**

#### 🗑️ Xóa giao dịch

1. Nhấn vào giao dịch cần xóa
2. Chọn **"Delete"**
3. Xác nhận xóa

#### 🔍 Lọc giao dịch

- **Theo tháng**: Chọn tháng để xem giao dịch trong tháng đó
- **Theo danh mục**: Lọc theo category
- **Theo loại**: Lọc Thu/Chi

---

### 4. Phân tích (Analysis)

#### 📊 Xem biểu đồ

1. Vào tab **"Analysis"** từ thanh điều hướng
2. Chọn **Năm** muốn xem
3. Biểu đồ hiển thị:
   - Thu nhập (Income) - màu xanh lá
   - Chi tiêu (Expense) - màu đỏ
   - Tổng hợp theo tháng

#### 🔍 Tìm kiếm nhanh

- Dùng thanh **Search** để tìm giao dịch cụ thể
- Lọc theo ngày, danh mục, loại

#### 💡 Mẹo:
- Theo dõi xu hướng chi tiêu theo tháng
- So sánh thu/chi để điều chỉnh ngân sách

---

### 5. Danh mục (Categories)

#### ➕ Thêm danh mục mới

1. Vào tab **"Categories"**
2. Nhấn nút **"+"**
3. Nhập tên danh mục (ví dụ: "gym", "shopping")
4. Nhấn **"Save"**

#### ✏️ Sửa/Xóa danh mục

- Nhấn vào danh mục → **Edit** hoặc **Delete**

#### 📂 Danh mục mặc định:
- `food` - Ăn uống
- `transport` - Di chuyển
- `entertainment` - Giải trí
- `bills` - Hóa đơn
- `salary` - Lương
- `groceries` - Tạp hóa
- `rent` - Thuê nhà
- `other` - Khác

---

### 6. Chatbot thông minh (Chat)

#### 🤖 Nhập giao dịch bằng ngôn ngữ tự nhiên

1. Nhấn **FAB** từ trang Home
2. Gõ câu lệnh, ví dụ:
   - *"Ăn cơm 30k"*
   - *"Cà phê 25k"*
   - *"Xăng xe 200k"*
3. Chatbot tự động tạo giao dịch

#### 💬 Cấu trúc câu lệnh:

```
[Nội dung] + [Số tiền]
```

**Ví dụ:**
- ✅ "Ăn trưa 50k"
- ✅ "Mua sách 150k"
- ✅ "Đi taxi 80k"

#### 💡 Mẹo:
- Câu lệnh ngắn gọn → Độ chính xác cao
- Ghi rõ số tiền (k = nghìn, tr = triệu)

---

### 7. Hồ sơ cá nhân (Profile)

#### 👤 Quản lý thông tin

1. Vào tab **"Profile"**
2. Xem/Sửa:
   - Ảnh đại diện
   - Email
   - Tên hiển thị

#### 📷 Đổi ảnh đại diện

1. Nhấn vào ảnh hiện tại
2. Chọn **"Change Photo"**
3. Chọn ảnh từ:
   - 📷 Camera (chụp mới)
   - 🖼️ Gallery (chọn có sẵn)
4. ⚠️ **Cần cấp quyền Photos/Files**

#### 🚪 Đăng xuất

- Nhấn **"Log out"** để thoát tài khoản

---

## 🚀 Khởi động nhanh (Quick Start)

### Luồng 5 bước cho người dùng mới:

```
1️⃣ Log in (hoặc Skip)
           ↓
2️⃣ Mở Chatbot → Nhập "Ăn sáng 20k"
           ↓
3️⃣ Vào Transactions → Kiểm tra giao dịch
           ↓
4️⃣ Vào Analysis → Xem biểu đồ
           ↓
5️⃣ Vào Categories → Thêm danh mục mới
```

---

## ☁️ Đồng bộ dữ liệu

### 🔄 Cách hoạt động:

| Trường hợp | Lưu trữ | Đồng bộ |
|-----------|---------|---------|
| **Đăng nhập** | SQLite + Cloud | ✅ Tự động |
| **Skip login** | SQLite (cục bộ) | ❌ Không |
| **Offline** | SQLite | ⏸️ Chờ kết nối |

### 📤 Bật đồng bộ đám mây:

1. **Đăng nhập** tài khoản Firebase
2. Dữ liệu tự động sync lên **Firestore**
3. Truy cập từ nhiều thiết bị

### 🔒 Bảo mật:

- Dữ liệu mã hóa khi truyền
- Chỉ người dùng xác thực mới truy cập được
- Backup tự động trên cloud

### 💡 Khuyến nghị:

> 🌟 **Nên đăng nhập và bật đồng bộ** để bảo vệ dữ liệu khi:
> - Đổi thiết bị mới
> - Cài lại ứng dụng
> - Mất/hỏng điện thoại

---

## 🛠️ Xử lý sự cố

### ❌ Lỗi đăng nhập

#### 1. **Wrong password** (Sai mật khẩu)
- ✅ Kiểm tra lại mật khẩu
- ✅ Sử dụng tính năng "Forgot Password" (nếu có)
- ✅ Liên hệ hỗ trợ

#### 2. **User not found** (Không tìm thấy người dùng)
- ✅ Kiểm tra Email đã nhập đúng chưa
- ✅ Thực hiện **Sign up** nếu chưa có tài khoản

#### 3. **No network** (Không có mạng)
- ✅ Kiểm tra kết nối Wi-Fi/4G/5G
- ✅ Thử lại sau khi có mạng
- ✅ Có thể dùng offline (không đăng nhập)

---

### 📊 Lỗi hiển thị dữ liệu

#### 1. **Không thấy giao dịch trong tháng**
- ✅ Kiểm tra bộ lọc tháng/năm
- ✅ Dùng Search để tìm kiếm
- ✅ Đảm bảo đã thêm giao dịch

#### 2. **Không thấy dữ liệu trong Analysis**
- ✅ Đảm bảo đã có ít nhất 1 giao dịch
- ✅ Thử đổi năm lọc
- ✅ Kiểm tra kết nối đồng bộ

---

### 📷 Lỗi quyền truy cập

#### **Permission denied** (Từ chối quyền Photos/Files)

**Giải pháp:**

1. Vào **Cài đặt** hệ thống
2. Chọn **Apps** → **Money App**
3. Chọn **Permissions**
4. Bật quyền:
   - ✅ Storage
   - ✅ Camera (nếu cần chụp ảnh)

---

### 🔄 Lỗi đồng bộ

#### **Sync failed**

- ✅ Kiểm tra kết nối mạng
- ✅ Đăng xuất và đăng nhập lại
- ✅ Liên hệ hỗ trợ nếu lỗi kéo dài

---

## ❓ Câu hỏi thường gặp (FAQ)

<details>
<summary><b>1. Có thể dùng không cần đăng nhập không?</b></summary>

**Đáp:** Có. Bạn có thể chọn **"Skip"** để trải nghiệm nhanh. Tuy nhiên:
- ❌ Dữ liệu chỉ lưu cục bộ
- ❌ Không đồng bộ đa thiết bị
- ✅ Khuyến nghị: Nên đăng nhập để bảo vệ dữ liệu

</details>

<details>
<summary><b>2. Có thể sửa/xóa giao dịch không?</b></summary>

**Đáp:** Có. 
- **Sửa**: Nhấn vào giao dịch → **Edit** → **Update**
- **Xóa**: Nhấn vào giao dịch → **Delete** → Xác nhận

</details>

<details>
<summary><b>3. Chatbot có hiểu tiếng Việt không?</b></summary>

**Đáp:** Có, Chatbot hỗ trợ:
- ✅ Tiếng Việt (có dấu)
- ✅ Tiếng Việt (không dấu)
- ✅ Viết tắt: k (nghìn), tr (triệu)

</details>

<details>
<summary><b>4. Dữ liệu có an toàn không?</b></summary>

**Đáp:** Rất an toàn:
- 🔐 Xác thực Firebase Authentication
- 🔒 Mã hóa khi truyền dữ liệu
- ☁️ Backup tự động trên cloud
- 👤 Dữ liệu riêng tư theo từng user

</details>

<details>
<summary><b>5. Có thể dùng trên nhiều thiết bị không?</b></summary>

**Đáp:** Có, nếu:
- ✅ Đăng nhập cùng tài khoản
- ✅ Bật đồng bộ đám mây
- ✅ Có kết nối internet

Dữ liệu sẽ tự động sync giữa các thiết bị.

</details>

<details>
<summary><b>6. Không thấy dữ liệu trong Analysis?</b></summary>

**Đáp:** Kiểm tra:
- ✅ Đã có giao dịch chưa?
- ✅ Đổi năm lọc (nút chọn năm)
- ✅ Dùng Search để tìm kiếm

</details>

<details>
<summary><b>7. Làm sao để thêm danh mục mới?</b></summary>

**Đáp:** 
1. Vào tab **"Categories"**
2. Nhấn nút **"+"**
3. Nhập tên danh mục
4. Nhấn **"Save"**

</details>

<details>
<summary><b>8. Chatbot không nhận diện được câu lệnh?</b></summary>

**Đáp:** Thử:
- ✅ Viết ngắn gọn: "Ăn cơm 30k"
- ✅ Ghi rõ số tiền cuối câu
- ✅ Hoặc thêm thủ công qua **Transactions**

</details>

<details>
<summary><b>9. Có thể xuất báo cáo không?</b></summary>

**Đáp:** Hiện tại:
- ✅ Xem biểu đồ trong **Analysis**
- ✅ Lọc và tìm kiếm trong **Transactions**
- 🔜 Tính năng xuất Excel/PDF sẽ có trong phiên bản sau

</details>

<details>
<summary><b>10. Ứng dụng có miễn phí không?</b></summary>

**Đáp:** ✅ Hoàn toàn **MIỄN PHÍ**
- Không quảng cáo
- Không giới hạn tính năng
- Không ẩn phí

</details>

---

## 📞 Hỗ trợ

### 🐛 Báo lỗi (Bug Report)

- **GitHub Issues**: [Tạo issue mới](https://github.com/yourusername/money-app/issues)
- Mô tả chi tiết lỗi và cách tái hiện

### 💬 Liên hệ

- **Email**: support@moneyapp.com
- **Hotline**: 1900-xxxx-xxx (8h-17h, T2-T6)

### 📖 Tài liệu kỹ thuật

- [Firebase Sync Flow](docs/firebase_sync_flow.md)
- [Firebase Sync Implementation](docs/firebase_sync_implementation.md)
- [Local Database Structure](docs/local_database.md)

### 🌟 Đóng góp (Contribution)

Mọi đóng góp đều được chào đón! Xem [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📚 Phụ lục

### A. Thuật ngữ kỹ thuật

| Thuật ngữ | Giải thích |
|-----------|------------|
| **Transaction** | Giao dịch thu hoặc chi |
| **Direction** | Hướng giao dịch: In (Thu) / Out (Chi) |
| **Category** | Danh mục: food, transport, entertainment, ... |
| **FAB** | Floating Action Button - Nút nổi trên giao diện |
| **Firebase Auth** | Hệ thống xác thực của Firebase |
| **SQLite** | Cơ sở dữ liệu cục bộ trên thiết bị |
| **Firestore** | Cơ sở dữ liệu đám mây của Firebase |
| **Sync** | Đồng bộ dữ liệu giữa thiết bị và cloud |

---

### B. Quy ước nhập liệu Chatbot

#### ✅ Câu lệnh chuẩn:

```
[Nội dung chi tiêu] + [Số tiền]
```

#### 📝 Ví dụ tốt:

| Câu lệnh | Kết quả |
|----------|---------|
| `Ăn cơm 30k` | ✅ Chi 30,000 VNĐ - Category: food |
| `Cà phê 25k` | ✅ Chi 25,000 VNĐ - Category: food |
| `Xăng xe 200k` | ✅ Chi 200,000 VNĐ - Category: transport |
| `Mua sách 150k` | ✅ Chi 150,000 VNĐ - Category: other |
| `Đi taxi 80k` | ✅ Chi 80,000 VNĐ - Category: transport |

#### ❌ Câu lệnh không tốt:

- ❌ "Hôm nay tôi đã ăn cơm và uống cà phê tốn 50k" (quá dài)
- ❌ "Chi tiêu" (thiếu số tiền)
- ❌ "30k" (thiếu nội dung)

---

### C. Ghi chú phát hành v1.0.0

#### 🎉 Tính năng ra mắt:

✅ Quản lý giao dịch thu/chi  
✅ Danh sách giao dịch gần đây  
✅ Phân tích biểu đồ theo năm  
✅ Quản lý danh mục chi tiêu  
✅ Chatbot nhập liệu nhanh  
✅ Xác thực Firebase Authentication  
✅ Lưu trữ SQLite cục bộ  
✅ Đồng bộ Firestore (tuỳ chọn)  

#### 🔜 Tính năng sắp tới (v1.1.0):

- 📊 Xuất báo cáo Excel/PDF
- 🔔 Thông báo nhắc nhở chi tiêu
- 💳 Quản lý nhiều tài khoản
- 🌍 Hỗ trợ đa ngôn ngữ (English, Chinese)
- 🎨 Tùy chỉnh giao diện (Dark mode)

---

## 📄 Giấy phép (License)

```
MIT License

Copyright (c) 2025 Money App Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<div align="center">

**Made with ❤️ by Money App Team**

⭐ Nếu bạn thấy hữu ích, hãy cho chúng tôi một star trên [GitHub](https://github.com/yourusername/money-app)!

[⬆ Về đầu trang](#hướng-dẫn-sử-dụng-money-app)

</div>

