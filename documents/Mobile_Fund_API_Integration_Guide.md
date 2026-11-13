# TÀI LIỆU ĐẶC TẢ TÍCH HỢP API QUẢN LÝ QUỸ NHÓM (MOBILE)

**Dự án:** Group Spending & Reminder (Quản lý & Nhắc nhở Chi tiêu Nhóm)  
**Phân hệ:** Quản lý Quỹ nhóm & Thu quỹ (Fund Collection Management)  
**Nền tảng mục tiêu:** Mobile App (iOS / Android / Flutter / React Native)  
**Phiên bản tài liệu:** v1.0.0  
**Ngày cập nhật:** 2026-09-30  

---

## MỤC LỤC
1. [Quy chuẩn chung & Định dạng dữ liệu](#1-quy-chuẩn-chung--định-dạng-dữ-liệu)
   - [1.1. Base URL & Authentication](#11-base-url--authentication)
   - [1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)](#12-cấu-trúc-phản-hồi-chung-apiresponse-pattern)
   - [1.3. Quy ước tiền tệ & Đơn vị tính](#13-quy-ước-tiền-tệ--đơn-vị-tính)
   - [1.4. Bảng Enum dùng chung](#14-bảng-enum-dùng-chung)
2. [Mô hình nghiệp vụ & Luồng tương tác (Business Flow)](#2-mô-hình-nghiệp-vụ--luồng-tương-tác-business-flow)
   - [2.1. Vòng đời đợt thu quỹ (Fund Collection Lifecycle)](#21-vòng-đời-đợt-thu-quỹ-fund-collection-lifecycle)
   - [2.2. Phân quyền vai trò (Role Permissions & Guards)](#22-phân-quyền-vai-trò-role-permissions--guards)
   - [2.3. Cơ chế phân bổ danh sách đóng quỹ](#23-cơ-chế-phân-bổ-danh-sách-đóng-quỹ)
   - [2.4. Ràng buộc nghiệp vụ quan trọng (Business Constraints)](#24-ràng-buộc-nghiệp-vụ-quan-trọng-business-constraints)
   - [2.5. Phân định giữa Quỹ nhóm (Fund) và Khoản chi tiêu (Expense)](#25-phân-định-giữa-quỹ-nhóm-fund-và-khoản-chi-tiêu-expense)
3. [Đặc tả chi tiết các API Endpoints chính](#3-đặc-tả-chi-tiết-các-api-endpoints-chính)
   - [3.1. Lấy dữ liệu tổng quan và danh sách đợt thu quỹ của nhóm (Get Group Funds Overview)](#31-lấy-dữ-liệu-tổng-quan-và-danh-sách-đợt-thu-quỹ-của-nhóm-get-group-funds-overview)
   - [3.2. Phát động đợt đóng quỹ mới (Create Fund Collection)](#32-phát-động-đợt-đóng-quỹ-mới-create-fund-collection)
   - [3.3. Chỉnh sửa thông tin đợt thu quỹ (Update Fund Collection)](#33-chỉnh-sửa-thông-tin-đợt-thu-quỹ-update-fund-collection)
   - [3.4. Xóa đợt thu quỹ (Delete Fund Collection)](#34-xóa-đợt-thu-quỹ-delete-fund-collection)
4. [Các API bổ trợ liên quan (Auxiliary Endpoints)](#4-các-api-bổ-trợ-liên-quan-auxiliary-endpoints)
   - [4.1. Lấy thông tin chi tiết một đợt thu quỹ (Get Fund Collection Details)](#41-lấy-thông-tin-chi-tiết-một-đợt-thu-quỹ-get-fund-collection-details)
   - [4.2. Quản trị viên xác nhận thành viên đã đóng quỹ (Mark Member Paid)](#42-quản-trị-viên-xác-nhận-thành-viên-đã-đóng-quỹ-mark-member-paid)
   - [4.3. Gửi thông báo nhắc nhở đóng quỹ (Send Fund Reminder)](#43-gửi-thông-báo-nhắc-nhở-đóng-quỹ-send-fund-reminder)
   - [4.4. Xuất danh sách đóng quỹ ra file CSV (Export Fund Collection to CSV)](#44-xuất-danh-sách-đóng-quỹ-ra-file-csv-export-fund-collection-to-csv)
5. [Bảng mã lỗi (Error Codes) & Hướng dẫn xử lý UI](#5-bảng-mã-lỗi-error-codes--hướng-dẫn-xử-lý-ui)
6. [Quy tắc trải nghiệm người dùng (UX Guidelines)](#6-quy-tắc-trải-nghiệm-người-dùng-ux-guidelines)

---

## 1. QUY CHUẨN CHUNG & ĐỊNH DẠNG DỮ LIỆU

### 1.1. Base URL & Authentication

- **Base URL Prefix:** `https://api.groupspending.xyz/api/v1` (Production) hoặc `http://<host>:8080/api/v1` (Development / Local)
- **Tất cả các API phân hệ Quỹ nhóm đều bắt buộc phải truyền Access Token:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json; charset=UTF-8
  Accept: application/json
  ```

---

### 1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)

Mọi phản hồi từ máy chủ đều tuân theo chuẩn đóng gói chung:

#### Phản hồi thành công (HTTP 200 OK / HTTP 201 Created):
```json
{
  "success": true,
  "message": "Tạo đợt đóng quỹ thành công",
  "data": { ... },
  "timestamp": "2026-09-30T14:50:00Z"
}
```

#### Phản hồi thất bại do lỗi nghiệp vụ (HTTP 400 / 403 / 404):
```json
{
  "success": false,
  "message": "Chỉ quản trị viên nhóm mới có quyền thực hiện thao tác này",
  "errors": null,
  "timestamp": "2026-09-30T14:50:00Z"
}
```

#### Phản hồi lỗi kiểm tra dữ liệu đầu vào (HTTP 400 Bad Request - Validation Error):
```json
{
  "success": false,
  "message": "Dữ liệu đầu vào không hợp lệ",
  "errors": {
    "name": "Tên đợt đóng quỹ không được để trống",
    "targetAmountPerPerson": "Số tiền tối thiểu là 1k"
  },
  "timestamp": "2026-09-30T14:50:00Z"
}
```

---

### 1.3. Quy ước tiền tệ & Đơn vị tính

Toàn bộ hệ thống quản lý quỹ sử dụng cơ chế cung cấp song song 2 trường giá trị:
1. **Đơn vị rút gọn (`k` / Nghìn VNĐ):** Các trường `targetAmountPerPerson`, `totalTargetAmount`, `totalCollectedAmount`.  
   *Ví dụ:* `100` tương ứng với `100.000 VNĐ`.
2. **Đơn vị quy đổi đầy đủ (`VNĐ`):** Các trường có hậu tố `Vnd` như `targetAmountPerPersonVnd`, `totalTargetAmountVnd`, `totalCollectedAmountVnd` (bằng giá trị đơn vị rút gọn nhân 1000).  
   *Ví dụ:* `100000`.
3. **Giới hạn tiền tệ:**
   - **Tối thiểu:** `1k` (tương đương `1.000 VNĐ`).

> **Khuyến nghị cho Mobile:** Phía Client nên ưu tiên đọc các trường có hậu tố `...Vnd` để format trực tiếp ra chuỗi tiền tệ hiển thị (ví dụ: `100.000 ₫`) thông qua thư viện `NumberFormat` của nền tảng, giúp đồng nhất và tránh sai số.

---

### 1.4. Bảng Enum dùng chung

#### 1.4.1. `FundCollectionStatus` (Trạng thái đợt thu quỹ)

Phản ánh tiến độ thu quỹ chung của toàn bộ đợt thu:

| Enum Key | Tên chuỗi (`value`) | Mô tả hiển thị (`description`) | Ý nghĩa nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `COLLECTING` | `COLLECTING` | `Đang thu` | Đợt quỹ đang diễn ra, vẫn còn ít nhất 1 thành viên chưa nộp tiền. |
| `COMPLETED` | `COMPLETED` | `Hoàn thành` | Toàn bộ thành viên trong danh sách đều đã đóng đủ tiền (`paidCount == totalMemberCount`). |

> **Cơ chế tự động:** Trạng thái của đợt quỹ được Backend tự động tính toán dựa trên tiến độ nộp tiền thực tế của các thành viên.

#### 1.4.2. `FundMemberStatus` (Trạng thái đóng quỹ của từng thành viên)

| Enum Key | Ý nghĩa | Hành động trên UI |
| :--- | :--- | :--- |
| `PENDING` | Chưa đóng quỹ | Hiển thị badge màu cam/vàng: *"Chưa nộp"*. Admin có nút *"Xác nhận đã thu"* và nút *"Nhắc nộp"*. |
| `PAID` | Đã đóng quỹ | Hiển thị badge màu xanh lá: *"Đã nộp"*, kèm thời gian hoàn thành (`paidAt`). |

#### 1.4.3. `FundTimeFilter` (Bộ lọc thời gian đợt thu quỹ)

| Enum Key | Mô tả lọc | Phạm vi áp dụng |
| :--- | :--- | :--- |
| `ALL` | Tất cả thời gian (Mặc định) | Không giới hạn thời gian tạo |
| `THIS_MONTH` | Trong tháng này | Từ ngày 01 đến ngày cuối cùng của tháng hiện tại |
| `LAST_MONTH` | Trong tháng trước | Từ ngày 01 đến ngày cuối cùng của tháng trước |
| `THIS_QUARTER` | Trong quý này | 3 tháng thuộc quý hiện hành (Q1, Q2, Q3 hoặc Q4) |

---

## 2. MÔ HÌNH NGHIỆP VỤ & LUỒNG TƯƠNG TÁC (BUSINESS FLOW)

### 2.1. Vòng đời đợt thu quỹ (Fund Collection Lifecycle)

```
[Quản trị viên (Admin) tạo đợt thu quỹ mới]
  ├── Nhập tên quỹ, mục tiêu/người, hạn nộp
  └── Chọn thành viên (Tất cả hoặc Chỉ định)
       │
       ├──► Tạo FundCollection & các bản ghi FundCollectionMember (PENDING)
       ├──► Gửi FCM Push Notification cho tất cả thành viên
       └──► Ghi nhật ký hoạt động nhóm (Activity Log: CREATE_FUND)
       │
       ▼
[Theo dõi tiến độ thu quỹ]
  ├── Xem Tổng tiền đã thu / Tổng dự kiến / % Hoàn thành
  ├── Lọc theo thời gian, trạng thái hoặc tìm kiếm tên đợt quỹ
  └── Admin bấm "Nhắc đóng quỹ" (FCM Push tới ai còn PENDING)
       │
       ▼
[Thu tiền thực tế & Xác nhận đóng quỹ]
  ├── Thành viên chuyển khoản / đưa tiền mặt cho Admin
  └── Admin bấm "Xác nhận đóng quỹ" (Chuyển thành viên sang PAID)
       │
       ├──► Cập nhật thời điểm paidAt = now()
       ├──► Bắn thông báo Push riêng cho thành viên được xác nhận
       └──► Khi 100% thành viên PAID -> Đợt quỹ tự động chuyển COMPLETED
```

---

### 2.2. Phân quyền vai trò (Role Permissions & Guards)

| Chức năng | Quản trị viên (`ADMIN`) | Thành viên thường (`MEMBER`) |
| :--- | :---: | :---: |
| **Xem danh sách tổng quan quỹ nhóm** | Cho phép | Cho phép |
| **Xem chi tiết đợt quỹ & danh sách nộp** | Cho phép | Cho phép |
| **Xuất báo cáo quỹ ra file CSV** | Cho phép | Cho phép |
| **Tạo đợt thu quỹ mới** | Cho phép | Bị chặn (`403 NOT_GROUP_ADMIN`) |
| **Chỉnh sửa đợt thu quỹ** | Cho phép | Bị chặn (`403 NOT_GROUP_ADMIN`) |
| **Xóa đợt thu quỹ** | Cho phép | Bị chặn (`403 NOT_GROUP_ADMIN`) |
| **Xác nhận thành viên đã nộp tiền** | Cho phép | Bị chặn (`403 NOT_GROUP_ADMIN`) |
| **Bấm nút nhắc đóng quỹ** | Cho phép | Bị chặn (`403 NOT_GROUP_ADMIN`) |

---

### 2.3. Cơ chế phân bổ danh sách đóng quỹ

Khi Admin phát động đợt quỹ mới:
1. **Áp dụng cho toàn bộ nhóm (Mặc định):**
   - Trường `memberUserIds` để trống (`null` hoặc `[]`).
   - Backend tự động quét tất cả các thành viên hiện có trong nhóm và tạo danh sách thu quỹ với số tiền bằng nhau cho từng người.
2. **Áp dụng cho danh sách chỉ định:**
   - Trường `memberUserIds` chứa danh sách ID cụ thể (ví dụ: `[1, 2, 5]`).
   - Backend kiểm tra từng `userId` phải là thành viên hợp lệ của nhóm. Nếu có người không thuộc nhóm, trả về lỗi HTTP 400 ngay lập tức.

---

### 2.4. Ràng buộc nghiệp vụ quan trọng (Business Constraints)

1. **Bảo toàn trạng thái đã nộp tiền (Data Integrity):**
   - Khi Admin cập nhật (sửa) đợt đóng quỹ, hệ thống **tuyệt đối không cho phép loại bỏ** thành viên đã có trạng thái `PAID` ra khỏi danh sách đóng quỹ. Nếu danh sách mới thiếu thành viên đã nộp, hệ thống trả về HTTP 400: *"Không thể loại bỏ thành viên đã đóng quỹ ({tên thành viên}) khỏi đợt quỹ"*.
2. **Nhóm đã lưu trữ (Archived Group):**
   - Nếu nhóm chi tiêu ở trạng thái `ARCHIVED`, toàn bộ tính năng Tạo, Sửa, Xóa đợt đóng quỹ đều bị vô hiệu hóa với mã lỗi `GROUP_ARCHIVED` (HTTP 400).
3. **Tự động chuyển trạng thái Hoàn tất:**
   - Khi thành viên cuối cùng được Admin xác nhận `PAID`, đợt quỹ lập tức chuyển từ `COLLECTING` sang `COMPLETED`, phần trăm hoàn thành đạt `100.0%`.

---

### 2.5. Phân định giữa Quỹ nhóm (Fund) và Khoản chi tiêu (Expense)

Để giao diện Mobile tránh gây nhầm lẫn cho người dùng:
- **Khoản chi tiêu (Expense):** Là các khoản tiền phát sinh hàng ngày (ăn uống, đi lại, mua sắm) do một thành viên trả trước và chia nợ cho các thành viên khác theo hình thức bù trừ công nợ. *(Chi tiết xem tại `Mobile_Expense_API_Integration_Guide.md`)*.
- **Đợt thu quỹ (Fund Collection):** Là đợt huy động tiền mặt hoặc ngân sách chung do Quản trị viên khởi xướng (ví dụ: quỹ phòng trọ, quỹ du lịch hè, quỹ bóng đá), trong đó mỗi người có trách nhiệm nộp một khoản tiền cố định cho thủ quỹ / Admin.

---

## 3. ĐẶC TẢ CHI TIẾT CÁC API ENDPOINTS CHÍNH

### 3.1. Lấy dữ liệu tổng quan và danh sách đợt thu quỹ của nhóm (Get Group Funds Overview)

Trả về thẻ thống kê tổng quan tiến độ thu quỹ của toàn nhóm (tổng tiền đã thu, tổng tiền dự kiến, tỷ lệ hoàn thành) kèm theo danh sách các đợt thu quỹ rút gọn. Hỗ trợ tìm kiếm theo tên và lọc theo thời gian, trạng thái.

- **Method:** `GET`
- **Path:** `/groups/{groupId}/funds`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/funds`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```
- **Path Parameters:**
  - `groupId` (Long, bắt buộc): ID của nhóm chi tiêu.

- **Query Parameters (Hỗ trợ lọc & tìm kiếm):**

| Tên tham số | Kiểu dữ liệu | Bắt buộc | Mặc định | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| `search` | String | Không | *null* | Ô nhập tìm kiếm gần đúng theo tên đợt thu quỹ (không phân biệt hoa/thường). |
| `timeFilter` | String (`FundTimeFilter`) | Không | `ALL` | Bộ lọc thời gian: `ALL`, `THIS_MONTH`, `LAST_MONTH`, `THIS_QUARTER`. |
| `status` | String (`FundCollectionStatus`) | Không | *null* | Bộ lọc trạng thái: `COLLECTING` (Đang thu), `COMPLETED` (Hoàn thành). Bỏ trống để lấy tất cả. |

- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Thành công",
  "data": {
    "groupId": 10,
    "totalCollectedAmount": 800,
    "totalCollectedAmountVnd": 800000,
    "totalTargetAmount": 1000,
    "totalTargetAmountVnd": 1000000,
    "completionPercentage": 80.0,
    "funds": [
      {
        "id": 101,
        "name": "Quỹ liên hoan chào tân sinh viên",
        "status": "COLLECTING",
        "statusText": "Đang thu",
        "startDate": "2026-09-25T08:30:00Z"
      },
      {
        "id": 98,
        "name": "Quỹ nước uống tháng 08",
        "status": "COMPLETED",
        "statusText": "Hoàn thành",
        "startDate": "2026-08-01T09:00:00Z"
      }
    ]
  },
  "timestamp": "2026-09-30T14:55:00Z"
}
```

> **Giải thích các trường dữ liệu tổng quan:**
> - `totalCollectedAmount` & `totalCollectedAmountVnd`: Tổng số tiền đã thu được từ tất cả các đợt quỹ trong nhóm.
> - `totalTargetAmount` & `totalTargetAmountVnd`: Tổng số tiền mục tiêu cần huy động.
> - `completionPercentage`: Tỷ lệ phần trăm hoàn thành làm tròn 2 chữ số thập phân (Ví dụ: `80.0%`). Mobile có thể bind thẳng vào LinearProgressIndicator.
> - `funds`: Danh sách các đợt quỹ rút gọn, tối ưu để hiển thị danh sách dạng Card trên màn hình.

---

### 3.2. Phát động đợt đóng quỹ mới (Create Fund Collection)

Tạo đợt thu quỹ mới cho nhóm. Sau khi tạo thành công, hệ thống tự động tạo các bản ghi tiến độ nộp tiền cho từng thành viên ở trạng thái `PENDING` và bắn thông báo Push Notification đến toàn bộ thành viên.

- **Method:** `POST`
- **Path:** `/groups/{groupId}/funds`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/funds`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json; charset=UTF-8
  ```
- **Path Parameters:**
  - `groupId` (Long, bắt buộc): ID nhóm phát động quỹ.

- **Quyền hạn bắt buộc:** Chỉ **Quản trị viên nhóm (`ADMIN`)** mới có quyền thực hiện.

- **Request Body (JSON - `CreateFundCollectionRequest`):**

| Tên trường | Kiểu dữ liệu | Bắt buộc | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| `name` | String | **Bắt buộc** | `@NotBlank` | Tên đợt đóng quỹ (Ví dụ: *"Quỹ dã ngoại Ba Vì"*). |
| `description` | String | Không | - | Mô tả chi tiết mục đích sử dụng quỹ. |
| `targetAmountPerPerson` | Long | **Bắt buộc** | `@NotNull`, `@Min(1)` | Số tiền mỗi thành viên cần nộp (Đơn vị: `k` / Nghìn VNĐ. Ví dụ `200` = `200.000 VNĐ`). |
| `dueDate` | String (LocalDate) | Không | Định dạng `YYYY-MM-DD` | Hạn chót nộp tiền quỹ. |
| `memberUserIds` | List\<Long\> | Không | Danh sách ID thành viên | Danh sách ID thành viên tham gia đóng quỹ. **Nếu để trống hoặc null:** Tự động áp dụng cho tất cả thành viên trong nhóm. |

#### Request Body mẫu:
```json
{
  "name": "Quỹ dã ngoại Ba Vì",
  "description": "Chi phí thuê lều bạt và tiền nước uống chung",
  "targetAmountPerPerson": 200,
  "dueDate": "2026-10-15",
  "memberUserIds": [1, 2, 3, 4]
}
```

- **Mã phản hồi thành công:** `201 Created`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Tạo đợt đóng quỹ thành công",
  "data": {
    "id": 105,
    "groupId": 10,
    "name": "Quỹ dã ngoại Ba Vì",
    "description": "Chi phí thuê lều bạt và tiền nước uống chung",
    "targetAmountPerPerson": 200,
    "targetAmountPerPersonVnd": 200000,
    "dueDate": "2026-10-15",
    "createdByUserId": 1,
    "createdByUserName": "Nguyễn Văn Admin",
    "totalTargetAmount": 800,
    "totalCollectedAmount": 0,
    "totalCollectedAmountVnd": 0,
    "paidCount": 0,
    "totalMemberCount": 4,
    "members": [
      {
        "id": 301,
        "userId": 1,
        "fullName": "Nguyễn Văn Admin",
        "email": "admin@example.com",
        "avatarUrl": "https://res.cloudinary.com/.../avatar1.jpg",
        "status": "PENDING",
        "paidAt": null
      },
      {
        "id": 302,
        "userId": 2,
        "fullName": "Trần Thị B",
        "email": "thib@example.com",
        "avatarUrl": "https://res.cloudinary.com/.../avatar2.jpg",
        "status": "PENDING",
        "paidAt": null
      },
      {
        "id": 303,
        "userId": 3,
        "fullName": "Lê Văn C",
        "email": "vanc@example.com",
        "avatarUrl": null,
        "status": "PENDING",
        "paidAt": null
      },
      {
        "id": 304,
        "userId": 4,
        "fullName": "Hoàng Thị D",
        "email": "thid@example.com",
        "avatarUrl": null,
        "status": "PENDING",
        "paidAt": null
      }
    ],
    "createdAt": "2026-09-30T15:00:00Z"
  },
  "timestamp": "2026-09-30T15:00:00Z"
}
```

---

### 3.3. Chỉnh sửa thông tin đợt thu quỹ (Update Fund Collection)

Cập nhật lại tên, mô tả, số tiền mỗi người, hạn nộp hoặc danh sách thành viên tham gia đóng quỹ.

- **Method:** `PUT`
- **Path:** `/funds/{fundId}`
- **Full URL:** `https://api.groupspending.xyz/api/v1/funds/{fundId}`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json; charset=UTF-8
  ```
- **Path Parameters:**
  - `fundId` (Long, bắt buộc): ID đợt thu quỹ cần chỉnh sửa.

- **Quyền hạn bắt buộc:** Chỉ **Quản trị viên nhóm (`ADMIN`)** mới có quyền thực hiện.

- **Request Body (JSON - `UpdateFundCollectionRequest`):**

| Tên trường | Kiểu dữ liệu | Bắt buộc | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| `name` | String | **Bắt buộc** | `@NotBlank` | Tên mới của đợt đóng quỹ. |
| `description` | String | Không | - | Ghi chú / mô tả cập nhật. |
| `targetAmountPerPerson` | Long | **Bắt buộc** | `@NotNull`, `@Min(1)` | Số tiền mục tiêu mỗi người (đơn vị: `k`). |
| `dueDate` | String (LocalDate) | Không | `YYYY-MM-DD` | Hạn nộp mới. |
| `memberUserIds` | List\<Long\> | Không | Danh sách ID | Danh sách thành viên sau khi cập nhật. **Lưu ý:** Không được bỏ sót thành viên nào đã có trạng thái `PAID`. |

#### Request Body mẫu:
```json
{
  "name": "Quỹ dã ngoại Ba Vì (Điều chỉnh tiền ăn)",
  "description": "Bổ sung thêm chi phí bữa trưa BBQ",
  "targetAmountPerPerson": 250,
  "dueDate": "2026-10-20",
  "memberUserIds": [1, 2, 3, 4]
}
```

- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:** Tương tự đối tượng `data` trong phản hồi tạo đợt thu quỹ ở mục 3.2.

---

### 3.4. Xóa đợt thu quỹ (Delete Fund Collection)

Xóa hoàn toàn một đợt thu quỹ khỏi cơ sở dữ liệu cùng với các bản ghi tiến độ nộp tiền của thành viên trong đợt quỹ đó.

- **Method:** `DELETE`
- **Path:** `/funds/{fundId}`
- **Full URL:** `https://api.groupspending.xyz/api/v1/funds/{fundId}`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```
- **Path Parameters:**
  - `fundId` (Long, bắt buộc): ID đợt thu quỹ cần xóa.

- **Quyền hạn bắt buộc:** Chỉ **Quản trị viên nhóm (`ADMIN`)** mới có quyền thực hiện.
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Xóa đợt đóng quỹ thành công",
  "data": null,
  "timestamp": "2026-09-30T15:05:00Z"
}
```

---

## 4. CÁC API BỔ TRỢ LIÊN QUAN (AUXILIARY ENDPOINTS)

### 4.1. Lấy thông tin chi tiết một đợt thu quỹ (Get Fund Collection Details)

Dùng cho màn hình Chi tiết đợt thu quỹ (Fund Detail Screen). Cung cấp danh sách toàn bộ thành viên, trạng thái nộp tiền của từng người (`PENDING` hay `PAID`), thời điểm nộp (`paidAt`), cùng tiến độ hoàn thành.

- **Method:** `GET`
- **Path:** `/funds/{fundId}`
- **Full URL:** `https://api.groupspending.xyz/api/v1/funds/{fundId}`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Path Parameters:**
  - `fundId` (Long, bắt buộc): ID đợt thu quỹ.
- **Quyền hạn:** Mọi thành viên trong nhóm đều có quyền xem.
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:** Xem cấu trúc đối tượng `FundCollectionResponse` ở mục 3.2.

---

### 4.2. Quản trị viên xác nhận thành viên đã đóng quỹ (Mark Member Paid)

Khi thành viên nộp tiền mặt hoặc chuyển khoản thành công cho Admin, Admin nhấn xác nhận để chuyển trạng thái thành viên từ `PENDING` sang `PAID`. Hệ thống tự động ghi nhận thời gian `paidAt`, ghi log hoạt động và gửi Push Notification chúc mừng tới thành viên đó.

- **Method:** `POST`
- **Path:** `/funds/{fundId}/members/{targetUserId}/paid`
- **Full URL:** `https://api.groupspending.xyz/api/v1/funds/{fundId}/members/{targetUserId}/paid`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Path Parameters:**
  - `fundId` (Long, bắt buộc): ID đợt thu quỹ.
  - `targetUserId` (Long, bắt buộc): ID thành viên đã hoàn thành nộp tiền.
- **Quyền hạn:** Chỉ **Quản trị viên nhóm (`ADMIN`)**.
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Đã xác nhận thành viên đóng quỹ thành công",
  "data": {
    "id": 105,
    "groupId": 10,
    "name": "Quỹ dã ngoại Ba Vì",
    "totalCollectedAmount": 200,
    "totalCollectedAmountVnd": 200000,
    "paidCount": 1,
    "totalMemberCount": 4,
    "members": [
      {
        "id": 302,
        "userId": 2,
        "fullName": "Trần Thị B",
        "status": "PAID",
        "paidAt": "2026-09-30T15:10:00Z"
      }
    ]
  },
  "timestamp": "2026-09-30T15:10:00Z"
}
```

---

### 4.3. Gửi thông báo nhắc nhở đóng quỹ (Send Fund Reminder)

Admin gửi thông báo đẩy (FCM Push Notification) đồng loạt tới tất cả các thành viên vẫn đang ở trạng thái `PENDING` chưa hoàn thành nộp tiền.

- **Method:** `POST`
- **Path:** `/funds/{fundId}/remind`
- **Full URL:** `https://api.groupspending.xyz/api/v1/funds/{fundId}/remind`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Path Parameters:**
  - `fundId` (Long, bắt buộc): ID đợt thu quỹ cần gửi nhắc nhở.
- **Quyền hạn:** Chỉ **Quản trị viên nhóm (`ADMIN`)**.
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Đã gửi thông báo nhắc đóng quỹ cho các thành viên chưa nộp",
  "data": null,
  "timestamp": "2026-09-30T15:12:00Z"
}
```

---

### 4.4. Xuất danh sách đóng quỹ ra file CSV (Export Fund Collection to CSV)

Tải về file báo cáo kiểm toán tiến độ đóng quỹ dạng bảng tính CSV (hỗ trợ tiếng Việt UTF-8 BOM, mở trực tiếp bằng Microsoft Excel / Google Sheets).

- **Method:** `GET`
- **Path:** `/funds/{fundId}/export-csv`
- **Full URL:** `https://api.groupspending.xyz/api/v1/funds/{fundId}/export-csv`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Path Parameters:**
  - `fundId` (Long, bắt buộc): ID đợt thu quỹ.
- **Mã phản hồi thành công:** `200 OK`
- **Response Headers:**
  - `Content-Type: text/csv; charset=UTF-8`
  - `Content-Disposition: attachment; filename=fund_collection_{fundId}.csv`
- **Cấu trúc cột trong File CSV xuất ra:**
  `STT, Họ và tên, Email, Trạng thái, Ngày đóng quỹ, Số tiền (VNĐ)`

---

## 5. BẢNG MÃ LỖI (ERROR CODES) & HƯỚNG DẪN XỬ LÝ UI

| HTTP Status | Error Code / Message | Nguyên nhân gây lỗi | Hướng dẫn xử lý trên Mobile UI |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `GROUP_ARCHIVED` | Nhóm chi tiêu đã bị lưu trữ, mọi thao tác tạo/sửa/xóa quỹ đều bị khóa. | Khóa toàn bộ các nút thao tác. Hiển thị thông báo: *"Nhóm đã lưu trữ, không thể chỉnh sửa quỹ."* |
| `400 Bad Request` | `Không thể loại bỏ thành viên đã đóng quỹ ({tên}) khỏi đợt quỹ` | Khi sửa đợt quỹ, Admin bỏ chọn thành viên đã ở trạng thái `PAID`. | Hiển thị Dialog cảnh báo và tự động giữ nguyên dấu tích chọn đối với các thành viên đã nộp tiền. |
| `400 Bad Request` | `Người dùng có ID {id} không phải là thành viên của nhóm` | Gửi ID người dùng không tham gia nhóm trong mảng `memberUserIds`. | Lọc danh sách chọn thành viên tham gia đóng quỹ chặt chẽ theo danh sách thành viên hiện hành của nhóm. |
| `400 Bad Request` | `Danh sách thành viên tham gia đóng quỹ không được để trống` | Gửi mảng `memberUserIds: []` rỗng khi cập nhật đợt quỹ. | Bắt buộc chọn ít nhất 1 thành viên trước khi cho phép bấm *"Lưu thay đổi"*. |
| `400 Bad Request` | `Thành viên không nằm trong danh sách đóng đợt quỹ này` | Admin cố gắng xác nhận nộp tiền cho một người không thuộc danh sách đợt quỹ này. | Reload lại dữ liệu chi tiết đợt quỹ để đồng bộ danh sách mới nhất. |
| `403 Forbidden` | `NOT_GROUP_ADMIN` | Thành viên thông thường cố tình gọi API Tạo, Sửa, Xóa quỹ hoặc Xác nhận thu tiền. | **Ẩn hoàn toàn** nút Tạo quỹ (FAB), nút Sửa, nút Xóa và nút Xác nhận nếu `isGroupAdmin == false`. |
| `403 Forbidden` | `NOT_GROUP_MEMBER` | Tài khoản hiện tại không phải thành viên của nhóm này. | Điều hướng người dùng về màn hình Danh sách nhóm kèm thông báo lỗi. |
| `404 Not Found` | `FUND_COLLECTION_NOT_FOUND` | Đợt thu quỹ không tồn tại hoặc đã bị xóa trước đó. | Thông báo: *"Đợt đóng quỹ không tồn tại hoặc đã bị xóa."*, sau đó tự động trở về danh sách quỹ của nhóm. |
| `404 Not Found` | `GROUP_NOT_FOUND` | ID nhóm truyền lên đường dẫn URL không hợp lệ. | Điều hướng quay lại màn hình chính. |

---

## 6. QUY TẮC TRẢI NGHIỆM NGƯỜI DÙNG (UX GUIDELINES)

1. **Phân quyền giao diện thông minh (Smart Role-Based UI):**
   - Chỉ hiển thị nút Floating Action Button (FAB) **"Tạo đợt quỹ mới"** nếu người dùng là `ADMIN` của nhóm.
   - Trên màn hình Chi tiết đợt quỹ:
     - Nút **"Sửa"**, **"Xóa"**, **"Nhắc đóng quỹ"** và các nút bấm **"Xác nhận đã thu"** cạnh từng thành viên chỉ hiển thị cho Quản trị viên.
     - Thành viên thường chỉ nhìn thấy tiến độ chung, hạn nộp, và trạng thái cá nhân của mình (*"Bạn đã nộp"* hoặc *"Chưa nộp - Vui lòng chuyển khoản cho Admin"*).
2. **Thanh tiến độ trực quan (Visual Fund Progress Indicator):**
   - Sử dụng thanh tiến độ (Progress Bar) kết hợp phần trăm hoàn thành `completionPercentage`.
   - Đổi màu thanh tiến độ linh hoạt:
     - `< 50%`: Màu cam hoặc xanh dương.
     - `50% - 99%`: Màu vàng lục hoặc xanh biển đậm.
     - `100%`: Màu xanh lá cây kèm icon tích xanh hoàn thành.
3. **Debounce cho Tìm kiếm & Chuyển Tabs mượt mà:**
   - Tại màn hình danh sách đợt quỹ, tích hợp Segmented Control / Tabs: **Tất cả**, **Đang thu (`COLLECTING`)**, **Đã xong (`COMPLETED`)**.
   - Đối với ô tìm kiếm tên đợt quỹ, cài đặt khoảng trễ (debounce) `350ms - 400ms` trước khi bắn request để trải nghiệm gõ phím không bị giật lag.
4. **Hộp thoại xác nhận an toàn (Safety Confirmation Dialogs):**
   - **Khi Xóa đợt quỹ:** Bắt buộc hiển thị Pop-up xác nhận cảnh báo:  
     *"Bạn có chắc chắn muốn xóa đợt đóng quỹ này? Mọi dữ liệu về trạng thái nộp tiền của các thành viên sẽ bị xóa vĩnh viễn."*
   - **Khi Xác nhận thu tiền:** Hiển thị Dialog xác nhận tên thành viên và số tiền tương ứng trước khi gửi request để tránh Admin bấm nhầm người.
5. **Cơ chế chống bấm liên tục (Spam Prevention) cho nút "Nhắc đóng quỹ":**
   - Sau khi Admin nhấn nút **"Nhắc đóng quỹ"**, vô hiệu hóa nút và đếm ngược (Cooldown) ít nhất `60 giây` kèm Toast: *"Đã gửi thông báo nhắc nhở tới các thành viên chưa đóng quỹ"* nhằm tránh làm phiền hộp thư thông báo của các thành viên.
