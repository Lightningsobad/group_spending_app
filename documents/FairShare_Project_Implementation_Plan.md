# FairShare — Kế hoạch khởi tạo cấu trúc dự án

Cập nhật: 23/09/2026. Dự án Flutter quản lý chi tiêu nhóm trên Android/iOS.

**Mục tiêu trước mắt: AI chỉ khởi tạo bộ khung thư mục (Pha 0), chưa triển khai tính năng.** Các phần về kiến trúc, nghiệp vụ và lộ trình bên dưới là ràng buộc cho các pha sau, không phải yêu cầu viết code ngay.

Nguồn tham chiếu:

- [Thiết kế HTML](FairShare_Mobile_Design_HTML_Document/index.html): chuẩn giao diện và điều hướng.
- [Bộ câu hỏi review](FairShare_Project_Plan_Review_and_Questions.md): bối cảnh Q01–Q36; khuyến nghị trong review không thay thế lựa chọn đã chốt trong tài liệu này.

## 1. Pha 0 — Phạm vi và cách thực hiện

Repository đã có dự án Flutter. Khởi tạo bổ sung trên cấu trúc hiện có, không chạy lại `flutter create`.

1. Đọc hướng dẫn repository, kiểm tra cây thư mục và thay đổi đang có.
2. Tạo các thư mục ở mục 2; mở rộng mẫu feature theo đúng bảng phân loại.
3. Tạo cây thư mục `test/` đối xứng với các thư mục con đã tạo trong `lib/`.
4. Đặt `.gitkeep` rỗng vào mỗi thư mục lá chưa có file để Git lưu được cấu trúc. Bỏ qua thư mục đã có nội dung; không ghi đè `.gitkeep` hiện có.
5. Đối chiếu checklist mục 4 và báo cáo thư mục đã tạo, phần đã có sẵn, phần còn thiếu nếu có.

**Giới hạn Pha 0:**

- Chỉ thêm thư mục và `.gitkeep`; giữ nguyên file hiện có, kể cả `lib/main.dart`, test mẫu và cấu hình nền tảng.
- Chưa tạo file `.dart`, class rỗng, barrel export, model, endpoint, màn hình hay dữ liệu giả.
- Chưa cài dependency, sửa `pubspec.yaml`/lockfile, tạo `l10n.yaml`, ARB hoặc cấu hình môi trường.
- Chưa triển khai API, auth, routing, UI, test nghiệp vụ hoặc thuật toán tính tiền.
- Chưa tạo module notifications, OCR, VietQR, upload hoặc backend.
- Thông tin API/Q31 còn thiếu không chặn việc tạo thư mục. Không tự suy đoán để triển khai phần chưa chốt.
- Nếu một đường dẫn cần tạo thư mục đang là file, giữ nguyên và báo xung đột; không tự xóa/đổi tên.

## 2. Cấu trúc thư mục cần tạo

### 2.1. Cây tổng thể

Cây dưới đây chỉ liệt kê các thư mục cần có; không phải danh sách thay thế toàn bộ repository. `android/`, `ios/`, các nền tảng khác, `documents/` và file hiện có được giữ nguyên.

```text
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── observers/
│   ├── session/
│   ├── sync/
│   ├── storage/
│   ├── theme/
│   ├── utils/
│   ├── l10n/
│   └── router/
├── shared/
│   └── widgets/
└── features/
    ├── onboarding/
    ├── auth/
    ├── dashboard/
    ├── groups/
    ├── expenses/
    ├── debts/
    ├── funds/
    ├── analytics/
    └── settings/
assets/
├── icons/
├── images/
└── fonts/
test/                  # Mở rộng đối xứng các thư mục trong lib/
integration_test/      # Chỉ giữ chỗ, chưa tạo kịch bản
```

### 2.2. Mẫu feature có dữ liệu API

Áp dụng đầy đủ mẫu sau cho **`auth`, `dashboard`, `groups`, `expenses`, `debts`, `funds`**. `<feature>` là ký hiệu thay thế, không tạo thư mục mang tên này.

```text
lib/features/<feature>/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── cubit/
    ├── screens/
    └── widgets/
```

Mapping model → entity nằm trong `data/`; chỉ thêm `data/mappers/` khi triển khai thực tế cần tách mapper. Không tạo sẵn `usecases/`, `services/` hoặc tầng trung gian chưa có nhu cầu.

### 2.3. Mẫu feature chỉ có presentation ở bước đầu

Áp dụng cho **`onboarding`, `analytics`, `settings`**:

```text
lib/features/<feature>/
└── presentation/
    ├── cubit/
    ├── screens/
    └── widgets/
```

