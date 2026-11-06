# Kế hoạch khắc phục luồng công nợ

Ngày lập: 06/11/2026. Trạng thái: kế hoạch triển khai, chưa sửa mã nguồn.

## 1. Mục tiêu và phạm vi

Khắc phục ba vấn đề phát hiện trong review: phản hồi tải nhóm cũ ghi đè nhóm đang xem; bỏ sót yêu cầu tất toán chờ xác nhận do chỉ lấy trang đầu; thiếu thao tác từ chối nhận tiền trong nợ thực tế.

Phạm vi gồm Cubit công nợ, repository/datasource lấy yêu cầu tất toán, giao diện nợ thực tế và kiểm thử liên quan. Các endpoint và quy tắc tính công nợ tiếp tục theo `Mobile_Debt_API_Integration_Guide.md`; kế hoạch không yêu cầu thay đổi công thức tính nợ phía backend.

Review dựa trên mã Flutter và tài liệu API trong repository, chưa kiểm chứng backend thực tế. Bộ test hiện có đã chạy thành công **49/49** bằng `flutter test --no-pub test/features/debts`; đây là kết quả trước khi sửa, chưa xác nhận các tình huống hồi quy bên dưới.

## 2. Tổng hợp và thứ tự triển khai

| Mã | Ưu tiên | Vấn đề | Kết quả cần đạt |
| --- | --- | --- | --- |
| DEBT-01 | P1 | Phản hồi cũ ghi đè chi tiết nhóm mới | Chỉ request còn hiệu lực của nhóm đang xem được cập nhật state |
| DEBT-02 | P2 | Chỉ lấy 20 đợt tất toán đầu tiên | Tải đầy đủ yêu cầu chờ xác nhận, kể cả yêu cầu cũ |
| DEBT-03 | P2 | Nợ thực tế chỉ cho xác nhận đã nhận | Chủ nợ có thể từ chối và đưa khoản nợ về trạng thái chưa thanh toán |

Thực hiện DEBT-01 → DEBT-02 → DEBT-03, sau đó chạy kiểm thử toàn bộ tính năng. Hoàn thành DEBT-01 trước khi bổ sung vòng tải nhiều trang để mọi phản hồi phân trang đều chịu cùng cơ chế kiểm tra hiệu lực.

## 3. DEBT-01 — Bảo vệ state trước phản hồi lỗi thời

### Hiện trạng và cách tái hiện

`DebtsCubit.loadGroupDebts()` kiểm tra `isClosed` và `sessionEpoch`, nhưng không kiểm tra request mới nhất hoặc nhóm đang được chọn. Màn hình chi tiết đọc trực tiếp dữ liệu trong state.

Mở nhóm A, quay lại và mở nhóm B khi A chưa tải xong. Cho B hoàn tất trước, A hoàn tất sau. Phản hồi A có thể ghi đè dữ liệu B dù `selectedGroupId` vẫn là B. Giao diện có thể hiển thị công nợ A trong màn hình B, còn callback thanh toán tối giản dùng ID nhóm B.

### Thiết kế chỉnh sửa

1. Thêm bộ đếm request cho việc tải chi tiết nhóm. Mỗi lần tải chụp lại request ID, group ID, bộ lọc và session epoch.
2. Trước mọi cập nhật state sau `await`, chỉ chấp nhận kết quả khi Cubit còn mở, phiên còn đúng, request còn mới nhất và `selectedGroupId` vẫn bằng group ID đã chụp. Áp dụng cùng điều kiện cho thành công, `AppException` và lỗi khác.
3. Vô hiệu hóa request đang chạy khi bỏ chọn nhóm hoặc `reset()`. Xử lý cả tình huống A → bỏ chọn → A để phản hồi của lần mở A trước không được chấp nhận.
4. Request cũ không được tắt loading, xóa thông báo hoặc ghi lỗi vào màn hình hiện tại. Request mới nhất chịu trách nhiệm kết thúc trạng thái loading; khi bỏ chọn/reset, trả trạng thái chi tiết về trạng thái thích hợp.
5. Áp dụng cho tải thường, kéo làm mới, tải silent từ đồng bộ dữ liệu và tải lại sau thanh toán/xác nhận. Khi thay bộ lọc, chụp giá trị bộ lọc trước khi gọi repository.
6. Ở màn hình chi tiết, chỉ dùng dữ liệu có group ID khớp nhóm đang xem. Đây là lớp bảo vệ bổ sung; vẫn phải loại phản hồi cũ tại Cubit.
7. Kiểm tra các nơi gọi trực tiếp `loadGroupDebts()` và cập nhật test để thiết lập nhóm được chọn trước khi tải. Không để điều kiện mới làm hỏng luồng mở chi tiết hiện tại.

