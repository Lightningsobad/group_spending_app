# Kế hoạch chỉnh sửa luồng CRUD khoản chi tiêu

Ngày lập: 06/11/2026. Trạng thái: kế hoạch triển khai, chưa sửa mã nguồn.

## 1. Mục tiêu và phạm vi

Khắc phục bốn vấn đề được phát hiện khi review luồng khoản chi: giữ đúng người chia tiền khi sửa; bảo đảm danh sách phản ánh request mới nhất; lưu được thao tác gỡ hóa đơn; ngăn lưu dữ liệu khi OCR chưa hoàn tất.

Phạm vi gồm màn hình tạo/sửa, Cubit quản lý form và danh sách, model request, multipart datasource, tài liệu API và kiểm thử liên quan. Không thay đổi công thức chia tiền hoặc cơ chế tính công nợ phía backend ngoài phần cần thiết để hỗ trợ xóa hóa đơn.

Review dựa trên mã nguồn hiện tại và tài liệu API trong repository. Working tree sạch tại thời điểm review. Lệnh `flutter test test/features/expenses` đã được thử nhưng không trả output và bị dừng; chưa có kết quả kiểm thử xác nhận. Các kiểm thử dưới đây là công việc cần thực hiện.

## 2. Tổng hợp công việc

| Mã | Ưu tiên | Vấn đề | Kết quả cần đạt | Phụ thuộc |
| --- | --- | --- | --- | --- |
| EXP-01 | P1 | Mất tập người chia khi tải thành viên bất đồng bộ | Sửa tiêu đề không làm thay đổi người chịu tiền | Xác nhận dữ liệu detail có trả splitOption hay không |
| EXP-02 | P2 | Phản hồi cũ ghi đè danh sách mới | Chỉ request còn hiệu lực được cập nhật state | Không |
| EXP-03 | P2 | Gỡ hóa đơn chỉ có hiệu lực local | Lưu và tải lại vẫn không còn hóa đơn | Hợp đồng xóa hóa đơn phía backend |
| EXP-04 | P2 | Lưu được khi OCR đang chạy | Chỉ submit sau khi scan kết thúc | Không |

Thứ tự thực hiện đề xuất: EXP-01 → EXP-02 → EXP-04 → EXP-03. Xác minh hợp đồng API của EXP-03 ngay từ đầu để tránh chờ backend ở cuối đợt sửa.

## 3. EXP-01 — Bảo toàn người chia tiền khi chỉnh sửa

### Hiện trạng và cách tái hiện

- `lib/features/expenses/presentation/cubit/expense_form_cubit.dart`: constructor suy luận splitOption bằng cách so sánh số splits với số members.
- `lib/features/expenses/presentation/screens/add_expense_screen.dart`: khi GroupModel chưa có members, form được tạo trước rồi tải thành viên qua `_fetchGroupDetail()`.
- Nếu members rỗng lúc khởi tạo, điều kiện `splits.length < members.length` sai, form chọn `equalAll`.
- Khi `updateMembers()` chạy, nhánh equalAll thay tập người chia gốc bằng toàn bộ thành viên.
- Tái hiện: nhóm có A, B, C; khoản chi chỉ chia A, B; mở sửa từ group chưa có members; chờ tải xong; chỉ đổi tiêu đề rồi lưu. Request có thể chuyển thành EQUAL_ALL, đưa C vào công nợ.

### Thiết kế chỉnh sửa

1. Khi edit, lấy tập userId trong splits làm dữ liệu gốc cần bảo toàn. Không suy luận chế độ chia từ members chưa tải.
2. Kiểm tra response detail thực tế và DTO backend để biết có splitOption hay không. Nếu có, parse và sử dụng trực tiếp; khi thiếu, dùng EQUAL_SELECTED với tập splits để bảo toàn người chịu tiền khi lưu.
3. Nếu backend không cung cấp splitOption, ghi nhận giới hạn: không thể phân biệt chắc chắn EQUAL_ALL và EQUAL_SELECTED có cùng tập người. Ưu tiên giữ tập người hiện có; bổ sung splitOption vào detail nếu cần giữ cả ý nghĩa “tất cả thành viên hiện tại”.
4. Tách trạng thái tải thành viên khỏi việc người dùng chủ động chọn “chia tất cả”. `updateMembers()` không được tự mở rộng tập người chia của khoản chi đang sửa.
5. Nếu một người trong splits không còn trong danh sách thành viên hiện tại, hiển thị thông báo và yêu cầu chọn lại theo hợp đồng backend; không âm thầm đổi sang toàn nhóm hoặc loại người rồi lưu.
6. Chặn lưu khi chưa tải được dữ liệu thành viên cần thiết để xác thực payer/participants. Tải lỗi phải có đường thử lại, giữ nguyên dữ liệu form.
7. Giữ hành vi tạo mới: mặc định chia tất cả; khi người dùng chủ động chọn tất cả, request dùng EQUAL_ALL.

