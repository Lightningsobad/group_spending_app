# FairShare — Implementation plan khắc phục chất lượng luồng Auth

Ngày lập: 25/09/2026. Trạng thái: **đề xuất triển khai, chưa sửa mã ứng dụng hoặc backend**.

## 1. Mục tiêu và phạm vi

Khắc phục các vấn đề trong hai lượt review: đăng nhập/đăng ký/xác thực email, quản lý phiên, hard-code, tuân thủ kiến trúc và cây widget. Thực hiện theo các đợt nhỏ có kiểm chứng; sửa hành vi và nền tảng trước khi tái cấu trúc UI.

Nguồn quyết định: [Implementation Plan hiện hành](FairShare_Project_Implementation_Plan.md), đặc biệt mục 3 và 5. Tài liệu này bổ sung kế hoạch khắc phục, không thay đổi các lựa chọn Q01–Q36. Những chi tiết mới như tên lớp, ngưỡng thử OTP và cách lắp route là đề xuất kỹ thuật, chưa phải quyết định sản phẩm đã chốt.

Phạm vi:

- Flutter: entry/bootstrap/app, config/DI, network/session/storage/router, auth data/state/UI, shared widget bị ảnh hưởng, theme/l10n/font và kiểm thử.
- Backend liên quan: hợp đồng lỗi auth, giới hạn nhập OTP và metadata gửi lại mã. Repository đối chiếu hiện tại: `D:/Back-end/GroupSpendingBE`; công việc backend được bàn giao và kiểm chứng riêng, không coi sửa Flutter là đã sửa server.
- Workflow: hoàn thiện và đưa [prompt triển khai tính năng](workflows/implement_feature.md) vào workflows khi thực hiện giai đoạn tương ứng.
- Onboarding/dashboard chỉ chỉnh phần nối phiên, điều hướng, theme/l10n cần thiết để hành trình auth nhất quán. Không xây nghiệp vụ dashboard mới.

Không bao gồm phát triển Google login, quên/reset mật khẩu mới, OCR, thanh toán, thông báo hoặc refactor toàn bộ feature chưa triển khai. Những vấn đề backend cũ ngoài phạm vi hai lượt review hiện tại phải được xác minh lại trước khi mở đầu việc riêng.

## 2. Điểm xuất phát và nguyên tắc

- Review trước đã chạy `flutter analyze` sạch và 20 test hiện có qua. Sáu phép kiểm tra tạm tái hiện lỗi đã được xóa; khi triển khai cần bổ sung regression test bền vững, không coi các phép kiểm tra tạm là test đang có trong repo.
- Hiện có `AuthScreen` 564 dòng, `VerifyOtpScreen` 453 dòng; thư mục widget riêng của auth còn trống.
- Giữ Feature-First Clean Architecture, Cubit, constructor injection, RepositoryProvider/BlocProvider và parse JSON thủ công. Không thêm get_it, UseCase một dòng hoặc framework state khác.
- Domain không phụ thuộc Flutter/Dio/data; core/shared không phụ thuộc feature. Model kế thừa Entity không tự nó cần refactor nếu không tạo vấn đề thực tế.
- Không dùng dữ liệu rỗng giả để che lỗi API. Test không gọi production, không gửi email thật ngoài môi trường kiểm thử được chỉ định.
- Không tự retry thao tác ghi chưa rõ kết quả; chỉ replay khi hợp đồng xác nhận an toàn.
- Không dùng giới hạn số dòng hoặc tỷ lệ coverage làm tiêu chí chất lượng duy nhất.

## 3. Danh sách vấn đề và đầu ra cần đạt