### File dự kiến thay đổi

- `lib/features/debts/presentation/cubit/debts_cubit.dart`
- `lib/features/debts/presentation/cubit/debts_state.dart` nếu cần điều chỉnh trạng thái khi bỏ chọn.
- `lib/features/debts/presentation/screens/group_debt_detail_view.dart`
- `test/features/debts/presentation/cubit/debts_cubit_test.dart`
- `test/features/debts/presentation/screens/debts_screen_test.dart`

### Kiểm thử và nghiệm thu

Dùng fake repository với `Completer` để điều khiển thứ tự hoàn tất, không dùng độ trễ ngẫu nhiên.

| Ca | Tình huống | Kết quả |
| --- | --- | --- |
| 01-A | A chậm, B nhanh; A thành công sau B | Chỉ dữ liệu B tồn tại trên màn hình B |
| 01-B | A lỗi sau B thành công | Không hiện lỗi A, không thay loading của B |
| 01-C | Hai request cùng nhóm, request mới hoàn tất trước | Kết quả request mới được giữ lại |
| 01-D | Đang tải rồi bỏ chọn, reset hoặc đổi phiên | Không khôi phục chi tiết hoặc thông báo cũ |
| 01-E | A → bỏ chọn → A trong khi lần tải A đầu chưa xong | Chỉ lần mở A mới được cập nhật state |
| 01-F | Silent refresh và tải thường hoàn tất trái thứ tự | Dữ liệu và loading thuộc request mới nhất |

Nghiệm thu: không có state hiển thị dữ liệu nhóm A cùng thao tác dùng group ID của B.

## 4. DEBT-02 — Tải đủ yêu cầu chờ xác nhận

### Hiện trạng và cách tái hiện

`loadGroupDebts()` gọi `getGroupDebtSettlements(groupId)` với trang mặc định 0, kích thước 20 và không lọc trạng thái. Datasource chỉ trả danh sách `content`, bỏ metadata phân trang. `pendingSettlements` sau đó lọc từ tập dữ liệu giới hạn này.

Theo mục 3.13 của tài liệu API, danh sách mặc định sắp xếp `createdAt,desc`. Tạo một yêu cầu chờ xác nhận rồi thêm ít nhất 20 đợt tất toán mới hơn đã xử lý. Yêu cầu cũ không còn nằm ở trang đầu và mất khỏi danh sách chờ trên ứng dụng.

### Thiết kế chỉnh sửa

1. Luồng phục vụ thẻ chờ xác nhận phải gửi `status=WAITING_FOR_CONFIRMATION` rõ ràng. Không dùng trang lịch sử tất cả trạng thái để suy ra danh sách chờ.
2. Bổ sung kiểu kết quả phân trang cho endpoint này, tối thiểu gồm `content`, `pageNumber`, `last` và `totalPages` theo hợp đồng API. Cập nhật interface, implementation và các fake repository chịu ảnh hưởng.
3. Thêm phương thức repository lấy toàn bộ yêu cầu đang chờ của một nhóm: tải tuần tự từ trang 0 đến trang cuối và ghép kết quả. Giữ phương thức phân trang để có thể dùng riêng cho lịch sử; không thay lịch sử tất cả trạng thái bằng dữ liệu chỉ đang chờ.
4. Loại bản ghi trùng theo settlement ID trước khi cập nhật state. Không giả định tăng `size` lên một giá trị lớn sẽ bảo đảm lấy đủ dữ liệu.
5. Nếu một trang thất bại, không công bố danh sách một phần như kết quả hoàn chỉnh. Với refresh, giữ dữ liệu đã tải trước đó và báo lỗi; với lần tải đầu, kết thúc loading và cho phép thử lại. Tôn trọng cơ chế loại request lỗi thời của DEBT-01.
6. Sau xác nhận/từ chối/thanh toán, tải lại danh sách chờ để loại yêu cầu đã xử lý và cập nhật thao tác tương ứng.
7. Xác minh trên môi trường tích hợp rằng endpoint hỗ trợ bộ lọc và metadata đúng tài liệu. Phân trang theo offset có thể thay đổi khi phát sinh giao dịch đồng thời; việc loại trùng không bảo đảm ảnh chụp nhất quán. Nếu cần bảo đảm mạnh hơn, ghi nhận yêu cầu backend hỗ trợ cursor/snapshot; trước mắt cung cấp refresh để lấy lại danh sách.

