# Kế hoạch chỉnh sửa và review CRUD quản lý nhóm

Ngày lập: 06/11/2026  
Trạng thái: Kế hoạch triển khai; chưa thực hiện sửa mã nguồn  
Phạm vi: Ứng dụng Flutter trong repository `group_spending_app`

## 1. Mục tiêu

Khắc phục các vấn đề được phát hiện trong lần review luồng quản lý nhóm và xác minh lại hành vi tạo, đọc, sửa, lưu trữ, xóa nhóm. Kết quả cần bảo đảm dữ liệu hiển thị không bị phản hồi cũ ghi đè, người dùng biểu đạt được ý định xóa mô tả và nhóm lưu trữ tuân thủ chế độ chỉ xem.

Tài liệu này là kế hoạch, không phải xác nhận các thay đổi hoặc kiểm thử đã hoàn tất.

## 2. Cơ sở và giới hạn của review ban đầu

- Working tree sạch tại thời điểm review; đối tượng review là mã hiện tại, không phải một diff chưa commit.
- Đã đọc các thành phần chính: form tạo/sửa nhóm, màn hình danh sách/chi tiết, `GroupsCubit`, state, repository, datasource và model.
- Đã đối chiếu tài liệu `Mobile_Group_API_Integration_Guide.md` và điểm vào tạo quỹ trong nhóm.
- Đã gọi một số test nhóm nhưng tiến trình không trả output và đã dừng. Chưa có kết quả test xác nhận từ lần review đó.
- Chưa xác minh backend thực tế xử lý trường `description` bị thiếu, `null` hoặc chuỗi rỗng như thế nào. Đây là điểm cần làm rõ bằng mã backend, đặc tả hoặc môi trường kiểm thử được phép sử dụng.
- Chưa kết luận về việc backend có thể bị vượt quyền. Vấn đề nhóm lưu trữ được xác định tại luồng giao diện.

## 3. Danh sách công việc và mức ưu tiên

| ID | Ưu tiên | Vấn đề | Kết quả mong đợi |
| --- | --- | --- | --- |
| GCRUD-01 | P1 | Phản hồi tải danh sách cũ có thể ghi đè trạng thái sau CRUD | Chỉ phản hồi còn hiệu lực được cập nhật state |
| GCRUD-02 | P2 | Form và datasource không truyền được ý định xóa mô tả | Xóa mô tả được gửi rõ ràng và hiển thị đúng sau tải lại |
| GCRUD-03 | P2 | Nhóm lưu trữ vẫn có điểm vào tạo quỹ | Nhóm lưu trữ chỉ cho phép các thao tác đọc phù hợp |
| GCRUD-04 | Theo kết quả rà soát | Rà soát đồng bộ chi tiết, lỗi API và các điểm vào liên quan | Không có lỗi hồi quy trong luồng CRUD |

## 4. Phạm vi triển khai

### Trong phạm vi

- Kiểm soát thứ tự phản hồi trong `GroupsCubit`.
- Đồng bộ danh sách và nhóm đang chọn sau cập nhật, lưu trữ, xóa.
- Biểu diễn và truyền thao tác xóa mô tả.
- Điều kiện mở form tạo quỹ đối với nhóm lưu trữ.
- Rà soát các điểm vào chỉnh sửa khác của nhóm lưu trữ; sửa các điểm vi phạm cùng quy tắc nếu được xác nhận.
- Bổ sung test tái hiện lỗi, chạy kiểm tra liên quan và review diff.

### Ngoài phạm vi mặc định

- Thay đổi thiết kế giao diện tổng thể, kiến trúc toàn ứng dụng hoặc API backend.
- Mở rộng tính năng quản lý thành viên, công nợ, chi tiêu hay quỹ ngoài phần liên quan trực tiếp.
- Commit, tạo PR, merge hoặc triển khai ứng dụng.

Nếu việc xác minh làm thay đổi bản chất một phát hiện, cập nhật tài liệu và phạm vi sửa theo bằng chứng trước khi triển khai giải pháp tương ứng.

## 5. Giai đoạn 1 — Xác minh và chuẩn bị

### Công việc