| ID | Vấn đề | Mức ưu tiên | Giai đoạn | Đầu ra kiểm chứng được |
| --- | --- | --- | --- | --- |
| AUTH-01 | Deadlock khi retry lỗi sau refresh | P1 | 2 | 401 → refresh 200 → retry 401/500 đều kết thúc; không giữ hàng đợi lỗi |
| AUTH-02 | OTP không giới hạn số lần nhập sai ở backend | P1 | 3 | Ngưỡng thử được cưỡng chế nguyên tử; sai mã không rollback bộ đếm |
| AUTH-03 | Mọi 403 bị hiểu là chưa xác thực | P2 | 3, 4 | Phân biệt account disabled/unverified/forbidden bằng mã lỗi |
| AUTH-04 | Lỗi resend bị ẩn; snackbar OTP bị lặp theo timer | P2 | 4, 5 | Mỗi thao tác có trạng thái riêng; mỗi lỗi chỉ hiển thị một lần |
| AUTH-05 | Verify/resend trùng; response cũ còn hiệu lực sau back/logout | P2 | 2, 4 | Một thao tác đang chạy; response cũ không sửa state hoặc lưu token |
| AUTH-06 | Cooldown 60 giây khởi động khi chưa gửi mã | P2 | 3, 4 | Chỉ đếm theo một lần gửi được chấp nhận hoặc deadline còn hiệu lực |
| AUTH-07 | Timeout/5xx refresh làm logout | P2 | 2 | Giữ phiên ở trạng thái cần thử lại; không xóa token vì lỗi tạm thời |
| AUTH-08 | Có chuỗi token là được xem như authenticated; thiếu route guard | P2 | 2 | Bootstrap quyết định phiên trước route riêng tư; guard theo session |
| ARCH-01 | Khởi tạo dependency trong build; chưa rõ dispose | P2 | 1 | Instance ổn định qua rebuild, đúng owner và scope |
| ARCH-02 | State gộp phiên/form/timer; nullable không xóa được | P2 | 4 | Session và form tách biệt; reset xóa đúng email/user/error |
| ARCH-03 | Parser chấp nhận dữ liệu bắt buộc thiếu/token null | P2 | 4 | Sai schema trở thành lỗi dữ liệu; không authenticated khi response thiếu token |
| ARCH-04 | Refresh triển khai hai nơi; lắp route trong core import feature | P2 | 1, 2 | Một đường điều phối refresh; đăng ký màn hình ở cấp app |
| CFG-01 | Production URL cố định; refresh bỏ qua client được inject | P2 | 1 | Mọi request cùng cấu hình môi trường; test không có đường gọi production |
| UI-01 | Chuỗi vi hard-code, màu sáng cố định, font chưa đóng gói | P2 | 5 | Auth chạy vi/en, light/dark; Nunito hoạt động offline |
| UI-02 | Build dài, countdown rebuild toàn màn hình, OTP tràn ngang | P2 | 5 | Widget có trách nhiệm rõ, cập nhật cục bộ, không tràn ở 320 px |
| PROC-01 | Workflow hiện tại chưa hướng dẫn triển khai tính năng | P3 | 6 | Có prompt triển khai và checklist tự review khớp quyết định dự án |

## 4. Thứ tự và phụ thuộc

| Giai đoạn | Nội dung | Điều kiện bắt đầu | Phạm vi phụ trách |
| --- | --- | --- | --- |
| 0 | Xác nhận contract và baseline | Có repo hiện tại | Flutter + backend |
| 1 | Cấu hình môi trường, DI và lifecycle | Sau 0; không cần đợi mọi sửa đổi backend | Flutter |
| 2 | Session, interceptor, bootstrap và guard | Sau phần config/DI của 1 | Flutter |
| 3 | Lỗi auth, chống đoán OTP, metadata resend | Sau 0; làm cùng thời gian với 1–2 | Backend |
| 4 | Parser, form state và hành vi OTP | Sau 2; tích hợp mã lỗi/metadata khi 3 sẵn sàng | Flutter + contract test |
| 5 | Widget, theme, l10n, font và responsive | Sau 4; có thể chuẩn bị assets/theme sớm | Flutter |
| 6 | Workflow, kiểm tra kiến trúc và nghiệm thu tích hợp | Sau các phần liên quan của 1–5 | Flutter + backend/QA |

Không đợi refactor UI mới sửa hai lỗi P1. Giai đoạn 3 được bắt đầu ngay khi thống nhất hợp đồng ở giai đoạn 0. Các test hồi quy đi cùng từng giai đoạn, không dồn đến cuối.

## 5. Công việc chi tiết

### Giai đoạn 0 — Contract và baseline

**Công việc**

