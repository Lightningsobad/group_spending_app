# Kế hoạch chỉnh sửa luồng thông báo

Ngày lập: 06/11/2026. Trạng thái: kế hoạch triển khai, chưa sửa mã nguồn.

## 1. Mục tiêu và cơ sở review

Khắc phục bảy vấn đề trong luồng REST → STOMP/FCM → badge/inbox → đánh dấu đã đọc/xóa → điều hướng. Bảo đảm dữ liệu đúng phiên đăng nhập, thao tác được đồng bộ với server và người dùng đến đúng nội dung của thông báo.

Review dựa trên mã nguồn hiện tại và `Mobile_Notification_API_Integration_Guide.md`. Working tree sạch khi review. Đã chạy `flutter test test/features/notifications`: 21 test pass. Các test hiện có chưa xác nhận điều hướng đến màn hình thực, xử lý response đảo thứ tự, đổi phiên hoặc lỗi mutation. Chưa kiểm thử push trên thiết bị thật hay xác minh hợp đồng backend đang triển khai.

Tài liệu này mô tả công việc cần làm; các ca nghiệm thu bên dưới chưa được thực hiện.

## 2. Danh sách công việc

| ID | Ưu tiên | Vấn đề | Kết quả cần đạt |
| --- | --- | --- | --- |
| NOTI-01 | P1 | Response phiên cũ có thể ghi lại dữ liệu sau logout | Mọi callback/request chỉ tác động lên phiên còn hiệu lực |
| NOTI-02 | P1 | Handler công nợ tìm DebtsCubit sai phạm vi provider | Mở tab công nợ và chọn đúng nhóm, đúng chế độ xem |
| NOTI-03 | P2 | Bấm push/toast chưa đánh dấu đã đọc đầy đủ | Cả ba điểm vào inbox, push và toast đều đồng bộ đã đọc |
| NOTI-04 | P2 | Thông báo chi tiêu/thành viên chỉ mở danh sách nhóm | Mở đúng chi tiết hoặc danh sách liên quan theo loại sự kiện |
| NOTI-05 | P2 | Response bộ lọc cũ ghi đè danh sách mới | Chỉ truy vấn còn hiệu lực được cập nhật danh sách/phân trang |
| NOTI-06 | P2 | Đọc/xóa thất bại nhưng UI giữ trạng thái thành công | Thất bại được phản ánh, dữ liệu được khôi phục hoặc đối soát |
| NOTI-07 | P2 | Lỗi tải inbox bị hiển thị như danh sách rỗng | Phân biệt lỗi, rỗng và dữ liệu cũ; có đường thử lại |

Thứ tự đề xuất: NOTI-01 → NOTI-05 → NOTI-06 → NOTI-03 → NOTI-02 → NOTI-04 → NOTI-07. Xác minh ma trận điều hướng và khả năng API ngay từ đầu; NOTI-03 sử dụng cơ chế xử lý mutation của NOTI-06.

## 3. NOTI-01 — Cô lập dữ liệu theo phiên

### Thiết kế chỉnh sửa

1. Cung cấp `SessionCoordinator` cho `NotificationsCubit`, dùng `sessionEpoch` và một generation nội bộ tăng khi `clear()` để vô hiệu hóa tác vụ cũ.
2. Chụp epoch/generation trước mỗi tác vụ bất đồng bộ. Trước mọi emit sau await, xác nhận cubit chưa đóng, phiên còn xác thực và epoch/generation còn khớp. Áp dụng cả nhánh thành công, lỗi và rollback; không chỉ tải danh sách mà cả unread count và mutation.
3. `clear()` vô hiệu hóa request, reset danh sách, badge, filter, trạng thái loading và thao tác chờ.
4. Trong `app.dart`, chụp epoch trước khi lấy current user để kết nối STOMP; không kết nối bằng user của phiên cũ. Callback STOMP/FCM chỉ được chuyển vào state/UI khi phiên hợp lệ. Không hiển thị toast còn sót sau logout.
5. Kiểm tra khả năng nhận push đã xếp hàng cho tài khoản trước trên cùng thiết bị. Nếu payload không có thông tin nhận diện người nhận, đối soát thông báo với API của phiên hiện tại trước khi hiển thị/điều hướng; ghi rõ hợp đồng payload cần bổ sung thay vì giả định có thể kiểm tra bằng epoch.