1. Kiểm tra hướng dẫn repository và trạng thái working tree trước khi sửa; bảo toàn thay đổi đang có của người dùng.
2. Đọc lại đường đi thực tế từ UI đến API và các subscriber của `DataSyncCoordinator`.
3. Kiểm kê mọi nơi gọi `loadGroups`, `loadGroupDetails`, tạo/sửa/lưu trữ/xóa nhóm.
4. Xác minh hợp đồng cập nhật mô tả, bao gồm ý nghĩa của trường bị thiếu, `null`, `""` và khoảng trắng.
5. Xác định các màn hình hoặc route có thể mở form tạo/sửa dữ liệu trong nhóm lưu trữ.
6. Chẩn đoán test không có output: trạng thái tiến trình, Flutter SDK, dependency và khóa khởi động; ghi nguyên nhân quan sát được, không suy đoán kết quả.

### Đầu ra

- Danh sách caller và file cần sửa thực tế.
- Hợp đồng xóa mô tả đã xác minh hoặc giới hạn xác minh được ghi rõ.
- Môi trường chạy được test, hoặc lỗi môi trường cụ thể kèm ảnh hưởng đến xác nhận kết quả.

## 6. GCRUD-01 — Ngăn phản hồi cũ ghi đè kết quả CRUD

### Kịch bản lỗi

1. Request A tải danh sách bắt đầu và đọc dữ liệu trước khi nhóm bị xóa.
2. Request xóa hoàn tất; Cubit loại nhóm khỏi danh sách.
3. A trả về sau và thay toàn bộ danh sách bằng snapshot cũ.
4. Nhóm vừa xóa xuất hiện lại trên UI. Trường hợp tương tự có thể làm mất nhóm mới tạo hoặc hoàn nguyên thông tin/trạng thái vừa sửa.

Kiểm tra `sessionEpoch` hiện tại chỉ loại phản hồi khác phiên đăng nhập, không giải quyết thứ tự request trong cùng phiên.

### Thiết kế dự kiến

- Dùng số thứ tự request tải danh sách để bảo đảm kết quả từ request mới nhất được ưu tiên.
- Dùng phiên bản dữ liệu/mutation để loại snapshot bắt đầu trước một mutation đã thành công.
- Khi `reset`, vô hiệu hóa các request cũ ngay cả khi không có `SessionCoordinator`.
- Giữ điều kiện `isClosed` và `sessionEpoch` hiện có.
- Áp dụng cùng điều kiện hiệu lực cho nhánh lỗi: lỗi của request cũ không được ghi đè trạng thái mới.
- Xác định rõ cách kết thúc trạng thái loading khi một response bị loại. Không để `status` mắc kẹt ở loading sau CRUD; dùng trạng thái hợp lệ hoặc tải lại có kiểm soát.
- Không tự động retry mutation vì có nguy cơ tạo thao tác trùng.

Chi tiết thời điểm tăng phiên bản cần được chốt sau test tái hiện: tối thiểu phải vô hiệu hóa snapshot cũ khi mutation thành công. Trường hợp request tải bắt đầu trong lúc mutation đang chạy phải có chính sách rõ ràng, không chỉ xử lý request bắt đầu trước mutation.

### Đồng bộ nhóm đang chọn

- Cập nhật nhóm đang chọn khi sửa/lưu trữ đúng ID đó.
- Khi xóa, chỉ xóa lựa chọn nếu lựa chọn trùng nhóm bị xóa.
- Kiểm tra request chi tiết đang chạy có thể khôi phục nhóm đã xóa hoặc ghi đè thông tin mới hay không.
- Nếu cần kiểm soát request chi tiết, dùng ID nhóm và phiên bản request phù hợp; tránh vô tình loại request hợp lệ của caller khác dùng chung Cubit.
- Kiểm tra vòng đời `GroupDetailView`: phản hồi phải còn đúng nhóm/view trước khi gán vào `_group`.

### File dự kiến

- `lib/features/groups/presentation/cubit/groups_cubit.dart`
- `lib/features/groups/presentation/cubit/groups_state.dart` nếu cần điều chỉnh cách cập nhật lựa chọn/trạng thái.
- `lib/features/groups/presentation/widgets/group_detail_view.dart` nếu xác nhận race ở state cục bộ.
- `test/features/groups/groups_cubit_test.dart`
- `test/features/groups/group_detail_view_test.dart` nếu thay đổi widget.