1. Kiểm tra diff, hướng dẫn repo và test hiện tại; ghi lại hành trình login/register/verify/logout/onboarding để bảo toàn giao diện và các lựa chọn đã xác nhận.
2. Lập `documents/contracts/auth_contract.md` với request/response thành công và lỗi cho register, login, verify, resend, refresh, logout; ghi nguồn và phiên bản backend thực sự đối chiếu.
3. Phân biệt response đăng ký đang chờ xác thực với response đã cấp phiên. Xác nhận trường bắt buộc, trạng thái disabled, token refresh có rotation không và hành vi OTP sau xác thực thành công nhưng client mất response.
4. Chốt môi trường test, chính sách replay, nguồn xác định thời hạn token và cách xác nhận phiên lúc bootstrap. Không tự tạo endpoint `/me` nếu contract chưa có.
5. Ghi quyết định còn thiếu trong bảng mục 7; phần chưa biết không được thay bằng giả định âm thầm.

**Điều kiện hoàn tất:** có fixture cho các response đang dùng và bảng khác biệt Flutter/backend; biết phần nào tích hợp thật, phần nào phải chờ backend. Baseline không phát sinh request production.

### Giai đoạn 1 — Cấu hình, lắp dependency và vòng đời

**File chính:** `lib/main.dart`, mới `lib/bootstrap.dart`, `lib/app.dart`; `core/config/app_config.dart`, `core/network/api_client.dart`, phần lắp router; README hướng dẫn chạy.

**Công việc**

- `main.dart` chỉ giữ entry point; bootstrap nạp cấu hình/settings và tạo dependency. App lắp provider/theme/locale/router. Xử lý lỗi bootstrap bằng trạng thái lỗi/Retry, không để splash treo vô hạn.
- Nạp `APP_ENV`, `API_BASE_URL` từ cấu hình build, ví dụ dart-define; chọn cơ chế cụ thể theo quy trình build hiện có. Kiểm tra cấu hình thiếu/sai trước khi gửi request; không fallback production. Không nhúng secret backend.
- Inject client refresh riêng nhưng dùng cùng AppConfig với client thường. Cả hai có adapter giả lập được trong test và chủ sở hữu đóng client.
- Tạo dependency dài hạn một lần theo scope. Provider dùng `create` khi sở hữu Cubit; `.value` chỉ dùng cho instance do owner khác quản lý. Theme/locale rebuild không tạo Cubit/client/router mới.
- Đăng ký màn hình feature ở cấp app, ví dụ `lib/app_routes.dart`; core/router nhận cấu hình route và trạng thái session. Ghi rõ đây là cách giải quyết mâu thuẫn vị trí router và quy tắc core không import feature, không mở ngoại lệ phụ thuộc ngầm.
- Khai báo rõ metadata public/authenticated của request; bỏ nhận diện quyền bằng `path.contains(...)`. Không tạo registry endpoint tổng quát quá mức cho feature chưa tồn tại.

**Kiểm chứng:** đổi config thì login và refresh cùng đến môi trường giả lập đó; thiếu config không gửi request; rebuild app không tạo phiên bản dependency mới; dispose đúng khi owner bị tháo.

### Giai đoạn 2 — Session, refresh, bootstrap và điều hướng

**File chính:** `core/session/*`, `core/network/auth_interceptor.dart`, `core/storage/token_storage.dart`, `core/router/*`, `app_routes.dart`; adapter trong `features/auth/data/`; nối lại `FlashScreen` và logout.

**Thiết kế đề xuất**

- `SessionCoordinator` trong core/session giữ trạng thái phiên, thế hệ phiên và thao tác commit/clear token. API của nó không import UserEntity hay model của feature.
- Contract gateway refresh trung lập đặt ở core/session; adapter trong auth/data gọi datasource bằng client refresh. Điểm lắp ghép ở app inject adapter. Không để core import AuthRepository/AuthCubit hoặc để Cubit gọi Cubit.
- Chỉ một nơi điều phối refresh. Repository có thể giữ API tương thích trong đợt chuyển đổi nhưng phải chuyển tiếp về cùng cơ chế, không còn hai nhánh tự lưu token riêng.

**Công việc**