### File dự kiến thay đổi

- `lib/features/expenses/presentation/cubit/expense_form_cubit.dart`
- `lib/features/expenses/presentation/cubit/expense_form_state.dart`
- `lib/features/expenses/presentation/screens/add_expense_screen.dart`
- `lib/features/expenses/data/models/expense_models.dart` nếu bổ sung splitOption từ API.
- `test/features/expenses/expense_logic_test.dart`
- `test/features/expenses/presentation/screens/add_expense_screen_test.dart`

### Kiểm thử và nghiệm thu

| Ca | Thao tác | Kết quả |
| --- | --- | --- |
| 01-A | Edit với members rỗng, sau đó tải A/B/C; splits A/B | Vẫn chỉ A/B, request EQUAL_SELECTED chứa đúng A/B |
| 01-B | Edit khi members có sẵn | Tập người chia giống dữ liệu gốc |
| 01-C | Edit khoản chia tất cả, chỉ đổi tiêu đề | Không thay đổi tập người chịu tiền; giữ mode nếu API cung cấp |
| 01-D | Thành viên cũ rời nhóm hoặc tải members lỗi | Không tự chuyển sang toàn nhóm; thông báo và chặn lưu dữ liệu chưa hợp lệ |
| 01-E | Create, đổi nhóm, chọn/bỏ chọn người chia | Payer và participants hợp lệ trong nhóm mới; hành vi mặc định vẫn đúng |

Nghiệm thu cuối: sau khi sửa tiêu đề và tải lại detail, tập userId trong splits không thay đổi ngoài lựa chọn chủ động của người dùng; tổng tiền chia vẫn bằng tổng khoản chi.

## 4. EXP-02 — Loại bỏ phản hồi danh sách hết hiệu lực

### Hiện trạng và cách tái hiện

`lib/features/expenses/presentation/cubit/expenses_cubit.dart` kiểm tra isClosed và sessionEpoch khi thành công, nhưng chưa kiểm tra thứ tự request. Nhánh lỗi cũng chưa kiểm tra epoch. Hai request đổi nhóm, đổi filter, tìm kiếm hoặc refresh sau CRUD có thể hoàn tất ngược thứ tự.

Tái hiện: cho request nhóm A chậm, chuyển sang nhóm B và trả B trước, sau đó trả A. State vẫn activeGroupId B nhưng expensesData nhận dữ liệu A. Tương tự, request trước khi xóa có thể trả về sau refresh và làm khoản đã xóa xuất hiện lại.

### Thiết kế chỉnh sửa

1. Thêm bộ đếm request tăng dần trong ExpensesCubit. Mỗi lần load giữ bản chụp requestId, groupId, sessionEpoch và tham số truy vấn.
2. Chỉ emit thành công hoặc lỗi nếu Cubit chưa đóng, requestId còn mới nhất, groupId còn active và epoch chưa đổi. Dùng chung điều kiện cho mọi nhánh sau await.
3. Khi chuyển nhóm hoặc clearActiveGroup, hủy debounce tìm kiếm và vô hiệu hóa request cũ để query của nhóm trước không chạy sang nhóm mới.
4. Sửa cơ chế clear activeGroupId: `ExpensesState.copyWith(activeGroupId: null)` hiện giữ giá trị cũ vì dùng toán tử `??`. Bổ sung cờ clear hoặc sentinel; xác nhận reset thực sự đưa activeGroupId về null.
5. Đồng nhất việc reset filter/search khi khác nhóm cho cả load thường và silent. Giữ hành vi silent refresh không bật skeleton toàn màn hình.
6. Có thể bổ sung CancelToken nếu cần giảm tải mạng, nhưng requestId vẫn là điều kiện bảo đảm đúng dữ liệu, không phụ thuộc khả năng hủy request.