### File dự kiến

- `lib/features/notifications/presentation/cubit/notifications_cubit.dart`
- `lib/app.dart`
- Các service STOMP/FCM và toast nếu cần vô hiệu hóa callback/overlay.

### Nghiệm thu

- Dùng fake repository và `Completer`: bắt đầu tải cho A → logout → đăng nhập B → trả response của A. Không có dữ liệu, badge hoặc lỗi của A trong state B.
- Mutation của A thất bại sau khi B đăng nhập không rollback dữ liệu A vào B.
- Logout trong khi lấy current user không tạo kết nối STOMP cũ; callback sau logout không hiện toast.
- Đóng cubit khi request còn chạy không gây emit sau close.

## 4. NOTI-02 — Điều hướng công nợ đúng phạm vi

### Thiết kế chỉnh sửa

1. Bỏ việc đọc `DebtsCubit` bằng `AppRouter.navigatorKey.currentContext`; provider nằm dưới navigator trong `MainShellScreen`.
2. Truyền ý định điều hướng bằng route, gồm tab công nợ, groupId và chế độ xem. Màn hình shell/công nợ tiêu thụ ý định sau khi provider sẵn sàng, chọn nhóm và tải dữ liệu.
3. Hỗ trợ cập nhật ý định khi dashboard đang mở, kể cả đang ở tab công nợ. Không chỉ xử lý trong `initState`; không dùng delay cố định hay nuốt lỗi provider để đồng bộ vòng đời.
4. Ánh xạ `DEBT`, `SIMPLIFIED_DEBT`, `DEBT_SETTLEMENT` theo tài liệu API và khả năng màn hình hiện tại. Với settlement, xác định màn hình hoặc tab có thao tác xác nhận tương ứng; không mặc định mọi reference khác DEBT đều vào chế độ rút gọn.
5. Khi nhóm không còn truy cập được, hiển thị lỗi phù hợp và cho quay lại danh sách công nợ.

### File dự kiến

- `lib/features/notifications/services/notification_navigation_handler.dart`
- `lib/app_routes.dart`
- `lib/features/main_shell/presentation/screens/main_shell_screen.dart`
- Màn hình/cubit công nợ liên quan đến tiếp nhận ý định điều hướng.

### Nghiệm thu

- Widget test với router và provider thực: bấm từng loại thông báo công nợ từ tab khác và khi đang xem nhóm khác; đúng nhóm, đúng chế độ, đúng request tải dữ liệu.
- Hai lần mở liên tiếp đến hai nhóm phải kết thúc ở nhóm mới nhất.
- Thông báo không đủ ID hoặc nhóm trả 403/404 có fallback rõ ràng, không im lặng.

## 5. NOTI-03 — Thống nhất hành vi mở và đánh dấu đã đọc

### Thiết kế chỉnh sửa

1. Tạo một điểm xử lý mở thông báo dùng chung cho inbox, toast và FCM tap: xác thực phiên → đánh dấu đã đọc → điều hướng. Lỗi đánh dấu đọc không chặn người dùng xem nội dung, nhưng phải được phản ánh và đối soát theo NOTI-06.
2. `markAsRead(id)` phải gọi API cho ID hợp lệ ngay cả khi không có trong danh sách cục bộ. Chỉ cập nhật item nếu item tồn tại.
3. Với ID không có local, không trừ badge theo phỏng đoán. Sau khi API thành công, tải lại unread count có kiểm soát epoch/request để lấy số chính xác.
4. Chống gửi trùng khi người dùng bấm nhiều lần hoặc hai kênh cung cấp cùng thông báo. Đọc lại item đã đọc không làm badge giảm thêm.
5. Với cold start, giữ ý định mở đến khi router và xác thực sẵn sàng; nếu cần đăng nhập, tiếp tục ý định sau đăng nhập khi đã xác minh quyền truy cập. Không bỏ mất sự kiện chỉ vì context chưa mount.