1. Dùng một Future refresh dùng chung cho cùng phiên. Request 401 đến muộn kiểm tra token mà nó đã dùng so với token hiện tại để tránh refresh nối tiếp không cần thiết.
2. Bỏ cấu trúc giữ hàng đợi lỗi rồi await request đi qua cùng hàng đợi. Mỗi request có dấu đã replay; request public/refresh và request không bảo đảm replay an toàn không tự gửi lại.
3. Tách lỗi refresh do token bị xác nhận vô hiệu khỏi lỗi mạng/5xx/parse/storage. Lỗi tạm thời giữ token, đưa phiên về cần thử lại và chặn thao tác cần phiên hợp lệ. Không gọi API logout đệ quy từ interceptor.
4. Bootstrap đọc token và metadata thời hạn theo contract; token cần refresh thì thử refresh trước route riêng tư. Việc đọc `exp` chỉ giúp quyết định thời hạn, không tự chứng minh token chưa bị server thu hồi. Nếu contract có kiểm tra phiên, sử dụng đúng endpoint đã xác nhận.
5. Mọi login/verify/refresh mang thế hệ phiên và mã thao tác. Kiểm tra hiệu lực trước khi lưu token và phát authenticated. Back khỏi verification vô hiệu hóa thao tác đó; logout/đổi tài khoản tăng thế hệ phiên.
6. Serialize commit/clear token và kiểm tra generation trong cùng vùng đồng bộ. Bảo đảm logout thắng response cũ ngay cả khi thao tác lưu secure storage đang chờ; chỉ bỏ qua emit trong Cubit là chưa đủ.
7. Lưu token pair theo cách tránh trạng thái nửa cũ nửa mới; nếu đổi định dạng lưu thì đọc tương thích hai key hiện tại và xử lý migration. Lỗi lưu không được phát authenticated giả.
8. Kết thúc phiên cục bộ có tính idempotent, dọn user info và state riêng tư. Logout do người dùng yêu cầu có thể thu hồi token server theo contract, nhưng không đợi vô hạn mới cập nhật trạng thái local.
9. Router theo session state và onboarding policy; một nơi quyết định đích sau authenticated. Deep link giữ đích nội bộ hợp lệ và kiểm tra quyền; back/logout không mở lại route riêng tư. Không xây toàn bộ shell tab của feature chưa triển khai.

**Điều kiện hoàn tất:** AUTH-01/05 phần phiên/07/08 có regression test; hết phiên chỉ xử lý một lần; mất mạng không xóa token; response cũ không phục hồi storage hoặc UI.

### Giai đoạn 3 — Hợp đồng lỗi và bảo vệ OTP ở backend

**File backend dự kiến:** `ApiResponse`, `GlobalExceptionHandler`, `ErrorCode`, `AuthServiceImpl`, entity/repository token xác thực, cấu hình và migration nếu cần; test service/controller/concurrency.

**Công việc**

- Bổ sung `errorCode` ổn định vào response lỗi theo cách tương thích client cũ. Phân biệt chưa xác thực, bị vô hiệu hóa, thiếu quyền, OTP sai/hết hạn/khóa thử, rate limit.
- Bổ sung chính sách số lần thử theo challenge/tài khoản và giới hạn request theo IP phù hợp kiến trúc triển khai. Giá trị cụ thể phải được chốt và đặt trong config; Flutter không chịu trách nhiệm cưỡng chế giới hạn bảo mật.
- Ghi nhận lần thử sai nguyên tử và commit ngay cả khi kết quả là lỗi nghiệp vụ. Không dùng một increment rồi throw exception khiến transaction rollback bộ đếm. Kiểm thử nhiều request đồng thời tại ranh giới giới hạn.
- Khóa/vô hiệu hóa challenge khi vượt ngưỡng; resend không được cho phép né giới hạn tài khoản bằng cách liên tục tạo challenge mới. Xác thực thành công tiêu thụ challenge nguyên tử, không cấp nhiều phiên do hai request cùng đọc một OTP hợp lệ.
- Resend trả thời điểm được gửi lại hoặc `retryAfterSeconds`/`Retry-After` theo contract đã chốt, cả trường hợp thành công và 429. Gửi lại và vô hiệu hóa mã cũ có quy tắc rõ ràng khi có request đồng thời.
- Xác nhận disabled account không được cấp phiên qua verify hoặc refresh, nhất quán với login. Đây là điều kiện tích hợp cần kiểm tra ở các đường cấp token liên quan.
- Phân biệt email được chấp nhận gửi với đã giao tới hòm thư. Xác nhận hành vi khi gửi email thất bại; không thêm queue/outbox mới trong đợt này nếu chưa cần và chưa thống nhất phạm vi.