### Tiêu chí nghiệm thu

- Phản hồi danh sách cũ không hoàn nguyên kết quả tạo, sửa, lưu trữ, xóa thành công.
- Với hai lần tải chồng nhau, phản hồi cũ và lỗi cũ không ghi đè kết quả mới.
- Đổi session, reset hoặc đóng Cubit không nhận phản hồi không còn hiệu lực.
- Mutation thất bại không làm mất dữ liệu đang có hoặc khiến loading kéo dài vô hạn.
- Nhóm đang chọn và nhóm ở danh sách nhất quán khi cùng ID.

## 7. GCRUD-02 — Hỗ trợ xóa mô tả

### Hiện trạng

`CreateGroupSheet` đổi nội dung trống thành `null`. `updateGroup` trong datasource chỉ thêm `description` vào payload khi có nội dung. Vì vậy, form không truyền được sự khác biệt giữa xóa mô tả và không cập nhật mô tả. Tác động lưu trữ cuối cùng còn phụ thuộc cách backend xử lý trường bị thiếu.

### Công việc

1. Xác nhận giá trị backend hỗ trợ để xóa mô tả.
2. Chốt ba ý định ở tầng cập nhật: giữ nguyên, gán nội dung mới, xóa nội dung.
3. Dùng biểu diễn rõ ràng phù hợp với caller thực tế; chỉ thêm sentinel/kiểu cập nhật riêng nếu cần phân biệt ba trạng thái tại cùng API Dart.
4. Điều chỉnh form để gửi ý định xóa khi người dùng xóa hết nội dung hoặc chỉ để khoảng trắng.
5. Điều chỉnh datasource để giữ giá trị xóa trong payload thay vì loại bỏ.
6. Rà soát `GroupModel.copyWith`: hiện `description ?? this.description` không thể xóa bằng `null`. Nếu cần hỗ trợ, bổ sung cơ chế rõ ràng và kiểm tra mọi caller bị ảnh hưởng.
7. Rà soát form sửa cũ trong `GroupDetailSheet` và các caller khác nếu còn được sử dụng.

### File dự kiến

- `lib/features/groups/presentation/widgets/create_group_sheet.dart`
- `lib/features/groups/data/datasources/groups_remote_data_source.dart`
- `lib/features/groups/data/models/group_model.dart`
- Interface repository và Cubit nếu phải thay đổi hợp đồng Dart.
- Test model, payload datasource và form tương ứng.

### Tiêu chí nghiệm thu

- Sửa mô tả có nội dung thành trống tạo đúng payload xóa theo hợp đồng backend.
- Tải lại chi tiết sau cập nhật vẫn hiển thị mô tả đã được xóa.
- Cập nhật tên/category không vô tình làm mất mô tả khi caller có ý định giữ nguyên.
- Tạo nhóm với mô tả trống vẫn hợp lệ.
- Nếu chưa xác minh được backend, chỉ ghi nhận test payload/model đã đạt; không tuyên bố tích hợp xóa mô tả đã thành công.

## 8. GCRUD-03 — Chế độ chỉ xem của nhóm lưu trữ

### Hiện trạng

`GroupFundsTabView` truyền `widget.group.isAdmin` cho `FundOverviewCard`; điều kiện chưa xét trạng thái lưu trữ. Nút tạo quỹ và hàm mở form vẫn hoạt động với admin của nhóm lưu trữ.

### Công việc

- Điều kiện hiển thị thao tác tạo quỹ phải bao gồm quyền admin và nhóm chưa lưu trữ.
- Chặn tại hàm mở form, bao gồm cả nhánh callback và nhánh điều hướng route.
- Rà soát các route hoặc điểm gọi khác có thể mở cùng form; đặt kiểm tra tại vị trí dùng chung nếu cần.
- Đối chiếu các thao tác tạo/sửa chi tiêu, quỹ và thông tin nhóm với quy tắc API.
- Giữ khả năng xem danh sách/chi tiết và thao tác xóa nhóm của owner theo hợp đồng hiện có; không chặn tất cả thao tác chỉ dựa trên `isArchived`.
- Giữ xử lý lỗi backend khi trạng thái/quyền thay đổi sau lúc mở màn hình; kiểm tra UI không thay thế phân quyền backend.

