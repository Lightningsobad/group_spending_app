# FairShare — Review kế hoạch khởi tạo và bộ câu hỏi bổ sung

Ngày review: 23/09/2026.

Tài liệu gốc: [FairShare_Project_Implementation_Plan.md](D:/App/group_spending_app/documents/FairShare_Project_Implementation_Plan.md).

Phạm vi đối chiếu: kế hoạch 218 dòng, README thiết kế, 10 màn hình HTML tĩnh từ `00_auth` đến `09_settings` (có cả màn chọn nhóm), `pubspec.yaml` và điểm khởi chạy Flutter. Đây là review đặc tả; chưa kiểm chứng API thật, hành vi của bản JavaScript tương tác hay độ khớp hình ảnh trên thiết bị. Repository hiện còn điểm khởi chạy ứng dụng đếm mẫu và danh sách dependency nền tảng.

**Tất cả khuyến nghị trong tài liệu này là đề xuất, chưa phải quyết định đã chốt.** Không thay thế các quyết định trong kế hoạch gốc. Phương án cần backend hỗ trợ phải được đối chiếu hợp đồng API trước khi đưa vào triển khai.

## 1. Nhận định tổng thể

Kế hoạch đủ định hướng để dựng bộ khung Flutter, nhưng chưa đủ đặc tả để triển khai xuyên suốt và nghiệm thu nghiệp vụ công nợ/quỹ. Phần mạnh nhất là cấu trúc feature, lựa chọn quản lý trạng thái, tách mạng/repository, phạm vi tiền tệ và các tính năng tạm hoãn. Phần thiếu nhất là quy tắc chuyển trạng thái giao dịch, hợp đồng API, đồng bộ sau thao tác ghi, ranh giới quyền hạn và lộ trình có điều kiện hoàn thành.

Nên giữ Feature-First, Cubit, DI bằng Provider, model JSON thủ công và VND. Chưa thấy lý do từ tài liệu hiện có để đổi toàn bộ stack, thêm offline database, WebSocket hoặc UseCase cho mọi thao tác. Ưu tiên bổ sung quy tắc và bằng chứng nghiệm thu trước khi tăng số thư viện.

Mức ưu tiên dùng trong review:

- **P0:** chốt trước khi triển khai luồng liên quan; có thể gây ghi trùng, sai công nợ, sai quyền hoặc buộc làm lại API/UI.
- **P1:** chốt trước khi hoàn thành tích hợp và UAT; ảnh hưởng trải nghiệm, độ tin cậy hoặc phạm vi bàn giao.
- **P2:** chỉnh độ chính xác, khả năng bảo trì và chất lượng tài liệu.

## 2. Các phát hiện cần xử lý

| ID | Mức | Dẫn chiếu kế hoạch | Phát hiện và hệ quả | Bổ sung đề xuất |
| --- | --- | --- | --- | --- |
| R01 | P0 | Dòng 17, 30–36 | “Backend có sẵn 100%” nhưng schema thành viên, quỹ và endpoint auth vẫn chờ cung cấp. Backend tồn tại chưa chứng minh các luồng trong kế hoạch đã được hỗ trợ. | Chốt OpenAPI/Postman, phiên bản, môi trường, tài khoản thử, mẫu lỗi; lập bảng đối chiếu từng tính năng với API. |
| R02 | P0 | Dòng 25, 41, 45 | “Real-time 100%”, “mỗi lần vào màn gọi API”, “chỉ kéo xuống mới tải” chưa thống nhất. Tab được giữ trạng thái có thể tiếp tục hiển thị số dư trước khi sửa hóa đơn. | Bỏ cam kết real-time; định nghĩa tải đầu, làm mới chủ động, tải sau ghi, khi quay lại tab và khi app hoạt động lại. |
| R03 | P0 | Dòng 16, 32 | Refresh thất bại được xử lý chung bằng logout, chưa phân biệt token bị thu hồi với mất mạng/timeout. Nhiều request 401 có thể cùng refresh. | Một refresh dùng chung cho các request; replay có giới hạn; token bị từ chối mới kết thúc phiên, lỗi tạm thời cho thử lại. Đây là đề xuất điều chỉnh quy tắc logout đã chốt. |
| R04 | P0 | Dòng 34 | Tên quyết định ghi “người tạo hoặc Admin”, mô tả lại ghi “người chi trả/tạo”. Người nhập hộ và người ứng tiền là hai chủ thể khác nhau. | Tách `createdBy`, `paidBy`, vai trò theo nhóm và ma trận quyền; backend kiểm tra quyền mỗi request. |
| R05 | P0 | Dòng 35, 39 | Chưa quy định phần lẻ, thanh toán một phần, hủy/từ chối xác nhận, nợ mới phát sinh trong lúc chờ nhận tiền. “Nợ về 0” không đúng cho mọi trường hợp. | Settlement gắn số tiền và đối tượng cụ thể; backend trả số dư mới; không đặt toàn bộ số dư về 0 ở client. |
| R06 | P0 | Dòng 34–39; HTML `06_expense_detail` | HTML cho đổi trạng thái trả tiền theo từng phần chia, còn kế hoạch dùng quyết toán công nợ hai bước. Chưa xác định hai thao tác này cập nhật cùng sổ nợ như thế nào. | Chốt một nguồn ghi nhận thanh toán; ngăn ghi nhận cùng khoản chuyển tiền ở cả hóa đơn lẫn màn công nợ. |
| R07 | P0 | Dòng 36, 43 | “Quỹ theo backend” chưa nói tiền đóng quỹ có làm giảm công nợ, ai xác nhận, có chi từ quỹ, hoàn tiền hay không. | Định nghĩa ranh giới đợt thu quỹ, đóng góp, xác nhận và công nợ; tránh tính cùng khoản tiền hai lần. |
| R08 | P0 | Dòng 24, 42 | Chặn ghi khi offline chưa xử lý trường hợp server đã ghi nhưng phản hồi bị mất. Bấm thử lại có thể tạo hai hóa đơn hoặc hai xác nhận. | Khóa thao tác đang gửi ở UI và cơ chế chống trùng phía server; có trạng thái “chưa rõ kết quả” để tra cứu trước khi gửi lại. |
| R09 | P1 | Dòng 38, 45–48; HTML/README thiết kế | HTML tĩnh có tab Thống kê thay cho Quỹ; Google login, CSV, báo cáo, sửa hồ sơ, đổi mật khẩu, ngân hàng; README có duyệt thành viên. Một số mục khác với quyết định đã chốt. | Bảng phạm vi từng màn/nút: làm thật, hoãn, thay đổi thiết kế. Quyết định đã chốt được ưu tiên hơn mẫu. |
| R10 | P1 | Dòng 14, 22, 45 | Đổi tab không đồng nghĩa hủy route/Cubit. Repository quản lý tài nguyên cũng không tự có logic giải phóng chỉ vì nằm trong Provider. | Mô tả scope app/session/tab/group, chủ sở hữu và `dispose`; tách logout khỏi vòng đời điều hướng thông thường. |
| R11 | P1 | Dòng 21, 192 | Một `status` dùng chung không đủ mô tả tải danh sách, tải trang tiếp theo, refresh và gửi form đồng thời mà vẫn giữ dữ liệu. | Giữ single-state, bổ sung trạng thái thao tác độc lập và lỗi theo phạm vi; không cần chuyển sang một hệ quản lý state khác. |
| R12 | P1 | Dòng 11–13; mục 2–3 | Domain chỉ có repository interface; chưa nói kiểu trả về thuộc domain hay data. Nếu interface import DTO thì ranh giới Clean Architecture bị ngược. | Chốt entity Dart thuần và mapping tối thiểu, hoặc công khai chọn kiến trúc giản lược; không để tên kiến trúc và dependency lệch nhau. |
| R13 | P1 | Dòng 24, 27 | Interceptor và màn hình đều có thể báo cùng một lỗi; toast lỗi tải nền có thể xuất hiện ở màn không liên quan. | Interceptor chuẩn hóa lỗi; lớp UI chịu trách nhiệm hiển thị. Sự kiện mất phiên chỉ phát một lần ở mức ứng dụng. |
| R14 | P1 | Dòng 29 | “Log toàn bộ State và Request/Response trong debug” có thể chứa mật khẩu, token, thông tin cá nhân và dữ liệu chi tiêu. | Che dữ liệu nhạy cảm cả debug, log theo danh sách trường được phép; thống nhất cách chẩn đoán bản release. |
| R15 | P1 | Dòng 43; mục 2 | Backend gửi push chưa đủ tạo trải nghiệm nhận push trong app. Thiếu đăng ký thiết bị, quyền thông báo, mở đích và dọn token khi logout. | Chọn kênh MVP thật sự được bàn giao; bổ sung hạ tầng notification nếu có push/in-app. |
| R16 | P1 | Mục 4 | Bốn test hiện có chưa bao phủ nghiệp vụ giá trị cao, cạnh tranh request, quyền hạn, dữ liệu cũ và tích hợp API. Chưa có tiêu chí pass của bản phát hành. | Test contract/model, state, refresh đồng thời, ghi trùng, settlement/quỹ, điều hướng và E2E nhiều tài khoản. |
| R17 | P1 | Toàn bộ kế hoạch | Thiếu pha triển khai, đầu vào/đầu ra, người phụ trách, dependency backend, cấu hình môi trường, build và phát hành. | Thêm roadmap theo lát cắt chạy được, điều kiện bắt đầu và nghiệm thu từng pha. |
| R18 | P2 | Dòng 19–23, 44, 170–180, 216 | Cubit gọi phương thức, không bắt buộc Event như Bloc; cây test chưa minh họa shared/settings/onboarding; chưa cấu hình `gen-l10n`; Chrome không thay thế kiểm thử native. | Chỉnh diễn đạt, bổ sung l10n config và phạm vi test thực tế; đánh giá responsive/a11y cùng độ khớp thiết kế. |