### File dự kiến

- `lib/app.dart`
- `lib/features/notifications/presentation/cubit/notifications_cubit.dart`
- `lib/features/notifications/presentation/widgets/in_app_notification_toast.dart`
- `lib/features/main_shell/presentation/widgets/notification_modal.dart`
- `lib/features/notifications/services/fcm_service.dart` và handler/coordinator mở thông báo.

### Nghiệm thu

- Push ID chưa từng tải trong inbox vẫn gọi API read, điều hướng và đồng bộ badge.
- Toast và inbox có cùng hành vi; bấm lặp không giảm badge hai lần hoặc tạo nhiều route trùng.
- Kiểm tra trên Android/iOS: foreground, background và terminated; ý định không mất khi qua splash/đăng nhập.

## 6. NOTI-04 — Hoàn thiện đích điều hướng chi tiêu/thành viên

### Ma trận cần triển khai

| Loại | Đích mong đợi | Fallback |
| --- | --- | --- |
| EXPENSE_CREATED / EXPENSE_UPDATED | Chi tiết khoản chi theo referenceId, trong đúng nhóm | Danh sách chi tiêu của nhóm nếu khoản chi không còn tồn tại |
| EXPENSE_DELETED | Danh sách chi tiêu của groupId | Danh sách nhóm nếu không còn quyền vào nhóm |
| MEMBER_JOIN_REQUEST | Danh sách yêu cầu gia nhập của đúng nhóm | Thông báo không đủ quyền hoặc yêu cầu không còn tồn tại |
| MEMBER_JOIN_APPROVED | Chi tiết đúng nhóm | Danh sách nhóm kèm phản hồi nếu không thể mở |
| MEMBER_JOIN_REJECTED | Trang chủ | Giữ hành vi hiện tại |

### Thiết kế chỉnh sửa

1. Đối chiếu ma trận trong tài liệu API với màn hình thực tế. Tái sử dụng màn hình hiện có; bổ sung route/ý định mở nội dung nếu màn hình đang chỉ được mở bằng state nội bộ.
2. Truyền đủ groupId/referenceId. Nếu dữ liệu điều hướng nằm trong `data`, xác minh hợp đồng rồi chuẩn hóa tại model/parser; không suy đoán cấu trúc payload.
3. Tải dữ liệu đích theo ID thay vì yêu cầu model đã có trong bộ nhớ. Kiểm tra quyền bằng phản hồi API; không dựa vào tên loại thông báo để cấp quyền duyệt thành viên.
4. Xử lý 403/404 với phản hồi dễ hiểu và fallback theo bảng. Không mở màn hình chi tiết rỗng hoặc tự chuyển trang không giải thích.

### File dự kiến và nghiệm thu

Sửa handler, `app_routes.dart` và các màn hình chi tiêu/nhóm cần nhận ý định. Bổ sung widget test cho từng hàng trong bảng, gồm ID hợp lệ, thiếu ID, đối tượng đã xóa và mất quyền truy cập. Kiểm tra từ cả inbox lẫn push để bảo đảm dùng cùng đích điều hướng.

## 7. NOTI-05 — Kiểm soát request danh sách và phân trang

### Thiết kế chỉnh sửa