| Feature | Trách nhiệm khi triển khai |
| --- | --- |
| `onboarding` | 4 slide giới thiệu, lưu cờ đã xem qua storage dùng chung. |
| `auth` | Email/password, đăng ký, quên/reset mật khẩu, logout và phiên. |
| `dashboard` | Tổng quan, tổng số từ API của các nghiệp vụ liên quan. |
| `groups` | Danh sách/chi tiết, tạo/join nhóm, thành viên, mã mời/QR. |
| `expenses` | Tạo/xem/sửa/xóa khoản chi, người ứng tiền và phần chia. |
| `debts` | Công nợ theo nhóm và yêu cầu quyết toán (settlement). |
| `funds` | Chiến dịch thu quỹ, đóng góp và xác nhận. |
| `analytics` | UI tab Thống kê; nghiệp vụ báo cáo/API đang hoãn. |
| `settings` | Cài đặt local, theme, ngôn ngữ, xem lại onboarding. |

### 2.4. Quy tắc thư mục test và đặt tên

- Với mỗi thư mục dưới `lib/` được chỉ định ở trên, tạo đường dẫn tương ứng dưới `test/`, bỏ tiền tố `lib/`. Ví dụ: `lib/features/groups/domain/entities/` → `test/features/groups/domain/entities/`; `lib/core/network/` → `test/core/network/`.
- Không tạo `test/lib/`, không đối xứng `assets/`, không sao chép file Dart sang test. Test thực tế chỉ thêm khi triển khai phần tương ứng.
- Tên thư mục/file dùng `snake_case`; feature giữ đúng tên số nhiều/số ít trong cây.
- Khi bắt đầu viết code: `<name>_remote_data_source.dart`, `<name>_model.dart`, `<name>_repository.dart`, `<name>_repository_impl.dart`, `<name>_cubit.dart`, `<name>_state.dart`, `<name>_screen.dart`, `<name>_test.dart`.
- Khi có file thật trong thư mục, xóa `.gitkeep` của thư mục đó nếu không còn cần giữ chỗ.

## 3. Ranh giới kiến trúc cho các pha sau

**Feature-First Clean Architecture**, Cubit mặc định; không bắt buộc UseCase cho thao tác đơn giản.

```text
Screen/Widget → Cubit → Repository contract (domain)
RepositoryImpl (data) implements Repository contract
RepositoryImpl → RemoteDataSource → ApiClient (Dio)
JSON → Model (data) → Entity (domain) → State → UI
```

| Vị trí | Trách nhiệm |
| --- | --- |
| `core/config`, `constants` | Cấu hình dev/staging/prod; hằng số assets, màu, typography, danh mục, endpoint sau khi có hợp đồng. |
| `core/network`, `errors` | Dio, interceptor, chuẩn hóa `AppException`; không hiển thị snackbar từ tầng mạng. |
| `core/session`, `sync` | Điều phối phiên, bỏ response cũ; thông báo thay đổi để làm mới dữ liệu liên feature. |
| `core/storage` | Token qua `flutter_secure_storage`; cài đặt qua `shared_preferences`. |
| `core/theme`, `l10n` | Light/dark, locale vi/en bằng ARB; font Nunito đóng gói trong assets. |
| `core/router` | GoRouter + StatefulShellRoute; bootstrap/auth guard; nhóm theo `/groups/:id`. |
| `core/observers`, `utils` | Observer, validator thuần, định dạng tiền/ngày, helper thông báo cho UI. |
| `shared/widgets` | Button, input, card, avatar, badge, trạng thái rỗng/lỗi và nút Retry dùng chung. |
| `features/*/domain` | Entity Dart thuần và repository contract; không import Flutter, Dio hay data model. |
| `features/*/data` | Gọi API, parse JSON thủ công có kiểm tra, map model → entity, triển khai repository. |
| `features/*/presentation` | Cubit/state, màn hình và widget riêng của feature. |

Khi triển khai nền tảng mới tách `lib/main.dart` (entry point), `lib/bootstrap.dart` (nạp cấu hình/settings/token) và `lib/app.dart` (lắp Provider, theme, locale, router).

Quy tắc phụ thuộc:

- Presentation gọi domain contract; `app.dart`/điểm lắp ghép kết nối implementation bằng `RepositoryProvider` và `BlocProvider`, constructor injection; không dùng `get_it`.
- `core` và `shared` không import feature; widget riêng ở feature, widget dùng chung ở `shared/widgets`.
- Cubit không gọi chéo Cubit. Sau ghi, truyền kết quả hoặc tín hiệu thay đổi qua cơ chế chung để cập nhật/đánh dấu dữ liệu cũ.
- State bất biến + `copyWith`; tách trạng thái tải đầu, refresh, tải thêm, submit khi cần. Giữ dữ liệu cũ lúc refresh.
- Scope app/session cho auth/theme/locale, nhánh cho tab, route cho nhóm/form. Chủ sở hữu chịu trách nhiệm dispose; đổi tab không mặc định đóng Cubit. Logout dọn dữ liệu riêng tư ở mọi scope.