**Điều kiện hoàn tất:** contract fixture khớp HTTP response thật; bộ đếm không rollback, không vượt ngưỡng vì race; có kết quả test backend. Rate limit tại gateway, nếu có, là lớp bổ sung được kiểm tra riêng.

### Giai đoạn 4 — Parser và state của login/register/verification

**File chính:** `features/auth/data/models/*`, `data/datasources/auth_remote_data_source.dart`, `data/repositories/auth_repository_impl.dart`, domain contract/entity cần thiết, `presentation/cubit/*`, `core/errors/app_exception.dart`.

**Công việc**

- Parse envelope và dữ liệu theo từng thao tác. Register chờ xác thực không bắt buộc token; login/verify thành công yêu cầu token hợp lệ theo contract; refresh chỉ giữ refresh token cũ nếu contract cho phép.
- Trường bắt buộc thiếu/sai kiểu → lỗi dữ liệu có thể xử lý; không thay email/tên bằng chuỗi rỗng để tiếp tục. Mặc định optional theo contract. Không authenticated trước khi lưu phiên thành công.
- Tách session app-wide khỏi form. Đề xuất `AuthFormCubit` cho login/register và `VerificationCubit` cho route OTP; không tách thêm Cubit cho từng trường nhập liệu. Tiến trình gửi form, xác thực OTP và resend độc lập.
- State có `copyWith` hỗ trợ xóa nullable và collection bất biến. Reset xóa pendingEmail/user/error thuộc flow; dữ liệu user phiên được quản lý qua session, không lưu như user đã đăng nhập khi mới register.
- Chỉ `ACCOUNT_NOT_VERIFIED` đưa sang verification. Không fallback toàn bộ 403; nếu backend cũ không trả mã thì hiển thị lỗi chung, không suy đoán bằng nội dung message.
- Khóa verify/resend trước await, vô hiệu hóa callback phù hợp ở UI. Kết quả cũ sau back/đổi email không cập nhật state hoặc lưu token; có xử lý khi Cubit đã close.
- Cooldown dựa trên deadline và đồng hồ có thể inject để test; tick chỉ phục vụ hiển thị. Rebuild/resume không tự đặt lại 60 giây. Login unverified cho người dùng yêu cầu mã mới hoặc gửi theo policy đã chốt, không báo đã gửi khi chưa gọi API.
- Lỗi verify/resend được phân loại riêng. Listener thông báo một lần theo effect ID hoặc thay đổi trạng thái thao tác; timer không phát lại lỗi. Clear lỗi khi bắt đầu thao tác mới.
- Tình huống verify đã được server chấp nhận nhưng client mất response phải có đường phục hồi, ví dụ trở lại login khi server xác nhận đã verified; không liên tục thử OTP đã tiêu thụ. Không tự coi mã đã verified là có phiên hợp lệ.

**Điều kiện hoàn tất:** AUTH-03/04/05 phần form/06 và ARCH-02/03 có test; register/login/verify chạy qua repository thực với adapter giả lập, không chỉ fake repository trả thành công.

### Giai đoạn 5 — Widget, responsive, theme, l10n và font

**File chính:** auth screens/widgets, `shared/widgets/app_text_field.dart`, `app_primary_button.dart`, `core/theme/*`, `core/l10n/*`, `assets/fonts/`, `pubspec.yaml`, `l10n.yaml`; các chuỗi/theme liên quan trong onboarding/dashboard placeholder.

**Phân chia widget đề xuất**

