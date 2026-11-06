# Kế hoạch chỉnh sửa luồng CRUD quỹ nhóm

Ngày lập: 06/11/2026  
Trạng thái: Chờ triển khai  
Phạm vi: 6 vấn đề phát hiện khi review luồng tạo, xem, sửa và xóa đợt thu quỹ trên ứng dụng Flutter.

## 1. Mục tiêu và giới hạn

Sửa đúng hành vi cập nhật quỹ, bảo đảm số tiền người dùng xác nhận trùng với payload API, ngăn phản hồi cũ ghi đè dữ liệu và hoàn thiện các trạng thái lỗi của giao diện.

Kế hoạch này chưa bao gồm thay đổi backend, thay đổi quy tắc phân quyền hoặc thay đổi nghiệp vụ xóa quỹ. Backend vẫn chịu trách nhiệm xác thực quyền quản trị và các ràng buộc dữ liệu. Không tự động chỉnh lại số tiền của các quỹ đã tồn tại.

Cơ sở đối chiếu: [Đặc tả API quỹ nhóm](Mobile_Fund_API_Integration_Guide.md). Các phát hiện hiện dựa trên mã nguồn và tài liệu trong repo; chưa xác minh bằng backend thực tế. Lần chạy `flutter test test/features/funds` trong phiên review không trả kết quả và đã được dừng, nên chưa có baseline kiểm thử đạt.

## 2. Danh sách công việc

| Mã | Mức ưu tiên | Vấn đề | Kết quả cần đạt |
| --- | --- | --- | --- |
| FUND-01 | P1 | Route sửa gọi tạo mới do thiếu dữ liệu quỹ | Mọi đường vào màn hình sửa đều cập nhật đúng ID |
| FUND-02 | P1 | Làm tròn tiền âm thầm khi gửi API | Số tiền hiển thị và lưu trùng nhau |
| FUND-03 | P2 | Phản hồi tải cũ ghi đè state mới | Chỉ request còn hiệu lực được cập nhật state |
| FUND-04 | P2 | Danh sách sửa chỉ có người đang thuộc quỹ | Có thể chọn thêm thành viên hợp lệ của nhóm |
| FUND-05 | P2 | Date picker lỗi với hạn nộp quá cũ | Mở lịch được với mọi hạn nộp hợp lệ đã lưu |
| FUND-06 | P2 | Tải lần đầu thất bại nhưng hiện skeleton mãi | Có thông báo lỗi và thao tác thử lại |

## 3. Phương án chỉnh sửa

### FUND-01 — Route chỉnh sửa quỹ

Vị trí: `lib/app_routes.dart`, `lib/features/funds/presentation/screens/fund_form_screen.dart` và phần tải dữ liệu quỹ liên quan.

Route `/groups/:groupId/funds/:fundId/edit` hiện chỉ truyền `isEdit: true`. Form thiếu `initialFund` nên chạy nhánh tạo mới khi lưu.

Các bước:

1. Đọc và kiểm tra `groupId`, `fundId` từ route; không chuyển ID không hợp lệ thành `0` rồi tiếp tục thao tác.
2. Bổ sung điểm vào màn hình sửa có khả năng tải dữ liệu theo `fundId`. Hiển thị loading, lỗi và thử lại trước khi dựng form đã điền dữ liệu.
3. Xác minh quỹ tải về thuộc `groupId` trên route. Nếu không khớp, dừng luồng và hiển thị lỗi.
4. Tách rõ chế độ tạo và sửa: chế độ sửa thiếu dữ liệu phải chặn lưu, tuyệt đối không fallback sang tạo mới.
5. Dùng chung cách mở form từ route trực tiếp và từ màn hình chi tiết; sau cập nhật thành công, tải lại chi tiết và đồng bộ danh sách.

Nghiệm thu:

- Mở route sửa trực tiếp, lưu thay đổi: gọi update đúng ID đúng một lần; không gọi create.
- Tải quỹ lỗi, quỹ không tồn tại hoặc sai nhóm: không thể gửi create/update.
- Mở sửa từ chi tiết vẫn điền đủ dữ liệu và hiển thị thay đổi sau khi quay lại.

### FUND-02 — Chuẩn hóa số tiền trước khi xác nhận

Vị trí: `lib/features/funds/data/repositories/funds_repository_impl.dart`, request models và phần tính tiền trong `fund_form_screen.dart`.

API nhận số nguyên đơn vị nghìn đồng. Repository hiện dùng `.round()` khiến số tiền đã xác nhận thay đổi âm thầm, ví dụ `1.499đ` thành `1.000đ`; tổng `100.000đ` chia 3 người thành tổng lưu `99.000đ`.

Phương án đề xuất giữ nguyên hợp đồng API:

