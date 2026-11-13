# Kế hoạch chỉnh sửa luồng thống kê FairShare

Ngày lập: 06/11/2026. Trạng thái: đề xuất triển khai, chưa sửa mã nguồn.

## 1. Mục tiêu và phạm vi

Khắc phục bốn vấn đề phát hiện khi review Tab Thống kê, Báo cáo tổng quan cá nhân và Thống kê nhóm. Bảo đảm bộ lọc, số liệu, danh sách hóa đơn và trạng thái lỗi phản ánh cùng một phạm vi dữ liệu.

Tài liệu tham chiếu:

- [Kế hoạch triển khai thống kê](FairShare_Statistics_Implementation_Plan.md).
- [Đặc tả API thống kê](Mobile_Statistics_API_Integration_Guide.md).
- [Đặc tả API chi tiêu](Mobile_Expense_API_Integration_Guide.md).

Kết quả kiểm tra ban đầu: 31 test trong `test/features/analytics` đều pass. Đây là kết quả của bộ test hiện có, chưa chứng minh các tình huống hồi quy dưới đây đã được bao phủ.

## 2. Danh sách vấn đề

| Mã | Ưu tiên | Vấn đề | Hậu quả |
| --- | --- | --- | --- |
| ANA-01 | P1 | Đổi kỳ thất bại nhưng vẫn hiển thị dữ liệu kỳ trước | Người dùng đọc số liệu dưới nhãn thời gian sai |
| ANA-02 | P2 | Response lọc nhóm cũ có thể ghi đè yêu cầu mới | Danh sách trống, thiếu hoặc không khớp bộ lọc |
| ANA-03 | P2 | Bộ đếm nhóm tính từ danh sách đã lọc | Số nhóm hoạt động/lưu trữ thay đổi sai khi chuyển chip |
| ANA-04 | P2 | Chưa có bộ chọn năm; lịch sử chỉ ánh xạ sang năm hiện tại | Không xem được báo cáo năm trước và có nguy cơ trộn kỳ dữ liệu |

## 3. Phương án chỉnh sửa

### ANA-01 — Giữ dữ liệu đúng kỳ khi tải thất bại

**Tái hiện:** Tải tháng này có tổng chi tiêu lớn hơn 0 → chọn tháng trước → API thất bại. Cả hai màn hình chi tiết hiện quyết định giữ nội dung dựa vào tổng chi tiêu cũ, nên vẫn hiện dữ liệu tháng này dưới chip tháng trước.

**Các file chính:**

- `lib/features/analytics/presentation/cubit/global_analytics_cubit.dart`
- `lib/features/analytics/presentation/cubit/global_analytics_state.dart`
- `lib/features/analytics/presentation/cubit/group_analytics_cubit.dart`
- `lib/features/analytics/presentation/cubit/group_analytics_state.dart`
- `lib/features/analytics/presentation/screens/global_analytics_screen.dart`
- `lib/features/analytics/presentation/screens/group_analytics_screen.dart`

**Cách sửa:**

1. Phân biệt kỳ đang chọn (`period`, `year`) với kỳ của dữ liệu đã tải thành công; lưu dấu kỳ đã tải hoặc một đối tượng mô tả phạm vi dữ liệu tương đương.
2. Khi chọn kỳ khác, chuyển sang loading và chỉ hiển thị dữ liệu nếu phạm vi đã tải trùng phạm vi đang chọn.
3. Khi tải kỳ mới thất bại, hiện lỗi và nút thử lại cho kỳ đó; không hiển thị KPI, phân bố, bảng xếp hạng hoặc hóa đơn của kỳ cũ.
4. Khi refresh cùng kỳ thất bại, có thể giữ dữ liệu đã tải kèm thông báo lỗi. Điều kiện giữ dữ liệu dựa vào phạm vi đã tải thành công, không dựa vào `totalSpendingVnd > 0`.
5. Tiếp tục dùng request ID và session epoch để bỏ response không còn hợp lệ. Chỉ cập nhật dấu kỳ đã tải sau khi toàn bộ tập dữ liệu cần thiết thành công.