| Screen | Widget con | Trách nhiệm còn lại của screen |
| --- | --- | --- |
| AuthScreen | AuthHeader, LoginForm, RegisterForm, phần đăng nhập xã hội, AuthModeSwitcher | Bố cục trang, mode, nối state/callback và listener thao tác |
| VerifyOtpScreen | VerificationHeader, OtpInput, ResendOtpSection | Bố cục trang và nối verification state/callback |
| FlashScreen | Branding/progress nếu cần | Hiển thị bootstrap state; không tự đọc token và quyết định phiên |

**Công việc**

- Widget feature nằm trong presentation/widgets, không đẩy tất cả vào shared. Dùng widget class có tham số rõ; controller/focus/timer có owner, dispose đúng.
- Giới hạn rebuild bằng selector/buildWhen. Countdown chỉ cập nhật vùng resend; tách widget không được làm phát sinh thêm listener hoặc side effect.
- Hàng OTP dùng chiều rộng khả dụng và gap xác định; hỗ trợ nhập, paste, backspace, autofill nếu nền tảng hỗ trợ, focus và semantics. Khi submit chạy không tự tạo request mới do người dùng sửa đủ sáu số.
- Chuyển chuỗi hiển thị sang ARB vi/en, kể cả validation/error/accessibility. Thông điệp không gán nhãn xác minh email một lần là xác thực hai lớp.
- Xây light/dark bằng ColorScheme và token theo vai trò. Chuyển màu lặp hoặc phá theme khỏi screen; giữ literal cục bộ hợp lý. Typography theo vai trò thay vì mọi nơi tùy biến font size không có quy ước.
- Đóng gói các weight Nunito đang dùng, cấu hình assets/font và tắt phụ thuộc tải font runtime. Xác nhận giấy phép font đi cùng asset. Không tải font mạng trong widget test.
- Tách validator thuần cho các quy tắc đã chốt; không sao chép quy tắc server chưa được xác nhận. Gom độ dài OTP/cooldown fallback đã chốt vào cấu hình feature thay vì rải số ở UI và Cubit.
- Screen/build dài là tín hiệu xem lại trách nhiệm, không đặt hard limit dòng code. Có thể tham khảo build ~100 dòng, screen ~300 dòng nhưng không tách widget vô nghĩa để đạt mốc.

**Điều kiện hoàn tất:** giao diện giữ ý đồ thiết kế HTML; auth/OTP không overflow ở chiều rộng 320/393/430 logical px, text scale 1.0/1.5/2.0, bàn phím mở, email dài, vi/en và light/dark. Test tự động chọn các tổ hợp rủi ro, kiểm tra trực quan trên thiết bị có sẵn và ghi giới hạn nền tảng.

### Giai đoạn 6 — Workflow và nghiệm thu tích hợp

- Hoàn thiện `documents/workflows/implement_feature.md`, loại bỏ phần mô tả bản nháp khi cài vào `.agents/workflows/implement-feature.md`; giữ hướng dẫn đọc quyết định đã chốt, contract, hard-code, lifecycle, widget và tự review.
- Cập nhật tài liệu kiến trúc về trách nhiệm session/router và cấu hình môi trường sau khi thiết kế được áp dụng; không ghi đề xuất thành hiện trạng trước khi triển khai.
- Bổ sung kiểm tra nhẹ cho domain import Flutter/Dio/data, core/shared import feature và chuỗi UI/màu hard-code đáng chú ý. Không bắt buộc thêm plugin lint lớn; review diff có thể là bước đầu, ngoại lệ phải có lý do.
- README ghi cách chạy dev/staging/prod, cách chạy test không chạm production, contract backend cần có và giới hạn kiểm chứng.
- Chạy contract/E2E trên môi trường test với tài khoản kiểm thử; kiểm tra hành trình register → verify → login → restart → refresh → logout, cả lỗi/chặn quyền và phục hồi mạng.
- Build Android theo cấu hình đã thống nhất; kiểm tra iOS trên môi trường macOS/CI phù hợp. Không khẳng định iOS đã pass từ máy Windows hoặc widget test.

**Điều kiện hoàn tất:** mọi ID ở mục 3 có bằng chứng hoặc dependency còn mở được nêu rõ; workflow hoạt động được thêm đúng nơi trong đợt triển khai, không chỉ có file đề xuất.

