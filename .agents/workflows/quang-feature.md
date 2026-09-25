---
description: Triển khai một tính năng FairShare theo kiến trúc đã chốt, kiểm soát hard-code, state và cây widget.
---

## 1. Đọc ngữ cảnh và xác định phạm vi

1. Đọc hướng dẫn repository áp dụng, `documents/FairShare_Project_Implementation_Plan.md`, cấu trúc hiện tại và thay đổi chưa commit. Đọc các tài liệu/API liên quan đến tính năng.
2. Kế hoạch Implementation Plan, đặc biệt mục 3 và 5, là nguồn quyết định. `FairShare_Project_Plan_Review_and_Questions.md` chỉ là bối cảnh đề xuất; không thay thế lựa chọn đã chốt. Giới hạn chỉ tạo thư mục của Pha 0 không áp dụng cho yêu cầu triển khai tính năng mới này.
3. Kiểm tra thành phần có thể tái sử dụng và xác định luồng Screen/Widget → Cubit → domain repository → data implementation → datasource → ApiClient.
4. Trước khi sửa, nêu ngắn gọn phạm vi, file/layer dự kiến thay đổi, trạng thái UI cần có, rủi ro và cách kiểm chứng. Phân biệt quyết định đã chốt với giả định.
5. Không đoán endpoint, schema, quyền, mã lỗi hoặc quy tắc nghiệp vụ. Nếu thiếu thông tin quyết định hành vi, hỏi câu cụ thể và tiếp tục phần độc lập có thể làm. Mock/fixture phải được xác định rõ, không được giả là API thật.

## 2. Giữ ranh giới kiến trúc

- Dùng Feature-First Clean Architecture và Cubit mặc định. Entity và repository contract trong domain là Dart thuần, không import Flutter, Dio hoặc data model.
- Data chịu trách nhiệm gọi API, parse/kiểm tra JSON, mapping và triển khai repository. Presentation không gọi Dio/datasource hoặc tự parse response.
- Parse thủ công: trường bắt buộc thiếu/sai kiểu phải thành lỗi dữ liệu có thể xử lý. Chỉ đặt mặc định cho trường optional khi hợp đồng quy định. Không dùng chuỗi rỗng, số 0 hoặc false để che response không hợp lệ.
- Không bắt buộc UseCase một dòng, không dựng base repository/base Cubit hay service trung gian khi chưa có nhu cầu thực tế. Model kế thừa Entity không tự nó là lỗi phụ thuộc; chỉ tách mapper khi khác biệt dữ liệu hoặc nghiệp vụ yêu cầu.
- Dùng constructor injection, RepositoryProvider và BlocProvider; không thêm get_it. Lắp implementation tại điểm lắp ghép của ứng dụng; phân tách main/bootstrap/app theo kế hoạch khi chỉnh nền tảng.
- Không tạo client/repository/Cubit có vòng đời dài mỗi lần build widget. Provider tạo Cubit thì chịu trách nhiệm đóng; `.value` chỉ nhận instance có chủ sở hữu và cơ chế đóng rõ ràng. Resource mạng, timer, stream và controller cần được giải phóng đúng scope.
- `core`/`shared` không phụ thuộc trực tiếp feature; Cubit không gọi chéo Cubit. Có một điểm cần thống nhất trong kế hoạch: router đặt trong core nhưng đăng ký route cần biết màn hình feature. Đề xuất lắp danh sách route ở cấp app và truyền vào router dùng chung; không tự biến điều này thành một ngoại lệ ngầm.
- Widget chỉ dùng trong feature đặt ở `features/<feature>/presentation/widgets/`; widget dùng chung thực sự mới đặt ở `shared/widgets/`.

## 3. Kiểm soát hard-code theo ý nghĩa

- Base URL và môi trường phải đến từ cấu hình dev/staging/prod được nạp và truyền vào. Khi dùng dart-define/flavor, kiểm tra cấu hình bắt buộc và không mặc định âm thầm sang production. Cấu hình client không phải kho bí mật.
- API path, mã lỗi và chính sách xác thực phải có nguồn xác định; không rải cùng giá trị ở nhiều tầng. Metadata yêu cầu xác thực/public nên được khai báo rõ, không suy luận bằng substring của URL.
- Các quy tắc như cooldown, giới hạn thử, độ dài mã, phân trang và quyền phải theo hợp đồng. Giá trị động lấy từ server nếu API hỗ trợ; giá trị cố định đã chốt có một nguồn khai báo phù hợp feature. Không tạo remote config chỉ để thay một hằng số ổn định.
- Chuỗi hiển thị dùng ARB vi/en, bao gồm lỗi, nhãn accessibility và trạng thái rỗng. Mã lỗi máy không dịch; UI ánh xạ mã lỗi sang thông báo phù hợp, không hiển thị raw exception/stack trace.
- Dùng Theme/ColorScheme và token màu theo vai trò để hỗ trợ light/dark; typography dùng Nunito đóng gói trong assets. Gom spacing/radius/style lặp lại khi có giá trị tái sử dụng.
- Không máy móc đưa mọi `SizedBox(height: 8)` hay kích thước trang trí riêng vào constants. Literal cục bộ dễ hiểu, không làm sai responsive/theme/nghiệp vụ, có thể giữ tại widget.
- Không dùng dữ liệu demo hay số 0 thay cho dữ liệu chưa tải/lỗi. Tính năng hoãn phải ghi rõ chưa hỗ trợ hoặc vô hiệu hóa hành động.

## 4. Thiết kế state và xử lý bất đồng bộ