**Nghiệm thu:** Đổi kỳ lỗi không hiện dữ liệu kỳ trước; retry gọi đúng kỳ hiện tại. Refresh lỗi cùng kỳ vẫn giữ được dữ liệu hợp lệ, kể cả báo cáo có tổng chi tiêu bằng 0.

### ANA-02 — Ngăn response cũ ghi đè bộ lọc nhóm

**Tái hiện:** Chọn ACTIVE rồi ALL liên tiếp; request ACTIVE về sau ALL. `setFilter()` hiện chỉ kiểm tra session epoch nên response ACTIVE vẫn ghi vào danh sách của ALL.

**File chính:** `lib/features/analytics/presentation/cubit/analytics_tab_cubit.dart`.

**Cách sửa đề xuất:** Dùng một danh sách nhóm đầy đủ làm nguồn dữ liệu và lọc trạng thái tại client, kết hợp với ANA-03. `setFilter()` chỉ thay đổi bộ lọc, không gọi API. `loadOverview()` tải danh sách với `status: null`, độc lập với chip đang chọn.

- Thêm request ID cho `loadOverview()` để refresh hoặc sự kiện đồng bộ cũ không ghi đè kết quả mới.
- Tăng hoặc vô hiệu hóa request ID khi `reset()`; giữ kiểm tra `isClosed` và session epoch.
- Đổi chip trong lúc đang tải chỉ thay đổi bộ lọc cục bộ. Response hợp lệ về sẽ được hiển thị theo chip hiện tại.
- Không nuốt lỗi tải danh sách: sử dụng trạng thái lỗi/refresh hiện có và giữ dữ liệu hợp lệ khi phù hợp.

**Điều kiện áp dụng:** Xác minh API group summaries với `status: null` trả đủ nhóm người dùng được phép xem và không có phân trang bị bỏ qua. Nếu API phân trang, phải tải đủ trang hoặc bổ sung bộ đếm độc lập từ backend trước khi dùng cách này.

**Phương án thay thế nếu cần lọc phía server:** Lưu riêng danh sách đầy đủ/bộ đếm và danh sách kết quả; dùng cùng cơ chế request ID cho mọi request ghi vào danh sách hiển thị, đồng thời chụp bộ lọc tại thời điểm gửi. Không tính tổng toàn bộ nhóm từ response đã lọc.

**Nghiệm thu:** Chuyển chip nhanh, refresh chồng nhau và reset giữa request đều không làm kết quả cũ ghi đè trạng thái mới.

### ANA-03 — Tính bộ đếm từ nguồn dữ liệu đầy đủ

**Tái hiện:** Có 1 nhóm ACTIVE và 1 nhóm ARCHIVED. Sau khi chọn ACTIVE, `groups` chỉ còn nhóm ACTIVE nên chip ARCHIVED hiển thị 0.

**Các file chính:**

- `lib/features/analytics/presentation/cubit/analytics_tab_state.dart`
- `lib/features/analytics/presentation/cubit/analytics_tab_cubit.dart`
- `lib/features/analytics/presentation/screens/analytics_tab_screen.dart`

**Cách sửa:**

- Theo phương án client ở ANA-02, giữ `groups` là danh sách đầy đủ; `filteredGroups` áp dụng đồng thời trạng thái và từ khóa tìm kiếm.
- Tính `allCount`, `activeCount`, `archivedCount` từ danh sách đầy đủ, không phụ thuộc chip hoặc từ khóa. Số lượng kết quả ở phần danh sách tiếp tục dùng `filteredGroups.length`.
- Xác minh tập trạng thái thực tế của group summaries. Thống nhất cách xử lý trạng thái null/không nhận diện giữa bộ đếm và bộ lọc, tránh một nhóm được đếm ở nhiều tập hoặc hiển thị trái bộ lọc.
- Loại bỏ `totalAllCount` nếu không còn cần thiết sau khi kiểm tra các nơi sử dụng.

