// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'FairShare';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get underDevelopment => 'Tính năng đang được phát triển.';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get close => 'Đóng';

  @override
  String get splashSlogan => 'Chia tiền minh bạch & nhắc nợ thông minh';

  @override
  String get authHeaderTitle => 'Quản lý & Nhắc nhở Chi tiêu\nNhóm';

  @override
  String get authHeaderSubtitle =>
      'Chia tiền minh bạch, nhắc nợ tế nhị, đóng quỹ dễ dàng.';

  @override
  String get loginTab => 'Đăng nhập';

  @override
  String get registerTab => 'Đăng ký';

  @override
  String get orLoginWithEmail => 'HOẶC ĐĂNG NHẬP BẰNG EMAIL';

  @override
  String get emailLabel => 'Địa chỉ Email';

  @override
  String get emailHint => 'Nhập địa chỉ email của bạn';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get passwordHint => 'Nhập mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginButton => 'Đăng nhập vào ứng dụng';

  @override
  String get noAccountPrompt => 'Chưa có tài khoản? ';

  @override
  String get registerNow => 'Đăng ký ngay';

  @override
  String get orRegisterWithEmail => 'HOẶC ĐĂNG KÝ BẰNG EMAIL';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get fullNameHint => 'Nhập họ và tên đầy đủ';

  @override
  String get phoneLabel => 'Số điện thoại';

  @override
  String get phoneOptionalTag => '(Không bắt buộc / Tùy chọn)';

  @override
  String get phoneHint => 'Nhập số điện thoại';

  @override
  String get registerButton => 'Tạo tài khoản mới';

  @override
  String get hasAccountPrompt => 'Đã có tài khoản? ';

  @override
  String get loginNow => 'Đăng nhập';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get googleAuthNotice =>
      'Tính năng đăng nhập Google đang được phát triển.';

  @override
  String get forgotPasswordNotice =>
      'Chức năng Quên mật khẩu đang được hỗ trợ.';

  @override
  String get enterEmailPrompt => 'Vui lòng nhập địa chỉ email.';

  @override
  String get enterPasswordPrompt => 'Vui lòng nhập mật khẩu.';

  @override
  String get enterFullNamePrompt => 'Vui lòng nhập họ và tên.';

  @override
  String get passwordMinLengthPrompt => 'Mật khẩu phải có ít nhất 6 ký tự.';

  @override
  String get otpTitle => 'Xác thực địa chỉ Email';

  @override
  String get otpSubtitle =>
      'Mã OTP 6 số bảo mật đã được gửi đến hòm thư của bạn';

  @override
  String get otpInputLabel => 'Mã xác thực OTP';

  @override
  String get otpDigitsHint => '6 chữ số bảo mật';

  @override
  String get verifyAndActivate => 'Xác thực & Kích hoạt';

  @override
  String get enterFullOtpPrompt => 'Vui lòng nhập đủ 6 chữ số mã xác thực OTP.';

  @override
  String get resendOtpPrompt => 'Chưa nhận được mã? ';

  @override
  String get resendOtpNow => 'Gửi lại mã';

  @override
  String resendIn(int seconds) {
    return 'Gửi lại mã sau (${seconds}s)';
  }

  @override
  String onboardingStep(int step, int total) {
    return 'Bước $step/$total';
  }

  @override
  String get skip => 'Bỏ qua';

  @override
  String get onboardingSlide1Pill => 'Quản lý nhóm';

  @override
  String get onboardingSlide1Title => 'KẾT NỐI & QUẢN LÝ NHÓM';

  @override
  String get onboardingSlide1Desc =>
      'Quản lý nhóm bạn bè, chuyến du lịch và chia sẻ mọi chi phí sinh hoạt chung một cách dễ dàng, trực quan và công bằng.';

  @override
  String get onboardingSlide2Pill => 'Quản lý chi tiêu';

  @override
  String get onboardingSlide2Title => 'QUẢN LÝ CHI TIÊU THÔNG MINH';

  @override
  String get onboardingSlide2Desc =>
      'Ghi nhận chi tiêu nhanh chóng, phân tích biểu đồ trực quan, chia đều hóa đơn và tự động rút gọn công nợ tối ưu.';

  @override
  String get onboardingSlide3Pill => 'Quản lý quỹ chung';

  @override
  String get onboardingSlide3Title => 'QUẢN LÝ QUỸ CHUNG MINH BẠCH';

  @override
  String get onboardingSlide3Desc =>
      'Thu quỹ nhóm tiện lợi, theo dõi tiến độ đóng góp theo thời gian thực và quản lý ngân sách an toàn, minh bạch 100%.';

  @override
  String get onboardingSlide4Pill => 'Nhắc nợ & Thanh toán';

  @override
  String get onboardingSlide4Title => 'NHẮC NỢ & THANH TOÁN TỐC ĐỘ';

  @override
  String get onboardingSlide4Desc =>
      'Gửi thông báo nhắc nợ tinh tế, quét mã VietQR tự động điền tài khoản và hoàn tất quyết toán chỉ trong tích tắc.';

  @override
  String get greeting => 'Xin chào,';

  @override
  String get tabOverview => 'Tổng quan';

  @override
  String get tabGroups => 'Nhóm';

  @override
  String get tabDebts => 'Công nợ';

  @override
  String get tabAnalytics => 'Thống kê';

  @override
  String get tabSettings => 'Cài đặt';

  @override
  String get notificationsTitle => 'Tổng hợp thông báo';

  @override
  String get noNotifications => 'Hiện bạn chưa có thông báo mới nào.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get roleAdmin => 'Trưởng nhóm (Admin)';

  @override
  String get roleMember => 'Thành viên';

  @override
  String get editProfile => 'Sửa thông tin';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get vietqrTitle => 'TÀI KHOẢN NHẬN TIỀN NỢ (VIETQR)';

  @override
  String get defaultBankInfo => 'Techcombank - 19034829104018';

  @override
  String get defaultAccountName => 'NGUYEN NHAT MINH';

  @override
  String get appearanceLanguageSection => 'GIAO DIỆN & NGÔN NGỮ';

  @override
  String get themeModeTitle => 'Chế độ giao diện (Theme)';

  @override
  String get themeLightSubtitle => 'Nền sáng #F8FAFC';

  @override
  String get themeDarkSubtitle => 'Nền tối #0F172A';

  @override
  String get lightThemeLabel => 'Light';

  @override
  String get darkThemeLabel => 'Dark';

  @override
  String get displayLanguageTitle => 'Ngôn ngữ hiển thị';

  @override
  String get displayLanguageSubtitle => 'Tiếng Việt (Toàn bộ nhãn)';

  @override
  String get infoSupportSection => 'THÔNG TIN & HỖ TRỢ';

  @override
  String get aboutAppTitle => 'Giới thiệu về FairShare';

  @override
  String get aboutAppSubtitle =>
      'Xem lại toàn bộ slide giới thiệu tính năng ứng dụng (Onboarding)';

  @override
  String get privacyPolicyTitle => 'Chính sách bảo mật & Quyền riêng tư';

  @override
  String get privacyPolicySubtitle =>
      'Cam kết mã hóa thông tin & bảo vệ tài khoản (Xem chi tiết)';

  @override
  String get logoutButton => 'Đăng xuất tài khoản';

  @override
  String get logoutTooltip => 'Đăng xuất';

  @override
  String get logoutConfirmTitle => 'Bạn có chắc chắn muốn đăng xuất?';
}