### File dự kiến

- `lib/features/funds/presentation/widgets/group_funds_tab_view.dart`
- `lib/features/funds/presentation/widgets/fund_overview_card.dart` chỉ khi cần đổi hợp đồng component.
- `lib/features/funds/presentation/screens/fund_form_screen.dart` hoặc điểm vào route nếu cần chặn đường mở trực tiếp.
- Test widget quỹ và chi tiết nhóm tương ứng.

### Tiêu chí nghiệm thu

- Admin của nhóm active vẫn tạo quỹ được.
- Admin của nhóm archived không mở được form từ các điểm vào đã kiểm kê.
- Member không có nút tạo quỹ theo quyền hiện hành.
- Nhóm archived vẫn xem được dữ liệu.
- API trả lỗi do thay đổi trạng thái/quyền được hiển thị phù hợp, không báo thành công giả.

## 9. Ma trận kiểm thử

| Mã | Tầng | Kịch bản | Kết quả kỳ vọng |
| --- | --- | --- | --- |
| R01 | Cubit | Hai request tải; request mới trả trước | Kết quả mới được giữ |
| R02 | Cubit | Tải cũ trả sau tạo nhóm thành công | Nhóm mới vẫn tồn tại, không trùng ID |
| R03 | Cubit | Tải cũ trả sau sửa nhóm thành công | Tên/category/mô tả mới được giữ |
| R04 | Cubit | Tải cũ trả sau lưu trữ thành công | Trạng thái vẫn archived |
| R05 | Cubit | Tải cũ trả sau xóa thành công | Nhóm không xuất hiện lại |
| R06 | Cubit | Lỗi tải cũ trả sau kết quả mới | Không ghi đè trạng thái hoặc thông báo mới |
| R07 | Cubit | Tải bắt đầu khi mutation đang chạy | Snapshot lỗi thời không được nhận sau mutation thành công |
| R08 | Cubit | Mutation thất bại khi có request tải | Dữ liệu và loading kết thúc hợp lệ |
| R09 | Cubit | Đổi session/reset/close khi request đang chạy | Không nhận phản hồi cũ, không emit sau close |
| R10 | Cubit/widget | Chi tiết cũ trả sau sửa/xóa hoặc đổi nhóm | Không khôi phục dữ liệu/nhóm cũ |
| D01 | Datasource | Mô tả có nội dung | Payload đã trim đúng |
| D02 | Form + datasource | Xóa hết mô tả hoặc nhập khoảng trắng | Payload chứa giá trị xóa đã thống nhất |
| D03 | Model | Xóa mô tả qua cơ chế copy mới | Giá trị thực sự được xóa |
| D04 | Datasource | Caller giữ nguyên mô tả | Không vô tình gửi thao tác xóa |
| D05 | Tích hợp | Xóa mô tả rồi tải lại | Backend và UI nhất quán |
| A01 | Widget | Admin + active | Có thao tác tạo quỹ |
| A02 | Widget | Admin + archived | Không mở form tạo quỹ |
| A03 | Widget | Member + active/archived | Không có thao tác dành riêng admin |
| A04 | Widget | Archived, mở tab quỹ/chi tiêu | Vẫn đọc dữ liệu được |
| A05 | Widget/tích hợp | Backend trả GROUP_ARCHIVED/403 | Hiển thị lỗi, không báo thành công |

Các test thứ tự phản hồi dùng `Completer` hoặc cơ chế điều khiển request tương đương, không phụ thuộc thời gian chờ ngẫu nhiên. Ưu tiên test hành vi có thể hồi quy, tránh test chỉ lặp lại chi tiết triển khai.

## 10. Trình tự triển khai và kiểm tra

1. Hoàn thành xác minh ở giai đoạn 1.
2. Thêm test tái hiện GCRUD-01, xác nhận thất bại đúng nguyên nhân rồi sửa.
3. Chạy test Cubit liên quan; chốt cách đồng bộ selected group và chi tiết.
4. Xác nhận hợp đồng mô tả, thêm test payload/model/form rồi sửa GCRUD-02.
5. Thêm test trạng thái archived rồi sửa GCRUD-03.
6. Chạy các test trực tiếp liên quan:

   ```text
   flutter test test/features/groups/groups_cubit_test.dart
   flutter test test/features/groups/groups_repository_impl_test.dart
   flutter test test/features/groups/group_model_test.dart
   flutter test test/features/groups/group_detail_view_test.dart
   flutter test test/features/groups/groups_screen_test.dart
   flutter test test/features/funds/presentation/widgets/group_funds_tab_view_test.dart
   ```