**Nghiệm thu:** Với 2 nhóm ACTIVE và 1 ARCHIVED, chip luôn hiển thị ALL=3, ACTIVE=2, ARCHIVED=1 khi đổi chip hoặc tìm kiếm. Số kết quả danh sách thay đổi đúng theo điều kiện tìm kiếm.

### ANA-04 — Bổ sung chọn năm và đồng bộ lịch sử hóa đơn

**Hiện trạng:** `AnalyticsPeriodBar` chỉ trả về period; hai màn hình gọi `setPeriod(p)` mà không chọn năm. Cubit đã có tham số `year`, nhưng ánh xạ BY_YEAR sang THIS_YEAR cho lịch sử/hóa đơn nhóm sẽ sai khi truyền năm cũ.

**Các file chính:**

- `lib/features/analytics/presentation/widgets/analytics_period_bar.dart`
- Hai màn hình, cubit và state báo cáo tổng quan/thống kê nhóm.
- Repository, data source thống kê và chi tiêu nếu cần mở rộng truy vấn lịch sử.
- Các file bản địa hóa trong `lib/l10n`.

**Cách sửa:**

1. Bấm chip “Cả năm” mở bộ chọn năm ở cả hai màn hình. Mặc định chọn năm đang xem hoặc năm hiện tại; hủy picker không thay đổi bộ lọc và không gọi API.
2. Sau khi xác nhận, truyền `StatisticsPeriod.byYear` kèm năm cụ thể. Hiển thị năm đã chọn trên chip; cho phép bấm lại để đổi năm.
3. Khi chuyển sang kỳ khác, xóa năm khỏi state. Sửa `copyWith` để có thể chủ động xóa nullable `year`; cách `year ?? this.year` hiện không thực hiện được việc này.
4. Gửi cùng period/year cho KPI, phân bố và bảng xếp hạng. Kế thừa bảo vệ phạm vi dữ liệu và request ID ở ANA-01.
5. Đồng bộ lịch sử hóa đơn với năm đã chọn theo quyết định dữ liệu dưới đây; không dùng THIS_YEAR cho năm quá khứ.

**Quyết định dữ liệu cần xác minh trước khi triển khai:** Đặc tả hiện có chỉ cung cấp timeFilter tương đối cho lịch sử và danh sách hóa đơn nhóm, chưa mô tả tham số năm tùy ý. Không tự gửi tham số `year` chưa được backend hỗ trợ.

- Nếu endpoint ALL trả đầy đủ dữ liệu: tải ALL khi xem năm quá khứ, sau đó lọc theo `expenseDate` trong khoảng của báo cáo (`startDate`–`endDate`). Xác minh định dạng ngày và quy tắc múi giờ; không âm thầm lấy năm hiện tại khi parse lỗi.
- Nếu endpoint có phân trang: phải lấy đủ trang cần thiết hoặc có lọc khoảng ngày/năm từ backend. Không lọc riêng trang đầu rồi coi là kết quả đầy đủ.
- Nếu không thể lấy đầy đủ dữ liệu với chi phí hợp lý: bổ sung hợp đồng API lọc năm/khoảng ngày cho cả hai luồng trước khi hoàn tất ANA-04. Trong giai đoạn chưa hỗ trợ, hiển thị rõ lịch sử năm đã chọn chưa khả dụng, không gắn lịch sử năm hiện tại vào báo cáo năm cũ.

**Nghiệm thu:** Chọn năm trước cho kết quả KPI, bảng xếp hạng và hóa đơn cùng năm; chọn lại năm khác hoạt động; hủy picker giữ nguyên màn hình. Thống nhất giới hạn năm theo dữ liệu sản phẩm và ràng buộc backend, không hardcode một mốc năm thiếu căn cứ.

## 4. Thứ tự triển khai

