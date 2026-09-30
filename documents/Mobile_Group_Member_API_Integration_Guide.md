# TÀI LIỆU ĐẶC TẢ TÍCH HỢP API THÀNH VIÊN NHÓM (MOBILE)

**Dự án:** Group Spending & Reminder (Quản lý & Nhắc nhở Chi tiêu Nhóm)  
**Phân hệ:** Quản lý Thành viên Nhóm & Xét duyệt Gia nhập (Group Members Management & Join Requests)  
**Nền tảng mục tiêu:** Mobile App (iOS / Android / Flutter / React Native)  
**Phiên bản tài liệu:** v1.1.0  
**Ngày cập nhật:** 2026-09-30  

---

## MỤC LỤC
1. [Quy chuẩn chung & Định dạng dữ liệu](#1-quy-chuẩn-chung--định-dạng-dữ-liệu)
   - [1.1. Base URL & Authentication](#11-base-url--authentication)
   - [1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)](#12-cấu-trúc-phản-hồi-chung-apiresponse-pattern)
   - [1.3. Bảng Enum dùng chung](#13-bảng-enum-dùng-chung)
   - [1.4. Quy ước tiền tệ & Đơn vị tính](#14-quy-ước-tiền-tệ--đơn-vị-tính)
2. [Mô hình nghiệp vụ & Luồng tương tác (Business Flow)](#2-mô-hình-nghiệp-vụ--luồng-tương-tác-business-flow)
   - [2.1. Ma trận phân quyền thao tác thành viên](#21-ma-trận-phân-quyền-thao-tác-thành-viên)
   - [2.2. Luồng xem danh sách & Tìm kiếm thành viên](#22-luồng-xem-danh-sách--tìm-kiếm-thành-viên)
   - [2.3. Luồng xem chi tiết hồ sơ thành viên](#23-luồng-xem-chi-tiết-hồ-sơ-thành-viên)
   - [2.4. Luồng xóa thành viên khỏi nhóm & Ràng buộc an toàn](#24-luồng-xóa-thành-viên-khỏi-nhóm--ràng-buộc-an-toàn)
   - [2.5. Luồng quản lý & Xét duyệt yêu cầu gia nhập nhóm (Join Request Review Flow)](#25-luồng-quản-lý--xét-duyệt-yêu-cầu-gia-nhập-nhóm-join-request-review-flow)
3. [Đặc tả chi tiết các API Endpoints cốt lõi](#3-đặc-tả-chi-tiết-các-api-endpoints-cốt-lõi)
   - [3.1. Lấy danh sách thành viên trong nhóm (Get Group Members)](#31-lấy-danh-sách-thành-viên-trong-nhóm-get-group-members)
   - [3.2. Xem thông tin chi tiết một thành viên (Get Member Details)](#32-xem-thông-tin-chi-tiết-một-thành-viên-get-member-details)
   - [3.3. Xóa thành viên khỏi nhóm (Remove Member)](#33-xóa-thành-viên-khỏi-nhóm-remove-member)
   - [3.4. Lấy danh sách yêu cầu gia nhập nhóm đang chờ duyệt (Get Pending Join Requests)](#34-lấy-danh-sách-yêu-cầu-gia-nhập-nhóm-đang-chờ-duyệt-get-pending-join-requests)
   - [3.5. Duyệt hoặc Từ chối yêu cầu gia nhập nhóm (Review Join Request)](#35-duyệt-hoặc-từ-chối-yêu-cầu-gia-nhập-nhóm-review-join-request)
4. [Các API bổ trợ liên quan trực tiếp](#4-các-api-bổ-trợ-liên-quan-trực-tiếp)
   - [4.1. Tự rời khỏi nhóm (Leave Group)](#41-tự-rời-khỏi-nhóm-leave-group)
   - [4.2. Chuyển quyền Quản trị viên nhóm (Transfer Ownership)](#42-chuyển-quyền-quản-trị-viên-nhóm-transfer-ownership)
   - [4.3. Bật / Tắt nhận thông báo từ nhóm (Toggle Mute Group)](#43-bật--tắt-nhận-thông-báo-từ-nhóm-toggle-mute-group)
   - [4.4. Tạo mã mời tham gia nhóm (Generate Invite Code)](#44-tạo-mã-mời-tham-gia-nhóm-generate-invite-code)
   - [4.5. Gửi yêu cầu gia nhập nhóm bằng mã mời (Join Group By Code)](#45-gửi-yêu-cầu-gia-nhập-nhóm-bằng-mã-mời-join-group-by-code)
5. [Bảng mã lỗi (Error Codes) & Hướng dẫn xử lý UI](#5-bảng-mã-lỗi-error-codes--hướng-dẫn-xử-lý-ui)
6. [Quy tắc trải nghiệm người dùng & Giao diện (UX Guidelines)](#6-quy-tắc-trải-nghiệm-người-dùng--giao-diện-ux-guidelines)

---

## 1. QUY CHUẨN CHUNG & ĐỊNH DẠNG DỮ LIỆU

### 1.1. Base URL & Authentication

- **Base URL Prefix:** `https://api.groupspending.xyz/api/v1` (Production) hoặc `http://<host>:8080/api/v1` (Development / Local)
- **Tất cả các API phân hệ Thành viên Nhóm đều bắt buộc phải truyền Access Token:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json; charset=UTF-8
  Accept: application/json
  ```

---

### 1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)

Mọi phản hồi từ máy chủ đều tuân theo cấu trúc bao bọc chuẩn (`ApiResponse<T>`):

#### Phản hồi thành công (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Thành công",
  "data": { ... },
  "timestamp": "2026-09-30T14:30:00Z"
}
```

#### Phản hồi thất bại do lỗi nghiệp vụ hoặc phân quyền (HTTP 400 / 403 / 404):
```json
{
  "success": false,
  "message": "Chỉ quản trị viên nhóm mới có quyền thực hiện thao tác này",
  "errors": null,
  "timestamp": "2026-09-30T14:30:00Z"
}
```

---

### 1.3. Bảng Enum dùng chung

#### `GroupMemberRole` (Vai trò thành viên trong nhóm)

| Enum Key | Ý nghĩa hiển thị trên Mobile | Quyền hạn tóm tắt |
| :--- | :--- | :--- |
| `ADMIN` | Quản trị viên (Trưởng nhóm) | Toàn quyền quản trị nhóm: duyệt/từ chối yêu cầu gia nhập, xóa thành viên, tạo đợt thu quỹ, chỉnh sửa/xóa nhóm, chuyển quyền Admin. |
| `MEMBER` | Thành viên thường | Xem thông tin nhóm, xem danh sách thành viên, tạo chi tiêu, xem công nợ cá nhân, tự rời nhóm. |

#### `JoinRequestStatus` (Trạng thái yêu cầu gia nhập nhóm)

| Enum Key | Ý nghĩa hiển thị | Mô tả |
| :--- | :--- | :--- |
| `PENDING` | Chờ duyệt | Người dùng đã gửi yêu cầu tham gia theo mã mời, đang chờ Admin nhóm xem xét. |
| `APPROVED` | Đã duyệt | Admin đã chấp thuận. Người dùng chính thức trở thành thành viên nhóm (`MEMBER`). |
| `REJECTED` | Đã từ chối | Admin đã từ chối yêu cầu gia nhập. Người dùng không được vào nhóm. |

---

### 1.4. Quy ước tiền tệ & Đơn vị tính

Trong thông tin chi tiết thành viên, dữ liệu tài chính (công nợ, số dư, tiền chi tiêu) được cung cấp song song:
1. **Đơn vị rút gọn (`k` / Nghìn VNĐ):** Các trường `debtAmount`, `receivableAmount`, `netBalance`, `amount`, `myAmountOwed`. Ví dụ: `150` tương ứng `150.000 VNĐ`.
2. **Đơn vị đầy đủ (`VNĐ`):** Các trường có hậu tố `Vnd` như `debtAmountVnd`, `receivableAmountVnd`, `netBalanceVnd`, `amountVnd`, `myAmountOwedVnd`. Ví dụ: `150000`.
3. **Khuyến nghị cho Mobile:** Luôn ưu tiên dùng các trường có hậu tố `Vnd` để format hiển thị bản địa hóa chuẩn xác theo đơn vị tiền tệ (`150.000 ₫`).

---

## 2. MÔ HÌNH NGHIỆP VỤ & LUỒNG TƯƠNG TÁC (BUSINESS FLOW)

### 2.1. Ma trận phân quyền thao tác thành viên

| Thao tác trên Mobile | Quản trị viên (`ADMIN`) | Thành viên thường (`MEMBER`) | Người ngoài nhóm |
| :--- | :---: | :---: | :---: |
| Xem danh sách thành viên nhóm | Cho phép | Cho phép | Bị từ chối (`403 NOT_GROUP_MEMBER`) |
| Tìm kiếm thành viên theo tên | Cho phép | Cho phép | Bị từ chối (`403 NOT_GROUP_MEMBER`) |
| Xem chi tiết thông tin thành viên khác | Cho phép | Cho phép | Bị từ chối (`403 NOT_GROUP_MEMBER`) |
| Xóa thành viên thường khỏi nhóm | Cho phép | Bị từ chối (`403 NOT_GROUP_ADMIN`) | Bị từ chối (`403 NOT_GROUP_MEMBER`) |
| Xem danh sách yêu cầu gia nhập nhóm | Cho phép | Bị từ chối (`403 NOT_GROUP_ADMIN`) | Bị từ chối (`403 NOT_GROUP_ADMIN`) |
| Duyệt / Từ chối yêu cầu gia nhập | Cho phép | Bị từ chối (`403 NOT_GROUP_ADMIN`) | Bị từ chối (`403 NOT_GROUP_ADMIN`) |
| Tự xóa chính mình khỏi nhóm qua API xóa | Bị chặn (`400 Bad Request`) | Không có quyền gọi API xóa | Không có quyền |
| Tự rời nhóm (`leaveGroup`) | Cần chuyển quyền nếu còn người | Cho phép | Bị từ chối |
| Chuyển quyền Quản trị viên | Cho phép | Bị từ chối (`403 NOT_GROUP_ADMIN`) | Bị từ chối |

---

### 2.2. Luồng xem danh sách & Tìm kiếm thành viên

1. Người dùng mở màn hình **"Thành viên nhóm"** từ màn hình chi tiết nhóm.
2. Mobile gửi request `GET /api/v1/groups/{groupId}/members` để lấy toàn bộ danh sách thành viên rút gọn.
3. Người dùng nhập từ khóa vào ô tìm kiếm:
   - Mobile áp dụng cơ chế **Debounce** (khuyến nghị 300ms - 400ms) trước khi gọi API.
   - Gửi request `GET /api/v1/groups/{groupId}/members?name={keyword}`.
   - Hiển thị kết quả tìm kiếm tức thời trên danh sách. Khi xóa trắng ô tìm kiếm, tự động gọi lại API không truyền `name` để tải lại toàn bộ danh sách.

---

### 2.3. Luồng xem chi tiết hồ sơ thành viên

1. Từ danh sách thành viên, người dùng nhấn chọn một thành viên bất kỳ (`targetUserId`).
2. Mobile điều hướng sang màn hình **"Chi tiết thành viên"** và gọi `GET /api/v1/groups/{groupId}/members/{targetUserId}`.
3. Màn hình chi tiết hiển thị 4 khối thông tin quan trọng:
   - **Hồ sơ cá nhân & Liên hệ:** Tên, Avatar, Vai trò (`ADMIN`/`MEMBER`), Ngày tham gia, Email, Số điện thoại.
   - **Tài khoản thụ hưởng:** Tên ngân hàng, Số tài khoản, Tên chủ tài khoản (hỗ trợ nút sao chép nhanh số tài khoản để phục vụ chuyển khoản trả nợ).
   - **Tình hình tài chính trong nhóm:**
     - Đang nợ (`debtAmountVnd`), Được nhận lại (`receivableAmountVnd`), Số dư ròng (`netBalanceVnd`).
     - Tỷ lệ hoàn tất tất toán công nợ (`debtSettlementRate` %).
     - Tỷ lệ hoàn thành đóng quỹ nhóm đúng hạn (`fundContributionOnTimeRate` %).
   - **Danh sách chi tiêu đã tham gia:** Danh sách các khoản chi tiêu có mặt thành viên này kèm theo số tiền thành viên này chịu (`myAmountOwedVnd`) và nhãn người thanh toán (`isPaidByMember`).

---

### 2.4. Luồng xóa thành viên khỏi nhóm & Ràng buộc an toàn

1. **Điều kiện hiển thị:**
   - Người dùng hiện tại (`currentUserId`) phải là `ADMIN` của nhóm.
   - Thành viên mục tiêu (`targetUserId`) phải có `role === "MEMBER"`.
   - **Không hiển thị** nút xóa trên dòng của chính Admin (`currentUserId === targetUserId`).
2. **Kiểm tra công nợ trước khi xóa (Best Practice UX):**
   - Khi Admin nhấn nút "Xóa khỏi nhóm", Mobile nên kiểm tra thông tin số dư ròng `netBalance` của thành viên:
     - Nếu thành viên đang nợ tiền nhóm (`debtAmount > 0`): Hiển thị Dialog cảnh báo màu cam: *"Thành viên này hiện còn khoản nợ chưa tất toán ([Số tiền nợ]). Bạn có chắc chắn muốn xóa thành viên khỏi nhóm?"*.
     - Nếu người khác đang nợ thành viên này (`receivableAmount > 0`): Hiển thị Dialog cảnh báo: *"Thành viên này hiện đang có khoản tiền chưa được nhận lại ([Số tiền]). Bạn có chắc chắn muốn tiếp tục?"*.
3. **Thực thi xóa:**
   - Admin xác nhận -> Mobile gửi `DELETE /api/v1/groups/{groupId}/members/{targetUserId}`.
   - Khi nhận phản hồi thành công (`200 OK`):
     - Hiển thị Toast/SnackBar thông báo: *"Đã xóa thành viên khỏi nhóm"*.
     - Xóa item thành viên khỏi danh sách cục bộ hoặc gọi lại API danh sách thành viên để đồng bộ dữ liệu.
     - Cập nhật lại số lượng thành viên hiển thị trên màn hình tổng quan nhóm.

---

### 2.5. Luồng quản lý & Xét duyệt yêu cầu gia nhập nhóm (Join Request Review Flow)

```
[Người dùng ngoài nhóm]                    [Admin nhóm]
         │                                       │
  Nhập mã mời & Gửi yêu cầu                      │
  (POST /groups/join)                            │
         │──────────────────────────────────────>│ Nhận Push Notification (FCM)
         │                                       │ "Yêu cầu tham gia nhóm"
         │                                       │
         │                                 Mở màn hình "Yêu cầu chờ duyệt"
         │                                 (GET /groups/{groupId}/join-requests)
         │                                       │
         │                                 Admin chọn Duyệt hoặc Từ chối:
         │                                 (POST /groups/join-requests/{id}/review)
         │                                 - approved: true / false
         │                                 - includePastFundCollections: true / false
         │                                       │
         │<──────────────────────────────────────┤
  Nhận Push Notification (FCM)
  "Bạn đã được duyệt vào nhóm..."
  (nếu approved == true)
```

1. **Tiếp nhận yêu cầu:** Khi người dùng ngoài nhóm nhập mã mời để gửi yêu cầu gia nhập, hệ thống tạo một bản ghi `JoinRequest` ở trạng thái `PENDING` và tự động gửi thông báo đẩy (Push Notification) đến thiết bị của Admin nhóm.
2. **Hiển thị huy hiệu (Badge):** Khi Admin mở màn hình quản lý nhóm, nếu có yêu cầu gia nhập đang chờ duyệt (`totalRequests > 0`), Mobile hiển thị badge số đếm màu đỏ bên cạnh mục "Yêu cầu gia nhập" hoặc tab "Thành viên".
3. **Admin xét duyệt:**
   - **Trường hợp Chấp thuận (`approved: true`):**
     - Thành viên được tạo mới trong bảng thành viên nhóm (`GroupMember`) với vai trò `MEMBER`.
     - **Tùy chọn truy thu quỹ cũ (`includePastFundCollections: true`):** Nếu Admin bật tùy chọn này, hệ thống sẽ tự động thêm thành viên mới vào danh sách phải đóng của tất cả các đợt thu quỹ (`FundCollection`) trước đây của nhóm với trạng thái `PENDING`. Nếu Admin để `false`, thành viên chỉ tham gia các đợt quỹ tạo mới sau này.
     - Hệ thống ghi nhật ký hoạt động nhóm `MEMBER_JOINED` và gửi thông báo FCM chúc mừng đến thành viên mới.
   - **Trường hợp Từ chối (`approved: false`):**
     - Yêu cầu được đổi trạng thái thành `REJECTED`. Người dùng này không được thêm vào nhóm.

---

## 3. ĐẶC TẢ CHI TIẾT CÁC API ENDPOINTS CỐT LÕI

### 3.1. Lấy danh sách thành viên trong nhóm (Get Group Members)

Lấy danh sách thành viên rút gọn theo từng nhóm chi tiêu. Người gọi bắt buộc phải là thành viên trong nhóm. Hỗ trợ tìm kiếm gần đúng theo họ và tên thành viên.

- **HTTP Method:** `GET`
- **Path:** `/groups/{groupId}/members`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/members`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```

#### Path Variables:
| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :---: | :--- |
| `groupId` | Long | Có | ID của nhóm cần lấy danh sách thành viên (Ví dụ: `10`) |

#### Query Parameters:
| Tham số | Kiểu dữ liệu | Bắt buộc | Mặc định | Mô tả |
| :--- | :--- | :---: | :---: | :--- |
| `name` | String | Không | *null* | Ô nhập tìm kiếm gần đúng theo tên thành viên (không phân biệt chữ hoa, chữ thường). Ví dụ: `nguyen`, `Anh` |

#### Phản hồi thành công (`200 OK`):
```json
{
  "success": true,
  "message": "Thành công",
  "data": [
    {
      "userId": 1,
      "fullName": "Nguyễn Văn Admin",
      "role": "ADMIN",
      "avatarUrl": "https://cdn.example.com/avatar/user1.jpg"
    },
    {
      "userId": 2,
      "fullName": "Trần Thị Bích",
      "role": "MEMBER",
      "avatarUrl": "https://cdn.example.com/avatar/user2.jpg"
    },
    {
      "userId": 3,
      "fullName": "Lê Hoàng Nam",
      "role": "MEMBER",
      "avatarUrl": null
    }
  ],
  "timestamp": "2026-09-30T14:31:00Z"
}
```

#### Chi tiết các trường dữ liệu trong mảng `data`:
| Trường dữ liệu | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `userId` | Long | ID duy nhất của người dùng |
| `fullName` | String | Họ và tên hiển thị của thành viên |
| `role` | String | Vai trò trong nhóm: `ADMIN` (Quản trị viên) hoặc `MEMBER` (Thành viên thường) |
| `avatarUrl` | String \| null | Đường dẫn ảnh đại diện. Nếu `null`, Mobile hiển thị avatar mặc định theo ký tự đầu của tên |

#### Các mã lỗi thường gặp:
- `401 Unauthorized`: Token không hợp lệ hoặc đã hết hạn (`INVALID_TOKEN`).
- `403 Forbidden`: `NOT_GROUP_MEMBER` - Người dùng không phải là thành viên trong nhóm này.
- `404 Not Found`: `GROUP_NOT_FOUND` - Nhóm không tồn tại hoặc đã bị xóa.

---

### 3.2. Xem thông tin chi tiết một thành viên (Get Member Details)

Lấy toàn bộ hồ sơ chi tiết của một thành viên trong nhóm, bao gồm thông tin cá nhân, thông tin chuyển khoản ngân hàng, toàn cảnh công nợ hiện tại, các tỷ lệ hoàn thành nghĩa vụ tài chính và danh sách tất cả các khoản chi tiêu đã tham gia.

- **HTTP Method:** `GET`
- **Path:** `/groups/{groupId}/members/{targetUserId}`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/members/{targetUserId}`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```

#### Path Variables:
| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :---: | :--- |
| `groupId` | Long | Có | ID của nhóm chi tiêu (Ví dụ: `10`) |
| `targetUserId` | Long | Có | ID của thành viên cần xem hồ sơ chi tiết (Ví dụ: `2`) |

#### Phản hồi thành công (`200 OK`):
```json
{
  "success": true,
  "message": "Thành công",
  "data": {
    "userId": 2,
    "fullName": "Trần Thị Bích",
    "avatarUrl": "https://cdn.example.com/avatar/user2.jpg",
    "role": "MEMBER",
    "joinedAt": "2026-09-01T08:30:00Z",
    "groupId": 10,
    "groupName": "Chuyến đi Đà Lạt 2026",
    "email": "bich.tran@example.com",
    "phone": "0987654321",
    "bankName": "MB Bank",
    "bankAccountNumber": "098765432101",
    "bankAccountName": "TRAN THI BICH",
    "debtAmount": 150,
    "debtAmountVnd": 150000,
    "receivableAmount": 300,
    "receivableAmountVnd": 300000,
    "netBalance": 150,
    "netBalanceVnd": 150000,
    "debtSettlementRate": 85.5,
    "fundContributionOnTimeRate": 100.0,
    "participatedExpenseCount": 2,
    "participatedExpenses": [
      {
        "expenseId": 101,
        "title": "Ăn tối lẩu gà lá é",
        "amount": 600,
        "amountVnd": 600000,
        "myAmountOwed": 150,
        "myAmountOwedVnd": 150000,
        "isPaidByMember": false,
        "expenseDate": "2026-09-28",
        "categoryName": "Ăn uống",
        "categoryIcon": "restaurant"
      },
      {
        "expenseId": 98,
        "title": "Thuê xe máy 3 ngày",
        "amount": 450,
        "amountVnd": 450000,
        "myAmountOwed": 150,
        "myAmountOwedVnd": 150000,
        "isPaidByMember": true,
        "expenseDate": "2026-09-26",
        "categoryName": "Đi lại",
        "categoryIcon": "two_wheeler"
      }
    ]
  },
  "timestamp": "2026-09-30T14:32:00Z"
}
```

#### Chi tiết các trường dữ liệu trong đối tượng `data`:

| Phân nhóm dữ liệu | Tên trường | Kiểu dữ liệu | Ý nghĩa & Hướng dẫn hiển thị |
| :--- | :--- | :--- | :--- |
| **Cơ bản & Nhóm** | `userId` | Long | ID người dùng |
| | `fullName` | String | Họ và tên |
| | `avatarUrl` | String \| null | Link ảnh đại diện |
| | `role` | String | `ADMIN` hoặc `MEMBER` |
| | `joinedAt` | Instant | Thời điểm gia nhập nhóm (ISO-8601 UTC) |
| | `groupId` | Long | ID của nhóm |
| | `groupName` | String | Tên nhóm chi tiêu |
| **Liên hệ & Ngân hàng** | `email` | String | Email cá nhân của thành viên |
| | `phone` | String \| null | Số điện thoại liên hệ |
| | `bankName` | String \| null | Tên ngân hàng thụ hưởng |
| | `bankAccountNumber` | String \| null | Số tài khoản ngân hàng |
| | `bankAccountName` | String \| null | Tên chủ tài khoản (viết hoa không dấu) |
| **Tình hình tài chính** | `debtAmount` | Long | Số tiền thành viên đang nợ người khác trong nhóm (đơn vị: k) |
| | `debtAmountVnd` | Long | Số tiền đang nợ quy đổi VNĐ đầy đủ (VNĐ) |
| | `receivableAmount` | Long | Số tiền người khác đang nợ thành viên này (đơn vị: k) |
| | `receivableAmountVnd` | Long | Số tiền được nhận quy đổi VNĐ đầy đủ (VNĐ) |
| | `netBalance` | Long | Số dư ròng công nợ (`receivableAmount - debtAmount`, đơn vị: k) |
| | `netBalanceVnd` | Long | Số dư ròng quy đổi đầy đủ VNĐ |
| **Chỉ số đánh giá** | `debtSettlementRate` | Double | Tỷ lệ tất toán công nợ (0.0 - 100.0%) |
| | `fundContributionOnTimeRate`| Double | Tỷ lệ đóng quỹ nhóm đúng thời hạn (0.0 - 100.0%) |
| **Khoản chi tham gia** | `participatedExpenseCount` | Integer | Tổng số khoản chi thành viên đã tham gia |
| | `participatedExpenses` | Array | Mảng danh sách các khoản chi tiêu chi tiết |

#### Chi tiết từng phần tử trong `participatedExpenses`:
| Tên trường | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `expenseId` | Long | ID của khoản chi tiêu |
| `title` | String | Tên khoản chi |
| `amount` | Long | Tổng tiền của cả hóa đơn chi tiêu (đơn vị: k) |
| `amountVnd` | Long | Tổng tiền hóa đơn chi tiêu (đơn vị: VNĐ) |
| `myAmountOwed` | Long | Phần tiền thành viên này phải chịu/gánh trong khoản chi (đơn vị: k) |
| `myAmountOwedVnd` | Long | Phần tiền thành viên này phải chịu (đơn vị: VNĐ) |
| `isPaidByMember` | Boolean | `true` nếu thành viên này là người ứng tiền thanh toán hóa đơn |
| `expenseDate` | String | Ngày phát sinh chi tiêu (định dạng `YYYY-MM-DD`) |
| `categoryName` | String | Tên danh mục chi tiêu (ví dụ: "Ăn uống", "Đi lại") |
| `categoryIcon` | String | Mã icon Material / Lucide của danh mục |

#### Các mã lỗi thường gặp:
- `401 Unauthorized`: Token không hợp lệ hoặc đã hết hạn (`INVALID_TOKEN`).
- `403 Forbidden`: `NOT_GROUP_MEMBER` - Người gọi API không phải là thành viên trong nhóm.
- `404 Not Found`: `GROUP_NOT_FOUND` - Nhóm không tồn tại.
- `404 Not Found`: `USER_NOT_FOUND` - Thành viên chỉ định (`targetUserId`) không thuộc nhóm này.

---

### 3.3. Xóa thành viên khỏi nhóm (Remove Member)

Quản trị viên nhóm (`ADMIN`) thực hiện xóa một thành viên thường (`MEMBER`) ra khỏi nhóm chi tiêu. Khi thực hiện thành công, quan hệ thành viên bị xóa bỏ và hệ thống ghi lại nhật ký hoạt động nhóm (`REMOVE_MEMBER`).

- **HTTP Method:** `DELETE`
- **Path:** `/groups/{groupId}/members/{targetUserId}`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/members/{targetUserId}`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```

#### Path Variables:
| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :---: | :--- |
| `groupId` | Long | Có | ID của nhóm chi tiêu (Ví dụ: `10`) |
| `targetUserId` | Long | Có | ID của thành viên cần xóa khỏi nhóm (Ví dụ: `2`) |

#### Phản hồi thành công (`200 OK`):
```json
{
  "success": true,
  "message": "Đã xóa thành viên khỏi nhóm",
  "data": null,
  "timestamp": "2026-09-30T14:35:00Z"
}
```

#### Các mã lỗi thường gặp:
| HTTP Status | Error Code / Message | Nguyên nhân cụ thể |
| :---: | :--- | :--- |
| `400` | `Admin không thể tự xóa chính mình khỏi nhóm` | Xảy ra khi Admin truyền `targetUserId` trùng với ID của chính mình. |
| `400` | `Thành viên không tồn tại trong nhóm` | `targetUserId` không phải là thành viên hiện tại của nhóm này. |
| `400` | `GROUP_ARCHIVED` | Nhóm đã ở trạng thái lưu trữ (Archived), không thể chỉnh sửa thành viên. |
| `401` | `INVALID_TOKEN` | Token hết hạn hoặc không hợp lệ. |
| `403` | `NOT_GROUP_ADMIN` | Người thực hiện thao tác không phải là Quản trị viên nhóm. |
| `404` | `GROUP_NOT_FOUND` | Nhóm không tồn tại hoặc đã bị xóa. |

---

### 3.4. Lấy danh sách yêu cầu gia nhập nhóm đang chờ duyệt (Get Pending Join Requests)

Lấy tổng số lượng và danh sách chi tiết các yêu cầu gia nhập nhóm đang ở trạng thái chờ duyệt (`PENDING`). Chỉ Quản trị viên (`ADMIN`) của nhóm mới có quyền gọi API này.

- **HTTP Method:** `GET`
- **Path:** `/groups/{groupId}/join-requests`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/join-requests`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```

#### Path Variables:
| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :---: | :--- |
| `groupId` | Long | Có | ID của nhóm cần xem danh sách yêu cầu gia nhập (Ví dụ: `10`) |

#### Phản hồi thành công (`200 OK`):
```json
{
  "success": true,
  "message": "Thành công",
  "data": {
    "groupId": 10,
    "totalRequests": 2,
    "requests": [
      {
        "id": 1,
        "groupId": 10,
        "groupName": "Chuyến đi Đà Lạt 2026",
        "userId": 5,
        "userFullName": "Phạm Quốc Huy",
        "userEmail": "huy.pham@example.com",
        "userAvatarUrl": "https://cdn.example.com/avatar/user5.jpg",
        "status": "PENDING",
        "requestedAt": "2026-09-30T10:00:00Z",
        "reviewedAt": null
      },
      {
        "id": 2,
        "groupId": 10,
        "groupName": "Chuyến đi Đà Lạt 2026",
        "userId": 6,
        "userFullName": "Đỗ Hoàng Lan",
        "userEmail": "lan.do@example.com",
        "userAvatarUrl": null,
        "status": "PENDING",
        "requestedAt": "2026-09-30T11:20:00Z",
        "reviewedAt": null
      }
    ]
  },
  "timestamp": "2026-09-30T14:40:00Z"
}
```

#### Chi tiết các trường dữ liệu trả về:
| Tên trường | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `groupId` | Long | ID của nhóm chi tiêu |
| `totalRequests` | Long | Tổng số lượng yêu cầu gia nhập đang ở trạng thái `PENDING` (dùng hiển thị Badge số đếm trên UI) |
| `requests` | Array | Danh sách chi tiết các yêu cầu gia nhập |
| `requests[i].id` | Long | **ID của yêu cầu gia nhập** (sử dụng giá trị này làm `requestId` khi gọi API xét duyệt 3.5) |
| `requests[i].userId` | Long | ID người dùng đang gửi yêu cầu |
| `requests[i].userFullName` | String | Họ và tên người xin vào nhóm |
| `requests[i].userEmail` | String | Email tài khoản của người xin vào nhóm |
| `requests[i].userAvatarUrl`| String \| null | Ảnh đại diện của người xin vào nhóm |
| `requests[i].status` | String | Trạng thái yêu cầu: luôn là `PENDING` |
| `requests[i].requestedAt` | Instant | Thời điểm gửi yêu cầu (ISO-8601 UTC) |
| `requests[i].reviewedAt` | Instant \| null | Thời điểm xét duyệt (`null` đối với yêu cầu đang chờ) |

#### Các mã lỗi thường gặp:
- `401 Unauthorized`: Token không hợp lệ hoặc đã hết hạn (`INVALID_TOKEN`).
- `403 Forbidden`: `NOT_GROUP_ADMIN` - Người dùng không phải là Quản trị viên của nhóm này.
- `404 Not Found`: `GROUP_NOT_FOUND` - Nhóm không tồn tại hoặc đã bị xóa.

---

### 3.5. Duyệt hoặc Từ chối yêu cầu gia nhập nhóm (Review Join Request)

Quản trị viên (`ADMIN`) thực hiện chấp thuận (`approved: true`) hoặc từ chối (`approved: false`) một yêu cầu gia nhập nhóm.

- **HTTP Method:** `POST`
- **Path:** `/groups/join-requests/{requestId}/review`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/join-requests/{requestId}/review`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json; charset=UTF-8
  Accept: application/json
  ```

#### Path Variables:
| Tên biến | Kiểu dữ liệu | Bắt buộc | Mô tả |
| :--- | :--- | :---: | :--- |
| `requestId` | Long | Có | ID của yêu cầu gia nhập (lấy từ trường `id` trong danh sách yêu cầu gia nhập ở mục 3.4) |

#### Request Body:

##### Trường hợp 1: Chấp thuận duyệt thành viên vào nhóm (Approved)
```json
{
  "approved": true,
  "includePastFundCollections": false
}
```

##### Trường hợp 2: Chấp thuận duyệt và ĐỒNG THỜI truy thu các đợt quỹ cũ đang mở
```json
{
  "approved": true,
  "includePastFundCollections": true
}
```

##### Trường hợp 3: Từ chối yêu cầu gia nhập nhóm (Rejected)
```json
{
  "approved": false
}
```

#### Chi tiết các trường trong Request Body:
| Trường | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa & Hướng dẫn sử dụng |
| :--- | :--- | :---: | :---: | :--- |
| `approved` | Boolean | **Có** | - | `true`: Chấp thuận cho thành viên vào nhóm. <br>`false`: Từ chối yêu cầu gia nhập. |
| `includePastFundCollections` | Boolean | Không | `false` | *Chỉ có tác dụng khi `approved: true`.* <br>- Nếu `true`: Hệ thống tự động thêm thành viên mới vào danh sách đóng của **tất cả các đợt quỹ trước đây** của nhóm với trạng thái `PENDING`. <br>- Nếu `false`: Thành viên chỉ bắt đầu tham gia các đợt quỹ mới sau này. |

#### Phản hồi thành công (`200 OK`):
```json
{
  "success": true,
  "message": "Đã xử lý yêu cầu gia nhập nhóm",
  "data": null,
  "timestamp": "2026-09-30T14:42:00Z"
}
```

#### Hành vi hệ thống sau khi duyệt thành công:
1. Bản ghi `JoinRequest` được cập nhật `status = APPROVED` (hoặc `REJECTED`), `reviewedAt = now()`.
2. Nếu `approved: true`:
   - Tạo mới bản ghi `GroupMember` với `role = MEMBER`, `isMuted = false`.
   - Nếu `includePastFundCollections: true`: Duyệt toàn bộ các `FundCollection` trước đây của nhóm và tạo `FundCollectionMember` trạng thái `PENDING`.
   - Ghi nhật ký nhóm: `MEMBER_JOINED` - *"Đã duyệt thành viên mới: [Tên thành viên]"*.
   - Gửi Push Notification (FCM) đến điện thoại của người được duyệt: *"Tham gia nhóm thành công: Bạn đã được duyệt vào nhóm [Tên nhóm]"*.

#### Các mã lỗi thường gặp:
| HTTP Status | Error Code / Message | Nguyên nhân cụ thể |
| :---: | :--- | :--- |
| `400` | `Dữ liệu đầu vào không hợp lệ` | Không truyền trường `approved` hoặc truyền sai kiểu dữ liệu. |
| `400` | `GROUP_ARCHIVED` | Nhóm chi tiêu này đã ở chế độ lưu trữ (Archived), không thể duyệt thêm người. |
| `401` | `INVALID_TOKEN` | Token hết hạn hoặc không hợp lệ. |
| `403` | `NOT_GROUP_ADMIN` | Người thực hiện không phải là Quản trị viên của nhóm này. |
| `404` | `JOIN_REQUEST_NOT_FOUND` | Không tìm thấy yêu cầu gia nhập với `requestId` tương ứng. |

---

## 4. CÁC API BỔ TRỢ LIÊN QUAN TRỰC TIẾP

Để hỗ trợ đầy đủ toàn bộ vòng đời thành viên trên ứng dụng Mobile, dưới đây là các API liên đới mật thiết:

### 4.1. Tự rời khỏi nhóm (Leave Group)

Dành cho bản thân người dùng muốn chủ động rời khỏi nhóm chi tiêu.

- **HTTP Method:** `POST`
- **Path:** `/groups/{groupId}/leave`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/leave`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Ràng buộc nghiệp vụ quan trọng:**
  - Nếu người rời nhóm là **Quản trị viên duy nhất (`ADMIN`)** và nhóm **vẫn còn các thành viên khác (`memberCount > 1`)**, hệ thống sẽ từ chối với lỗi:  
    `400 Bad Request`: `CANNOT_LEAVE_AS_ONLY_ADMIN` (*"Admin không thể rời nhóm khi còn thành viên khác. Vui lòng chuyển quyền Admin trước."*).  
    -> Phía Mobile cần điều hướng Admin sang màn hình **Chuyển quyền Admin** trước khi cho phép rời nhóm.
- **Phản hồi thành công (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Đã rời khỏi nhóm thành công",
    "data": null,
    "timestamp": "2026-09-30T14:36:00Z"
  }
  ```

---

### 4.2. Chuyển quyền Quản trị viên nhóm (Transfer Ownership)

Cho phép Quản trị viên hiện tại bàn giao quyền Trưởng nhóm cho một thành viên khác trong nhóm. Sau khi chuyển quyền thành công, Quản trị viên cũ sẽ trở thành `MEMBER` và người được chọn trở thành `ADMIN`.

- **HTTP Method:** `POST`
- **Path:** `/groups/{groupId}/transfer-ownership`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/transfer-ownership`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  Content-Type: application/json
  ```
- **Request Body:**
  ```json
  {
    "newOwnerId": 2
  }
  ```
- **Phản hồi thành công (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Chuyển quyền Admin nhóm thành công",
    "data": null,
    "timestamp": "2026-09-30T14:37:00Z"
  }
  ```

---

### 4.3. Bật / Tắt nhận thông báo từ nhóm (Toggle Mute Group)

Cho phép thành viên bật hoặc tắt thông báo (Push Notification) từ nhóm này mà không làm ảnh hưởng đến các thành viên khác.

- **HTTP Method:** `PATCH`
- **Path:** `/groups/{groupId}/mute`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/mute`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Phản hồi thành công (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Đã cập nhật cài đặt thông báo cho nhóm",
    "data": null,
    "timestamp": "2026-09-30T14:38:00Z"
  }
  ```

---

### 4.4. Tạo mã mời tham gia nhóm (Generate Invite Code)

Cho phép Quản trị viên tạo hoặc làm mới mã mời (Invite Code 8 ký tự) để gửi cho bạn bè tham gia nhóm.

- **HTTP Method:** `POST`
- **Path:** `/groups/{groupId}/invite-code`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/invite-code`
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Phản hồi thành công (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Tạo mã mời mới thành công",
    "data": {
      "inviteCode": "A8X2B9K1"
    },
    "timestamp": "2026-09-30T14:43:00Z"
  }
  ```

---

### 4.5. Gửi yêu cầu gia nhập nhóm bằng mã mời (Join Group By Code)

Dành cho người dùng bên ngoài nhập mã mời để gửi yêu cầu xin gia nhập nhóm chi tiêu.

- **HTTP Method:** `POST`
- **Path:** `/groups/join`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/join?inviteCode={code}`
- **Query Parameter:**
  - `inviteCode` (`String`, bắt buộc): Mã mời 8 ký tự.
- **Headers:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Phản hồi thành công (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Đã gửi yêu cầu tham gia nhóm, vui lòng chờ Admin duyệt",
    "data": {
      "id": 15,
      "groupId": 10,
      "groupName": "Chuyến đi Đà Lạt 2026",
      "userId": 7,
      "userFullName": "Lê Văn C",
      "userEmail": "c@example.com",
      "userAvatarUrl": null,
      "status": "PENDING",
      "requestedAt": "2026-09-30T14:44:00Z",
      "reviewedAt": null
    },
    "timestamp": "2026-09-30T14:44:00Z"
  }
  ```

---

## 5. BẢNG MÃ LỖI (ERROR CODES) & HƯỚNG DẪN XỬ LÝ UI

| HTTP Status | Error Code / Message | Ý nghĩa nghiệp vụ | Hướng dẫn xử lý hiển thị trên Mobile UI |
| :---: | :--- | :--- | :--- |
| `400` | `Admin không thể tự xóa chính mình khỏi nhóm` | Admin bấm nhầm nút xóa chính mình | Hiển thị Dialog thông báo: *"Bạn là Quản trị viên, không thể tự xóa chính mình. Nếu muốn rời nhóm, vui lòng chọn tính năng Rời nhóm."* |
| `400` | `Thành viên không tồn tại trong nhóm` | Người dùng đã rời nhóm hoặc bị xóa trước đó | Tải lại danh sách thành viên (`Get Group Members`) để làm mới UI. |
| `400` | `GROUP_ARCHIVED` | Nhóm đã chuyển sang chế độ lưu trữ | Vô hiệu hóa nút xóa và duyệt thành viên; thông báo nhóm đang ở chế độ Chỉ đọc. |
| `400` | `CANNOT_LEAVE_AS_ONLY_ADMIN` | Admin cố tình rời nhóm khi chưa chuyển quyền | Mở Dialog gợi ý chuyển quyền: *"Bạn cần bàn giao quyền Quản trị viên cho một thành viên khác trước khi rời nhóm."* kèm nút bấm dẫn tới màn hình chuyển quyền. |
| `400` | `ALREADY_IN_GROUP` | Người dùng xin vào nhóm nhưng đã là thành viên | Hiển thị thông báo *"Bạn đã là thành viên của nhóm này rồi."* |
| `400` | `Bạn đã gửi yêu cầu tham gia và đang chờ Admin duyệt` | Gửi trùng yêu cầu khi yêu cầu trước vẫn đang `PENDING` | Thông báo *"Bạn đã gửi yêu cầu tham gia nhóm này rồi, vui lòng chờ Admin phê duyệt."* |
| `400` | `Mã mời không tồn tại` / `Mã mời này đã hết hạn` | Nhập mã mời sai hoặc quá hạn | Hiển thị thông báo lỗi trực tiếp dưới ô nhập mã mời. |
| `401` | `INVALID_TOKEN` | Phiên đăng nhập hết hạn | Kích hoạt luồng làm mới token tự động (Refresh Token) hoặc đăng xuất về màn hình Đăng nhập. |
| `403` | `NOT_GROUP_MEMBER` | Người dùng hiện tại không thuộc nhóm | Hiển thị thông báo: *"Bạn không có quyền truy cập nhóm này"*, điều hướng quay lại danh sách nhóm. |
| `403` | `NOT_GROUP_ADMIN` | Thành viên thường cố gọi thao tác quản trị (xóa/duyệt thành viên) | Ẩn hoàn toàn các nút xóa/duyệt thành viên đối với tài khoản `MEMBER`. Nếu gặp lỗi này, thông báo *"Bạn không có quyền Quản trị viên"*. |
| `404` | `GROUP_NOT_FOUND` | Nhóm không tồn tại hoặc đã bị xóa | Thông báo *"Nhóm chi tiêu không tồn tại"*, quay về màn hình chính. |
| `404` | `USER_NOT_FOUND` | Thành viên mục tiêu không thuộc nhóm | Thông báo *"Không tìm thấy thông tin thành viên này trong nhóm"*. |
| `404` | `JOIN_REQUEST_NOT_FOUND` | Yêu cầu gia nhập không tồn tại hoặc đã được xử lý trước đó | Làm mới lại danh sách yêu cầu gia nhập để cập nhật trạng thái mới nhất. |
| `500` | `INTERNAL_SERVER_ERROR` | Lỗi máy chủ không xác định | Hiển thị SnackBar/Toast: *"Hệ thống gián đoạn, vui lòng thử lại sau"*. |

---

## 6. QUY TẮC TRẢI NGHIỆM NGƯỜI DÙNG & GIAO DIỆN (UX GUIDELINES)

### 6.1. Hiển thị Huy hiệu yêu cầu gia nhập chờ duyệt (Badge Notification)
- Trên màn hình chi tiết nhóm, mục menu **"Yêu cầu gia nhập"** (hoặc tab **"Thành viên"**):
  - Khi `totalRequests > 0`: Hiển thị chấm đỏ hoặc con số badge tròn màu đỏ nổi bật (ví dụ: `[2]`) để Admin biết có yêu cầu mới cần xử lý ngay mà không phải tự tìm kiếm.
  - Khi `totalRequests === 0`: Ẩn badge số đếm.

### 6.2. Thiết kế giao diện danh sách yêu cầu gia nhập
- Mỗi thẻ (Card) yêu cầu hiển thị rõ:
  - Avatar, Họ tên, Email người yêu cầu.
  - Thời gian gửi yêu cầu (sử dụng định dạng thân thiện: *"10 phút trước"*, *"Hôm qua"*).
  - Hai nút thao tác nhanh:
    - **Nút "Từ chối" (Màu xám/đỏ nhạt):** Khi nhấn, gọi trực tiếp API với `approved: false`.
    - **Nút "Duyệt" (Màu xanh lá):** Khi nhấn, mở Modal/BottomSheet xác nhận.

### 6.3. BottomSheet xác nhận duyệt có tùy chọn quỹ cũ
- Khi Admin nhấn nút **"Duyệt"**, Mobile nên hiển thị BottomSheet với nội dung:
  - Thông điệp: *"Chấp thuận cho [Tên người dùng] tham gia nhóm?"*
  - Một ô chọn (Checkbox): **"Yêu cầu đóng các đợt quỹ trước đây của nhóm"** (mặc định để `uncheck / false`).
  - Gợi ý nhỏ bên dưới checkbox: *"Nếu chọn, thành viên mới sẽ được thêm vào danh sách phải đóng của tất cả các đợt quỹ đang mở trước đây."*
  - Nút bấm **"Xác nhận duyệt"** -> Gửi `approved: true` cùng giá trị `includePastFundCollections`.

### 6.4. Phân quyền hiển thị nút Xóa thành viên
- **Thành viên thường (`role === "MEMBER"`):**
  - Không nhìn thấy bất kỳ nút xóa hoặc biểu tượng thùng rác nào trong danh sách thành viên và màn hình chi tiết thành viên.
  - Không nhìn thấy mục menu "Yêu cầu gia nhập".
  - Chỉ có nút **"Rời nhóm"** ở cuối màn hình thông tin nhóm.
- **Quản trị viên (`role === "ADMIN"`):**
  - Hiển thị nút xóa (biểu tượng thùng rác màu đỏ hoặc menu vuốt trái - Swipe to delete) trên từng item thành viên có `role === "MEMBER"`.
  - Tuyệt đối **không hiển thị nút xóa** trên dòng tài khoản của chính mình.
  - Khi xóa, **bắt buộc** phải hiển thị Modal xác nhận với thông điệp rõ ràng để tránh thao tác nhầm lẫn.

### 6.5. Cảnh báo công nợ trước khi xóa thành viên
- Trước khi thực hiện xóa thành viên khỏi nhóm, nếu thành viên đó có `debtAmountVnd > 0` hoặc `receivableAmountVnd > 0`:
  - Hiển thị cảnh báo màu cam: *"Thành viên này hiện còn khoản nợ chưa tất toán ([Số tiền]). Bạn có chắc chắn muốn xóa thành viên khỏi nhóm?"* nhằm bảo vệ dữ liệu công nợ của cả nhóm.

### 6.6. Tối ưu tìm kiếm thành viên (Debounce Search)
- Không gọi API trên từng ký tự gõ phím. Áp dụng kỹ thuật Debounce với thời gian chờ từ 300ms đến 400ms sau khi người dùng dừng nhập.
- Hiển thị nút `x` (Clear text) trong ô tìm kiếm. Khi nhấn `x`, xóa trắng từ khóa và gọi lại API để phục hồi danh sách gốc đầy đủ.

### 6.7. Tiện ích sao chép thông tin ngân hàng nhanh (Copy to Clipboard)
- Trong màn hình chi tiết thành viên, tại khối thông tin ngân hàng (`bankAccountNumber`), đặt icon **Copy** bên cạnh.
- Khi người dùng chạm vào icon Copy, Mobile thực hiện sao chép số tài khoản vào khay nhớ tạm (Clipboard) và hiển thị thông báo Toast nhanh: *"Đã sao chép số tài khoản"*, giúp trải nghiệm chuyển khoản thanh toán nợ diễn ra mượt mà mà không cần chuyển qua lại giữa các ứng dụng.

### 6.8. Xử lý khi nhóm đã lưu trữ (`ARCHIVED`)
- Khi nhóm chi tiêu đã ở trạng thái `ARCHIVED`:
  - Ẩn toàn bộ thao tác xóa thành viên, duyệt yêu cầu gia nhập và chuyển quyền Admin.
  - Chuyển giao diện sang chế độ **Chỉ đọc (Read-only)**.