### File dự kiến thay đổi

- `lib/features/debts/data/datasources/debts_remote_data_source.dart`
- `lib/features/debts/data/models/` — bổ sung model trang kết quả.
- `lib/features/debts/domain/entities/` — bổ sung kiểu trang nếu public repository sử dụng.
- `lib/features/debts/domain/repositories/debts_repository.dart`
- `lib/features/debts/data/repositories/debts_repository_impl.dart`
- `lib/features/debts/presentation/cubit/debts_cubit.dart`
- Các test datasource, model, repository và Cubit tương ứng.

### Kiểm thử và nghiệm thu

| Ca | Tình huống | Kết quả |
| --- | --- | --- |
| 02-A | Yêu cầu đang chờ cũ hơn 20 giao dịch đã xử lý | Vẫn hiển thị và có thao tác phù hợp |
| 02-B | Có hơn 20 yêu cầu đang chờ | Tải đủ tất cả trang, không chỉ trang đầu |
| 02-C | Trang cuối rỗng hoặc có đúng 20 bản ghi | Dừng đúng theo metadata, không lặp vô hạn |
| 02-D | Bản ghi trùng giữa các trang | Mỗi settlement ID chỉ xuất hiện một lần |
| 02-E | Trang thứ hai lỗi | Không coi trang đầu là danh sách hoàn chỉnh; có thể thử lại |
| 02-F | Đổi nhóm trong khi tải nhiều trang | Không cập nhật state bằng kết quả nhóm cũ |
| 02-G | Xác nhận hoặc từ chối một yêu cầu | Yêu cầu rời danh sách chờ sau khi tải lại |

Nghiệm thu: với dữ liệu không thay đổi trong lúc phân trang, toàn bộ yêu cầu chờ từ API đều xuất hiện, không phụ thuộc số giao dịch lịch sử.

## 5. DEBT-03 — Bổ sung từ chối nhận tiền ở nợ thực tế

### Hiện trạng và cách tái hiện

`ActualDebtCardWidget._handleDebtorTap()` xử lý `DebtAction.confirm` bằng hộp thoại xác nhận đã nhận tiền và chỉ gọi `onDebtorConfirm(debtor, true)`. Nút hủy chỉ đóng hộp thoại. Chủ nợ chưa nhận được tiền không thể đưa khoản nợ thực tế từ `WAITING_FOR_CONFIRMATION` về `PENDING` qua giao diện này.

### Thiết kế chỉnh sửa

1. Với `DebtAction.confirm`, cung cấp hai lựa chọn rõ ràng: “Đã nhận tiền” và “Chưa nhận tiền / Từ chối”. Có thể dùng một hộp lựa chọn rồi mở hộp xác nhận tương ứng; đóng hoặc hủy không gọi API.
2. Xác nhận đã nhận tiếp tục gọi `onDebtorConfirm(debtor, true)`; từ chối sau khi người dùng xác nhận gọi `onDebtorConfirm(debtor, false)`.
3. Tái sử dụng `SettleDebtDialogs.showConfirmSettled(..., confirmed: false)` và chuỗi bản địa hóa hiện có nếu phù hợp. Luồng nợ thực tế dùng `POST /debts/{splitId}/confirm?confirmed=false`; không gửi sang endpoint `debt-settlements` của nợ tối giản và không tự bổ sung trường lý do ngoài hợp đồng API.
4. Chỉ hiển thị thao tác theo `DebtAction.confirm` từ server. Chặn gửi lặp trong lúc thao tác đang xử lý bằng trạng thái submit hiện có, đồng thời kiểm tra widget/context còn hiệu lực sau khi đóng hộp thoại.
5. Khi thành công, dùng luồng tải lại hiện có để cập nhật trạng thái và tổng quan. Khi lỗi, hiển thị thông báo và giữ khả năng thử lại, không tự chuyển trạng thái khoản nợ sang PENDING tại client.

