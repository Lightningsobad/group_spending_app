================================================================================
THIẾT KẾ GIAO DIỆN MOBILE FAIRSHARE (CHỈ PHẦN MOBILE DUY NHẤT)
================================================================================
Ứng dụng: FairShare - Quản lý & Nhắc nhở Chi tiêu Nhóm
Chuẩn thiết bị: iPhone 15 / 16 Pro (393 x 852 px Retina)
Đặc điểm: CHỈ PHẦN MOBILE DUY NHẤT, không có thêm thành phần ngoài lề nào khác.

CÁCH MỞ VÀ TRẢI NGHIỆM:
--------------------------------------------------------------------------------
1. MỞ ỨNG DỤNG MOBILE:
   - Nhấp đúp chuột vào file "index.html".
   - File sẽ mở ngay trên trình duyệt web của bạn (Chrome, Safari, Edge, Firefox, Cốc Cốc...).
   - Chạy 100% OFFLINE, không cần Internet hay bất kỳ máy chủ nào.
   - Trên điện thoại / màn hình di động: Tự động vừa khít 100% toàn màn hình.
   - Trên máy tính: Hiển thị khung iPhone 16 Pro cao cấp ở giữa màn hình.

2. CÁC TÍNH NĂNG VÀ ĐIỀU HƯỚNG TƯƠNG TÁC ĐẦY ĐỦ:
   - Thanh điều hướng dưới đáy (BottomNavBar):
     + 🏠 Trang chủ (Dashboard): Xem số dư ròng, nhóm chi tiêu, hóa đơn gần đây.
     + 👥 Nhóm (Groups): Quản lý các nhóm chi tiêu.
     + ➕ "+ Thêm chi tiêu": Chọn nhóm và nhập khoản chi với bàn phím số & phân chia tiền.
     + ⚖️ Quyết toán (Debts): Rút gọn nợ tối giản, bấm "Trả ngay" để mở mã VietQR Napas247,
       bấm "Nhắc nợ", "Xác nhận đã nhận tiền".
     + 💰 Quỹ chung (Funds): Tiến độ thu quỹ 70%, danh sách đã nộp/chưa nộp, tạo chiến dịch quỹ.
     + ⚙️ Cài đặt (Settings): Đổi Dark/Light mode ngay lập tức, đổi ngôn ngữ Tiếng Việt/English,
       cài đặt STK ngân hàng nhận tiền, Đăng xuất/Đăng nhập.
   - Chạm vào thẻ nhóm (Phòng 402 Sunrise, Đà Lạt): Xem màn hình Chi tiết nhóm.
   - Chạm vào nút Quản trị trong nhóm: Mở màn hình duyệt thành viên và phân quyền Admin.
   - Chạm vào từng hóa đơn: Xem bảng phân bổ chi tiết số tiền từng thành viên.
   - Nút quay lại (←): Tự động quay về màn hình trước đó.

3. CẤU TRÚC GÓI NÉN:
   ├── index.html               <- Ứng dụng mobile tương tác hoàn chỉnh
   ├── assets/
   │   ├── style.css            <- Toàn bộ mã CSS Tailwind compiled
   │   └── mobile-bundle.js     <- Mã nguồn JavaScript IIFE chạy offline không lỗi CORS
   ├── screens/                 <- 10 trang HTML tĩnh xem riêng từng màn hình nếu cần
   │   ├── 00_auth.html
   │   ├── 01_dashboard.html
   │   ├── 02_group_detail.html
   │   ├── ...
   └── README_HUONG_DAN.txt     <- File hướng dẫn này
================================================================================