| Bước | Công việc | Điều kiện hoàn tất |
| --- | --- | --- |
| 1 | ANA-01: phạm vi dữ liệu và xử lý lỗi đổi kỳ | Hai màn hình không hiển thị sai kỳ; có test hồi quy |
| 2 | ANA-02 + ANA-03: thống nhất nguồn nhóm, chống response cũ, sửa bộ đếm | Xác minh hợp đồng summaries; chip, tìm kiếm và refresh nhất quán |
| 3 | Xác minh truy vấn lịch sử theo năm | Chọn phương án dữ liệu đầy đủ hoặc cập nhật hợp đồng backend |
| 4 | ANA-04: picker, state năm, truy vấn và lịch sử | Hai màn hình đáp ứng các tình huống chọn/hủy/đổi năm |
| 5 | Kiểm thử tích hợp và rà soát cuối | Test pass, kiểm tra API thực tế, không có hồi quy điều hướng |

## 5. Kế hoạch kiểm thử

| Nhóm | Tình huống bắt buộc | Kỳ vọng |
| --- | --- | --- |
| Cubit báo cáo | Tải kỳ A thành công, đổi B thất bại, retry B | Không trình bày A như dữ liệu B; retry cập nhật đúng B |
| Cubit báo cáo | Refresh cùng kỳ thất bại, cả báo cáo 0 và khác 0 | Giữ dữ liệu cùng kỳ và thông báo lỗi |
| Cubit báo cáo | Đổi kỳ/năm nhanh; response về ngược thứ tự | Chỉ request mới nhất cập nhật state |
| Cubit tab | Refresh chồng nhau, đổi chip khi tải | Dữ liệu cuối và chip nhất quán |
| Cubit tab | Reset/session thay đổi/close trong lúc tải | Không khôi phục dữ liệu từ request cũ |
| State tab | ACTIVE, ARCHIVED, ALL kết hợp tìm kiếm | Bộ đếm tổng ổn định; danh sách lọc chính xác |
| Widget | Chọn năm, hủy, mở lại, đổi sang kỳ khác | Nhãn và state đúng; không gọi API khi hủy |
| Dữ liệu năm | Hóa đơn đầu/cuối năm, ngày ngoài khoảng, ngày không hợp lệ | Không lẫn năm; xử lý lỗi ngày có quy tắc rõ ràng |
| API/data source | BY_YEAR với năm cụ thể và kỳ không dùng năm | Query đúng hợp đồng, không gửi năm thừa |
| Tích hợp | Tab → tổng quan → hóa đơn → thống kê nhóm → quay lại | Điều hướng hoạt động và mỗi màn hình có bộ lọc nhất quán |

Dùng `Completer` hoặc fake repository có điều khiển để chủ động thứ tự response; tránh phụ thuộc thời gian chờ ngẫu nhiên. Bổ sung test vào các file hiện có dưới `test/features/analytics`; chỉ mở rộng test chi tiêu khi thay đổi hợp đồng truy vấn của module đó.

Chạy sau khi triển khai:

```powershell
flutter test test/features/analytics --reporter compact
flutter analyze
```

Nếu sửa module chi tiêu/nhóm hoặc bản địa hóa, chạy thêm bộ test liên quan và kiểm tra sinh mã bản địa hóa theo quy trình hiện có của dự án.

## 6. Tiêu chí hoàn thành

- [ ] Bốn vấn đề có thay đổi mã nguồn và test hồi quy tương ứng.
- [ ] Hai màn hình chi tiết không trình bày dữ liệu sai kỳ khi request thất bại.
- [ ] Chip trạng thái, từ khóa tìm kiếm và số đếm nhóm nhất quán.
- [ ] Người dùng chọn được năm; mọi phần dữ liệu khớp năm hoặc nêu rõ phần chưa khả dụng.
- [ ] Hợp đồng API và giả định về phân trang được kiểm chứng bằng tài liệu hoặc response thực tế.
- [ ] Test liên quan pass; không có lỗi phân tích tĩnh mới do thay đổi.
- [ ] Kiểm tra thủ công với API thực tế, bao gồm mạng lỗi, báo cáo rỗng và thao tác đổi bộ lọc nhanh.

Tài liệu này lập kế hoạch chỉnh sửa; chưa thay đổi hành vi ứng dụng hay hợp đồng backend.