## 6. Ma trận kiểm chứng bắt buộc theo rủi ro

| Kịch bản | Kết quả mong đợi | Loại kiểm tra |
| --- | --- | --- |
| Nhiều request cùng dùng token cũ nhận 401 | Một refresh cho đợt token đó; không phát sinh refresh dây chuyền vì response đến muộn | Interceptor/session |
| Retry sau refresh trả 401 hoặc 500 | Future kết thúc; tối đa một replay; không deadlock | Interceptor |
| Refresh timeout/mất mạng/5xx | Token còn lưu, phiên cần thử lại, không gọi logout lặp | Session + widget |
| Logout trong lúc refresh/login/verify hoặc ghi storage đang chạy | Không phục hồi token/user/route của phiên cũ | Session + storage race |
| Token thiếu/hết hạn/refresh token vô hiệu lúc mở app | Bootstrap/guard đi đúng trạng thái, không hiện dashboard như phiên hợp lệ | Router integration |
| 403 disabled và 403 unverified | Chỉ unverified mở OTP; disabled có thông báo đúng | Contract + Cubit |
| Response success thiếu token hoặc field bắt buộc | Lỗi dữ liệu, không lưu phiên một phần, không authenticated | Parser + repository |
| OTP sai và countdown tiếp tục tick | Một thông báo lỗi cho một lần submit | Widget |
| Resend lỗi 429/timeout | Hiện lỗi đúng; deadline chỉ thay theo contract | Cubit + widget |
| Bấm resend nhiều lần/nhập OTP nhiều lần khi request đang chạy | Chỉ một request cho thao tác; verify và resend phối hợp đúng | Cubit + widget |
| Back/đổi email trước khi verify hoàn tất | Không navigate hoặc lưu phiên từ thao tác đã bỏ | Repository + Cubit/router |
| Login unverified có OTP cũ hết hạn | Không khóa gửi lại giả 60 giây; không nói đã gửi mã mới | Contract + widget |
| Background/resume khi đang cooldown | Thời gian còn lại dựa trên deadline, không reset hoặc đếm chậm theo timer bị dừng | Cubit |
| Nhập OTP sai đến ngưỡng, kể cả request đồng thời | Bị khóa đúng; bộ đếm không rollback; resend không né giới hạn | Backend integration/concurrency |
| Hai verify cùng OTP hợp lệ | Chỉ một lần tiêu thụ challenge theo contract | Backend concurrency |
| Theme/locale rebuild và đóng cây provider | Instance cần giữ không bị tạo lại; resource được đóng đúng owner | Lifecycle test |
| Màn 320 px/chữ lớn/vi-en/dark/bàn phím | Không overflow hoặc che thao tác chính; thông tin đọc được | Widget + kiểm tra trực quan |
| API test khác production, kể cả refresh | Toàn bộ request đi adapter/môi trường test đã inject | Network/config |

Không chạy toàn bộ tổ hợp UI một cách máy móc. Ưu tiên tình huống thất bại đã review và vùng bị thay đổi. Unit/widget test không thay thế bằng chứng backend hoặc thiết bị.

## 7. Quyết định cần xác nhận khi bắt đầu phần liên quan

| Điểm chưa chốt | Đề xuất | Ảnh hưởng nếu còn thiếu |
| --- | --- | --- |
| Ngưỡng thử OTP, thời gian khóa và phạm vi rate limit | Cấu hình backend, kết hợp challenge/tài khoản/IP; chọn ngưỡng sau khi đối chiếu nhu cầu và hạ tầng | Chặn nghiệm thu AUTH-02, không chặn sửa Flutter độc lập |
| Mã lỗi và metadata resend | errorCode ổn định; retryAfterSeconds hoặc deadline có quy ước rõ | Chặn tích hợp chính xác AUTH-03/06; có thể viết fixture đề xuất trước |
| Xác nhận phiên lúc bootstrap | Theo contract hiện có: thời hạn token, refresh và kiểm tra server nếu API hỗ trợ | Không được tự thêm endpoint hoặc coi chuỗi token là bằng chứng đủ |
| Endpoint nào được replay an toàn | Danh sách theo contract; mặc định không tự replay mutation chưa được xác nhận | Chặn tự retry ghi, không chặn single-flight refresh |
| Thứ tự onboarding/auth và đích sau verify/deep link | Giữ hành vi đã xác nhận; dùng một policy chung, ghi rõ khác biệt hiện tại giữa screen | Chốt trước khi thay router để không đổi sản phẩm ngoài ý muốn |
| Locale/theme mặc định | Theo quyết định sản phẩm; hỗ trợ lưu lựa chọn hiện có nếu có | Có thể triển khai resource trước, chưa tự quyết mặc định |
| Lắp router tại app và core/session trung lập | Dùng thiết kế giai đoạn 1–2 để giữ core không import feature | Ghi nhận trong quyết định kiến trúc trước khi áp dụng |
| Môi trường dev/staging, test account và email test | Cung cấp cấu hình riêng, không fallback production | Chặn E2E thật, không chặn test bằng adapter giả lập |