Stack đã chọn cho các pha sau: `flutter_bloc`, `dio`, `go_router`, `shared_preferences`, `flutter_secure_storage`, `google_fonts` (Nunito), `lucide_icons`, `flutter_localizations`. Không thêm `formz`, sinh JSON bằng `build_runner`, cache nghiệp vụ xuống đĩa hoặc sinh trắc học trong MVP. `flutter gen-l10n` vẫn được phép. Chưa chọn phiên bản package/SDK mới trong Pha 0.

## 4. Checklist hoàn thành Pha 0

- [ ] Đủ thư mục `core`, `shared`, 9 feature, assets và `integration_test`.
- [ ] Sáu feature API đúng mẫu mục 2.2; ba feature presentation đúng mẫu mục 2.3.
- [ ] `test/` đối xứng đầy đủ các thư mục `lib/` được yêu cầu.
- [ ] Mỗi thư mục lá rỗng có `.gitkeep`; không có thư mục tên `<feature>`.
- [ ] Không đổi file/code/dependency hiện có; không thêm nội dung ngoài phạm vi Pha 0.
- [ ] Chạy lại việc khởi tạo không ghi đè, không tạo bản trùng.
- [ ] Báo cáo kết quả kiểm tra cây thư mục và danh sách file thêm mới.

Pha 0 chỉ thay đổi cấu trúc, không yêu cầu chạy build hoặc viết test mới. Hoàn thành bộ khung không đồng nghĩa hoàn thành tính năng hay tích hợp API.

## 5. Quyết định đã chốt cần giữ khi triển khai

Bảng này là bản rút gọn các lựa chọn của chủ sản phẩm ngày 23/09/2026, không mở lại đáp án. Các quyết định kiến trúc Q23–Q27 đã thể hiện ở mục 3.

| Nhóm quyết định | Nội dung áp dụng |
| --- | --- |
| Nền tảng/UI — Q01–Q02, Q34 | Android/iOS; Chrome hỗ trợ phát triển. HTML là chuẩn UI: tab Tổng quan/Nhóm/Công nợ/Thống kê/Cài đặt; Quỹ theo luồng thiết kế. Kiểm tra light/dark, vi/en, màn nhỏ/lớn, chữ lớn, bàn phím, safe area. |
| API/phạm vi — Q03–Q06 | Có hợp đồng endpoint/schema/lỗi/quyền/môi trường test trước tích hợp từng feature. Phân trang theo API, thứ tự ổn định, lọc server. Dev/staging/prod tách cấu hình, pin SDK và lock dependency, CI đồng nhất; không đóng gói secret backend. |
| Tiền/quyền — Q07–Q09 | VND nguyên đồng; chia đều toàn nhóm hoặc người được chọn, backend phân bổ phần dư ổn định. 8 danh mục: Ăn uống, Di chuyển, Mua sắm, Nhà ở, Giải trí, Siêu thị, Y tế, Khác. Tách `createdBy`/`paidBy`; chỉ creator hoặc Admin nhóm sửa/xóa. Chỉ settlement ghi nhận thanh toán; phần chia chỉ đọc trạng thái nếu backend có liên kết. |
| Sửa/xóa — Q10-C | Cho sửa/xóa trực tiếp kể cả sau settlement, vẫn kiểm tra quyền/version. Khi API xác nhận ghi thành công, client chỉnh số dư theo chênh lệch rồi đối chiếu backend, không áp dụng chênh lệch hai lần. Không tự khóa sửa hoặc bắt buộc bút toán điều chỉnh; không tự hủy settlement. Quy tắc đối chiếu phải có trong hợp đồng; logic Dart tách khỏi widget, không viết lại thuật toán rút gọn nợ. |
| Công nợ — Q11–Q13 | Backend rút gọn trong từng nhóm, bảo toàn số dư ròng. Settlement trả toàn bộ nợ một cặp tại thời điểm tạo, số tiền cố định: pending → confirmed/rejected/cancelled. Người gửi hủy khi chờ; người nhận xác nhận hoặc từ chối kèm lý do. Server kiểm tra chuyển trạng thái nguyên tử và trả số dư mới, không mặc định về 0. |
| Quỹ — Q14–Q15 | Chỉ thu quỹ, tách công nợ, chưa chi từ quỹ. Thành viên xem/khai báo chờ; Admin xác nhận, chỉ khoản xác nhận tính tiến độ. Chỉ sửa mục tiêu/danh sách hoặc xóa chiến dịch khi chưa có đóng góp được xác nhận. |
| Thành viên — Q16, Q30 | Chặn rời/xóa khi còn nghĩa vụ; Admin cuối chuyển quyền; giữ ID lịch sử, không tự chia lại hóa đơn cũ cho người mới. Code/QR vào nhóm ngay; mã thu hồi/tạo lại theo API, có nhập mã khi camera bị từ chối. |
| Phiên — Q17–Q18, Q29, Q32 | Auth email/password; bootstrap trước route riêng tư, quay lại đích hợp lệ sau login và kiểm tra quyền. Một refresh dùng chung; replay tối đa một lần khi hợp đồng bảo đảm an toàn. Token bị xác nhận không hợp lệ mới logout; lỗi mạng/5xx giữ phiên cần thử lại, chặn thao tác cần xác thực. Response cũ không phục hồi phiên sau logout; 403 thiếu quyền không tự logout/refresh. |
| Ghi dữ liệu — Q19-B, Q20 | Không tự retry thao tác ghi chưa rõ kết quả; tải/đối chiếu trước khi làm tiếp. Version/ETag hoặc chuyển trạng thái nguyên tử; xung đột thì tải bản mới, không ghi đè âm thầm. Chưa mặc định backend hỗ trợ idempotency. |
| Đồng bộ — Q21–Q22 | Tải đầu, kéo refresh, cập nhật/đánh dấu cũ các màn liên quan sau ghi; bỏ response của nhóm/bộ lọc/phiên cũ. Không cache nghiệp vụ xuống đĩa hay hàng đợi ghi offline. Giữ dữ liệu phiên và cảnh báo cũ khi mất mạng, chặn gửi mới; chưa có dữ liệu thì lỗi/Retry, không dùng số 0 giả. |
| Ngôn ngữ/log — Q28, Q33 | vi/en bằng ARB; tiền luôn `x.xxx.xxx đ`, ngày nghiệp vụ theo `Asia/Ho_Chi_Minh`, timestamp theo API có timezone. Debug lọc dữ liệu nhạy cảm, release không log payload; dùng request ID/log backend, chưa thêm crash reporting bên thứ ba. |
| Hoãn/chưa chốt — Q04, Q31–Q32 | Hoãn OCR, VietQR, upload, Google login, CSV, báo cáo thật, hồ sơ/ngân hàng chưa xác nhận. UI phần hoãn ghi rõ chưa hỗ trợ hoặc khóa hành động. Q31 chưa chọn kênh nhắc nợ/quỹ, inbox/push/provider. |
| Hoàn thành feature — Q35-B, Q36 | UI khớp mẫu + happy path dữ liệu mô phỏng là tiêu chí feature đã chọn. UI và API vẫn triển khai trong cùng đợt feature; theo dõi trạng thái tích hợp API riêng, không coi mock là API hoàn tất và không dồn toàn bộ API đến cuối. |