Các điểm kỹ thuật R03, R10, R18 đã đối chiếu tài liệu chính thức: Dio cho phép interceptor chạy đồng thời; `StatefulShellRoute` giữ cây điều hướng từng nhánh; `BlocProvider(create:)` đóng Bloc do mình tạo, còn repository có tài nguyên cần callback dispose; ARB có thể được sinh lớp localization bằng `flutter gen-l10n`, độc lập với `build_runner`. [Dio](https://pub.dev/packages/dio), [GoRouter](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html), [flutter_bloc](https://pub.dev/packages/flutter_bloc), [Flutter l10n](https://docs.flutter.dev/ui/internationalization).

## 3. Bộ câu hỏi trắc nghiệm để chốt bổ sung

Mỗi câu chọn một phương án A/B/C; có thể sửa nội dung phương án. “Khuyến nghị” là đánh giá cho MVP hiện tại, không khẳng định backend đã hỗ trợ. Các câu về nghiệp vụ cần chủ sản phẩm và backend cùng xác nhận. Các câu về triển khai có thể giao kỹ thuật chốt trong giới hạn đã chọn.

### Nhóm A — Phạm vi và hợp đồng tích hợp

**Q01 · P1 — Nền tảng nào thuộc phạm vi nghiệm thu MVP?**

- A. Android và iOS; Chrome chỉ hỗ trợ kiểm tra trong quá trình phát triển.
- B. Android trước; iOS là mốc bàn giao sau.
- C. Android, iOS và Web đều là sản phẩm được nghiệm thu.

**Khuyến nghị: A**, phù hợp mục tiêu Flutter mobile. Ghi phiên bản OS tối thiểu, thiết bị đại diện, hướng màn hình và người/môi trường phụ trách build iOS. Nếu chưa có năng lực kiểm thử iOS, chọn B và ghi rõ mốc bổ sung.

**Q02 · P0 — Khi HTML khác quyết định đã chốt, áp dụng nguồn nào?**

- A. Kế hoạch đã chốt là chuẩn nghiệp vụ; cập nhật danh mục khác biệt thiết kế, giữ 5 tab Dashboard/Groups/Debts/Funds/Settings.
- B. HTML là chuẩn cuối cùng; mở lại các quyết định khác mẫu để chốt lại.
- C. Mỗi màn dùng nguồn mà lập trình viên thấy hợp lý hơn.

**Khuyến nghị: A.** Ghi rõ tab Thống kê và luồng duyệt thành viên không tự động vào MVP; nút thêm chi tiêu là hành động, không mặc nhiên là tab thứ sáu. Mọi thay đổi phạm vi có mã quyết định.

**Q03 · P0 — Điều kiện nào cho phép bắt đầu tích hợp một feature?**

- A. Có hợp đồng API được xác nhận, mẫu request/response/lỗi, quyền và môi trường test cho feature đó.
- B. Có tài liệu nháp; dùng fixture khớp tài liệu, chỉ tích hợp thật sau khi đối chiếu và xử lý sai khác.
- C. Suy ra schema từ HTML và sửa dần khi backend được cung cấp.

**Khuyến nghị: A**, dùng B cho phần bị chặn nếu cần giữ tiến độ dựng UI. Bổ sung bảng endpoint/method, nullable, ID, amount, date, pagination, error code, version, idempotency và người xác nhận. Không coi fixture là bằng chứng hoàn tất tích hợp.

**Q04 · P1 — Những chức năng có trên HTML nhưng chưa chốt sẽ vào MVP đến đâu?**

- A. Chỉ triển khai chức năng đã có đặc tả/API; hoãn Google login, CSV, báo cáo, hồ sơ/ngân hàng nếu chưa xác nhận; ghi trạng thái từng nút.
- B. Bổ sung đặc tả và triển khai toàn bộ chức năng đang nhìn thấy trên HTML.
- C. Để các nút hoạt động mô phỏng và báo thành công trong bản bàn giao.

**Khuyến nghị: A.** Với OCR/VietQR/upload đã hoãn, UI mô phỏng phải ghi rõ chưa hỗ trợ hoặc vô hiệu hóa; không tạo cảm giác dữ liệu thật đã được lưu hay tiền đã chuyển. Nếu CSV được đưa vào, bổ sung quyền, định dạng và xử lý nội dung ô an toàn khi mở bằng bảng tính.

**Q05 · P1 — Danh sách dài được tải, sắp xếp và lọc thế nào?**

- A. Theo cơ chế phân trang API thực tế; tải tiếp, thứ tự ổn định và lọc trên server.
- B. Tải toàn bộ với giới hạn dữ liệu MVP do backend cam kết rõ.
- C. Tự phân trang/lọc dữ liệu đang có trên máy dù server chỉ trả một phần.

**Khuyến nghị: A.** Chốt cursor hoặc page/limit theo backend, không ép một kiểu trước khi đọc API. Ví dụ đề xuất: 20 mục/lần, mới nhất trước và ID làm tiêu chí phụ; khi đổi bộ lọc phải reset trang và bỏ response cũ.

**Q06 · P1 — Cấu hình môi trường và phiên bản công cụ được quản lý thế nào?**

- A. Dev/staging/prod tách cấu hình; pin Flutter SDK và lock dependency; CI dùng cùng cấu hình công cụ.
- B. Dev và prod; cấu hình chuyển thủ công theo hướng dẫn.
- C. Một Base URL cố định trong source dùng cho mọi bản build.

**Khuyến nghị: A.** Ghi app identifier, base URL, cấu hình push nếu có, người giữ signing và quy trình build. URL công khai có thể nằm trong cấu hình build; khóa bí mật phía server không đóng gói vào app.

### Nhóm B — Tiền, quyền và vòng đời nghiệp vụ

**Q07 · P0 — Người tạo khoản chi và người ứng tiền có quyền sửa/xóa thế nào?**

- A. Chỉ người tạo hoặc Admin của nhóm; người ứng tiền khác người tạo không tự có quyền sửa.
- B. Người tạo, người ứng tiền hoặc Admin đều có quyền sửa.
- C. Mọi thành viên tham gia khoản chi đều có quyền sửa.

**Khuyến nghị: A**, sát tên quyết định đã chốt. Chốt thêm ai được nhập hộ người trả; đề xuất thành viên đang hoạt động được chọn một người trả thuộc nhóm, lưu riêng `createdBy` và `paidBy`, không mặc định người trả phải tham gia chia. Backend thực thi ma trận quyền, UI chỉ phản ánh quyền.

**Q08 · P0 — Trạng thái “đã trả/chờ duyệt” trong chi tiết hóa đơn lấy từ đâu?**

- A. Chỉ quyết toán công nợ tạo giao dịch thanh toán; phần chia hóa đơn là chỉ đọc và chỉ hiện trạng thái được backend liên kết rõ.
- B. Thanh toán trực tiếp theo phần chia hóa đơn; mọi lần xác nhận đồng thời cập nhật cùng sổ công nợ.
- C. Cho sửa độc lập trạng thái hóa đơn và trạng thái công nợ.

**Khuyến nghị: A**, giảm hai đường ghi cùng nghiệp vụ. Nếu backend tối giản nợ nhưng không phân bổ settlement về từng hóa đơn, bỏ nhãn đã/chưa trả ở từng phần chia thay vì tự suy ra. Nếu chọn B, phải chốt mapping và chống ghi nhận trùng ở backend.

**Q09 · P0 — Tiền VND và phần dư khi chia đều được xử lý thế nào?**

- A. Số nguyên đồng; backend phân bổ phần dư theo quy tắc ổn định, trả từng phần chia.
- B. Làm tròn mỗi người độc lập, phần chênh lệch tự động tính cho người ứng tiền.
- C. Dùng số thực và làm tròn khi hiển thị.

**Khuyến nghị: A.** Ví dụ 100.000đ/3 phải ra 33.334 + 33.333 + 33.333 = 100.000đ. Chốt thứ tự nhận phần dư, min/max theo API, số người tham gia tối thiểu và việc cấm khoản chi 0/âm trong MVP. Khi chọn người tham gia, không có ID trùng; tổng phần chia phải đúng tổng chi. Client có thể xem trước nhưng kết quả server là chuẩn.

**Q10 · P0 — Khoản chi đã liên quan thanh toán có được sửa/xóa không?**

- A. Cho sửa/xóa khi chưa có settlement liên quan; khóa thay đổi tài chính khi đã có giao dịch chờ hoặc được xác nhận.
- B. Cho sửa bằng bút toán điều chỉnh, giữ lịch sử và tính lại số dư trên server.
- C. Cho ghi đè/xóa trực tiếp mọi lúc và client tự chỉnh số dư.

**Khuyến nghị: A cho MVP nếu backend xác định được quan hệ**, B khi backend đã có sổ giao dịch và điều chỉnh. Với nợ được tối giản, có thể không xác định quan hệ từng hóa đơn; lúc đó cần quy tắc khóa theo kỳ/nhóm hoặc B, không tự giả định A khả thi. Metadata như ghi chú cũng cần ghi rõ có được sửa riêng hay không.

**Q11 · P0 — Quyết toán hỗ trợ thanh toán bao nhiêu mỗi lần?**

- A. Toàn bộ số nợ của một cặp người trong một nhóm tại thời điểm tạo yêu cầu.
- B. Một phần hoặc toàn bộ, cho nhập số tiền trong giới hạn backend cho phép.
- C. Một lần gộp toàn bộ nợ qua nhiều nhóm.

**Khuyến nghị: A cho MVP.** Settlement lưu cố định người gửi, người nhận, nhóm, số tiền, ID và phiên bản dữ liệu. Ví dụ đang chờ nhận 450.000đ mà phát sinh thêm 100.000đ thì sau xác nhận vẫn còn 100.000đ; app dùng số dư backend trả về, không ép về 0. Chốt có cho nhiều settlement chờ cùng cặp/nhóm không; đề xuất chỉ một trong MVP.

**Q12 · P0 — Ngoài xác nhận đã nhận, người dùng xử lý yêu cầu thanh toán chờ như thế nào?**

- A. Người gửi được hủy khi còn chờ; người nhận được xác nhận hoặc từ chối kèm lý do; mọi chuyển trạng thái do server kiểm tra.
- B. Chỉ người nhận được xác nhận; không hỗ trợ hủy/từ chối ở MVP.
- C. App tự xác nhận khi hết thời gian chờ.

**Khuyến nghị: A.** Chốt các trạng thái pending/confirmed/rejected/cancelled theo tên API, quyền từng bước, thông báo và lịch sử. Người gửi bấm “đã chuyển” chỉ là khai báo; không chứng minh chuyển tiền thành công. Xác nhận lặp hoặc đua giữa hủy/xác nhận phải có một kết quả hợp lệ duy nhất.

**Q13 · P0 — Công nợ được rút gọn ở phạm vi nào?**

- A. Trong từng nhóm, theo thuật toán backend, giữ số dư ròng của từng thành viên.
- B. Theo từng cặp người của từng khoản chi, không rút gọn qua người trung gian.
- C. Gộp và rút gọn giữa tất cả các nhóm.

**Khuyến nghị: A nếu API hiện có đã rút gọn nợ.** Xác nhận UI có thể hiển thị người nhận khác người ứng tiền của một hóa đơn. Chốt xử lý khi đồ thị nợ thay đổi lúc settlement đang chờ: backend phải bảo toàn nghĩa vụ đã ghi nhận và tái tính giao dịch còn lại, không để thanh toán trùng.

**Q14 · P0 — “Quỹ chung” trong MVP là sổ thu tiền hay ví dùng để chi?**

- A. Chỉ chiến dịch thu và theo dõi đóng góp; tách công nợ chi tiêu, chưa hỗ trợ chi từ quỹ.
- B. Sổ quỹ đầy đủ có thu/chi, số dư và liên kết khoản chi.
- C. Mỗi lần đóng quỹ tự động giảm nợ cá nhân cùng số tiền.

**Khuyến nghị: A**, phù hợp cấu trúc campaign/contributor hiện có. Chốt mục tiêu, danh sách phải đóng, hạn chót và số phải đóng mỗi người; đóng quỹ không mặc nhiên quyết toán một hóa đơn. Nếu chọn B, bổ sung nguồn tiền, giao dịch chi, đối soát và hoàn quỹ.

**Q15 · P0 — Ai ghi nhận một thành viên đã nộp quỹ và khi nào đợt thu được sửa/xóa?**

- A. Admin xác nhận tiền đã nhận; thành viên chỉ xem/khai báo đang chờ; chỉ sửa mục tiêu/danh sách hoặc xóa khi chưa có đóng góp được xác nhận.
- B. Thành viên tự đánh dấu “đã nộp” có hiệu lực ngay; Admin được chỉnh lại sau.
- C. Mọi thành viên sửa trạng thái nộp của mọi người.

**Khuyến nghị: A.** Đề xuất MVP không nộp một phần/vượt mức trừ khi API đã hỗ trợ; chỉ tiền xác nhận được tính vào tiến độ. Ghi người xác nhận và thời gian, quy tắc đóng chiến dịch, quá hạn, hủy/hoàn tiền; nếu chưa làm hoàn tiền thì phải chặn thao tác cần hoàn, không xóa lịch sử đã thu.

**Q16 · P0 — Thành viên rời/bị xóa khỏi nhóm và Admin cuối cùng được xử lý ra sao?**

- A. Chặn rời/xóa khi còn nghĩa vụ nợ hoặc quỹ chưa xử lý; Admin cuối phải chuyển quyền; lịch sử giữ nguyên ID người cũ.
- B. Cho rời ngay, tiếp tục cho phép xem và xử lý nghĩa vụ cũ ở chế độ hạn chế.
- C. Xóa thành viên kèm mọi dữ liệu liên quan.

**Khuyến nghị: A cho MVP.** Backend kiểm tra nghĩa vụ ở thời điểm thao tác, không dựa vào số dư cũ trên UI. Thành viên mới không được tự động thêm vào hóa đơn/đợt thu cũ; danh sách tham gia phải được lưu theo giao dịch. Quy định lưu trữ nhóm: đề xuất chỉ Admin lưu trữ khi nghĩa vụ đã xử lý, nhóm lưu trữ chỉ đọc; xóa nhóm có lịch sử không nằm trong MVP.

### Nhóm C — Phiên, tính nhất quán và lỗi mạng

**Q17 · P0 — Refresh token thất bại vì mất mạng có đăng xuất ngay không?**

- A. Chỉ đăng xuất khi server xác nhận refresh token hết hạn/bị thu hồi/không hợp lệ; lỗi mạng hoặc 5xx giữ phiên ở trạng thái cần thử lại và chặn thao tác cần xác thực.
- B. Mọi lỗi refresh đều đăng xuất như câu chữ kế hoạch hiện tại.
- C. Bỏ qua lỗi và tiếp tục xem phiên là đã xác thực bình thường.

**Khuyến nghị: A.** Đây là đề xuất sửa quyết định hiện có, cần ghi nhận khi chốt. 403 do thiếu quyền không kích hoạt refresh/logout. Khi logout thật: xóa token, dữ liệu người dùng trong bộ nhớ và các route được bảo vệ; hiển thị thông báo một lần.

**Q18 · P0 — Nhiều request đồng thời bị 401 được xử lý thế nào?**

- A. Chờ cùng một tác vụ refresh trong phiên; cập nhật token một lần và replay mỗi request tối đa một lần theo quy tắc an toàn.
- B. Mỗi request tự refresh độc lập.
- C. Khóa toàn bộ HTTP vào một hàng đợi kể cả lúc token còn hợp lệ.

**Khuyến nghị: A.** Request refresh không tự gọi lại interceptor refresh; token cũ trả 401 trễ phải nhận biết token đã đổi. Response refresh của phiên cũ không được ghi lại token sau logout/đổi tài khoản. Chỉ dùng `QueuedInterceptor` không tự thay thế các quy tắc này; cần test tình huống đồng thời.

**Q19 · P0 — Timeout sau lệnh tạo chi/đóng quỹ/xác nhận được thử lại thế nào?**

- A. Dùng mã thao tác chống trùng do server hỗ trợ; retry cùng thao tác dùng cùng mã, hoặc tra cứu kết quả trước khi gửi lại.
- B. Không tự retry thao tác ghi; báo kết quả chưa rõ và yêu cầu tải/đối chiếu lại trước khi thực hiện tiếp.
- C. Tự retry mọi request 2–3 lần cho đến khi nhận thành công.

**Khuyến nghị: A khi API hỗ trợ, B là phương án tối thiểu nếu chưa có.** Khóa nút chỉ ngăn bấm lặp trong một màn hình, không giải quyết response bị mất hay hai thiết bị. Retry request đọc có giới hạn; thao tác ghi/replay sau refresh phải theo cam kết API, không suy ra an toàn chỉ từ method HTTP.

**Q20 · P0 — Hai người cùng sửa một bản ghi hoặc xác nhận cùng giao dịch thì sao?**

- A. Backend kiểm tra version/ETag hoặc chuyển trạng thái có điều kiện nguyên tử; app báo xung đột, tải bản mới và cho người dùng xem lại.
- B. Người lưu cuối cùng thắng, chấp nhận khả năng ghi đè dữ liệu người khác.
- C. App khóa nút trên thiết bị của mình và coi như hết xung đột.

**Khuyến nghị: A.** Chốt mã lỗi xung đột theo API, cách giữ nội dung form để so sánh và xử lý quyền bị thu hồi giữa lúc xem/sửa. Nếu backend chưa hỗ trợ, ghi nhận dependency cần giải quyết thay vì tuyên bố đã chống xung đột.

**Q21 · P0 — Chính sách làm mới dữ liệu thống nhất là gì?**

- A. Tải lúc mở lần đầu; pull-to-refresh; sau ghi thành công cập nhật/làm mới các dữ liệu liên quan; tab giữ trạng thái tải lại khi đã được đánh dấu cũ.
- B. Mỗi lần màn hình được hiển thị hoặc app hoạt động lại đều gọi API, vẫn cho pull-to-refresh.
- C. Sau lần tải đầu chỉ cập nhật khi người dùng kéo xuống.

**Khuyến nghị: A.** Không lưu cache nghiệp vụ xuống đĩa; cho giữ dữ liệu trong state của phiên. Sau sửa chi: chi tiết/danh sách chi, tổng nhóm, dashboard và debts đều cần được cập nhật hoặc đánh dấu cũ. Đề xuất khi app hoạt động lại sau 60 giây, tải lại màn đang xem; đây là ngưỡng cần chốt. Không cam kết đồng bộ tức thời thay đổi từ thiết bị khác.

**Q22 · P1 — Mất mạng và yêu cầu đã gửi nhưng chưa rõ kết quả hiển thị thế nào?**

- A. Giữ dữ liệu đã tải trong phiên, báo dữ liệu có thể cũ; chặn gửi mới khi biết offline; request đang bay xử lý theo kết quả/đối soát.
- B. Xóa dữ liệu khỏi màn và chỉ hiện lỗi cho tới khi có mạng.
- C. Lưu hàng đợi thao tác ghi offline để tự gửi sau.

**Khuyến nghị: A**, giữ phạm vi no-offline-write đã chốt. Có Wi-Fi không chứng minh API truy cập được; lỗi HTTP/timeout vẫn là đầu vào xử lý. Khởi động offline khi chưa có dữ liệu phải có màn lỗi/retry; không hiển thị số 0 như số dư thật. Không persist bản nháp nghiệp vụ offline trong MVP trừ khi được bổ sung riêng.

**Q23 · P1 — Single State mô tả các tác vụ đồng thời thế nào?**

- A. Một state bất biến với trạng thái tải dữ liệu, refresh, tải thêm và gửi thao tác tách biệt khi cần.
- B. Một `status` chung; tác vụ mới luôn thay thế trạng thái tác vụ cũ.
- C. Chuyển toàn bộ sang các lớp state rời và thay cấu trúc đã chốt.

**Khuyến nghị: A.** Phân biệt tải đầu lỗi, refresh lỗi nhưng còn dữ liệu, danh sách rỗng và submit lỗi. Dùng request ID/cancellation để response cũ không ghi đè bộ lọc/nhóm mới; không emit vào Cubit đã đóng. Toast/navigation là hiệu ứng một lần, không phát lại vì widget rebuild.

**Q24 · P1 — Scope của Cubit và việc đồng bộ các feature được tổ chức ra sao?**

- A. Auth/theme/locale ở app hoặc session; state tab theo nhánh; nhóm/form theo route; truyền kết quả thao tác hoặc sự kiện thay đổi để màn liên quan tải lại.
- B. Một Cubit toàn cục chứa tất cả nhóm và toàn bộ nghiệp vụ.
- C. Mọi widget tự tạo Cubit/repository mới, không quy tắc chia sẻ hay thông báo cập nhật.

**Khuyến nghị: A.** Constructor injection cho Cubit/repository, `BuildContext` dùng tại điểm lắp ghép UI. Ghi rõ ai đóng Cubit/stream/client; đổi tab không mặc nhiên dispose. Thoát phiên phải bỏ state của tài khoản cũ ngay cả khi shell giữ các nhánh.

### Nhóm D — Kiến trúc, dữ liệu và điều hướng

**Q25 · P1 — Kiểu dữ liệu đi qua repository interface thuộc tầng nào?**

- A. Domain entity Dart thuần; data model parse JSON và map sang entity, không phụ thuộc Flutter/Dio trong domain.
- B. Model dùng chung trung lập được đặt ở module chung, chủ động chọn kiến trúc giản lược.
- C. Domain import trực tiếp model trong `data/` nhưng vẫn yêu cầu phân lớp nghiêm ngặt.

**Khuyến nghị: A**, nhất quán với Clean Architecture đã chọn. Thêm `domain/entities/` và mapper cần thiết, không bắt buộc thêm UseCase một dòng. Auth identity khác group membership; quyền Admin phải gắn nhóm, không chỉ là thuộc tính toàn cục của User.

**Q26 · P1 — Tầng nào chịu trách nhiệm hiển thị lỗi?**

- A. Tầng mạng/repository chuẩn hóa lỗi; Cubit và UI quyết định field error, banner, retry hoặc snackbar; auth mất phiên xử lý một lần ở app.
- B. Interceptor luôn hiện snackbar, UI cũng được hiển thị lỗi của mình.
- C. Chỉ log, không thông báo trên UI.

**Khuyến nghị: A.** Giữ AppException, thêm mã nghiệp vụ, field errors, request ID và cách phân biệt forbidden/not-found/conflict/rate-limit/parse/cancel. Không nhất thiết tạo một class cho từng mã; cancellation do điều hướng không phải lỗi cần báo người dùng. Dùng mã lỗi để dịch vi/en thay vì hiển thị thẳng stack trace/raw body.

**Q27 · P1 — Parse JSON thủ công xử lý dữ liệu thiếu hoặc lạ thế nào?**

- A. Trường bắt buộc sai kiểu/thiếu thì báo lỗi dữ liệu; trường optional có quy tắc mặc định rõ, enum lạ có fallback nếu an toàn.
- B. Mọi trường thiếu đều thay bằng chuỗi rỗng, 0 hoặc false.
- C. Ép kiểu trực tiếp toàn bộ và để UI tự bắt lỗi khi truy cập.

**Khuyến nghị: A.** Đặc biệt không biến thiếu amount thành 0 hoặc thiếu quyền thành Admin. Lưu category ID ổn định, tách nhãn vi/en; xác nhận ID backend cho 8 danh mục. Viết fixture test cho mẫu hợp lệ, null, enum lạ và kiểu số thực tế của API.

**Q28 · P1 — Ngày giờ, ngôn ngữ và định dạng tiền vận hành theo quy ước nào?**

- A. Timestamp có timezone, lưu/trao đổi theo chuẩn API; nghiệp vụ ngày/hạn quỹ dùng Asia/Ho_Chi_Minh; tiền luôn `x.xxx đ`, cả vi/en.
- B. Mọi ngày giờ và tiền hiển thị theo locale/timezone thiết bị.
- C. Parse và hiển thị nguyên chuỗi do server gửi.

**Khuyến nghị: A** cho MVP thuần VND tại Việt Nam. Phân biệt date-only với thời điểm; chốt hạn quỹ kết thúc vào giờ nào, trường ngày chi có được sửa/hồi tố hay không. Cho phép `flutter gen-l10n` sinh mã localization, vẫn giữ JSON model thủ công và không dùng `build_runner`. Chốt vi mặc định hay theo thiết bị; đề xuất vi mặc định, lựa chọn người dùng được lưu.

**Q29 · P1 — App khởi động, nhận link và gặp route không còn truy cập được xử lý thế nào?**

- A. Có trạng thái bootstrap; đọc settings/onboarding/token trước khi quyết định route; sau đăng nhập quay lại đích hợp lệ và kiểm tra quyền.
- B. Luôn mở Dashboard trước rồi sửa route khi tải xong phiên.
- C. Chỉ mở link được khi đã đăng nhập; mọi trường hợp khác quay về trang chủ.

**Khuyến nghị: A.** Chốt thứ tự first launch/onboarding/auth, logout/back không quay lại màn riêng tư, nhóm không tồn tại/bị thu hồi quyền, route modal ở root hay trong tab và cảnh báo rời form chưa lưu. Destination từ link phải được giới hạn vào route hợp lệ của app, không tự mở URL tùy ý.

**Q30 · P1 — Mã mời và QR tham gia nhóm có chính sách nào?**

- A. Giữ nhập mã và quét QR vào nhóm ngay; mã có thể thu hồi/tạo lại theo API, xử lý đã tham gia/mã hết hạn; từ chối camera vẫn nhập mã được.
- B. MVP chỉ nhập mã; đưa QR sang giai đoạn sau.
- C. Giữ mã/QR nhưng bổ sung bước Admin duyệt mọi thành viên.

**Khuyến nghị: A**, bảo toàn quyết định đã chốt; B/C là thay đổi phạm vi cần ghi rõ. QR tham gia nhóm khác VietQR thanh toán đang hoãn. Chốt payload, xác thực đúng loại QR, quyền tạo lại mã, giới hạn nhóm, nhóm lưu trữ không cho gia nhập và quyền xem lịch sử của người mới. Đề xuất thành viên mới được xem lịch sử nhóm nhưng không tự gánh phần chia cũ.

### Nhóm E — Thông báo, tài khoản, bảo mật và bàn giao

**Q31 · P1 — Nhắc nợ/nhắc quỹ sử dụng kênh nào trong MVP?**

- A. In-app notification có API danh sách/đã đọc và đích mở; chưa bàn giao push nền.
- B. Push và in-app đầy đủ, bao gồm đăng ký device token, quyền nhận, mở đích và xử lý logout/đổi tài khoản.
- C. Chỉ gọi API nhắc và báo kết quả gửi; app chưa có nơi nhận/xem thông báo.

**Khuyến nghị: A nếu backend có inbox; B nếu nhận push khi app đóng là tiêu chí bắt buộc.** C cần mô tả là xác nhận yêu cầu gửi, không gọi là luồng nhắc nợ hoàn chỉnh. Chốt người được nhắc, quyền gửi, nhắc hàng loạt hay từng người; cooldown theo API và lỗi 429. Chỉ cho nhắc nghĩa vụ chưa hoàn thành; không hứa đã giao thông báo chỉ vì API nhận request.

**Q32 · P1 — Phạm vi tài khoản nào phải hoạt động thật?**

- A. Email/password: đăng nhập, đăng ký, quên/reset mật khẩu, logout; các bước xác minh theo API; hoãn Google login và mục hồ sơ/ngân hàng chưa chốt.
- B. A cộng Google login, sửa hồ sơ, đổi mật khẩu và lưu tài khoản ngân hàng.
- C. Chỉ đăng nhập/logout; đăng ký và quên mật khẩu là giao diện mô phỏng.

**Khuyến nghị: A**, theo auth đã ghi trong kế hoạch. C là thu hẹp phạm vi hiện tại. Chốt reset bằng OTP hay link, trạng thái email chưa xác minh, logout một thiết bị hay toàn bộ phiên, lỗi secure storage và màn hỗ trợ/xóa tài khoản nếu đưa vào phạm vi sản phẩm. Nếu giữ đổi mật khẩu trong Settings thì phải bổ sung endpoint và quy tắc thu hồi phiên tương ứng.

**Q33 · P1 — Chính sách log và chẩn đoán lỗi là gì?**

- A. Log debug có che dữ liệu nhạy cảm; release không ghi payload; sự cố được đối chiếu bằng request ID và log backend.
- B. Như A, bổ sung crash/error reporting đã lọc dữ liệu cho bản release.
- C. Giữ log nguyên request/response và toàn bộ state trong debug.

**Khuyến nghị: A để giữ MVP gọn.** Không log mật khẩu, token, cookie, mã reset, thông tin ngân hàng hoặc toàn bộ nội dung chi tiêu. Chọn B nếu cần chẩn đoán lỗi ngoài môi trường test; phải chốt dữ liệu gửi đi, thời gian lưu và thông tin quyền riêng tư trước khi bật. Không cam kết “mã hóa toàn bộ” trên UI nếu chưa có cơ sở kỹ thuật tương ứng.

**Q34 · P1 — Tiêu chí nghiệm thu UI dùng cách nào?**

- A. Đối chiếu thiết kế ở kích thước chuẩn, đồng thời kiểm tra màn nhỏ/lớn, chữ lớn, bàn phím, safe area, vi/en và light/dark trên thiết bị mục tiêu.
- B. Chỉ yêu cầu khớp pixel ở khung HTML 393 × 852.
- C. Chỉ cần có đúng các trường, không kiểm tra bố cục hay khả năng sử dụng.

**Khuyến nghị: A.** Giữ Nunito nhưng đóng gói font cần dùng để hiển thị ổn định khi mất mạng; thống nhất bộ icon có thật trong package. Bổ sung nhãn đọc màn hình, độ tương phản, vùng chạm, trạng thái loading/empty/error. Các tiêu chí accessibility có thể kiểm tra bằng công cụ Flutter. [Hướng dẫn kiểm thử accessibility](https://docs.flutter.dev/ui/accessibility/accessibility-testing).

**Q35 · P1 — Điều kiện nào cho phép coi một feature hoàn thành?**

- A. Đủ UI/trạng thái, API thật, quyền/lỗi, test rủi ro chính; analyze/test/build qua và UAT theo checklist.
- B. UI khớp mẫu và happy path chạy được bằng dữ liệu mô phỏng.
- C. Code hoàn tất, dồn toàn bộ kiểm thử vào cuối dự án.

**Khuyến nghị: A.** Không dùng tỷ lệ coverage làm điều kiện duy nhất. Luồng thanh toán/quỹ phải kiểm thử nhiều tài khoản trên backend staging và được chủ sản phẩm xác nhận. Ghi rõ ai duyệt, bằng chứng test, bug chặn release và cách smoke-test bản build phát hành.

**Q36 · P1 — Triển khai theo thứ tự nào để phát hiện rủi ro sớm?**

- A. Hợp đồng/API → nền tảng + auth → nhóm + khoản chi chạy xuyên suốt → công nợ → quỹ/thông báo → hoàn thiện và phát hành.
- B. Dựng toàn bộ UI các màn trước, cuối cùng mới tích hợp API/nghiệp vụ.
- C. Xây mọi feature cùng lúc, không có mốc nghiệm thu trung gian.

**Khuyến nghị: A.** Mỗi pha có đầu vào, đầu ra, dependency, chủ trì và tiêu chí pass. Chỉ gắn lịch ngày khi biết năng lực đội, độ sẵn sàng API và phạm vi đã chọn; không suy ra thời lượng từ số màn hình.

## 4. Nội dung đề xuất để đưa vào kế hoạch sau khi chọn đáp án

### 4.1. Những câu nên chỉnh ngay về độ chính xác

- “Real-time No-Cache, đảm bảo thời gian thực 100%” → “Không lưu cache nghiệp vụ xuống đĩa; dùng dữ liệu trong state của phiên và chính sách làm mới đã thống nhất; backend là nguồn dữ liệu chuẩn.” Chính sách cụ thể chờ Q21.
- “Chỉ người chi trả/tạo...” → tách rõ `createdBy`, `paidBy`, Admin theo nhóm; quyền chờ Q07.
- “Xác nhận đã nhận → nợ về 0” → “Backend ghi nhận đúng settlement được xác nhận và trả số dư sau cập nhật.”
- “Provider tự động dispose” → “BlocProvider đóng Bloc do mình tạo; resource của repository/client/stream có chủ sở hữu và logic dispose rõ.”
- “BLoC/Cubit tách State & Event” → “Dùng Cubit làm mặc định; UI gọi phương thức Cubit, Cubit phát state. Chỉ dùng Bloc/Event khi có nhu cầu đã xác định.”
- “Không sinh code” nếu xuất hiện trong hướng dẫn sau này → giới hạn ở model JSON; localization vẫn có thể dùng `flutter gen-l10n`.
- “Chrome emulator” → “Trình duyệt Chrome cho kiểm tra Flutter Web; emulator/simulator hoặc thiết bị Android/iOS cho nghiệm thu mobile.”
- Thay các link `file:///d:/...` trong tài liệu chia sẻ bằng đường dẫn phù hợp repository để cộng tác viên khác mở được.

### 4.2. Các mục còn thiếu nên thêm vào kế hoạch

| Mục mới | Nội dung bắt buộc | Câu liên quan |
| --- | --- | --- |
| Phạm vi MVP và nguồn chuẩn | Ma trận màn/nút, làm thật/hoãn, nền tảng, điểm lệch HTML | Q01–Q04, Q30–Q32 |
| Hợp đồng API và dữ liệu | Endpoint, mẫu dữ liệu, kiểu tiền/ngày, phân trang, mã lỗi, capability backend | Q03, Q05, Q09, Q19–Q20, Q27–Q28 |
| Ma trận quyền và nghiệp vụ | Quyền theo nhóm, creator/payer, thành viên, lưu trữ, phần chia, settlement và quỹ | Q07–Q16 |
| Trạng thái và đồng bộ | State machine auth/settlement/quỹ, mutation retry, dữ liệu cũ và concurrency | Q12, Q17–Q24 |
| Bootstrap và composition root | Cấu hình môi trường, DI, scope, router, phiên người dùng | Q06, Q24–Q25, Q29 |
| Bảo mật và thông báo | Token/log, account lifecycle, kênh notification, quyền camera/push | Q17–Q18, Q30–Q33 |
| Nghiệm thu và vận hành | UI/device matrix, test, CI, build ký, staging, owner, release checklist | Q01, Q06, Q34–Q36 |
| Lộ trình thực hiện | Pha, đầu vào, đầu ra, phụ thuộc backend, owner và tiêu chí hoàn thành | Q36 |

Mỗi quyết định cần lưu: mã Q, đáp án, diễn giải cuối cùng, người chốt, ngày chốt, API liên quan và tiêu chí nghiệm thu. Câu chưa có API hỗ trợ được ghi là dependency, không đánh dấu “đã hoàn tất”.

### 4.3. Bộ acceptance test cần bổ sung

Các tình huống dưới đây dùng phương án khuyến nghị; cập nhật lại nếu chọn phương án khác. Backend chịu trách nhiệm tính toán và cưỡng chế quyền; app kiểm tra cách tích hợp/hiển thị, không triển khai một thuật toán công nợ thứ hai chỉ để test.

| Tình huống | Kết quả cần chứng minh |
| --- | --- |
| 100.000đ chia 3 người | Tổng phần chia đúng 100.000đ; người nhận phần dư ổn định theo API. |
| Người tạo khác người ứng tiền | Quyền sửa/xóa đúng Q07, cả UI và API; trường người tạo không bị ghi thành người trả. |
| Bấm lưu nhiều lần, phản hồi bị mất | Chỉ một thao tác có hiệu lực; UI phân biệt thất bại thật với chưa biết kết quả. |
| Năm request cùng 401 | Một refresh của phiên; replay có giới hạn; không lặp vô hạn hoặc toast nhiều lần. |
| Logout trong lúc refresh đang chạy | Response cũ không hồi sinh phiên hoặc lộ dữ liệu của tài khoản trước. |
| Refresh gặp timeout rồi có mạng lại | Theo Q17, phiên được thử lại đúng cách; không ghi khi chưa xác thực được. |
| Chờ nhận 450.000đ, phát sinh thêm 100.000đ | Xác nhận ghi đúng 450.000đ; hiển thị số dư backend mới, không đặt 0. |
| Hai thiết bị xác nhận cùng settlement | Chỉ ghi nhận một lần; thiết bị còn lại nhận trạng thái nhất quán. |
| Một người hủy, người kia xác nhận gần đồng thời | Server chấp nhận đúng một chuyển trạng thái cuối hợp lệ. |
| Sửa khoản chi đã liên quan quyết toán | Bị chặn hoặc tạo điều chỉnh đúng Q10; lịch sử được bảo toàn. |
| Sau tạo/sửa/xóa chi quay về các tab | Dashboard, nhóm, chi tiêu và công nợ cùng phản ánh thay đổi theo Q21. |
| Lọc/tải trang trong lúc đổi nhóm | Response cũ không chèn dữ liệu nhóm trước vào nhóm hiện tại. |
| Refresh lỗi khi đã có dữ liệu | Dữ liệu cũ còn hiển thị với lỗi phù hợp; không thành số 0 hay danh sách trống giả. |
| Người mới tham gia, người cũ rời nhóm | Phần chia cũ không đổi; quyền và lịch sử đúng Q16/Q30. |
| Đóng quỹ, sau đó xem công nợ | Không trừ nợ hai lần; tiến độ chỉ dùng đóng góp có trạng thái được tính. |
| Mã QR không hợp lệ hoặc camera bị từ chối | Có lỗi cụ thể, nhập mã thay thế; không gia nhập sai nhóm. |
| Người dùng bị xóa khỏi nhóm đang mở | UI dừng thao tác trái quyền và xử lý response quyền bị từ chối. |
| Đăng nhập tài khoản B sau tài khoản A | Không còn dữ liệu, route, subscription hoặc device association của A trong phạm vi cần xóa. |
| Deep link khi app đóng/chưa đăng nhập | Qua bootstrap/auth rồi đến đích hợp lệ, có kiểm tra quyền. |
| vi/en, light/dark, chữ lớn và bàn phím | Không che nút, tràn nội dung quan trọng hoặc mất nhãn truy cập. |

Test tự động nên đặt theo module thật: unit cho formatter/validator/parser và điều phối trạng thái; widget cho các trạng thái giao diện; integration cho hành trình quan trọng. Các invariant tiền, quyền, chống trùng và chuyển trạng thái nguyên tử phải có bằng chứng kiểm thử backend hoặc contract/E2E trên môi trường tích hợp; mock thành công trên client không chứng minh backend đúng.

### 4.4. Lộ trình khuyến nghị với điều kiện hoàn thành

| Pha | Kết quả bàn giao | Điều kiện qua pha |
| --- | --- | --- |
| 0. Chốt đặc tả | Đáp án P0, capability matrix API, scope các nút HTML, dữ liệu test | Mỗi luồng lõi có request/response/quyền/trạng thái rõ; dependency còn lại có owner |
| 1. Nền tảng và phiên | Env, theme/l10n, DI, Dio, storage, bootstrap/router, auth thật | Luồng login/refresh/logout đúng, không lộ dữ liệu phiên trước; CI nền tảng chạy được |
| 2. Nhóm và chi tiêu | Tạo/join/xem nhóm, tạo/xem/sửa/xóa chi theo quyền, chia đều | Một hành trình nhiều tài khoản chạy trên staging; số liệu liên màn đồng bộ |
| 3. Công nợ | Đọc nợ, settlement hai bước, hủy/từ chối theo lựa chọn | Đúng số tiền, người nhận, nhóm; chống xác nhận trùng và race |
| 4. Quỹ và nhắc | Campaign, đóng góp/xác nhận, nhắc theo kênh đã chọn | Không lẫn quỹ/công nợ; đúng tiến độ/quyền, hành vi quá hạn và nhận thông báo |
| 5. Hoàn thiện và phát hành | Onboarding/settings còn lại, UX lỗi, thiết bị, signing, build bàn giao | Checklist DoD/UAT pass; chủ sản phẩm chấp nhận; hướng dẫn cấu hình và phát hành đầy đủ |

Mỗi pha cần thêm người phụ trách app/backend/QA, ước lượng sau khi chốt phạm vi, rủi ro và mốc kiểm tra. Onboarding/theme có thể dựng sớm cùng bộ khung; thứ tự trên ưu tiên kiểm chứng nghiệp vụ chứ không bắt buộc mọi công việc diễn ra tuần tự.

## 5. Cách trả lời nhanh

Ưu tiên trả lời **17 câu P0**: **Q02, Q03 và Q07–Q21**. Đây là các quyết định về nguồn chuẩn, hợp đồng API, quyền, tiền, quỹ, phiên và tính nhất quán dữ liệu.

Có thể trả lời theo mẫu: `Q02=A; Q03=A; Q07=A; Q08=A; Q09=A...`, hoặc `Chọn các khuyến nghị, ngoại trừ Qxx=...`. Những câu khuyến nghị phụ thuộc API (đặc biệt Q10, Q13, Q19, Q31) vẫn phải xác nhận capability, không thể suy ra từ lựa chọn của phía app.

## 6. Nguồn kỹ thuật đã đối chiếu

- [GoRouter — StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html): vòng đời các nhánh điều hướng có trạng thái.
- [flutter_bloc](https://pub.dev/packages/flutter_bloc): quyền sở hữu BlocProvider và callback dispose của RepositoryProvider.
- [Dio](https://pub.dev/packages/dio): interceptor chạy đồng thời, QueuedInterceptor và hành vi logging.
- [Flutter internationalization](https://docs.flutter.dev/ui/internationalization): cấu hình ARB và gen-l10n.
- [Flutter accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing): công cụ kiểm tra vùng chạm, nhãn và độ tương phản.

Các quy tắc nghiệp vụ đề xuất trong review là suy luận từ phạm vi FairShare và tình huống biên, không phải nội dung do các tài liệu thư viện quyết định.
