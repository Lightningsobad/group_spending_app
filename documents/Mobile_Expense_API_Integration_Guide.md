# TÀI LIỆU ĐẶC TẢ TÍCH HỢP API QUẢN LÝ KHOẢN CHI & PHÂN BỔ CHI PHÍ (MOBILE)

**Dự án:** Group Spending & Reminder (Quản lý & Nhắc nhở Chi tiêu Nhóm)  
**Phân hệ:** Quản lý Khoản chi & Chia tiền (Expense Management & Cost Splitting)  
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
   - [2.1. Vòng đời khoản chi (Expense Lifecycle)](#21-vòng-đời-khoản-chi-expense-lifecycle)
   - [2.2. Cơ chế phân bổ chia tiền (Expense Split Mechanism)](#22-cơ-chế-phân-bổ-chia-tiền-expense-split-mechanism)
   - [2.3. Tác động Real-time đến đồ thị nợ & Settlement](#23-tác-động-real-time-đến-đồ-thị-nợ--settlement)
   - [2.4. Phân quyền thao tác (Permissions & Guards)](#24-phân-quyền-thao-tác-permissions--guards)
   - [2.5. Kiểm soát giới hạn & Chống spam](#25-kiểm-soát-giới-hạn--chống-spam)
   - [2.6. Đồng bộ thời gian thực (Push Notification & WebSocket)](#26-đồng-bộ-thời-gian-thực-push-notification--websocket)
3. [Đặc tả chi tiết các API Endpoints chính](#3-đặc-tả-chi-tiết-các-api-endpoints-chính)
   - [3.1. Lấy danh sách chi tiêu rút gọn của một nhóm (Get Group Expenses)](#31-lấy-danh-sách-chi-tiêu-rút-gọn-của-một-nhóm-get-group-expenses)
   - [3.2. Tạo mới khoản chi tiêu trong nhóm (Create Expense)](#32-tạo-mới-khoản-chi-tiêu-trong-nhóm-create-expense)
   - [3.3. Cập nhật khoản chi tiêu (Update Expense)](#33-cập-nhật-khoản-chi-tiêu-update-expense)
   - [3.4. Xóa khoản chi tiêu (Delete Expense)](#34-xóa-khoản-chi-tiêu-delete-expense)
4. [Các API bổ trợ liên quan (Auxiliary Endpoints)](#4-các-api-bổ-trợ-liên-quan-auxiliary-endpoints)
   - [4.1. Lấy chi tiết một khoản chi (Get Expense Details)](#41-lấy-chi-tiết-một-khoản-chi-get-expense-details)
   - [4.2. Lấy danh sách thể loại chi tiêu khả dụng (Get Expense Categories)](#42-lấy-danh-sách-thể-loại-chi-tiêu-khả-dụng-get-expense-categories)
   - [4.3. Tìm kiếm chi tiêu trong nhóm theo từ khóa (Search Group Expenses)](#43-tìm-kiếm-chi-tiêu-trong-nhóm-theo-từ-khóa-search-group-expenses)
   - [4.4. Lấy lịch sử chi tiêu trên tất cả các nhóm của tôi (Get All Groups Expense History)](#44-lấy-lịch-sử-chi-tiêu-trên-tất-cả-các-nhóm-của-tôi-get-all-groups-expense-history)
   - [4.5. Bình luận & Trao đổi trên khoản chi (Expense Comments)](#45-bình-luận--trao-đổi-trên-khoản-chi-expense-comments)
5. [Bảng mã lỗi (Error Codes) & Hướng dẫn xử lý UI](#5-bảng-mã-lỗi-error-codes--hướng-dẫn-xử-lý-ui)
6. [Quy tắc trải nghiệm người dùng (UX Guidelines)](#6-quy-tắc-trải-nghiệm-người-dùng-ux-guidelines)

---

## 1. QUY CHUẨN CHUNG & ĐỊNH DẠNG DỮ LIỆU

### 1.1. Base URL & Authentication

- **Base URL Prefix:** `https://api.groupspending.xyz/api/v1` (Production) hoặc `http://<host>:8080/api/v1` (Development / Staging)
- **Tất cả các API liên quan đến khoản chi đều bắt buộc phải truyền Access Token:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```
- **Lưu ý đối với API Thêm / Sửa khoản chi:** Do có hỗ trợ đính kèm ảnh hóa đơn (`receipt`), định dạng Content-Type của Request là `multipart/form-data`. Đối với các API khác là `application/json; charset=UTF-8`.

---

### 1.2. Cấu trúc phản hồi chung (ApiResponse Pattern)

Mọi phản hồi từ máy chủ đều tuân theo cấu trúc bao bọc chuẩn:

#### Phản hồi thành công (HTTP 200 OK / HTTP 201 Created):
```json
{
  "success": true,
  "message": "Tạo khoản chi tiêu thành công",
  "data": { ... },
  "timestamp": "2026-09-30T14:20:00Z"
}
```

#### Phản hồi thất bại do lỗi nghiệp vụ (HTTP 400 / 403 / 404):
```json
{
  "success": false,
  "message": "Chỉ người tạo khoản chi hoặc Admin nhóm mới có quyền chỉnh sửa",
  "errors": null,
  "timestamp": "2026-09-30T14:20:00Z"
}
```

#### Phản hồi lỗi dữ liệu đầu vào (HTTP 400 Bad Request - Validation Error):
```json
{
  "success": false,
  "message": "Dữ liệu đầu vào không hợp lệ",
  "errors": {
    "title": "Tiêu đề khoản chi không được để trống",
    "totalAmount": "Số tiền tối thiểu là 1k (1.000 VNĐ)"
  },
  "timestamp": "2026-09-30T14:20:00Z"
}
```

---

### 1.3. Quy ước tiền tệ & Đơn vị tính

Toàn bộ hệ thống áp dụng cơ chế song song 2 đơn vị tiền tệ:
1. **Đơn vị rút gọn (`k` / Nghìn VNĐ):** Các trường `totalAmount`, `amount`, `amountOwed`, `totalSpending`.  
   *Ví dụ:* `150` tương ứng với `150.000 VNĐ`.
2. **Đơn vị quy đổi đầy đủ (`VNĐ`):** Các trường có hậu tố `Vnd` như `totalAmountVnd`, `amountVnd`, `myAmountOwedVnd`, `totalSpendingVnd` (giá trị bằng đơn vị rút gọn nhân với 1000).  
   *Ví dụ:* `150000`.
3. **Giới hạn tiền tệ:**
   - **Tối thiểu:** `1k` (tương đương `1.000 VNĐ`).
   - **Tối đa:** `1.000.000k` (tương đương `1.000.000.000 VNĐ` - Một tỷ VNĐ).

> **Khuyến nghị cho Mobile:** Phía Client có thể bind trực tiếp các trường `...Vnd` để format hiển thị tiền tệ có dấu chấm phân cách hàng nghìn (ví dụ: `NumberFormat.currency(locale: 'vi_VN', symbol: '₫')`), giúp tránh nhầm lẫn tính toán.

---

### 1.4. Bảng Enum dùng chung

#### 1.4.1. `ExpenseCategoryType` (Thể loại chi tiêu)

Hệ thống cung cấp sẵn 8 thể loại tiêu chuẩn kèm theo icon Material tương ứng:

| Enum Key | Tên hiển thị (`value`) | Material Icon (`defaultIcon`) | Mô tả |
| :--- | :--- | :--- | :--- |
| `FOOD` | `Food` | `restaurant` | Ăn uống, cà phê, liên hoan |
| `TRANSPORT` | `Transport` | `directions_car` | Đi lại, xăng xe, Grab/Taxi, vé máy bay |
| `SHOPPING` | `Shopping` | `shopping_bag` | Mua sắm quần áo, đồ dùng cá nhân |
| `ENTERTAIMENT` | `Entertaiment` | `sports_esports` | Giải trí, xem phim, karaoke, du lịch |
| `HOUSING` | `Housing` | `home` | Tiền thuê nhà, phòng trọ, khách sạn |
| `GROCERISE` | `Grocerise` | `local_grocery_store` | Thực phẩm, chợ, tạp hóa, siêu thị |
| `HEALTHCARE` | `Healthcare` | `medical_services` | Y tế, khám bệnh, thuốc men |
| `OTHERS` | `Others` | `more_horiz` | Các khoản chi phí khác |

> **Ghi chú mở rộng (Tolerance):** Backend hỗ trợ chuyển đổi linh hoạt không phân biệt hoa thường và các từ đồng nghĩa (ví dụ: `food`, `Food`, `AN_UONG`, `ENTERTAINMENT`, `GROCERIES`, `OTHER` đều được nhận diện tự động).

#### 1.4.2. `SplitOption` (Hình thức chia tiền)

| Enum Key | Ý nghĩa | Hành vi hệ thống |
| :--- | :--- | :--- |
| `EQUAL_ALL` | Chia đều cho tất cả thành viên | Hệ thống tự động lấy danh sách tất cả thành viên hiện tại của nhóm và chia đều khoản tiền. Không cần truyền `participantUserIds`. |
| `EQUAL_SELECTED` | Chia đều cho các thành viên được chọn | Chỉ chia đều cho các thành viên có `userId` nằm trong danh sách `participantUserIds`. Bắt buộc truyền ít nhất 1 thành viên. |

#### 1.4.3. `ExpenseTimeFilter` (Bộ lọc thời gian chi tiêu)

Áp dụng cho danh sách chi tiêu nhóm và lịch sử chi tiêu cá nhân:

| Enum Key | Mô tả tác vụ |
| :--- | :--- |
| `ALL` | Toàn bộ thời gian (Mặc định) |
| `THIS_MONTH` | Trong tháng hiện tại (Từ ngày 1 đến ngày cuối tháng) |
| `LAST_MONTH` | Trong tháng trước |
| `THIS_QUARTER` | Trong quý hiện tại (Quý 1, 2, 3 hoặc 4) |
| `THIS_YEAR` | Trong năm hiện hành (Từ 01/01 đến 31/12) |

#### 1.4.4. `ExpensePayerFilter` (Bộ lọc người thanh toán)

| Enum Key | Mô tả |
| :--- | :--- |
| `ALL` | Tất cả người chi tiền (Mặc định) |
| `PAID_BY_ME` | Khoản chi do chính người dùng hiện tại trả trước |
| `PAID_BY_OTHERS` | Khoản chi do người khác trong nhóm trả trước |

#### 1.4.5. `ExpenseCategoryFilter` (Bộ lọc chủ đề chi tiêu)

Bao gồm `ALL` (toàn bộ) và 8 thể loại: `FOOD`, `TRANSPORT`, `SHOPPING`, `ENTERTAIMENT`, `HOUSING`, `GROCERISE`, `HEALTHCARE`, `OTHERS`.

#### 1.4.6. `ExpenseStatus` (Trạng thái khoản chi)

| Trạng thái | Mô tả |
| :--- | :--- |
| `ACTIVE` | Khoản chi hợp lệ, đang có hiệu lực và tham gia vào tính toán công nợ |
| `DELETED` | Khoản chi đã bị xóa |
| `PENDING_SETTLEMENT` | Khoản chi đang chờ đối soát |
| `SETTLED` | Khoản chi đã được tất toán toàn bộ |

---

## 2. MÔ HÌNH NGHIỆP VỤ & LUỒNG TƯƠNG TÁC (BUSINESS FLOW)

### 2.1. Vòng đời khoản chi (Expense Lifecycle)

```
[Thành viên trả tiền thực tế] 
       │
       ▼
[Tạo Khoản Chi (POST /groups/{id}/expenses)] 
  ├── Đính kèm hóa đơn (Receipt)
  └── Chọn hình thức chia tiền (SplitOption)
       │
       ├──► Lưu bản ghi Expense & ExpenseSplit
       ├──► Tự động kích hoạt tính lại công nợ (Debt Recalculation)
       ├──► Bắn Push Notification (FCM) & WebSocket STOMP
       └──► Ghi nhật ký hoạt động (Activity Log)
       │
       ▼
[Chỉnh sửa (PUT) / Xóa (DELETE)]
  ├── Quyền: Người tạo (Creator) HOẶC Admin nhóm
  └── Tự động hoàn tác và tính toán lại công nợ nhóm thời gian thực
```

---

### 2.2. Cơ chế phân bổ chia tiền (Expense Split Mechanism)

Khi tạo hoặc sửa khoản chi, hệ thống tự động xử lý chia tiền theo 3 trường hợp:

1. **`splitOption = EQUAL_ALL` (Mặc định):**
   - Lấy toàn bộ thành viên đang hoạt động trong nhóm ($N$ người).
   - Số tiền cơ bản: $Share = \lfloor TotalAmount / N \rfloor$.
   - **Xử lý tiền lẻ (Remainder):** Phần dư $R = TotalAmount \pmod N$ sẽ được cộng thêm $1k$ lần lượt cho $R$ thành viên đầu tiên.
   - *Đảm bảo 100%:* Tổng số tiền nợ của từng người (`splits.amountOwed`) luôn bằng chính xác `totalAmount`.
2. **`splitOption = EQUAL_SELECTED`:**
   - Hệ thống chia đều cho danh sách thành viên chỉ định trong `participantUserIds`.
   - Thuật toán xử lý tiền lẻ tương tự như trên.
3. **Chỉ định danh sách thủ công (`splits: List<ExpenseSplitRequest>`):**
   - Trường hợp người dùng tự gõ số tiền từng người trên UI.
   - Backend sẽ kiểm tra nghiêm ngặt: $\sum amountOwed == totalAmount$. Nếu sai lệch dù chỉ $1k$, hệ thống trả về mã lỗi `INVALID_EXPENSE_SPLIT` (HTTP 400).

---

### 2.3. Tác động Real-time đến đồ thị nợ & Settlement

- Mỗi khi một khoản chi được **Thêm mới**, **Cập nhật** hoặc **Xóa**, Backend sẽ gọi tự động dịch vụ `DebtSimplificationService.recalculateDebtsForGroup(groupId)`.
- Dịch vụ này tính toán lại bù trừ dòng tiền đa phương (Debt Simplification), cập nhật lại bảng công nợ tối giản của nhóm ngay lập tức mà Client không cần gọi thêm API nào khác.

---

### 2.4. Phân quyền thao tác (Permissions & Guards)

| Hành động | Ai có quyền? | Phản hồi khi vi phạm |
| :--- | :--- | :--- |
| **Xem danh sách chi tiêu** | Mọi thành viên trong nhóm | `403 Forbidden` (`NOT_GROUP_MEMBER`) |
| **Xem chi tiết khoản chi** | Mọi thành viên trong nhóm | `403 Forbidden` (`NOT_GROUP_MEMBER`) |
| **Thêm khoản chi mới** | Mọi thành viên trong nhóm | `403 Forbidden` (`NOT_GROUP_MEMBER`) |
| **Sửa khoản chi** | **Người tạo (`createdBy`)** HOẶC **Admin nhóm** | `403 Forbidden` (`UNAUTHORIZED`: "Chỉ người tạo khoản chi hoặc Admin nhóm mới có quyền chỉnh sửa") |
| **Xóa khoản chi** | **Người tạo (`createdBy`)** HOẶC **Admin nhóm** | `403 Forbidden` (`UNAUTHORIZED`: "Chỉ người tạo khoản chi hoặc Admin nhóm mới có quyền xóa") |

---

### 2.5. Kiểm soát giới hạn & Chống spam

1. **Giới hạn số tiền:** Không vượt quá `1.000.000k` (1 tỷ VNĐ) cho một khoản chi. Nếu vượt quá sẽ bị chặn với mã lỗi `EXPENSE_LIMIT_EXCEEDED` (HTTP 400).
2. **Giới hạn số lượng khoản chi theo tháng (Anti-Spam):** Mỗi nhóm tối đa `5.000` khoản chi trong một tháng dương lịch. Nếu vượt quá trả về mã lỗi `MONTHLY_EXPENSE_LIMIT_EXCEEDED` (HTTP 400).
3. **Nhóm đã lưu trữ (Archived):** Không thể thêm, sửa hoặc xóa khoản chi trong nhóm có trạng thái `ARCHIVED`. Trả về mã lỗi `GROUP_ARCHIVED` (HTTP 400).

---

### 2.6. Đồng bộ thời gian thực (Push Notification & WebSocket)

- **Firebase Cloud Messaging (FCM Push):** Khi có khoản chi mới, Backend tự động gửi push notification đến tất cả thành viên khác trong nhóm.
- **WebSocket STOMP Channel:**
  - Topic đăng ký nhận sự kiện khoản chi: `/topic/group/{groupId}/expenses`
  - Client đăng ký topic này để tự động reload danh sách khi có người khác vừa thêm/sửa khoản chi mà không cần kéo vuốt reload màn hình.

---

## 3. ĐẶC TẢ CHI TIẾT CÁC API ENDPOINTS CHÍNH

### 3.1. Lấy danh sách chi tiêu rút gọn của một nhóm (Get Group Expenses)

Lấy danh sách các khoản chi tiêu trong nhóm kèm theo tổng tiền chi tiêu, số lượng khoản chi, và số tiền cá nhân người dùng nợ trong từng khoản chi. Danh sách này được tối ưu nhẹ nhất cho màn hình Dashboard / Tab Chi tiêu của nhóm.

- **Method:** `GET`
- **Path:** `/groups/{groupId}/expenses`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/expenses`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```
- **Path Parameters:**
  - `groupId` (Long, bắt buộc): ID của nhóm.

- **Query Parameters (Hỗ trợ lọc & tìm kiếm):**

| Tên tham số | Kiểu dữ liệu | Bắt buộc | Mặc định | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| `timeFilter` | String (`ExpenseTimeFilter`) | Không | `ALL` | Bộ lọc thời gian: `ALL`, `THIS_MONTH`, `LAST_MONTH`, `THIS_QUARTER`, `THIS_YEAR` |
| `payerFilter` | String (`ExpensePayerFilter`) | Không | `ALL` | Bộ lọc người chi: `ALL`, `PAID_BY_ME`, `PAID_BY_OTHERS` |
| `categoryFilter` | String (`ExpenseCategoryFilter`) | Không | `ALL` | Bộ lọc thể loại: `ALL`, `FOOD`, `TRANSPORT`, `SHOPPING`, `ENTERTAIMENT`, `HOUSING`, `GROCERISE`, `HEALTHCARE`, `OTHERS` |
| `search` | String | Không | *null* | Ô tìm kiếm gần đúng theo tên/tiêu đề khoản chi |

- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Thành công",
  "data": {
    "totalSpending": 1500,
    "totalSpendingVnd": 1500000,
    "expenseCount": 2,
    "expenses": [
      {
        "id": 101,
        "title": "Ăn lẩu Haidilao cuối tuần",
        "amount": 1200,
        "amountVnd": 1200000,
        "expenseDate": "2026-09-29",
        "paidBy": "Nguyễn Văn A",
        "paidByUserId": 1,
        "status": "PAID_BY_ME",
        "myAmountOwed": 0,
        "myAmountOwedVnd": 0,
        "categoryName": "Food",
        "categoryIcon": "restaurant"
      },
      {
        "id": 102,
        "title": "Tiền Grab đi làm chung",
        "amount": 300,
        "amountVnd": 300000,
        "expenseDate": "2026-09-30",
        "paidBy": "Trần Thị B",
        "paidByUserId": 2,
        "status": "100.000 VNĐ",
        "myAmountOwed": 100,
        "myAmountOwedVnd": 100000,
        "categoryName": "Transport",
        "categoryIcon": "directions_car"
      }
    ]
  },
  "timestamp": "2026-09-30T14:30:00Z"
}
```

> **Giải thích trường đặc biệt trong `expenses`:**
> - `status`:
>   - Nếu người dùng hiện tại là người chi trả: trả về `"PAID_BY_ME"`.
>   - Nếu người khác trả và người dùng được chia nợ: trả về chuỗi tiền nợ định dạng sẵn (ví dụ: `"100.000 VNĐ"`).
> - `myAmountOwed` & `myAmountOwedVnd`: Số tiền nợ thực tế của người dùng đối với khoản chi này ($= 0$ nếu là người thanh toán).
> - `categoryIcon`: Tên icon Material (ví dụ: `restaurant`, `directions_car`, `shopping_bag`) dùng trực tiếp trên Flutter Icon hoặc Jetpack Compose Icon.

---

### 3.2. Tạo mới khoản chi tiêu trong nhóm (Create Expense)

Tạo mới một khoản chi tiêu trong nhóm. Hỗ trợ đính kèm ảnh hóa đơn thực tế và lựa chọn hình thức chia tiền.

- **Method:** `POST`
- **Path:** `/groups/{groupId}/expenses`
- **Full URL:** `https://api.groupspending.xyz/api/v1/groups/{groupId}/expenses`
- **Content-Type:** `multipart/form-data`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Path Parameters:**
  - `groupId` (Long, bắt buộc): ID nhóm phát sinh chi tiêu.

- **Multipart Parts (hoặc Parameters đi kèm):**

| Tên Part / Tham số | Kiểu dữ liệu | Bắt buộc | Vị trí | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| `data` | JSON String (`CreateExpenseRequest`) | **Bắt buộc** | Form Part (`application/json`) | Chứa toàn bộ thông tin chi tiết của khoản chi dạng JSON. |
| `receipt` | File Binary | Không | Form Part (`image/*`) | File ảnh hóa đơn/chứng từ (JPEG, PNG, WEBP, tối đa 10MB). |
| `category` | String (`ExpenseCategoryType`) | Không | Query Param / Form Param | Ô chọn thể loại chi tiêu: `Food`, `Transport`, `Shopping`, `Entertaiment`, `Housing`, `Grocerise`, `Healthcare`, `Others`. |
| `splitOption` | String (`SplitOption`) | Không | Query Param / Form Param | Hình thức chia tiền: `EQUAL_ALL` (mặc định) hoặc `EQUAL_SELECTED`. |
| `participantUserIds` | List\<Long\> | Không (Bắt buộc nếu chọn `EQUAL_SELECTED`) | Query Param / Form Param | Danh sách ID các thành viên tham gia chia tiền (Ví dụ: `1, 2, 3`). |

#### Cấu trúc JSON bên trong Part `data`:
```json
{
  "title": "Ăn trưa cơm văn phòng",
  "totalAmount": 150,
  "paidByUserId": 1,
  "expenseDate": "2026-09-30",
  "notes": "Ăn tại quán Cơm tấm Sài Gòn",
  "category": "Food",
  "splitOption": "EQUAL_ALL",
  "participantUserIds": [1, 2, 3]
}
```

> **Mẹo tích hợp:** Mobile có thể truyền `category`, `splitOption`, `participantUserIds` trực tiếp ngay trong JSON part `data` HOẶC truyền qua Query Params / Form Data params. Cả hai cách Backend đều tiếp nhận chính xác.

- **Mã phản hồi thành công:** `201 Created`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Tạo khoản chi tiêu thành công",
  "data": {
    "id": 105,
    "groupId": 10,
    "category": {
      "id": 1,
      "groupId": null,
      "name": "Food",
      "icon": "restaurant",
      "isDefault": true
    },
    "title": "Ăn trưa cơm văn phòng",
    "totalAmount": 150,
    "totalAmountVnd": 150000,
    "paidByUserId": 1,
    "paidByUserName": "Nguyễn Văn A",
    "paidByUserAvatar": "https://res.cloudinary.com/.../avatar1.jpg",
    "expenseDate": "2026-09-30",
    "receiptUrl": "https://res.cloudinary.com/.../receipts/uuid-bill.jpg",
    "status": "ACTIVE",
    "notes": "Ăn tại quán Cơm tấm Sài Gòn",
    "createdByUserId": 1,
    "createdByUserName": "Nguyễn Văn A",
    "splits": [
      {
        "id": 201,
        "userId": 1,
        "fullName": "Nguyễn Văn A",
        "email": "vana@example.com",
        "avatarUrl": "https://res.cloudinary.com/.../avatar1.jpg",
        "amountOwed": 50,
        "amountOwedVnd": 50000
      },
      {
        "id": 202,
        "userId": 2,
        "fullName": "Trần Thị B",
        "email": "thib@example.com",
        "avatarUrl": "https://res.cloudinary.com/.../avatar2.jpg",
        "amountOwed": 50,
        "amountOwedVnd": 50000
      },
      {
        "id": 203,
        "userId": 3,
        "fullName": "Lê Văn C",
        "email": "vanc@example.com",
        "avatarUrl": "https://res.cloudinary.com/.../avatar3.jpg",
        "amountOwed": 50,
        "amountOwedVnd": 50000
      }
    ],
    "commentCount": 0,
    "createdAt": "2026-09-30T14:35:00Z",
    "updatedAt": "2026-09-30T14:35:00Z"
  },
  "timestamp": "2026-09-30T14:35:00Z"
}
```

---

### 3.3. Cập nhật khoản chi tiêu (Update Expense)

Cho phép người tạo khoản chi hoặc Admin nhóm chỉnh sửa thông tin chi tiêu, số tiền, người trả, danh sách chia tiền hoặc thay đổi ảnh hóa đơn.

- **Method:** `PUT`
- **Path:** `/expenses/{expenseId}`
- **Full URL:** `https://api.groupspending.xyz/api/v1/expenses/{expenseId}`
- **Content-Type:** `multipart/form-data`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Path Parameters:**
  - `expenseId` (Long, bắt buộc): ID khoản chi cần chỉnh sửa.

- **Multipart Parts / Tham số:**
  - `data` (JSON String, bắt buộc): Dữ liệu cập nhật (`UpdateExpenseRequest`). Có thể truyền thêm trường boolean `removeReceipt: true` khi người dùng muốn xóa ảnh hóa đơn cũ.
  - `receipt` (File Binary, tùy chọn): Ảnh hóa đơn mới. Nếu không upload ảnh mới và không truyền `removeReceipt: true`, hệ thống sẽ giữ nguyên hóa đơn hiện tại.
  - Các params tùy chọn: `category`, `splitOption`, `participantUserIds`.

#### Cấu trúc JSON bên trong Part `data`:
```json
{
  "title": "Ăn trưa cơm văn phòng (Bổ sung nước uống)",
  "totalAmount": 180,
  "paidByUserId": 1,
  "expenseDate": "2026-09-30",
  "notes": "Gọi thêm 3 cốc trà đá",
  "category": "Food",
  "splitOption": "EQUAL_ALL",
  "removeReceipt": false
}
```

- **Quyền hạn bắt buộc:**
  - Người gửi yêu cầu phải là **Chính người đã tạo khoản chi (`createdBy`)** HOẶC **Quản trị viên nhóm (`ADMIN`)**.
  - Nếu thành viên thường khác cố tình chỉnh sửa, hệ thống trả về HTTP `403 Forbidden` (`UNAUTHORIZED`).
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Cập nhật khoản chi thành công",
  "data": {
    "id": 105,
    "groupId": 10,
    "title": "Ăn trưa cơm văn phòng (Bổ sung nước uống)",
    "totalAmount": 180,
    "totalAmountVnd": 180000,
    "paidByUserId": 1,
    "paidByUserName": "Nguyễn Văn A",
    "expenseDate": "2026-09-30",
    "receiptUrl": "https://res.cloudinary.com/.../receipts/uuid-bill.jpg",
    "status": "ACTIVE",
    "splits": [
      {
        "id": 204,
        "userId": 1,
        "fullName": "Nguyễn Văn A",
        "amountOwed": 60,
        "amountOwedVnd": 60000
      },
      {
        "id": 205,
        "userId": 2,
        "fullName": "Trần Thị B",
        "amountOwed": 60,
        "amountOwedVnd": 60000
      },
      {
        "id": 206,
        "userId": 3,
        "fullName": "Lê Văn C",
        "amountOwed": 60,
        "amountOwedVnd": 60000
      }
    ],
    "commentCount": 0,
    "createdAt": "2026-09-30T14:35:00Z",
    "updatedAt": "2026-09-30T14:40:00Z"
  },
  "timestamp": "2026-09-30T14:40:00Z"
}
```

---

### 3.4. Xóa khoản chi tiêu (Delete Expense)

Xóa vĩnh viễn một khoản chi tiêu khỏi hệ thống. Các bản ghi chia tiền liên quan (`splits`) sẽ tự động được thu hồi và toàn bộ đồ thị công nợ trong nhóm được hoàn tác, tính toán lại ngay lập tức.

- **Method:** `DELETE`
- **Path:** `/expenses/{expenseId}`
- **Full URL:** `https://api.groupspending.xyz/api/v1/expenses/{expenseId}`
- **Header:**
  ```http
  Authorization: Bearer <accessToken>
  Accept: application/json
  ```
- **Path Parameters:**
  - `expenseId` (Long, bắt buộc): ID khoản chi cần xóa.

- **Quyền hạn bắt buộc:**
  - Người gửi yêu cầu phải là **Người tạo khoản chi** HOẶC **Admin nhóm**.
  - Không được xóa khoản chi thuộc nhóm đã bị lưu trữ (`ARCHIVED`).
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Xóa khoản chi thành công",
  "data": null,
  "timestamp": "2026-09-30T14:42:00Z"
}
```

---

## 4. CÁC API BỔ TRỢ LIÊN QUAN (AUXILIARY ENDPOINTS)

### 4.1. Lấy chi tiết một khoản chi (Get Expense Details)

Dùng cho màn hình Xem chi tiết khoản chi (Expense Detail Screen) hiển thị đầy đủ thông tin: ảnh hóa đơn phóng to, người trả, người tạo, danh sách ai nợ bao nhiêu tiền, ngày giờ tạo, và số lượng bình luận.

- **Method:** `GET`
- **Path:** `/expenses/{expenseId}`
- **Full URL:** `https://api.groupspending.xyz/api/v1/expenses/{expenseId}`
- **Mã phản hồi thành công:** `200 OK`
- **Response Body:** Tương tự đối tượng `data` trong phản hồi tạo mới khoản chi ở mục 3.2.

---

### 4.2. Lấy danh sách thể loại chi tiêu khả dụng (Get Expense Categories)

Dùng để render danh sách chọn Thể loại (Category Selector / Picker) trên màn hình Thêm / Sửa khoản chi.

- **Method:** `GET`
- **Path:** `/expenses/categories`
- **Full URL:** `https://api.groupspending.xyz/api/v1/expenses/categories`
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Thành công",
  "data": [
    "Food",
    "Transport",
    "Shopping",
    "Entertaiment",
    "Housing",
    "Grocerise",
    "Healthcare",
    "Others"
  ],
  "timestamp": "2026-09-30T14:45:00Z"
}
```

---

### 4.3. Tìm kiếm chi tiêu trong nhóm theo từ khóa (Search Group Expenses)

Dùng cho thanh tìm kiếm nhanh trong nhóm theo từ khóa tự do.

- **Method:** `GET`
- **Path:** `/groups/{groupId}/expenses/search`
- **Query Parameter:** `q` (String, bắt buộc) - Từ khóa tìm kiếm (Ví dụ: `q=bún bò`).
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:** Danh sách các đối tượng `ExpenseResponse`.

---

### 4.4. Lấy lịch sử chi tiêu trên tất cả các nhóm của tôi (Get All Groups Expense History)

Dùng cho màn hình Sổ chi tiêu cá nhân (Personal Spending History), hiển thị tất cả các khoản chi tiêu từ tất cả các nhóm mà người dùng đang tham gia.

- **Method:** `GET`
- **Path:** `/expenses/history`
- **Query Parameters:**
  - `timeFilter`: `ALL`, `THIS_MONTH`, `LAST_MONTH`, `THIS_QUARTER`, `THIS_YEAR`
  - `categoryFilter`: `ALL`, `FOOD`, `TRANSPORT`, v.v.
- **Mã phản hồi thành công:** `200 OK`
- **Response Body mẫu:**
```json
{
  "success": true,
  "message": "Thành công",
  "data": [
    {
      "id": 105,
      "groupId": 10,
      "groupName": "Phòng trọ 201",
      "title": "Ăn trưa cơm văn phòng",
      "expenseDate": "2026-09-30",
      "totalAmount": 180,
      "totalAmountVnd": 180000,
      "categoryName": "Food",
      "paidByUserName": "Nguyễn Văn A"
    }
  ],
  "timestamp": "2026-09-30T14:47:00Z"
}
```

---

### 4.5. Bình luận & Trao đổi trên khoản chi (Expense Comments)

Khi thành viên nhóm cần hỏi lại hoặc trao đổi về một khoản chi:

- **Thêm bình luận mới:**
  - `POST /api/v1/expenses/{expenseId}/comments`
  - Body: `{"content": "Hóa đơn này có tính tiền nước suối không nhỉ?"}`
- **Lấy danh sách bình luận:**
  - `GET /api/v1/expenses/{expenseId}/comments`
- **Xóa bình luận:**
  - `DELETE /api/v1/comments/{commentId}`

---

## 5. BẢNG MÃ LỖI (ERROR CODES) & HƯỚNG DẪN XỬ LÝ UI

| HTTP Status | Error Code / Message | Nguyên nhân gây lỗi | Hướng dẫn xử lý trên Mobile UI |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `EXPENSE_LIMIT_EXCEEDED` | Khoản chi vượt quá giới hạn tối đa `1.000.000k` (1 tỷ VNĐ). | Hiển thị Dialog: *"Số tiền chi tiêu tối đa cho một khoản là 1 tỷ VNĐ. Vui lòng kiểm tra lại."* |
| `400 Bad Request` | `MONTHLY_EXPENSE_LIMIT_EXCEEDED` | Nhóm đã tạo vượt quá 5.000 khoản chi trong tháng này. | Hiển thị cảnh báo: *"Nhóm đã vượt hạn mức 5.000 khoản chi trong tháng này để đảm bảo an toàn hệ thống."* |
| `400 Bad Request` | `INVALID_EXPENSE_SPLIT` | Tổng tiền các phần chia không bằng tổng tiền của khoản chi. | Báo lỗi tại trường chia tiền: *"Tổng tiền chia cho các thành viên chưa bằng tổng tiền khoản chi."* |
| `400 Bad Request` | `GROUP_ARCHIVED` | Nhóm đã bị lưu trữ (Read-Only), không thể tạo, sửa hay xóa chi tiêu. | Khóa các nút *"Thêm chi tiêu"*, *"Sửa"*, *"Xóa"*. Hiển thị Banner màu xám: *"Nhóm này đã được lưu trữ."* |
| `400 Bad Request` | `Người trả tiền phải là thành viên của nhóm` | Chọn một `paidByUserId` không nằm trong danh sách thành viên nhóm. | Lọc danh sách Dropdown người thanh toán chỉ bao gồm các thành viên thuộc nhóm. |
| `400 Bad Request` | `Vui lòng chọn ít nhất một thành viên để chia tiền` | Chọn hình thức `EQUAL_SELECTED` nhưng danh sách `participantUserIds` rỗng. | Bắt buộc validate checkbox chọn người trước khi cho phép bấm nút *"Lưu"*. |
| `403 Forbidden` | `NOT_GROUP_MEMBER` | Tài khoản hiện tại không thuộc nhóm này. | Điều hướng người dùng quay lại màn hình danh sách nhóm chính và hiển thị Toast thông báo. |
| `403 Forbidden` | `UNAUTHORIZED` | Thành viên cố tình sửa/xóa khoản chi mà không phải người tạo hoặc Admin nhóm. | **Ẩn icon Sửa / Xóa** trên giao diện nếu `currentUserId != expense.createdByUserId` và `currentUserId != group.adminId`. Nếu API trả về, hiển thị Snackbar lỗi quyền hạn. |
| `404 Not Found` | `EXPENSE_NOT_FOUND` | Khoản chi không tồn tại hoặc đã bị xóa trước đó. | Hiển thị thông báo: *"Khoản chi không tồn tại hoặc đã bị xóa"*, sau đó tự động reload lại danh sách. |
| `404 Not Found` | `GROUP_NOT_FOUND` | ID nhóm truyền lên không tồn tại. | Điều hướng quay về Dashboard nhóm. |
| `415 Unsupported Media Type` | *Spring Content Type Mismatch* | Part `data` trong Multipart không được gán header `application/json`. | Kiểm tra lại code đóng gói `MediaType('application', 'json')`. |

---

## 6. QUY TẮC TRẢI NGHIỆM NGƯỜI DÙNG (UX GUIDELINES)

1. **Hiển thị Phân quyền Thông minh (Smart Action Visibility):**
   - Trên màn hình Chi tiết khoản chi (`Expense Detail`), kiểm tra điều kiện:
     ```dart
     final canEditOrDelete = (currentUserId == expense.createdByUserId) || isGroupAdmin;
     ```
   - Nếu `canEditOrDelete == false`: Ẩn hoàn toàn hoặc disable các nút **Chỉnh sửa** và **Xóa** để tránh người dùng bấm vào rồi nhận lỗi `403`.
2. **Xử lý Đơn vị Tiền tệ:**
   - Trường nhập liệu: Cho phép người dùng gõ số tiền trực tiếp theo VNĐ (ví dụ gõ `150,000`). Trước khi đóng gói gửi lên API, quy đổi về đơn vị `k` (ví dụ chia cho 1000 $\rightarrow 150$) hoặc hiển thị chú thích rõ ràng.
   - Khi hiển thị danh sách: Ưu tiên dùng trường `amountVnd` và `myAmountOwedVnd` kết hợp với thư viện format tiền tệ quốc gia để có dấu phân cách hàng nghìn rõ ràng.
3. **Debounce cho Thanh Tìm kiếm:**
   - Đối với ô tìm kiếm chi tiêu (`search`), áp dụng cơ chế Debounce tối thiểu `400ms` trước khi kích hoạt gọi API `GET /groups/{groupId}/expenses?search=...` để giảm áp lực tải mạng và giật lag giao diện.
4. **Xem trước & Nén ảnh Hóa đơn (Image Preview & Compression):**
   - Khi người dùng chụp hóa đơn từ Camera hoặc thư viện ảnh, thực hiện nén ảnh (Compress) về dung lượng $< 2MB$ trước khi upload lên Multipart.
   - Cung cấp tính năng chạm vào ảnh hóa đơn để mở trình xem ảnh toàn màn hình (Photo Viewer) kèm cử chỉ zoom in / zoom out.
5. **Đồng bộ Dữ liệu Tự động (WebSocket & Push Notification):**
   - Lắng nghe sự kiện từ kênh WebSocket `/topic/group/{groupId}/expenses` khi màn hình danh sách chi tiêu đang hiển thị.
   - Khi nhận được bản tin cập nhật, tự động làm mới danh sách chi tiêu và cập nhật lại thẻ thống kê tổng chi tiêu trên đầu màn hình một cách mượt mà.
6. **Xác nhận Trước khi Xóa (Confirmation Dialog):**
   - Hành động xóa khoản chi tiêu sẽ làm thay đổi toàn bộ kết quả nợ nần giữa các thành viên. Luôn hiển thị Dialog xác nhận với cảnh báo rõ ràng:  
     *"Bạn có chắc chắn muốn xóa khoản chi này? Công nợ của các thành viên trong nhóm sẽ được tính toán lại ngay lập tức."*