### File dự kiến thay đổi

- `lib/features/expenses/presentation/cubit/expenses_cubit.dart`
- `lib/features/expenses/presentation/cubit/expenses_state.dart`
- `test/features/expenses/expenses_cubit_test.dart` (tạo mới nếu chưa có).
- `test/features/expenses/presentation/widgets/group_expenses_tab_view_test.dart` nếu cần xác nhận UI chuyển nhóm.

### Kiểm thử và nghiệm thu

Dùng fake repository và Completer điều khiển thứ tự hoàn tất; không dùng độ trễ mạng ngẫu nhiên.

- A chậm/B nhanh, cả hai thành công: cuối cùng chỉ hiển thị B.
- Request cũ báo lỗi sau request mới thành công: không chuyển state thành failure hoặc hiện snackbar lỗi cũ.
- Hai bộ lọc hoặc hai query liên tiếp: nhận kết quả của truy vấn mới nhất.
- Request trước CRUD trả về sau refresh: không phục hồi dữ liệu đã xóa hoặc dữ liệu trước cập nhật.
- Clear group, đóng Cubit hoặc đổi session khi request đang chạy: không cập nhật state từ request đó, kể cả lỗi.
- Gõ tìm kiếm rồi đổi nhóm trước 400 ms: query cũ không áp dụng vào nhóm mới.

Nghiệm thu: dữ liệu danh sách, tổng chi, activeGroupId và bộ lọc luôn thuộc cùng một ngữ cảnh truy vấn còn hiệu lực.

## 5. EXP-03 — Lưu thao tác xóa hóa đơn

### Hiện trạng và giới hạn đã biết

`removeReceipt()` xóa receiptFile/receiptUrl khỏi state. `UpdateExpenseRequest.toJson()` bỏ receiptUrl nếu null/rỗng. Datasource không có tín hiệu xóa riêng. Theo `documents/Mobile_Expense_API_Integration_Guide.md`, PUT không upload ảnh mới sẽ giữ hóa đơn hiện tại.

Vì vậy, gỡ ảnh rồi lưu hiện tạo request không thể hiện ý định xóa. Đây là kết luận từ mã nguồn và hợp đồng được ghi trong repo; cần xác minh backend đang triển khai trước khi chọn payload cuối cùng.

### Thống nhất hợp đồng API

Đề xuất thêm `removeReceipt: true` vào JSON part data của PUT; đây là đề xuất, chưa phải trường API được xác nhận.

| Ý định | Payload đề xuất | Backend xử lý |
| --- | --- | --- |
| Giữ nguyên | Không gửi cờ xóa, không gửi ảnh mới | Giữ hóa đơn hiện tại |
| Gỡ hóa đơn | removeReceipt=true, không file/URL mới | Xóa liên kết hóa đơn khỏi khoản chi |
| Thay bằng file | Có receipt multipart, không cờ xóa | Lưu liên kết ảnh mới |
| Thay bằng URL OCR | Có receiptUrl mới, không cờ xóa | Lưu URL đã được kiểm tra hợp lệ |

- Xác định rõ backend từ chối tổ hợp xóa + thay ảnh, hoặc quy tắc ưu tiên; đề xuất từ chối payload mâu thuẫn.
- Nếu backend đã có cơ chế tương đương, dùng đúng tên trường/endpoint đó và cập nhật tài liệu thay vì tạo thêm cơ chế.
- Không mặc định gửi null hay chuỗi rỗng sẽ xóa ảnh khi chưa xác nhận.
- Backend tiếp tục kiểm tra quyền người tạo/Admin. Việc dọn file lưu trữ cần tuân theo cơ chế hiện có, tránh xóa file đang được tài nguyên khác tham chiếu.

### Thiết kế phía ứng dụng

