# TÀI LIỆU ĐẶC TẢ TÍCH HỢP API HỆ THỐNG THÔNG BÁO (MOBILE)

**Dự án:** Group Spending & Reminder (Quản lý & Nhắc nhở Chi tiêu Nhóm)  
**Phân hệ:** Hệ thống Thông báo Đa kênh (Multi-Channel Notification System)  
**Nền tảng mục tiêu:** Mobile App (iOS / Android / Flutter / React Native)  
**Phiên bản tài liệu:** v1.0.0  
**Ngày cập nhật:** 2026-10-08  

---

## MỤC LỤC
1. [Quy chuẩn chung & Định dạng dữ liệu](#1-quy-chuẩn-chung--định-dạng-dữ-liệu)
   - [1.1. Base URL & Authentication](#11-base-url--authentication)
   - [1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)](#12-cấu-trúc-phản-hồi-chung-apiresponse-pattern)
   - [1.3. Bảng Enum NotificationType](#13-bảng-enum-notificationtype)
2. [Kiến trúc & Các kênh truyền tải thông báo](#2-kiến-trúc--các-kênh-truyền-tải-thông-báo)
   - [2.1. In-App Notification Inbox (CSDL)](#21-in-app-notification-inbox-csdl)
   - [2.2. Firebase Cloud Messaging (FCM Push)](#22-firebase-cloud-messaging-fcm-push)
   - [2.3. WebSocket STOMP qua SockJS (Real-time)](#23-websocket-stomp-qua-sockjs-real-time)
3. [Hướng dẫn cấu hình & Tích hợp trên Mobile Client](#3-hướng-dẫn-cấu-hình--tích-hợp-trên-mobile-client)
   - [3.1. Tích hợp FCM & Đồng bộ fcmToken](#31-tích-hợp-fcm--đồng-bộ-fcmtoken)
   - [3.2. Kết nối WebSocket STOMP & Lắng nghe sự kiện](#32-kết-nối-websocket-stomp--lắng-nghe-sự-kiện)
4. [Đặc tả chi tiết các RESTful API Endpoints](#4-đặc-tả-chi-tiết-các-restful-api-endpoints)
   - [4.1. Lấy danh sách thông báo phân trang (Get Notifications)](#41-lấy-danh-sách-thông-báo-phân-trang-get-notifications)
   - [4.2. Đếm số lượng thông báo chưa đọc (Get Unread Count)](#42-đếm-số-lượng-thông-báo-chưa-đọc-get-unread-count)
   - [4.3. Đánh dấu một thông báo đã đọc (Mark As Read)](#43-đánh-dấu-một-thông-báo-đã-đọc-mark-as-read)
   - [4.4. Đánh dấu tất cả thông báo đã đọc (Mark All As Read)](#44-đánh-dấu-tất-cả-thông-báo-đã-đọc-mark-all-as-read)
   - [4.5. Xóa một thông báo (Delete Notification)](#45-xóa-một-thông-báo-delete-notification)
   - [4.6. Xóa tất cả thông báo đã đọc (Delete All Read Notifications)](#46-xóa-tất-cả-thông-báo-đã-đọc-delete-all-read-notifications)
5. [Ma trận sự kiện & Hướng dẫn điều hướng Deep-Linking](#5-ma-trận-sự-kiện--hướng-dẫn-điều-hướng-deep-linking)
6. [Bảng mã lỗi (Error Codes) & Hướng dẫn xử lý UI](#6-bảng-mã-lỗi-error-codes--hướng-dẫn-xử-lý-ui)
7. [Quy tắc trải nghiệm người dùng (UX Guidelines)](#7-quy-tắc-trải-nghiệm-người-dùng-ux-guidelines)

---

## 1. QUY CHUẨN CHUNG & ĐỊNH DẠNG DỮ LIỆU

### 1.1. Base URL & Authentication

- **Base URL:** `https://api.groupspending.xyz/api/v1` (Production) hoặc `http://<host>:8080/api/v1` (Local / Staging)
- **Tất cả các API thông báo đều yêu cầu Access Token JWT qua Header:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json; charset=UTF-8
  Accept: application/json
  ```

---

### 1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)

Mọi phản hồi RESTful từ máy chủ đều tuân theo cấu trúc bao bọc chuẩn:

#### Phản hồi thành công (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Thành công",
  "data": { ... },
  "timestamp": "2026-10-08T15:00:00Z"
}
```

#### Phản hồi lỗi (HTTP 4xx / 5xx):
```json
{
  "success": false,
  "message": "Không tìm thấy thông báo",
  "errorCode": "NOTIFICATION_NOT_FOUND",
  "timestamp": "2026-10-08T15:00:00Z"
}
```

---

### 1.3. Bảng Enum NotificationType

| Giá trị Enum | Ý nghĩa nghiệp vụ | Nhóm nghiệp vụ | Gợi ý Icon hiển thị |
|:---|:---|:---|:---:|
| `EXPENSE_CREATED` | Khoản chi mới được tạo | Chi tiêu | ➕ 💰 |
| `EXPENSE_UPDATED` | Khoản chi được cập nhật | Chi tiêu | ✏️ 📝 |
| `EXPENSE_DELETED` | Khoản chi bị xóa | Chi tiêu | 🗑️ ❌ |
| `DEBT_REMINDER` | Lời nhắc nợ từ chủ nợ / Admin | Công nợ | ⏰ 🔔 |
| `DEBT_PAY_REQUEST` | Con nợ báo đã chuyển tiền tất toán | Công nợ | 💳 ⏳ |
| `DEBT_SETTLED` | Chủ nợ xác nhận đã nhận đủ tiền | Công nợ | ✅ 🤝 |
| `DEBT_REJECTED` | Chủ nợ từ chối xác nhận trả nợ | Công nợ | ⚠️ 🚫 |
| `FUND_CREATED` | Trưởng nhóm phát động đợt quỹ mới | Quỹ chung | 🏦 📢 |
| `FUND_REMINDER` | Lời nhắc nộp tiền quỹ | Quỹ chung | ⏰ 💸 |
| `FUND_PAID` | Trưởng nhóm xác nhận đã đóng quỹ | Quỹ chung | 🎉 ✅ |
| `MEMBER_JOIN_REQUEST` | Yêu cầu xin gia nhập nhóm | Thành viên | 👥 📩 |
| `MEMBER_JOIN_APPROVED` | Yêu cầu gia nhập nhóm được duyệt | Thành viên | 🎉 🥳 |
| `MEMBER_JOIN_REJECTED` | Yêu cầu gia nhập nhóm bị từ chối | Thành viên | 🚫 ❌ |

---

## 2. KIẾN TRÚC & CÁC KÊNH TRUYỀN TẢI THÔNG BÁO

Hệ thống cung cấp cơ chế thông báo toàn diện qua 3 tầng:

1. **In-App Notification Inbox (CSDL MySQL):** Mỗi thông báo được lưu trữ vĩnh viễn trong CSDL cho từng người dùng. Khi người dùng mở app hoặc vào màn hình "Hộp thư thông báo" (Notification Center), danh sách được tải về kèm trạng thái đã đọc/chưa đọc.
2. **Firebase Cloud Messaging (FCM Push):** Đẩy thông báo ra màn hình khóa, thanh trạng thái (Notification Tray) của điện thoại khi người dùng tắt ứng dụng hoặc ứng dụng đang ở chế độ nền (Background).
3. **WebSocket STOMP qua SockJS (Real-time):** Đẩy sự kiện tức thời khi người dùng đang mở ứng dụng (Foreground). Ứng dụng tự động tăng số lượng trên badge chuông đỏ và hiển thị Toast/Banner mà không cần gọi lại API.

---

## 3. HƯỚNG DẪN CẤU HÌNH & TÍCH HỢP TRÊN MOBILE CLIENT

### 3.1. Tích hợp FCM & Đồng bộ fcmToken

Khi ứng dụng khởi động hoặc ngay sau khi người dùng đăng nhập thành công, Mobile Client cần lấy FCM Token từ Firebase SDK và gửi lên máy chủ:

#### Endpoint đồng bộ FCM Token:
```http
PUT /api/v1/users/me/fcm-token?fcmToken=YOUR_DEVICE_FCM_TOKEN
Authorization: Bearer <accessToken>
```

#### Code mẫu Flutter (Dart):
```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> syncFcmToken(String accessToken) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Yêu cầu cấp quyền nhận thông báo (iOS & Android 13+)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken();
    if (token != null) {
      // Gọi API cập nhật FCM Token lên Backend
      await dio.put(
        'https://api.groupspending.xyz/api/v1/users/me/fcm-token',
        queryParameters: {'fcmToken': token},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    }
    
    // Lắng nghe khi token tự động refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      dio.put(
        'https://api.groupspending.xyz/api/v1/users/me/fcm-token',
        queryParameters: {'fcmToken': newToken},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }
}
```

---

### 3.2. Kết nối WebSocket STOMP & Lắng nghe sự kiện

- **Địa chỉ kết nối:** `http://<host>:8080/api/v1/ws` (qua SockJS) hoặc `ws://<host>:8080/api/v1/ws/websocket`
- **Kênh cá nhân cần subscribe:**
  - Kênh chính: `/topic/users/{myUserId}/notifications` hoặc `/user/queue/notifications`

#### Code mẫu Flutter với `stomp_dart_client`:
```dart
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

StompClient createStompClient(String myUserId) {
  return StompClient(
    config: StompConfig.sockJS(
      url: 'https://api.groupspending.xyz/api/v1/ws',
      onConnect: (StompFrame frame) {
        // Lắng nghe thông báo cá nhân
        client.subscribe(
          destination: '/topic/users/$myUserId/notifications',
          callback: (StompFrame frame) {
            if (frame.body != null) {
              final notificationJson = jsonDecode(frame.body!);
              // notificationJson có cấu trúc của NotificationResponse
              // 1. Tăng số đếm chuông đỏ (unreadCount++)
              // 2. Hiển thị In-app Toast banner
            }
          },
        );
      },
      onWebSocketError: (dynamic error) => print("WebSocket error: $error"),
    ),
  );
}
```

---

## 4. ĐẶC TẢ CHI TIẾT CÁC RESTFUL API ENDPOINTS

### 4.1. Lấy danh sách thông báo phân trang (Get Notifications)

- **URL:** `GET /api/v1/notifications`
- **Quyền:** Mọi tài khoản đã đăng nhập
- **Query Parameters:**
  - `unreadOnly` *(boolean, tùy chọn)*: Truyền `true` để chỉ lấy thông báo chưa đọc.
  - `type` *(NotificationType, tùy chọn)*: Lọc theo phân loại (ví dụ: `EXPENSE_CREATED`, `DEBT_REMINDER`, `FUND_CREATED`...).
  - `page` *(int, mặc định `0`)*: Chỉ số trang (bắt đầu từ 0).
  - `size` *(int, mặc định `20`)*: Số lượng thông báo trên 1 trang.

#### Phản hồi thành công (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Thành công",
  "data": {
    "content": [
      {
        "id": 105,
        "title": "Khoản chi mới",
        "body": "Nguyễn Văn A vừa thêm khoản chi \"Ăn tối lẩu Haidilao\" (650.000 VNĐ) vào nhóm Đi Chơi Đà Lạt",
        "type": "EXPENSE_CREATED",
        "referenceType": "EXPENSE",
        "referenceId": 42,
        "groupId": 10,
        "groupName": "Đi Chơi Đà Lạt",
        "actorId": 2,
        "actorName": "Nguyễn Văn A",
        "actorAvatarUrl": "https://res.cloudinary.com/.../avatar.jpg",
        "isRead": false,
        "readAt": null,
        "createdAt": "2026-10-08T14:30:00Z",
        "data": "{\"groupId\":\"10\",\"expenseId\":\"42\"}"
      },
      {
        "id": 104,
        "title": "Xác nhận thanh toán nợ",
        "body": "Trần Thị B đã chuyển khoản 200.000 VNĐ. Vui lòng kiểm tra và xác nhận 'Đã nhận'!",
        "type": "DEBT_PAY_REQUEST",
        "referenceType": "DEBT",
        "referenceId": 18,
        "groupId": 10,
        "groupName": "Đi Chơi Đà Lạt",
        "actorId": 5,
        "actorName": "Trần Thị B",
        "actorAvatarUrl": "https://res.cloudinary.com/.../avatar_b.jpg",
        "isRead": true,
        "readAt": "2026-10-08T14:45:00Z",
        "createdAt": "2026-10-08T14:20:00Z",
        "data": "{\"groupId\":\"10\",\"debtId\":\"18\"}"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    },
    "totalElements": 2,
    "totalPages": 1,
    "last": true
  },
  "timestamp": "2026-10-08T15:00:00Z"
}
```

---

### 4.2. Đếm số lượng thông báo chưa đọc (Get Unread Count)

Dùng để gọi khi mở app hoặc khi quay lại màn hình chính nhằm hiển thị số đỏ trên icon chuông thông báo (🔔).

- **URL:** `GET /api/v1/notifications/unread-count`
- **Quyền:** Đã đăng nhập

#### Phản hồi thành công (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Thành công",
  "data": {
    "unreadCount": 3
  },
  "timestamp": "2026-10-08T15:00:00Z"
}
```

---

### 4.3. Đánh dấu một thông báo đã đọc (Mark As Read)

Gọi khi người dùng bấm vào một thông báo cụ thể trong danh sách.

- **URL:** `PATCH /api/v1/notifications/{notificationId}/read`
- **Quyền:** Chỉ người nhận thông báo mới có quyền

#### Phản hồi thành công (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Đã đánh dấu thông báo là đã đọc",
  "data": null,
  "timestamp": "2026-10-08T15:00:00Z"
}
```

---

### 4.4. Đánh dấu tất cả thông báo đã đọc (Mark All As Read)

Gọi khi người dùng bấm nút "Đánh dấu tất cả đã đọc" ở góc trên màn hình thông báo.

- **URL:** `PATCH /api/v1/notifications/read-all`
- **Quyền:** Đã đăng nhập

#### Phản hồi thành công (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Đã đánh dấu tất cả thông báo là đã đọc",
  "data": null,
  "timestamp": "2026-10-08T15:00:00Z"
}
```

---

### 4.5. Xóa một thông báo (Delete Notification)

Gọi khi người dùng vuốt sang trái (Swipe-to-delete) trên một mục thông báo.

- **URL:** `DELETE /api/v1/notifications/{notificationId}`
- **Quyền:** Người sở hữu thông báo

#### Phản hồi thành công (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Đã xóa thông báo thành công",
  "data": null,
  "timestamp": "2026-10-08T15:00:00Z"
}
```

---

### 4.6. Xóa tất cả thông báo đã đọc (Delete All Read Notifications)

Dọn dẹp các thông báo cũ đã xem để làm gọn hộp thư.

- **URL:** `DELETE /api/v1/notifications`
- **Quyền:** Đã đăng nhập

#### Phản hồi thành công (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Đã xóa các thông báo đã đọc thành công",
  "data": null,
  "timestamp": "2026-10-08T15:00:00Z"
}
```

---

## 5. MA TRẬN SỰ KIỆN & HƯỚNG DẪN ĐIỀU HƯỚNG DEEP-LINKING

Khi người dùng nhấn vào thông báo (từ Push Notification banner hoặc từ danh sách In-App Inbox), ứng dụng sử dụng các trường `type`, `referenceType`, `referenceId` và `data` để chuyển hướng người dùng đến đúng màn hình:

| Loại thông báo (`type`) | `referenceType` | Màn hình đích trên Mobile | Hành động đề xuất trên UI |
|:---|:---:|:---|:---|
| `EXPENSE_CREATED` | `EXPENSE` | `ExpenseDetailScreen(expenseId)` | Hiển thị chi tiết khoản chi vừa tạo và danh sách chia tiền |
| `EXPENSE_UPDATED` | `EXPENSE` | `ExpenseDetailScreen(expenseId)` | Hiển thị chi tiết khoản chi đã sửa |
| `EXPENSE_DELETED` | `EXPENSE` | `GroupExpensesScreen(groupId)` | Mở danh sách chi tiêu của nhóm |
| `DEBT_REMINDER` | `DEBT` | `DebtDetailScreen(debtId)` hoặc `ActualDebtsScreen(groupId)` | Mở màn hình trả nợ, làm nổi bật nút **"Đã trả"** |
| `DEBT_PAY_REQUEST` | `DEBT` | `ActualDebtsScreen(groupId)` | Mở màn hình công nợ, làm nổi bật nút **"Xác nhận đã nhận tiền"** (Confirm) |
| `DEBT_SETTLED` | `DEBT` | `UserBalanceOverviewScreen` | Hiển thị thông báo nợ đã được tất toán thành công |
| `DEBT_REJECTED` | `DEBT` | `ActualDebtsScreen(groupId)` | Hiển thị cảnh báo chủ nợ từ chối nhận tiền |
| `FUND_CREATED` | `FUND` | `FundDetailScreen(fundId)` | Xem mục tiêu đóng quỹ và danh sách đóng tiền |
| `FUND_REMINDER` | `FUND` | `FundDetailScreen(fundId)` | Mở màn hình đợt quỹ để người dùng nộp tiền |
| `FUND_PAID` | `FUND` | `FundDetailScreen(fundId)` | Hiển thị trạng thái đã hoàn thành đóng quỹ |
| `MEMBER_JOIN_REQUEST` | `GROUP` | `GroupJoinRequestsScreen(groupId)` | Màn hình duyệt thành viên dành cho Admin nhóm |
| `MEMBER_JOIN_APPROVED` | `GROUP` | `GroupDetailScreen(groupId)` | Chào mừng thành viên mới vào trang chủ nhóm |
| `MEMBER_JOIN_REJECTED` | `GROUP` | `HomeScreen` | Thông báo yêu cầu đã bị từ chối |

---

## 6. BẢNG MÃ LỖI (ERROR CODES) & HƯỚNG DẪN XỬ LÝ UI

| HTTP Status | Error Code (`errorCode`) | Nguyên nhân | Hành vi xử lý trên Mobile UI |
|:---:|:---|:---|:---|
| `404` | `NOTIFICATION_NOT_FOUND` | Thông báo không tồn tại hoặc đã bị xóa trước đó | Xóa item khỏi danh sách cục bộ, hiển thị Toast: *"Thông báo này không còn tồn tại"*. |
| `401` | `UNAUTHORIZED` | Token hết hạn hoặc không hợp lệ | Đăng xuất người dùng và chuyển về màn hình Đăng nhập. |
| `403` | `FORBIDDEN` | Cố ý truy cập hoặc xóa thông báo của người khác | Không thực hiện hành động, báo lỗi phân quyền. |

---

## 7. QUY TẮC TRẢI NGHIỆM NGƯỜI DÙNG (UX GUIDELINES)

1. **Badge chuông thông báo (Notification Bell Badge):**
   - Đặt icon chuông ở góc phải thanh AppBar của màn hình chính.
   - Khi `unreadCount > 0`, hiển thị chấm đỏ hoặc số (nếu $> 99$ thì hiển thị `99+`).
   - Lắng nghe sự kiện WebSocket: Mỗi khi nhận frame qua `/topic/users/{id}/notifications`, tự động tăng `unreadCount` lên 1 và rung nhẹ (Haptic Feedback).
2. **Hiển thị danh sách thông báo:**
   - Phân biệt trực quan giữa thông báo **chưa đọc** (nền màu xanh nhạt hoặc có chấm tròn xanh bên cạnh) và thông báo **đã đọc** (nền trắng/xám nhạt).
   - Hiển thị Avatar của người thực hiện (`actorAvatarUrl`) để tăng tính cá nhân hóa.
   - Định dạng thời gian tương đối: *"Vừa xong"*, *"5 phút trước"*, *"2 giờ trước"*, *"Hôm qua"*.
3. **Thao tác nhanh (Quick Actions):**
   - Hỗ trợ kéo xuống để làm mới danh sách (**Pull to Refresh**).
   - Hỗ trợ cuộn vô tận (**Infinite Scroll**) tự động tải trang tiếp theo khi người dùng cuộn đến 80% chiều dài danh sách.
   - Nút **"Đánh dấu tất cả đã đọc"** trên thanh tiêu đề.
   - Vuốt sang trái (**Swipe to dismiss / Delete**) để xóa nhanh 1 thông báo.
