# TÀI LIỆU ĐẶC TẢ TÍCH HỢP API QUẢN LÝ NHÓM (MOBILE)

**Dự án:** Group Spending & Reminder (Quản lý & Nhắc nhở Chi tiêu Nhóm)  
**Phân hệ:** Quản lý nhóm chi tiêu (Group Management)  
**Nền tảng mục tiêu:** Mobile App (iOS / Android / Flutter)  
**Phiên bản tài liệu:** v1.0.0  
**Ngày cập nhật:** 2026-09-26  

---

## MỤC LỤC
1. [Quy chuẩn chung & Định dạng dữ liệu](#1-quy-chuẩn-chung--định-dạng-dữ-liệu)
   - [1.1. Base URL & Authentication](#11-base-url--authentication)
   - [1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)](#12-cấu-trúc-phản-hồi-chung-apiresponse-pattern)
   - [1.3. Bảng Enum dùng chung](#13-bảng-enum-dùng-chung)
2. [Đặc tả chi tiết các API Endpoints](#2-đặc-tả-chi-tiết-các-api-endpoints)
   - [2.1. Lấy danh sách nhóm của người dùng (Get My Groups)](#21-lấy-danh-sách-nhóm-của-người-dùng-get-my-groups)
   - [2.2. Lấy thông tin chi tiết của từng nhóm (Get Group Details)](#22-lấy-thông-tin-chi-tiết-của-từng-nhóm-get-group-details)
   - [2.3. Thêm nhóm mới (Create Group)](#23-thêm-nhóm-mới-create-group)
   - [2.4. Sửa thông tin nhóm (Update Group)](#24-sửa-thông-tin-nhóm-update-group)
   - [2.5. Lưu trữ nhóm (Archive Group)](#25-lưu-trữ-nhóm-archive-group)
   - [2.6. Xóa nhóm chi tiêu (Delete Group)](#26-xóa-nhóm-chi-tiêu-delete-group)
3. [Bảng mã lỗi (Error Codes) & Hướng dẫn xử lý UI](#3-bảng-mã-lỗi-error-codes--hướng-dẫn-xử-lý-ui)
4. [Quy tắc nghiệp vụ & Trải nghiệm người dùng (UX Guidelines)](#4-quy-tắc-nghiệp-vụ--trải-nghiệm-người-dùng-ux-guidelines)

---

## 1. QUY CHUẨN CHUNG & ĐỊNH DẠNG DỮ LIỆU

### 1.1. Base URL & Authentication

- **Base URL Prefix:** `https://api.groupspending.xyz/api/v1` (Production) 
- **Tất cả các API quản lý nhóm đều bắt buộc phải truyền Access Token:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json; charset=UTF-8
  Accept: application/json
  ```

---

### 1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)

Mọi phản hồi từ máy chủ đều tuân theo cấu trúc bao bọc chuẩn:

#### Phản hồi thành công (HTTP 200 OK / 201 Created):
```json
{
  "success": true,
  "message": "Thành công",
  "data": { ... },
  "timestamp": "2026-09-26T11:42:00Z"
}
```

#### Phản hồi thất bại do lỗi nghiệp vụ (HTTP 400 / 403 / 404):
```json
{
  "success": false,
  "message": "Thông điệp mô tả lỗi chi tiết",
  "errors": null,
  "timestamp": "2026-09-26T11:42:00Z"
}
```

#### Phản hồi lỗi dữ liệu đầu vào (HTTP 400 Bad Request - Validation Error):
```json
{
  "success": false,
  "message": "Dữ liệu đầu vào không hợp lệ",
  "errors": {
    "name": "Tên nhóm không được để trống"
  },
  "timestamp": "2026-09-26T11:42:00Z"
}
```

---

### 1.3. Bảng Enum dùng chung

#### `GroupCategory` (Thể loại nhóm)
Chuỗi giá trị gửi lên và trả về (JSON Value):

| Giá trị chuỗi | Ý nghĩa |
| :--- | :--- |
| `Apartment` | Nhóm căn hộ, phòng trọ, sinh hoạt chung |
| `Travel & Trip` | Du lịch, dã ngoại, chuyến đi xa |
| `Sport & Clubs` | Thể thao, câu lạc bộ, giải trí định kỳ |
| `Friends & Dining` | Bạn bè, liên hoan, ăn uống |
| `Works & Project` | Công việc, dự án nhóm |
| `Other` | Thể loại khác (Mặc định khi không chọn) |

#### `GroupFilter` (Bộ lọc danh sách nhóm)

| Enum Key | Mô tả tác vụ lọc |
| :--- | :--- |
| `ALL` | Toàn bộ các nhóm người dùng đang tham gia (Mặc định) |
| `ACTIVE` | Các nhóm đang hoạt động |
| `ARCHIVED` | Các nhóm đã lưu trữ (Read-Only) |
| `ADMIN` | Các nhóm do chính người dùng hiện tại làm Quản trị viên (`ADMIN`) |

#### `GroupStatus` (Trạng thái nhóm)

| Trạng thái | Mô tả |
| :--- | :--- |
| `ACTIVE` | Nhóm đang hoạt động bình thường |
| `ARCHIVED` | Nhóm đã đóng/lưu trữ (Chế độ chỉ đọc, không thể ghi thêm chi tiêu hay chỉnh sửa thông tin) |

#### `GroupMemberRole` (Vai trò thành viên)

| Vai trò | Quyền hạn |
| :--- | :--- |
| `ADMIN` | Quản trị viên nhóm: Có toàn quyền sửa, lưu trữ, xóa nhóm, duyệt thành viên, tạo mã mời |
| `MEMBER` | Thành viên thông thường: Xem thông tin, tạo và chia sẻ chi tiêu |

---

## 2. ĐẶC TẢ CHI TIẾT CÁC API ENDPOINTS

### 2.1. Lấy danh sách nhóm của người dùng (Get My Groups)

Lấy danh sách các nhóm mà người dùng đã tham gia hoặc tạo ra. Hỗ trợ lọc theo trạng thái và tìm kiếm gần đúng theo tên nhóm. Response được tối ưu hóa cho màn hình danh sách (lược bỏ danh sách thành viên `members` và thống kê tổng chi tiêu để giảm tải mạng).

- **Method:** `GET`
- **Path:** `/groups`
- **Full URL:** `/api/v1/groups`
- **Query Parameters:**

| Tên tham số | Kiểu dữ liệu | Bắt buộc | Mặc định | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| `filter` | String (`GroupFilter`) | Không | `ALL` | Bộ lọc nhóm: `ALL`, `ACTIVE`, `ARCHIVED`, `ADMIN` |
| `search` | String | Không | *null* | Chuỗi tìm kiếm gần đúng theo tên nhóm |

- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```

- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Thành công",
  "data": [
    {
      "id": 10,
      "name": "Nhóm bóng đá thứ 6",
      "description": "Tiền sân, tiền nước hàng tuần",
      "defaultCurrency": "VND",
      "category": "Sport & Clubs",
      "inviteCode": "E93KLA",
      "codeExpiredAt": "2026-10-26T08:30:00Z",
      "status": "ACTIVE",
      "ownerId": 1,
      "ownerName": "Nguyễn Văn A",
      "role": "ADMIN",
      "userBalance": 150000,
      "totalSpending": null,
      "totalSpendingVnd": null,
      "totalFundCollected": null,
      "totalFundCollectedVnd": null,
      "memberCount": 6,
      "createdAt": "2026-09-01T08:30:00Z"
    },
    {
      "id": 11,
      "name": "Tiền phòng 301",
      "description": "Điện nước phòng trọ",
      "defaultCurrency": "VND",
      "category": "Apartment",
      "inviteCode": "X78Y2P",
      "codeExpiredAt": "2026-10-15T09:00:00Z",
      "status": "ACTIVE",
      "ownerId": 5,
      "ownerName": "Trần Văn C",
      "role": "MEMBER",
      "userBalance": -85000,
      "totalSpending": null,
      "totalSpendingVnd": null,
      "totalFundCollected": null,
      "totalFundCollectedVnd": null,
      "memberCount": 4,
      "createdAt": "2026-09-05T09:00:00Z"
    }
  ],
  "timestamp": "2026-09-26T11:42:00Z"
}
```

---

### 2.2. Lấy thông tin chi tiết của từng nhóm (Get Group Details)

Lấy toàn bộ thông tin chi tiết của nhóm bao gồm: thông tin cơ bản, vai trò người gọi, số dư cá nhân, tổng quan tài chính (tổng chi tiêu, tổng quỹ thu) và danh sách đầy đủ các thành viên.

- **Method:** `GET`
- **Path:** `/groups/{groupId}`
- **Full URL:** `/api/v1/groups/{groupId}`
- **Path Variables:**

| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `groupId` | Long | Có | ID của nhóm cần xem |

- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```

- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Thành công",
  "data": {
    "id": 10,
    "name": "Nhóm bóng đá thứ 6",
    "description": "Tiền sân, tiền nước hàng tuần",
    "defaultCurrency": "VND",
    "category": "Sport & Clubs",
    "inviteCode": "E93KLA",
    "codeExpiredAt": "2026-10-26T08:30:00Z",
    "status": "ACTIVE",
    "ownerId": 1,
    "ownerName": "Nguyễn Văn A",
    "role": "ADMIN",
    "userBalance": 150000,
    "totalSpending": 1500,
    "totalSpendingVnd": 1500000,
    "totalFundCollected": 500,
    "totalFundCollectedVnd": 500000,
    "memberCount": 2,
    "members": [
      {
        "id": 101,
        "userId": 1,
        "fullName": "Nguyễn Văn A",
        "email": "nguyenvana@gmail.com",
        "avatarUrl": "https://cdn.example.com/avatar/1.jpg",
        "role": "ADMIN",
        "isMuted": false,
        "joinedAt": "2026-09-01T08:30:00Z"
      },
      {
        "id": 102,
        "userId": 2,
        "fullName": "Trần Thị B",
        "email": "tranthib@gmail.com",
        "avatarUrl": null,
        "role": "MEMBER",
        "isMuted": false,
        "joinedAt": "2026-09-02T09:15:00Z"
      }
    ],
    "createdAt": "2026-09-01T08:30:00Z"
  },
  "timestamp": "2026-09-26T11:42:00Z"
}
```

- **Mã lỗi thường gặp:**
  - `403 Forbidden`: `NOT_GROUP_MEMBER` - Người dùng không phải thành viên của nhóm.
  - `404 Not Found`: `GROUP_NOT_FOUND` - Không tìm thấy nhóm.

---

### 2.3. Thêm nhóm mới (Create Group)

Tạo nhóm chi tiêu mới. Người tạo sẽ tự động là Quản trị viên (`ADMIN`) kiêm Chủ nhóm (`Owner`). Hệ thống tự động tạo mã mời (`inviteCode`) có hiệu lực trong 30 ngày.

- **Method:** `POST`
- **Path:** `/groups`
- **Full URL:** `/api/v1/groups`
- **Query Parameters:** (Tùy chọn)
  - `category`: Có thể truyền trực tiếp qua param URL hoặc đặt trong JSON Request Body.
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json
  ```

- **Request Body (JSON):**

| Trường dữ liệu | Kiểu | Bắt buộc | Ràng buộc / Mặc định | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| `name` | String | Có | `@NotBlank`, chuỗi không được để trống | Tên nhóm chi tiêu |
| `description` | String | Không | *null* | Mô tả nhóm |
| `defaultCurrency` | String | Không | Mặc định `"VND"` | Đơn vị tiền tệ |
| `category` | String | Không | Mặc định `"Other"` | Thể loại nhóm (theo bảng `GroupCategory`) |

*Ví dụ Request Body:*
```json
{
  "name": "Chuyến đi Đà Lạt 2026",
  "description": "Chi phí thuê xe và ăn uống",
  "defaultCurrency": "VND",
  "category": "Travel & Trip"
}
```

- **Mã phản hồi thành công:** `201 Created`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Tạo nhóm thành công",
  "data": {
    "id": 15,
    "name": "Chuyến đi Đà Lạt 2026",
    "description": "Chi phí thuê xe và ăn uống",
    "defaultCurrency": "VND",
    "category": "Travel & Trip",
    "inviteCode": "DL2026",
    "codeExpiredAt": "2026-10-26T11:42:00Z",
    "status": "ACTIVE",
    "ownerId": 1,
    "ownerName": "Nguyễn Văn A",
    "role": "ADMIN",
    "userBalance": 0,
    "memberCount": 1,
    "createdAt": "2026-09-26T11:42:00Z"
  },
  "timestamp": "2026-09-26T11:42:00Z"
}
```

- **Mã lỗi thường gặp:**
  - `400 Bad Request`: `Dữ liệu đầu vào không hợp lệ` (trường `name` bị trống hoặc khoảng trắng).

---

### 2.4. Sửa thông tin nhóm (Update Group)

Cập nhật thông tin cơ bản của nhóm: tên, mô tả, đơn vị tiền tệ hoặc thể loại nhóm. Chỉ Quản trị viên (`ADMIN`) của nhóm mới có quyền thực hiện.

- **Method:** `PUT`
- **Path:** `/groups/{groupId}`
- **Full URL:** `/api/v1/groups/{groupId}`
- **Path Variables:**

| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `groupId` | Long | Có | ID của nhóm cần sửa |

- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json
  ```

- **Request Body (JSON):**

| Trường dữ liệu | Kiểu | Bắt buộc | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| `name` | String | Có | `@NotBlank`, không để trống | Tên mới của nhóm |
| `description` | String | Không | Tùy chọn | Mô tả mới của nhóm |
| `defaultCurrency` | String | Không | Tùy chọn | Đơn vị tiền tệ mặc định |
| `category` | String | Không | Tùy chọn | Thể loại nhóm (theo bảng `GroupCategory`) |

*Ví dụ Request Body:*
```json
{
  "name": "Chuyến đi Đà Lạt 2026 (Cập nhật)",
  "description": "Chi phí thuê homestay, xe máy và ăn uống",
  "defaultCurrency": "VND",
  "category": "Travel & Trip"
}
```

- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Cập nhật thông tin nhóm thành công",
  "data": {
    "id": 15,
    "name": "Chuyến đi Đà Lạt 2026 (Cập nhật)",
    "description": "Chi phí thuê homestay, xe máy và ăn uống",
    "defaultCurrency": "VND",
    "category": "Travel & Trip",
    "inviteCode": "DL2026",
    "codeExpiredAt": "2026-10-26T11:42:00Z",
    "status": "ACTIVE",
    "ownerId": 1,
    "ownerName": "Nguyễn Văn A",
    "role": "ADMIN",
    "userBalance": 0,
    "memberCount": 1,
    "createdAt": "2026-09-26T11:42:00Z"
  },
  "timestamp": "2026-09-26T11:45:00Z"
}
```

- **Mã lỗi thường gặp:**
  - `403 Forbidden`: `NOT_GROUP_ADMIN` - Bạn không phải là quản trị viên của nhóm.
  - `400 Bad Request`: `GROUP_ARCHIVED` - Nhóm đã lưu trữ, không thể thực hiện thao tác chỉnh sửa.
  - `404 Not Found`: `GROUP_NOT_FOUND` - Không tìm thấy nhóm.

---

### 2.5. Lưu trữ nhóm (Archive Group)

Chuyển trạng thái hoạt động của nhóm từ `ACTIVE` sang `ARCHIVED`. Sau khi lưu trữ, nhóm trở thành chế độ chỉ xem (Read-Only), không thể tạo thêm hóa đơn chi tiêu, không thể tạo đợt thu quỹ hoặc cập nhật thông tin. Chỉ `ADMIN` của nhóm mới có quyền thực hiện.

- **Method:** `POST`
- **Path:** `/groups/{groupId}/archive`
- **Full URL:** `/api/v1/groups/{groupId}/archive`
- **Path Variables:**

| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `groupId` | Long | Có | ID của nhóm cần lưu trữ |

- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Request Body:** Không có.

- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Nhóm đã được chuyển sang chế độ lưu trữ",
  "data": null,
  "timestamp": "2026-09-26T11:46:00Z"
}
```

- **Mã lỗi thường gặp:**
  - `403 Forbidden`: `NOT_GROUP_ADMIN` - Chỉ quản trị viên mới có quyền thực hiện.
  - `404 Not Found`: `GROUP_NOT_FOUND` - Không tìm thấy nhóm.

---

### 2.6. Xóa nhóm chi tiêu (Delete Group)

Xóa vĩnh viễn nhóm chi tiêu. Hệ thống sẽ tự động dọn dẹp và cascade xóa toàn bộ:
1. Tất cả các khoản nợ của nhóm (`debts`).
2. Toàn bộ các khoản chi tiêu (`expenses`), các phần chia tiền (`splits`) và các bình luận (`comments`).
3. Các danh mục chi tiêu tùy chỉnh riêng của nhóm (`categories`).
4. Toàn bộ quan hệ thành viên trong nhóm (`group_members`).

> **CẢNH BÁO QUAN TRỌNG:** Chỉ duy nhất Người tạo/Sở hữu nhóm (`Owner`) mới có quyền xóa nhóm. Admin được ủy quyền nếu không phải chủ nhóm ban đầu sẽ bị từ chối với lỗi `NOT_GROUP_ADMIN`.

- **Method:** `DELETE`
- **Path:** `/groups/{groupId}`
- **Full URL:** `/api/v1/groups/{groupId}`
- **Path Variables:**

| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `groupId` | Long | Có | ID của nhóm cần xóa |

- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Request Body:** Không có.

- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Xóa nhóm thành công",
  "data": null,
  "timestamp": "2026-09-26T11:47:00Z"
}
```

- **Mã lỗi thường gặp:**
  - `403 Forbidden`: `NOT_GROUP_ADMIN` - Chỉ quản trị viên người tạo nhóm mới có quyền xóa nhóm.
  - `404 Not Found`: `GROUP_NOT_FOUND` - Không tìm thấy nhóm.

---

## 3. BẢNG MÃ LỖI (ERROR CODES) & HƯỚNG DẪN XỬ LÝ UI

| HTTP Status | Error Code | Message mặc định | Nguyên nhân & Hướng dẫn xử lý trên Mobile UI |
| :---: | :--- | :--- | :--- |
| `400` | `GROUP_ARCHIVED` | Nhóm này đã lưu trữ, không thể thực hiện thao tác chỉnh sửa | Xảy ra khi cố gọi API sửa nhóm đối với nhóm đã lưu trữ. Mobile nên disable nút sửa từ trước khi gọi API. |
| `400` | *Validation Error* | Dữ liệu đầu vào không hợp lệ | Đọc dictionary `errors` trong response để hiển thị lỗi validation dưới từng text field tương ứng (ví dụ: ô nhập tên nhóm). |
| `401` | `INVALID_TOKEN` | Token không hợp lệ hoặc đã hết hạn | Hết hạn phiên đăng nhập. Kích hoạt luồng silent refresh token hoặc điều hướng về màn hình đăng nhập. |
| `403` | `NOT_GROUP_MEMBER` | Bạn không phải là thành viên của nhóm này | Người dùng không thuộc nhóm hoặc đã bị xóa khỏi nhóm. Hiển thị thông báo và điều hướng quay lại danh sách nhóm. |
| `403` | `NOT_GROUP_ADMIN` | Chỉ quản trị viên nhóm mới có quyền thực hiện thao tác này | Người dùng là `MEMBER` nhưng cố tình gọi các API quản trị (sửa, lưu trữ, xóa). Cần ẩn các button/menu này đối với `MEMBER`. |
| `404` | `GROUP_NOT_FOUND` | Không tìm thấy nhóm chi tiêu | Nhóm đã bị xóa hoặc `groupId` không tồn tại. Hiển thị Toast/SnackBar và refresh lại danh sách nhóm. |
| `500` | `INTERNAL_SERVER_ERROR` | Đã có lỗi xảy ra trên hệ thống | Lỗi máy chủ không mong muốn. Hiển thị thông báo lỗi thân thiện: *"Có lỗi xảy ra, vui lòng thử lại sau"*. |

---

## 4. QUY TẮC NGHIỆP VỤ & TRẢI NGHIỆM NGƯỜI DÙNG (UX GUIDELINES)

### 4.1. Phân quyền hiển thị theo `role` và `ownerId`
- **Đối với thành viên thường (`role === "MEMBER"`):**
  - Không hiển thị nút/menu *Chỉnh sửa nhóm*, *Lưu trữ nhóm*, *Xóa nhóm*.
  - Chỉ hiển thị tùy chọn *Rời nhóm* (`/groups/{groupId}/leave`).
- **Đối với Quản trị viên (`role === "ADMIN"`):**
  - Hiển thị menu Quản lý nhóm (*Chỉnh sửa*, *Lưu trữ*).
  - Riêng chức năng **Xóa nhóm**: Chỉ hiển thị hoặc cho phép thực hiện nếu `currentUserId === ownerId`.
  - Trước khi gọi API xóa nhóm, Mobile **bắt buộc** phải hiển thị Modal/Dialog cảnh báo đỏ yêu cầu người dùng xác nhận rõ ràng vì hành động này xóa sạch toàn bộ lịch sử chi tiêu và công nợ của nhóm.

### 4.2. Xử lý trạng thái nhóm lưu trữ (`status === "ARCHIVED"`)
- Khi nhóm có trạng thái `ARCHIVED`:
  - Hiển thị nhãn/badge **"Đã lưu trữ"** màu vàng/xám ở góc trên màn hình chi tiết nhóm.
  - Vô hiệu hóa (disable) hoặc ẩn hoàn toàn nút nổi (FAB) *Thêm chi tiêu mới*, nút *Tạo đợt thu quỹ* và nút *Sửa nhóm*.
  - Người dùng trong nhóm vẫn có thể xem danh sách chi tiêu, xem báo cáo tổng kết và xem công nợ ở chế độ Read-Only.

### 4.3. Hiển thị số dư cá nhân (`userBalance`)
- Giá trị trả về là số nguyên (đơn vị VNĐ):
  - `userBalance > 0`: Người dùng đang được nhận lại tiền (ví dụ `+150.000 đ`). Hiển thị màu xanh lá kèm nhãn *"Bạn được nhận"*.
  - `userBalance < 0`: Người dùng đang nợ các thành viên khác (ví dụ `-85.000 đ`). Hiển thị màu cam/đỏ kèm nhãn *"Bạn đang nợ"*.
  - `userBalance === 0`: Người dùng đã cân bằng công nợ. Hiển thị màu xám kèm nhãn *"Đã thanh toán hết"*.

### 4.4. Sử dụng trường dữ liệu tổng tài chính
- Backend cung cấp song song:
  - `totalSpending` (đơn vị: nghìn đồng / k) và `totalSpendingVnd` (đơn vị: VNĐ đầy đủ).
  - `totalFundCollected` (k) và `totalFundCollectedVnd` (VNĐ đầy đủ).
- Khuyến nghị phía Mobile:
  - Nên sử dụng trường có hậu tố `Vnd` (`totalSpendingVnd`, `totalFundCollectedVnd`) để format hiển thị chuẩn hóa theo thư viện tiền tệ bản địa (Locale) của thiết bị (ví dụ: `NumberFormat.currency(locale: 'vi_VN', symbol: '₫')`).