1. Mỗi lần refresh/đổi filter tạo một request generation mới, chụp toàn bộ query tại lúc gửi. Chỉ response thuộc generation/query hiện hành được cập nhật state.
2. `loadMore()` gắn với generation, query và page đã chụp. Refresh/đổi filter vô hiệu hóa loadMore cũ và reset loading-more/page/hasReachedMax phù hợp.
3. Bảo vệ cả unread count: response đếm cũ không được ghi đè số mới sau đọc/xóa hoặc nhận realtime. Có thể dùng revision riêng và đối soát lại sau tác vụ mới nhất.
4. Khi nhận realtime trong lúc tải trang đầu, không để response cũ xóa mất item mới. Dùng revision hoặc buffer sự kiện để merge theo ID; chỉ đưa item vào danh sách nếu khớp filter hiện hành.
5. Khi đang lọc chưa đọc, đánh dấu đọc thành công phải loại item khỏi tập hiển thị. Rà soát phân trang sau đọc/xóa vì tập server có thể dịch chuyển; reset/tải lại các trang cần thiết để tránh bỏ sót item.

### File dự kiến

- `lib/features/notifications/presentation/cubit/notifications_cubit.dart`
- `lib/features/notifications/presentation/cubit/notifications_state.dart` nếu cần thêm metadata.

### Nghiệm thu

- A chậm/B nhanh: bộ lọc B và dữ liệu B được giữ dù A trả sau, cả trường hợp A thành công hoặc báo lỗi.
- LoadMore cũ trả sau refresh không nối item sai query hoặc ghi lại page cũ.
- Realtime đến trong lúc refresh không mất item, không trùng ID và không làm sai bộ lọc.
- Response unread count cũ sau mutation không làm badge tăng trở lại.

## 8. NOTI-06 — Xử lý lỗi thao tác đọc/xóa

### Thiết kế chỉnh sửa

1. Theo dõi thao tác chờ theo ID và phiên; ngăn thao tác xung đột hoặc xác định rõ thứ tự cho read, delete, read-all và delete-read.
2. Có thể giữ optimistic update cho đọc/xóa đơn, nhưng rollback phải theo item/revision và chỉ khi thao tác còn hiệu lực. Không khôi phục nguyên snapshot toàn danh sách vì có thể xóa thông báo realtime mới nhận.
3. Với thao tác hàng loạt, ưu tiên khóa nút khi gửi và áp dụng kết quả sau thành công; giữ dữ liệu hiện tại và hiển thị lỗi nếu thất bại. Xác định tập item tại thời điểm thao tác, không tự đánh dấu hoặc xóa các item mới đến sau đó.
4. Nếu kết quả không chắc chắn, ví dụ timeout sau khi server có thể đã thực hiện, đối soát danh sách và unread count. Cho người dùng thử lại khi mạng hồi phục.
5. Xử lý riêng 404, 403 và 401 theo tài liệu API: item không tồn tại được loại khỏi local khi phù hợp; lỗi quyền được thông báo; hết phiên đi qua cơ chế session hiện có. Không rollback vào phiên mới.
6. Với swipe delete, bảo đảm việc khôi phục item không vi phạm vòng đời `Dismissible`; có widget test cho nhánh API thất bại.

### File dự kiến và nghiệm thu

Sửa cubit/state, modal và phần thông báo lỗi tương ứng. Test lỗi từng mutation; timeout rồi đối soát; bấm lặp; read rồi delete; thao tác hàng loạt có realtime xen giữa; logout khi mutation đang chạy. Badge phải khớp server sau đối soát và thông báo mới không bị mất do rollback.

## 9. NOTI-07 — Hiển thị lỗi và thử lại trong inbox

### Thiết kế chỉnh sửa

1. Tách lỗi tải ban đầu, refresh, loadMore và mutation để UI chọn cách phản hồi phù hợp.
2. Tải lần đầu thất bại và chưa có dữ liệu: hiển thị thông báo lỗi cùng nút thử lại. Chỉ hiện “không có thông báo” khi tải thành công và kết quả rỗng.
3. Refresh thất bại: giữ dữ liệu cũ và hiển thị lỗi không che nội dung. LoadMore thất bại: giữ trang hiện có và cung cấp nút thử lại ở cuối danh sách.
4. Trạng thái rỗng sau tải thành công vẫn hỗ trợ làm mới. Xóa lỗi cũ khi retry bắt đầu và kết thúc thành công.
5. Dùng chuỗi qua hệ thống l10n hiện có cho nội dung mới.