1. Chế độ nhập mỗi người: yêu cầu số tiền tối thiểu `1.000đ` và là bội số của `1.000đ`; hiển thị lỗi rõ ràng nếu không hợp lệ.
2. Chế độ nhập tổng: tính mức mỗi người theo nghìn đồng bằng cách làm tròn lên để đạt ít nhất tổng mong muốn. Hiển thị riêng tổng mong muốn, mức mỗi người và tổng thực thu dự kiến.
3. Ví dụ `100.000đ / 3 người`: hiển thị `34.000đ/người`, tổng thực tế `102.000đ` trước khi lưu. Khi đổi thành viên, tính lại cả hai số ngay.
4. Dùng chung một hàm tính/kiểm tra tiền cho phần tóm tắt và payload; dùng phép toán số nguyên để tránh sai số.
5. Repository kiểm tra tính hợp lệ thay vì tự làm tròn hoặc ép giá trị lên `1k`. Áp dụng cho cả create và update.

Nghiệm thu:

- Mỗi người `1.000đ`, `200.000đ`: payload lần lượt là `1`, `200`.
- Mỗi người `1.499đ`, dưới mức tối thiểu: báo lỗi và không gọi API.
- Tổng `100.000đ / 3 người`: thông tin xác nhận và dữ liệu sau lưu đều là `34.000đ/người`, tổng `102.000đ`.
- Đổi số người, đổi chế độ nhập và lưu lại không tạo chênh lệch giữa tóm tắt và payload.

Quy tắc làm tròn lên ở chế độ tổng là quyết định sản phẩm được đề xuất trong kế hoạch này. Nếu yêu cầu bắt buộc tổng phải chính xác tuyệt đối, cần đổi thiết kế nhập liệu hoặc hợp đồng API vì một số tổng không thể chia đều theo nghìn đồng.

### FUND-03 — Loại bỏ phản hồi request hết hiệu lực

Vị trí: `lib/features/funds/presentation/cubit/funds_cubit.dart`.

Kiểm tra `sessionEpoch` hiện chỉ bảo vệ khi phiên đăng nhập thay đổi, chưa bảo vệ khi đổi nhóm hoặc bộ lọc trong cùng phiên.

Các bước:

1. Bổ sung số thứ tự request tăng dần; chụp lại group ID, search, status, time filter và session epoch trước khi gọi repository.
2. Chỉ emit kết quả hoặc lỗi nếu request vẫn là request mới nhất, nhóm vẫn khớp, phiên còn hiệu lực và Cubit chưa đóng.
3. Khi đổi nhóm, reset hoặc đổi tiêu chí tìm kiếm/lọc, vô hiệu hóa request cũ ngay; không đợi hết debounce mới vô hiệu hóa.
4. Hủy debounce khi đổi nhóm, reset và close. Khi đổi nhóm, xóa dữ liệu và tiêu chí của nhóm trước theo cùng một quy tắc cho cả tải thường lẫn tải silent.

Nghiệm thu bằng repository giả và `Completer`, chủ động đảo thứ tự phản hồi:

- A tải chậm, chuyển sang B; B trả trước, A trả sau: state chỉ giữ dữ liệu B.
- Search hoặc bộ lọc cũ trả sau bộ lọc mới: không ghi đè kết quả mới.
- Request cũ thất bại sau khi request mới thành công: không chuyển state sang failure.
- Reset, đổi phiên hoặc close trong lúc tải: phản hồi cũ không khôi phục dữ liệu.

### FUND-04 — Tải đầy đủ thành viên khi sửa

Vị trí: phần `initState`, `_initData`, `_loadMembers` trong `fund_form_screen.dart`.

Danh sách thành viên quỹ chỉ là danh sách tham gia hiện tại, không đại diện cho toàn bộ thành viên nhóm. Không dùng danh sách này để quyết định bỏ qua tải thành viên nhóm.

Các bước:

1. Khi mở sửa, tải danh sách thành viên hiện hành của nhóm, kể cả khi đã có thành viên trong quỹ hoặc dữ liệu nhóm truyền vào.
2. Giữ lựa chọn ban đầu theo thành viên quỹ; thành viên nhóm chưa tham gia phải xuất hiện ở trạng thái chưa chọn.
3. Giữ và khóa bỏ chọn người đã `PAID`, kể cả khi dùng thao tác chọn/bỏ chọn tất cả.
4. Đối chiếu trường hợp thành viên quỹ đã rời nhóm với backend: cần làm rõ cách giữ người đã `PAID` khi API đồng thời kiểm tra tư cách thành viên. Không tự bỏ người đã nộp hoặc gửi ID không hợp lệ để né ràng buộc.
5. Khi tải danh sách lỗi, hiển thị lỗi/thử lại và chặn lưu danh sách chưa được xác minh; tránh lưu gây loại bỏ thành viên ngoài ý muốn.

Nghiệm thu:

- Nhóm có A, B, C; quỹ chỉ có A: mở sửa vẫn thấy B, C và thêm được họ.
- `group` không được truyền vào hoặc `group.members` thiếu/cũ: vẫn tải danh sách mới.
- Người đã `PAID` không thể bị bỏ chọn; người chưa nộp có thể thêm/bớt theo quyền và quy tắc API.
- Lỗi tải thành viên có thể thử lại và không làm mất lựa chọn đang có.

### FUND-05 — Khoảng ngày hợp lệ của date picker

Vị trí: `_pickDueDate` trong `fund_form_screen.dart`.