7. Chạy test mới của datasource/form nếu được bổ sung.
8. Chạy `flutter analyze` hoặc lệnh kiểm tra được repository quy định; phân biệt lỗi có sẵn và lỗi phát sinh.
9. Review diff theo logic, phân quyền hiển thị, vòng đời async, tương thích caller và phạm vi thay đổi.
10. Chỉ mở rộng kiểm thử khi có thay đổi liên quan, lỗi mới hoặc nghi vấn chưa giải quyết. Ghi rõ mọi kiểm tra không chạy được.

## 11. Kiểm tra thủ công nếu có môi trường phù hợp

- Tạo nhóm có/không có mô tả; mở chi tiết và quay lại danh sách.
- Sửa tên, category, mô tả; xóa mô tả; tải lại để xác nhận dữ liệu lưu trên server.
- Lưu trữ nhóm; mở lại từ bộ lọc archived; kiểm tra chế độ chỉ xem.
- Xóa nhóm bằng owner; xác nhận nhóm biến mất khỏi danh sách và không còn lựa chọn cũ.
- Kiểm tra member không thấy sửa/lưu trữ và admin không phải owner không thấy xóa nhóm.
- Mô phỏng mạng chậm/lỗi trong môi trường test để xác nhận không hoàn nguyên dữ liệu, không loading vô hạn và không thành công giả.

Chỉ dùng dữ liệu kiểm thử cho thao tác xóa và lưu trữ; không dùng dữ liệu thật để xác minh luồng phá hủy.

## 12. Rủi ro và cách xử lý

| Rủi ro | Cách xử lý |
| --- | --- |
| Backend coi null và thiếu trường giống nhau | Xác minh hợp đồng trước khi chọn payload; ghi nhận nhu cầu sửa backend nếu API chưa hỗ trợ xóa |
| Loại response cũ làm loading mắc kẹt | Test rõ các thứ tự response và mutation, gồm nhánh thất bại |
| Cubit dùng chung nhiều caller chi tiết | Kiểm kê caller trước khi chọn phạm vi token request |
| `copyWith` thay đổi ảnh hưởng caller cũ | Giữ mặc định giữ nguyên; thao tác xóa phải rõ ràng và có test |
| UI giữ `_group` riêng với Cubit | Kiểm tra cả state Cubit lẫn state widget; không chỉ sửa một tầng |
| Thông báo sync gây tải lại hoặc cập nhật ngoài dự kiến | Đọc subscriber và xác nhận không có vòng lặp/tải thừa do bản sửa |
| SDK/test không chạy ổn định | Ghi lỗi cụ thể; không coi kiểm tra chưa chạy là đã đạt |

## 13. Điều kiện hoàn tất và bàn giao

- [ ] Các phát hiện đã được xác minh; kết luận phụ thuộc backend được ghi rõ.
- [ ] GCRUD-01 có test kiểm soát thứ tự phản hồi và bản sửa đạt tiêu chí nghiệm thu.
- [ ] GCRUD-02 có hợp đồng xóa rõ ràng và test ở tầng chịu trách nhiệm.
- [ ] GCRUD-03 chặn các điểm vào tạo quỹ trong nhóm lưu trữ đã kiểm kê.
- [ ] Trạng thái danh sách, selected group và chi tiết nhất quán sau CRUD.
- [ ] Test liên quan và phân tích tĩnh đã chạy; kết quả/lỗi môi trường được ghi lại.
- [ ] Diff được review lại, không có thay đổi ngoài phạm vi không được giải thích.
- [ ] Báo cáo bàn giao nêu file thay đổi, hành vi trước/sau, kiểm tra đã chạy và giới hạn còn lại.

Khi triển khai, cập nhật checklist theo kết quả thực tế. Không đánh dấu hoàn tất chỉ dựa trên việc đã viết mã.