### File dự kiến thay đổi

- `lib/features/debts/presentation/widgets/actual_debt_card_widget.dart`
- `lib/features/debts/presentation/screens/group_debt_detail_view.dart`
- `lib/features/debts/presentation/widgets/settle_debt_dialogs.dart` nếu bổ sung hộp lựa chọn dùng chung.
- File l10n nếu cần chuỗi mới.
- `test/features/debts/presentation/widgets/actual_debt_card_widget_test.dart`
- `test/features/debts/presentation/widgets/settle_debt_dialogs_test.dart`
- Test màn hình, Cubit và datasource liên quan.

### Kiểm thử và nghiệm thu

| Ca | Thao tác | Kết quả |
| --- | --- | --- |
| 03-A | Chủ nợ chọn đã nhận, xác nhận | Gửi đúng split ID và `confirmed=true` |
| 03-B | Chủ nợ chọn chưa nhận, xác nhận từ chối | Gửi đúng split ID và `confirmed=false` |
| 03-C | Hủy hoặc đóng hộp thoại | Không gửi request |
| 03-D | Server trả lỗi | Hiện lỗi, cho thử lại, không giả định đã từ chối thành công |
| 03-E | Server xử lý từ chối thành công | Sau reload khoản nợ là PENDING; thao tác theo action server trả |
| 03-F | Action khác CONFIRM hoặc đang submit | Không xuất hiện thao tác không hợp lệ, không gửi lặp |
| 03-G | Tiếng Việt và tiếng Anh | Nhãn rõ ràng, đủ hai lựa chọn, không tràn nội dung |

Nghiệm thu tích hợp: con nợ báo đã trả → chủ nợ từ chối → khoản nợ quay lại PENDING; luồng đã nhận vẫn hoạt động và nợ tối giản không bị ảnh hưởng.

## 6. Kiểm chứng và bàn giao

1. Viết các test hồi quy quan trọng trước khi sửa, xác nhận chúng thất bại vì đúng lỗi đã mô tả: phản hồi nhóm trái thứ tự, yêu cầu chờ nằm ngoài trang đầu và nhánh từ chối nợ thực tế.
2. Chạy test mục tiêu sau từng thay đổi; sau khi hoàn tất cả ba mục, chạy `flutter test --no-pub test/features/debts` và `flutter analyze`.
3. Khi thay interface repository hoặc model phân trang, tìm và cập nhật mọi implementation/mock, chạy thêm các test bị ảnh hưởng ngoài thư mục công nợ nếu có.
4. Kiểm thử tích hợp với hai tài khoản con nợ/chủ nợ và nhóm có đủ dữ liệu phân trang. Ghi nhận request/response đã loại thông tin nhạy cảm để xác nhận ID, trạng thái, bộ lọc và metadata thực tế.
5. Kiểm tra thủ công: chuyển nhóm nhanh khi mạng chậm; kéo refresh; xác nhận/từ chối từ hai tài khoản; quay lại tổng quan; đăng xuất khi request đang chạy.

Điều kiện hoàn tất: các ca nghiệm thu trên đạt; bộ test công nợ không hồi quy; không phát sinh lỗi phân tích tĩnh từ thay đổi; kiểm chứng backend thực tế hoặc ghi rõ phần chưa thể kiểm chứng trong bàn giao. Cập nhật tài liệu này bằng kết quả và lệnh kiểm thử sau khi triển khai, không dùng kết quả 49/49 trước sửa làm bằng chứng nghiệm thu bản sửa.