Không hỏi lại các lựa chọn đã có trong Implementation Plan. Khi thiếu thông tin, chỉ hỏi phần ảnh hưởng trực tiếp; tiếp tục các đầu việc độc lập.

## 8. Chia đợt thay đổi và nghiệm thu

| Đợt thay đổi đề xuất | Nội dung | Bằng chứng cần kèm |
| --- | --- | --- |
| A | Contract/baseline + config/DI/lifecycle | Fixture, test config/lifecycle, hướng dẫn chạy |
| B | Session/interceptor/bootstrap/router | Regression deadlock, concurrency, logout race, guard |
| C — backend riêng | Error contract + OTP limits + resend metadata | API fixtures, migration nếu có, test concurrency |
| D | Parser + auth form/verification state | Test dữ liệu sai, mã lỗi, trùng request, response cũ |
| E | Widget + theme/l10n/font | Widget test rủi ro, đối chiếu thiết kế và ma trận UI |
| F | Workflow/docs + E2E/build theo môi trường | Kết quả thực tế, dependency/giới hạn còn lại |

Mỗi đợt phải biên dịch được và giữ hành trình hiện có trong lúc chuyển đổi. Không để cả AuthCubit cũ lẫn policy mới cùng điều hướng. Chỉ xóa đường code cũ khi consumer đã chuyển hết và regression liên quan qua; khi rollback phải xét tương thích token storage/API, không bật lại fallback 403 hoặc cơ chế refresh đã biết treo.

Các đợt trên là đơn vị review, không phải yêu cầu tạo PR ngay trong lượt lập kế hoạch. Không ấn định số ngày khi chưa biết nguồn lực backend, môi trường test và mức sẵn sàng contract.

Tiêu chí hoàn thành kế hoạch khắc phục: các lỗi trong phạm vi được giải quyết và có bằng chứng tương ứng; analyze/test liên quan qua; kiểm tra môi trường/build/UI được báo đúng phạm vi đã chạy. Theo Q35-B của dự án, tiếp tục báo riêng **UI + happy path mô phỏng** và **tích hợp API**. Bộ kiểm tra khắc phục này không tự thay thế tiêu chí feature đã chốt hoặc biến mock thành bằng chứng backend hoàn tất.

## 9. Checklist triển khai

- [ ] G0: contract và baseline được ghi nhận; các câu hỏi thật sự còn mở có chủ trì xử lý.
- [ ] G1: cấu hình môi trường/DI/lifecycle đạt kiểm tra; không có đường refresh về production ngoài config.
- [ ] G2: session/refresh/router đạt regression; không mất phiên do lỗi tạm thời hoặc hồi sinh phiên cũ.
- [ ] G3: backend trả mã lỗi đúng và cưỡng chế OTP nguyên tử; metadata resend thống nhất.
- [ ] G4: parser/state/OTP xử lý lỗi, reset, request trùng và response cũ đúng.
- [ ] G5: widget/theme/l10n/font/responsive được kiểm tra theo ma trận đã nêu.
- [ ] G6: workflow được áp dụng, tài liệu cập nhật, E2E/build được báo cáo cùng giới hạn thực tế.

Tất cả checkbox hiện để trống vì tài liệu này là kế hoạch, không phải báo cáo đã triển khai.