- Mô tả trạng thái và chuyển trạng thái trước khi viết: initial/loading/success/empty/error và refresh/submit/load-more nếu tính năng cần. Tách các thao tác có thể diễn ra độc lập; không dùng một cờ loading chung gây khóa hoặc ghi đè luồng khác.
- State bất biến; collection không bị sửa tại chỗ. `copyWith` phải phân biệt giữ nguyên với chủ động xóa giá trị nullable.
- Giữ dữ liệu cũ khi refresh lỗi, kèm trạng thái cần thử lại. Không biến lỗi thành danh sách rỗng hoặc số 0.
- Chặn submit trùng trước await. Dùng request ID, session generation hoặc cancellation phù hợp để response cũ không cập nhật màn hình/nhóm/bộ lọc/phiên mới. Có kiểm tra vòng đời sau await khi cần.
- Snackbar, dialog và navigation xử lý một lần qua listener/effect có điều kiện. Countdown hoặc rebuild không được phát lại thông báo cũ. Chỉ có một nơi chịu trách nhiệm quyết định điều hướng phiên.
- Nếu tính năng liên quan auth: một refresh dùng chung cho phiên, replay tối đa một lần khi hợp đồng bảo đảm an toàn; không chờ request đi qua cùng hàng đợi lỗi đang bị giữ. Chỉ logout khi token được xác nhận vô hiệu; timeout/5xx giữ phiên cần thử lại. Response cũ không được lưu token hoặc phục hồi phiên sau logout.
- Không tự retry thao tác ghi chưa rõ kết quả. Đối chiếu server theo hợp đồng trước khi làm tiếp; không mặc định API có idempotency. Sau ghi, cập nhật hoặc đánh dấu dữ liệu liên quan cần tải lại theo cơ chế chung.

## 5. Xây cây widget theo trách nhiệm

- Screen giữ bố cục cấp trang, liên kết state, callback và listener. Logic nghiệp vụ, truy cập storage/network và quy tắc điều hướng phiên không nằm rải trong build.
- Tách widget khi khối có trách nhiệm rõ (header/form/input OTP/trạng thái gửi lại), có state hoặc vòng đời riêng, được lặp lại, hoặc cần giới hạn phạm vi rebuild. Ưu tiên class StatelessWidget/StatefulWidget với tham số rõ; không chỉ chuyển toàn bộ cây dài sang các hàm `_build...`.
- Truyền giá trị cần hiển thị và callback cho widget con; không truyền toàn bộ repository hoặc AuthState vào mọi widget. Widget nhỏ không tự quyết định điều hướng toàn ứng dụng.
- Dùng const khi phù hợp, BlocSelector/buildWhen cho phần dữ liệu liên quan. Countdown chỉ cập nhật vùng cần hiển thị countdown; không buộc cả màn hình dựng lại mỗi giây. Việc tách file đơn thuần không đảm bảo giảm rebuild.
- Mốc tham khảo để dừng và xem lại: build khoảng trên 100 dòng hoặc screen khoảng trên 300 dòng. Đây không phải giới hạn cứng; ưu tiên trách nhiệm, độ dễ đọc và khả năng kiểm thử, không chia widget vô nghĩa để đạt số dòng.
- Dùng constraints/LayoutBuilder/Flexible/Expanded phù hợp. Tránh hàng gồm các ô cố định vượt chiều rộng khả dụng. Kiểm tra màn nhỏ/lớn, chữ lớn, bàn phím, safe area và chuỗi dài vi/en.
- Với form: tách validator thuần có ý nghĩa tái sử dụng; controller/focus thuộc widget sở hữu và được dispose. Có field error, trạng thái đang gửi, thao tác bàn phím và nhãn accessibility phù hợp.

## 6. Kiểm chứng theo rủi ro

- Thêm test có ý nghĩa cho phần logic mới hoặc lỗi được sửa: parser dữ liệu hợp lệ/thiếu/sai kiểu, validator, chuyển state, lỗi mạng/nghiệp vụ, submit trùng và response cũ nếu liên quan.
- Widget test tập trung hành vi: nhập liệu, loading, lỗi hiển thị đúng một lần, retry, điều hướng và bố cục ở kích thước rủi ro. Dùng pump có thời lượng xác định khi màn hình có timer/animation liên tục.
- Test repository/datasource/interceptor bằng fixture hoặc adapter giả lập; không gọi production trong test tự động. Test happy path dùng fake repository không chứng minh tích hợp API đúng.
- Chạy format cho file Dart thay đổi, flutter analyze và nhóm test liên quan. Mở rộng kiểm tra/build/integration khi thay đổi nền tảng hoặc rủi ro yêu cầu. Không viết test chỉ sao chép implementation, không thêm golden cho mọi thay đổi trang trí nhỏ.
- Kiểm tra trực quan theo thiết kế trên công cụ/thiết bị có sẵn. Ghi rõ ma trận đã kiểm tra và phần chưa kiểm tra; không suy ra Android/iOS pass từ một widget test hoặc Chrome.
- Không tự thêm dependency/generator/framework lớn chỉ để đơn giản một thay đổi nhỏ. Không sửa/xóa thay đổi của người dùng ngoài phạm vi.

## 7. Tự review và bàn giao

Trước khi kết thúc, đọc diff và đối chiếu:

- Có import vượt ranh giới, logic nghiệp vụ trong build, dependency sai vòng đời hay resource không được giải phóng không?
- Có URL production cố định, chuỗi UI ngoài ARB, màu phá dark mode, quy tắc API bị đoán hoặc giá trị mặc định che lỗi không?
- Có state nullable không xóa được, request trùng, response cũ, retry ghi không an toàn hoặc listener phát hiệu ứng lặp không?
- Cây widget có trách nhiệm rõ và phản hồi được kích thước/chữ lớn/locale không? Việc tách widget có giải quyết vấn đề thực tế không?
- Test có kiểm tra hành vi quan trọng và ít nhất tình huống lỗi liên quan, thay vì chỉ render/happy path không?