## 6. Sau Pha 0

Chỉ chuyển pha khi có yêu cầu triển khai tiếp. Thứ tự kỹ thuật đề xuất:

1. **Nền tảng:** entry/bootstrap/app, config, DI, theme/l10n, router, network/storage và widget chung.
2. **Auth → Nhóm → Chi tiêu → Công nợ → Quỹ:** mỗi feature xây UI, state, domain/data và tích hợp API trong cùng đợt.
3. **Tổng quan/cài đặt:** cập nhật dashboard cùng nghiệp vụ phát sinh tổng số; onboarding/settings local có thể làm cùng nền tảng.
4. **Hoàn thiện:** đối chiếu HTML, kiểm tra Android/iOS và chuẩn bị phát hành theo tiêu chí được cung cấp sau.

Trước khi tích hợp phần liên quan, cần bổ sung: hợp đồng API và schema Member; hệ quả Q10-C lên settlement/số dư; kiểu tiền/ngày/category ID/phân trang; reset/xác minh/logout; vòng đời quỹ/nhóm; thứ tự onboarding/auth/deep link; locale mặc định/ngưỡng refresh khi resume; Q31; SDK/OS minimum/app ID/signing và tiêu chí phát hành. Các mục này chưa được tự coi là đã xác nhận.

Kiểm thử theo phần thực sự triển khai: parser/mapper/validator/formatter, Cubit và response cũ, refresh token đồng thời, quyền sửa/xóa, settlement/quỹ, lỗi/refresh UI và hành trình API. Mock không chứng minh backend xử lý đúng; tiêu chí feature Q35-B và tình trạng tích hợp API vẫn được báo cáo riêng.

## 7. Prompt giao AI khởi tạo

> Đọc `documents/FairShare_Project_Implementation_Plan.md` và thực hiện đúng Pha 0. Kiểm tra repository hiện có, tạo các thư mục ở mục 2 cùng cây test đối xứng; thêm `.gitkeep` cho thư mục lá rỗng. Chỉ bổ sung cấu trúc, giữ nguyên file/code/dependency hiện có, chưa tạo Dart/API/UI hay cấu hình mới. Không triển khai các pha sau. Kiểm tra checklist mục 4 và báo cáo kết quả cùng các xung đột nếu có.