Các bước:

1. Chuẩn hóa ngày hiện tại và ngày đã chọn về ngày lịch, bỏ thành phần giờ.
2. Mở rộng `firstDate`/`lastDate` để luôn bao gồm ngày đã lưu; bảo đảm `firstDate <= initialDate <= lastDate`.
3. Giữ nguyên hạn nộp đã lưu nếu người dùng hủy chọn. Không âm thầm sửa dữ liệu cũ chỉ để mở lịch.

Nghiệm thu:

- Hạn nộp cách hiện tại hơn 30 ngày trong quá khứ hoặc hơn 2 năm trong tương lai: mở lịch không phát sinh exception.
- Chưa có hạn nộp: mở lịch với ngày mặc định hợp lệ.
- Hủy lịch giữ nguyên ngày cũ; chọn ngày mới gửi đúng định dạng `yyyy-MM-dd`.

### FUND-06 — Trạng thái lỗi và thử lại ở danh sách quỹ

Vị trí: `lib/features/funds/presentation/widgets/group_funds_tab_view.dart` và state/Cubit nếu cần.

Các bước:

1. Phân biệt rõ loading ban đầu, failure chưa có dữ liệu, thành công rỗng và refresh lỗi khi đã có dữ liệu.
2. Khi lần tải đầu thất bại, dừng skeleton, hiển thị thông báo lỗi và nút thử lại cho nhóm hiện tại.
3. Nếu refresh lỗi nhưng có dữ liệu cùng nhóm, giữ nội dung đang có và hiển thị thông báo lỗi có thể thử lại.
4. Không hiển thị dữ liệu nhóm trước khi đổi nhóm; chỉ hiện empty state sau phản hồi thành công có danh sách rỗng.

Nghiệm thu:

- API lỗi lần đầu: hiện lỗi và nút thử lại, không hiện skeleton vô hạn.
- Thử lại thành công: hiển thị dữ liệu; thành công rỗng: hiển thị empty state.
- Refresh lỗi: giữ dữ liệu cùng nhóm và cho phép thử lại.
- Chuyển nhóm trong lúc lỗi/tải: không lộ danh sách nhóm trước.

## 4. Thứ tự triển khai

| Đợt | Công việc | Điều kiện hoàn tất |
| --- | --- | --- |
| 1 | Khôi phục baseline chạy test; FUND-01, FUND-02 | Không tạo nhầm khi sửa; tiền hiển thị trùng payload |
| 2 | FUND-03, FUND-06 | Không ghi đè bởi phản hồi cũ; tải lỗi có thể phục hồi |
| 3 | FUND-04, FUND-05 | Sửa được thành viên và ngày cũ; quy tắc thành viên rời nhóm được xác minh |
| 4 | Kiểm thử tích hợp và hồi quy CRUD | Đạt các tiêu chí ở mục 5 |

Mỗi đợt triển khai kèm kiểm thử cho hành vi thay đổi, không dồn toàn bộ kiểm thử đến cuối. Nếu baseline không chạy được, ghi rõ nguyên nhân và cách khắc phục trước khi kết luận kiểm thử đạt.

## 5. Kiểm thử và nghiệm thu chung

- Unit test: kiểm tra chuẩn hóa tiền ở create/update và các phản hồi tải hoàn thành sai thứ tự.
- Widget test: route sửa tải dữ liệu, chọn thêm thành viên, khóa người đã nộp, mở lịch với ngày ngoài khoảng mặc định, màn hình lỗi/thử lại.
- Kiểm thử tích hợp với API: tạo → xem chi tiết → sửa tên/tiền/ngày/thành viên → quay lại danh sách → xóa có xác nhận. Kiểm tra dữ liệu sau mỗi bước và sau khi mở lại màn hình.
- Kiểm tra quyền: thành viên thường xem được dữ liệu nhưng không có thao tác quản trị; backend từ chối mutation trái quyền.
- Kiểm tra hủy xóa không gửi request; xóa thất bại giữ màn hình và báo lỗi; xóa thành công quay lại danh sách đã cập nhật.

Lệnh kiểm tra dự kiến:

```powershell
flutter analyze
flutter test test/features/funds
```

Chạy thêm các test router/nhóm bị ảnh hưởng khi thay đổi điểm điều hướng hoặc thành phần dùng chung. Ghi nhận lỗi có sẵn riêng với lỗi phát sinh từ thay đổi.

## 6. Điều kiện đóng kế hoạch

- Cả 6 vấn đề có kiểm thử tái hiện và kiểm thử xác nhận hành vi sau sửa phù hợp.
- Không còn đường vào chế độ sửa có thể gọi create do thiếu dữ liệu.
- Tiền hiển thị trước xác nhận trùng dữ liệu thực tế gửi và nhận từ API.
- Không có phản hồi cũ ghi đè dữ liệu nhóm/bộ lọc hiện tại.
- Hoàn thành luồng CRUD tích hợp và xác minh các điểm phụ thuộc backend nêu trên.
- Cập nhật tài liệu này với kết quả kiểm thử, giới hạn còn lại và trạng thái từng công việc.