1. Biểu diễn rõ ba ý định keep/remove/replace trong state, hoặc dùng cờ removal kết hợp receiptFile/receiptUrl với invariant rõ ràng.
2. Gỡ ảnh trong edit phải giữ ý định remove qua các lần copyWith; gỡ ảnh trong create chỉ loại attachment local, không gửi lệnh xóa tài nguyên chưa tồn tại.
3. Chọn hoặc scan thành công ảnh mới phải reset ý định remove. Kiểm tra không giữ URL cũ khiến submit bỏ qua file mới.
4. Serialize tín hiệu xóa chỉ trong UpdateExpenseRequest theo hợp đồng đã thống nhất. Datasource tiếp tục gửi JSON trong part data và receipt trong part file.
5. Save lỗi giữ ý định xóa để thử lại. Save thành công tải lại detail và kiểm tra receiptUrl đã trống.
6. Nếu backend chưa hỗ trợ, tạm ẩn/vô hiệu thao tác gỡ ảnh đã lưu và giải thích ngắn trên UI; không báo lưu thành công như thể ảnh đã bị xóa. Việc hoàn tất EXP-03 phụ thuộc backend hỗ trợ và kiểm thử tích hợp đạt.

### File dự kiến thay đổi

- `lib/features/expenses/presentation/cubit/expense_form_state.dart`
- `lib/features/expenses/presentation/cubit/expense_form_cubit.dart`
- `lib/features/expenses/data/models/expense_models.dart`
- `lib/features/expenses/data/datasources/expenses_remote_data_source.dart` nếu hợp đồng yêu cầu.
- `lib/features/expenses/presentation/screens/add_expense_screen.dart`
- `test/features/expenses/expense_form_cubit_scan_test.dart`
- Test serialization/multipart mới trong `test/features/expenses/`.
- `documents/Mobile_Expense_API_Integration_Guide.md` và thay đổi backend tương ứng ngoài phạm vi repo mobile.

### Kiểm thử và nghiệm thu

- Edit giữ ảnh: không gửi cờ xóa, tải lại vẫn đúng URL cũ.
- Edit gỡ ảnh: payload có tín hiệu xóa; GET detail sau PUT trả receiptUrl trống.
- Gỡ rồi chọn ảnh mới: chỉ gửi ý định thay ảnh, không kèm cờ xóa.
- Create chọn ảnh rồi gỡ: không gửi file, URL hoặc cờ xóa.
- PUT lỗi rồi retry: vẫn gửi đúng ý định remove; UI không báo thành công trước response.
- Multipart test kiểm tra JSON part và file part thực tế, không chỉ kiểm tra giá trị state.

## 6. EXP-04 — Chặn submit khi đang quét hóa đơn

### Hiện trạng và cách tái hiện

`lib/features/expenses/presentation/screens/add_expense_screen.dart` chỉ khóa nút lưu theo isSubmitting; `submitExpense()` cũng chưa kiểm tra isScanningReceipt. Form đã có tiêu đề/số tiền hợp lệ có thể được lưu khi scan chưa trả dữ liệu. OCR trả sau đó không sửa được request đã gửi.

### Thiết kế chỉnh sửa

1. Khóa nút lưu khi isScanningReceipt hoặc isSubmitting; hiển thị trạng thái quét để người dùng biết lúc nào có thể lưu.
2. Thêm guard ngay đầu submitExpense cho cả hai trạng thái để lời gọi trực tiếp không bỏ qua quy tắc. Khi bị chặn, không gọi create/update và không chuyển status sang submitting.
3. Khi submit đang chạy, chặn bắt đầu scan hoặc thay/gỡ attachment để tránh thay đổi dữ liệu trong lúc request được chuẩn bị. Chốt snapshot dữ liệu hợp lệ trước thao tác lưu bất đồng bộ.
4. Khi scan thành công hoặc thất bại, luôn trả isScanningReceipt về false nếu Cubit còn hoạt động. Thất bại vẫn cho nhập tay và lưu dữ liệu hợp lệ.
5. Không tự submit sau khi OCR hoàn tất; cho người dùng kiểm tra kết quả trước khi lưu.
6. Giữ kiểm tra isClosed sau await. Nếu hỗ trợ thay/hủy scan đồng thời trong tương lai, bổ sung scanId để bỏ kết quả cũ; không để kết quả quét đã hết hiệu lực ghi đè ảnh mới.

### File dự kiến thay đổi

- `lib/features/expenses/presentation/screens/add_expense_screen.dart`
- `lib/features/expenses/presentation/cubit/expense_form_cubit.dart`
- `lib/features/expenses/presentation/cubit/expense_form_state.dart` nếu gom getter canSubmit/isBusy.
- `test/features/expenses/expense_form_cubit_scan_test.dart`
- `test/features/expenses/presentation/screens/add_expense_screen_test.dart`