### File dự kiến và nghiệm thu

Sửa `notification_modal.dart`, notifications state/cubit và l10n liên quan. Widget test các trạng thái loading, empty, initial-error, refresh-error, loadMore-error và retry thành công; xác nhận retry giữ đúng bộ lọc.

## 10. Kế hoạch kiểm thử và hoàn tất

### Kiểm thử tự động

- Mở rộng `test/features/notifications/presentation/cubit/notifications_cubit_test.dart` bằng fake repository điều khiển response qua `Completer`; không dựa vào độ trễ ngẫu nhiên.
- Thay các ca navigation chỉ kiểm tra context null bằng widget test có router/provider, xác nhận route, nhóm được chọn và dữ liệu được tải. Giữ ca null-context như một kiểm tra biên.
- Thêm widget test cho modal/toast và xử lý lỗi thao tác; test parser nếu phải bổ sung payload điều hướng.
- Sau mỗi nhóm sửa, chạy test trực tiếp liên quan. Cuối đợt chạy `flutter test test/features/notifications`, test màn hình/router bị ảnh hưởng và `flutter analyze`. Mở rộng kiểm tra nếu phát hiện lỗi hoặc thay đổi phạm vi.

### Kiểm thử tích hợp trên thiết bị

| Kịch bản | Xác nhận |
| --- | --- |
| Nhận cùng sự kiện qua STOMP và FCM | Không trùng item, badge không tăng hai lần; ghi nhận và sửa nếu toast bị lặp |
| Nhấn push ở foreground/background/terminated | Mở đúng nội dung, không bị splash ghi đè, đã đọc được đồng bộ |
| Chuyển tài khoản trên cùng thiết bị | Không lộ dữ liệu/overlay của phiên trước, token và subscription khớp phiên |
| Mất mạng khi tải/đọc/xóa, rồi kết nối lại | Có phản hồi lỗi, thử lại được, state cuối khớp server |
| Đối tượng bị xóa hoặc quyền nhóm thay đổi | Fallback rõ ràng, không màn hình trống hay lỗi bị nuốt |
| Danh sách nhiều trang, đọc/xóa khi lọc chưa đọc | Không bỏ sót hoặc trùng item do thay đổi phân trang |

### Điều kiện hoàn tất

- Cả NOTI-01 đến NOTI-07 có thay đổi được review và bằng chứng test tương ứng.
- Không có response/rollback/callback phiên cũ cập nhật dữ liệu phiên mới.
- Inbox, toast và push dùng cùng hành vi mở, đánh dấu đọc và xử lý lỗi.
- Điều hướng đạt ma trận đã thống nhất; mọi giới hạn do thiếu màn hình hoặc payload được ghi rõ và xử lý trước khi nghiệm thu mục tương ứng.
- Các kiểm tra liên quan pass; ghi lại lệnh, kết quả và giới hạn kiểm thử thiết bị trong báo cáo triển khai.
- Cập nhật tài liệu API nếu hợp đồng payload/đích điều hướng được xác minh khác tài liệu hiện tại.

## 11. Điểm cần xác minh khi triển khai

1. Payload FCM thực tế: ID thông báo, ID người nhận, groupId/referenceId và cấu trúc `data`; tính tương đương với REST/STOMP.
2. Tính idempotent của API read/delete, response khi đối tượng không tồn tại và khả năng đối soát một thông báo theo ID của người dùng hiện tại.
3. Cách backend xác định tập thông báo cho read-all/delete-read khi có sự kiện mới đồng thời.
4. Khả năng mở trực tiếp chi tiết khoản chi, yêu cầu gia nhập và settlement trong các màn hình hiện có.

Các điểm này được xác minh bằng mã/đặc tả backend hoặc môi trường kiểm thử được phép sử dụng. Nếu cần thay đổi API, tách rõ phần phụ thuộc backend và tiếp tục các mục frontend độc lập.