### Kiểm thử và nghiệm thu

- Form hợp lệ, scan còn pending: nút lưu disabled; gọi trực tiếp submitExpense không gọi repository create/update.
- Scan thành công: mở lại nút lưu; request chứa số tiền/ngày/tiêu đề/URL OCR đang hiển thị.
- Scan thất bại: thoát trạng thái scanning, cho chỉnh tay và lưu; không bị kẹt nút.
- Nhấn lưu liên tiếp hoặc gọi submit hai lần: chỉ một request mutation đang chạy.
- Đóng màn hình trước khi scan kết thúc: không emit lên Cubit đã đóng hoặc điều hướng ngoài ý muốn.

## 7. Các bước triển khai và xác minh chung

1. Xác minh payload detail, hợp đồng splitOption và xóa receipt với backend; lưu ví dụ request/response đã loại dữ liệu nhạy cảm vào tài liệu API.
2. Bổ sung regression test điều khiển được thứ tự async cho EXP-01, EXP-02, EXP-04; xác nhận các test bắt được hành vi cũ.
3. Sửa từng vấn đề theo thứ tự ưu tiên, chạy test liên quan sau mỗi thay đổi. Không gộp chỉnh giao diện không liên quan.
4. Hoàn thiện EXP-03 theo hợp đồng API đã xác nhận; kiểm tra cả JSON serialization, multipart và GET sau PUT.
5. Format các file Dart thay đổi và chạy analyze; chạy bộ test expenses cùng các ca dashboard chọn nhóm có liên quan.

Các lệnh kiểm tra dự kiến:

```powershell
flutter analyze
flutter test test/features/expenses
flutter test test/features/dashboard/select_group_for_expense_view_test.dart
```

Nếu Flutter tiếp tục không trả output, ghi lại nguyên nhân môi trường và log trước khi kết luận; kiểm tra tiến trình/SDK lock, dependencies và cấu hình SDK. Không coi tiến trình đã khởi chạy là test đã pass.

### Kiểm tra thủ công trên môi trường tích hợp

- Tạo khoản chia tất cả và khoản chỉ chia một số người; kiểm tra số tiền VND/k, payer, ngày và tổng splits sau GET.
- Mở sửa từ group chưa có members; đổi tiêu đề, lưu và đối chiếu tập userId trước/sau.
- Đổi nhóm, filter và tìm kiếm khi mạng chậm; kiểm tra dữ liệu và tổng chi đúng nhóm hiện tại.
- Giữ/thay/gỡ ảnh, lưu rồi mở lại; kiểm tra cả scan lỗi và retry lưu lỗi.
- Xóa một khoản, chờ refresh; khoản đã xóa không xuất hiện lại khi request cũ hoàn tất. Kiểm tra detail không còn truy cập được và tổng chi/công nợ cập nhật theo backend.
- Kiểm tra quyền người tạo/Admin và response từ chối của thành viên thường theo hợp đồng hiện có.

## 8. Điều kiện hoàn tất và bàn giao

- [ ] EXP-01: sửa thông tin không làm thay đổi người chia ngoài ý định người dùng.
- [ ] EXP-02: response cũ, lỗi cũ và debounce cũ không cập nhật ngữ cảnh mới.
- [ ] EXP-03: hợp đồng xóa ảnh được xác nhận, triển khai và kiểm chứng bằng GET sau PUT.
- [ ] EXP-04: không thể submit khi scan đang chạy và không gửi trùng mutation khi đang lưu.
- [ ] Regression test liên quan pass; ghi rõ lệnh và kết quả thực tế.
- [ ] Analyze hoàn tất, phân biệt lỗi mới với lỗi tồn tại từ trước nếu có.
- [ ] Tài liệu API cập nhật khớp backend; nêu rõ yêu cầu phiên bản backend nếu bổ sung trường mới.
- [ ] Kiểm tra thủ công luồng tạo → xem → sửa → xóa trên môi trường tích hợp đạt.

Bàn giao gồm danh sách file thay đổi, kết quả test/analyze, bằng chứng kiểm tra payload và các phụ thuộc backend còn lại. Chỉ đánh dấu hoàn tất khi các điều kiện tương ứng đã được xác minh.
