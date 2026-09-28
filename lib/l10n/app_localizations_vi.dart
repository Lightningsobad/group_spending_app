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

  @override
  String get financialOverviewTitle => 'TỔNG QUAN SỐ DƯ TÀI CHÍNH';

  @override
  String get youOwe => 'Bạn đang nợ';

  @override
  String get paySoonSubtitle => 'Cần thanh toán sớm';

  @override
  String get youAreOwed => 'Bạn nhận';

  @override
  String get friendsOweYouSubtitle => 'Bạn bè đang nợ bạn';

  @override
  String get addExpense => 'Thêm chi tiêu';

  @override
  String get addExpenseFeatureNotice =>
      'Tính năng Thêm chi tiêu đang được tích hợp.';

  @override
  String get createGroupAction => 'Tạo nhóm';

  @override
  String get codeOrQrAction => 'Mã / QR';

  @override
  String get yourGroupsSection => 'CÁC NHÓM CỦA BẠN';

  @override
  String seeAllGroupsCount(int count) {
    return 'Xem tất cả ($count)';
  }

  @override
  String get noGroupsJoinedTitle => 'Bạn chưa tham gia nhóm nào';

  @override
  String get noGroupsJoinedSubtitle =>
      'Hãy tạo nhóm mới hoặc gia nhập nhóm qua mã mời để bắt đầu chia tiền cùng bạn bè!';

  @override
  String get createGroupNow => 'Tạo nhóm ngay';

  @override
  String notificationsToggledForGroup(String name) {
    return 'Đã thay đổi thông báo cho \"$name\".';
  }

  @override
  String get groupListHeaderTitle => 'Danh sách nhóm của bạn';

  @override
  String get searchGroupPlaceholder => 'Tìm kiếm theo tên nhóm, thể loại...';

  @override
  String filterAllCount(int count) {
    return 'Tất cả ($count)';
  }

  @override
  String filterActiveCount(int count) {
    return 'Đang hoạt động ($count)';
  }

  @override
  String filterArchivedCount(int count) {
    return 'Đã lưu trữ ($count)';
  }

  @override
  String filterAdminCount(int count) {
    return 'Tôi quản lý ($count)';
  }

  @override
  String get noMatchingGroupsTitle => 'Không tìm thấy nhóm phù hợp';

  @override
  String get noMatchingGroupsSubtitle =>
      'Thử tìm kiếm với từ khóa khác hoặc đổi bộ lọc.';

  @override
  String get noGroupsInTabTitle => 'Chưa có nhóm trong mục này';

  @override
  String get noGroupsInTabSubtitle =>
      'Nhấn \"+ Tạo nhóm mới\" để tạo nhóm đầu tiên của bạn!';

  @override
  String get createGroupTitle => 'Tạo nhóm chi tiêu mới';

  @override
  String get createGroupSubtitle =>
      'Đặt tên nhóm và chọn danh mục để bắt đầu quản lý chi tiêu chung.';

  @override
  String get groupNameLabel => 'Tên nhóm chi tiêu *';

  @override
  String get groupNameHint =>
      'Nhập tên nhóm (VD: Chuyến đi Đà Lạt, Chung cư 402...)';

  @override
  String get groupDescLabel => 'Mô tả nhóm (Tùy chọn)';

  @override
  String get groupDescHint =>
      'Nhập mô tả ngắn về mục đích chi tiêu của nhóm...';

  @override
  String get groupCategoryLabel => 'Danh mục nhóm';

  @override
  String get defaultCurrencyLabel => 'Tiền tệ mặc định';

  @override
  String get groupNameRequired => 'Vui lòng nhập tên nhóm.';

  @override
  String get joinGroupTitle => 'Gia nhập nhóm bằng mã mời';

  @override
  String get joinGroupSubtitle =>
      'Nhập mã mời gồm 6-12 ký tự để tham gia nhóm chi tiêu của bạn bè.';

  @override
  String get inviteCodeLabel => 'Mã mời nhóm *';

  @override
  String get inviteCodeHint => 'VD: DALAT2024, ROOM402...';

  @override
  String get inviteCodeRequired => 'Vui lòng nhập mã mời.';

  @override
  String get joinGroupButton => 'Tham gia nhóm';

  @override
  String get groupDetailTitle => 'Chi tiết nhóm';

  @override
  String get groupInviteCodePrefix => 'Mã mời nhóm:';

  @override
  String get codeCopiedToClipboard => 'Đã sao chép mã mời vào khay nhớ tạm';

  @override
  String get copyCodeTooltip => 'Sao chép mã';

  @override
  String get archiveGroupAction => 'Lưu trữ nhóm';

  @override
  String get archiveGroupConfirmTitle => 'Xác nhận lưu trữ nhóm?';

  @override
  String get archiveGroupConfirmMessage =>
      'Nhóm sẽ được chuyển vào mục lưu trữ và chỉ cho phép xem thông tin.';

  @override
  String get archiveConfirmButton => 'Lưu trữ';

  @override
  String get deleteGroupAction => 'Xóa nhóm';

  @override
  String get deleteGroupConfirmTitle => 'Xác nhận xóa vĩnh viễn nhóm?';

  @override
  String get deleteGroupConfirmMessage =>
      'Hành động này sẽ xóa toàn bộ chi tiêu, công nợ, quỹ chung và danh sách thành viên của nhóm. Không thể khôi phục!';

  @override
  String get deleteConfirmButton => 'Xóa nhóm';

  @override
  String get editGroupTitle => 'Sửa thông tin nhóm';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get groupMembersTitle => 'Thành viên nhóm';

  @override
  String get loadDashboardFailed => 'Không thể tải dữ liệu tổng quan';

  @override
  String get loadGroupsFailed => 'Không thể tải danh sách nhóm';

  @override
  String get createGroupSuccess => 'Tạo nhóm thành công!';

  @override
  String get updateGroupSuccess => 'Cập nhật nhóm thành công!';

  @override
  String get archiveGroupSuccess => 'Nhóm đã được chuyển sang chế độ lưu trữ.';

  @override
  String get deleteGroupSuccess => 'Xóa nhóm thành công.';

  @override
  String get joinGroupSuccess => 'Tham gia nhóm thành công!';

  @override
  String get editGroupAction => 'Sửa nhóm';

  @override
  String get inviteCodeCardTitle => 'MÃ MỜI THAM GIA';

  @override
  String get groupFinancialOverviewTitle => 'TỔNG QUAN TÀI CHÍNH NHÓM';

  @override
  String get yourBalanceLabel => 'Số dư của bạn:';

  @override
  String get totalGroupSpendingLabel => 'Tổng chi tiêu nhóm:';

  @override
  String get totalFundCollectedLabel => 'Tổng quỹ đã thu:';

  @override
  String groupMembersCountTitle(int count) {
    return 'THÀNH VIÊN ($count)';
  }

  @override
  String groupMemberCountSimple(int count) {
    return 'Nhóm có $count thành viên';
  }

  @override
  String get deleteGroupPermanently => 'Xóa nhóm vĩnh viễn';

  @override
  String get tabAnalyticsTitle => 'Báo cáo & Thống kê';

  @override
  String get totalSpendingAllGroups => 'Tổng chi tất cả nhóm';

  @override
  String get activeGroupsJoinedCount => 'Số nhóm tham gia';

  @override
  String get groupsUnit => 'nhóm';

  @override
  String get totalInvoicesRecorded => 'Số hóa đơn đã ghi';

  @override
  String get invoicesUnit => 'hóa đơn';

  @override
  String get overallReportBannerTitle => 'Báo cáo tổng quan';

  @override
  String get viewOverallReportAction => 'Xem toàn cảnh';

  @override
  String get searchGroupByHint => 'Tìm kiếm nhóm theo tên, danh mục...';

  @override
  String filterAllTab(int count) {
    return 'Tất cả ($count)';
  }

  @override
  String get filterActiveTab => 'Đang hoạt động';

  @override
  String get filterArchivedTab => 'Đã lưu trữ';

  @override
  String get groupSpendingListTitle => 'DANH SÁCH NHÓM CHI TIÊU';

  @override
  String get totalSpendingLabel => 'Tổng chi tiêu';

  @override
  String get overallReportTitle => 'Báo cáo tổng quan';

  @override
  String get overallReportSubtitle => 'Tổng hợp tất cả nhóm đang tham gia';

  @override
  String get financialMetricsTitle => 'CHỈ SỐ TÀI CHÍNH NHÓM';

  @override
  String get totalSpendingMetric => 'Tổng tiền chi tiêu';

  @override
  String get commonGroupSpendingSubtitle => 'Chi tiêu chung cả nhóm';

  @override
  String get averagePerPersonMetric => 'Bình quân đầu người';

  @override
  String get splitEquallySubtitle => 'Mỗi thành viên chia đều';

  @override
  String friendsCountBadge(int count) {
    return '÷ $count bạn';
  }

  @override
  String get expenseCountMetric => 'Số khoản chi';

  @override
  String get invoicesBadge => 'Hóa đơn';

  @override
  String get expensesUnit => 'khoản chi';

  @override
  String get recordedAndAuditedSubtitle => 'Đã ghi nhận & đối soát';

  @override
  String get settlementRateMetric => 'Tỷ lệ tất toán';

  @override
  String get paidRateSuffix => 'đã trả';

  @override
  String get groupDebtLabel => 'Công nợ nhóm';

  @override
  String remainingDebtRate(String percent) {
    return 'Còn $percent% tồn';
  }

  @override
  String get categoryDistributionTitle => 'PHÂN BỐ THEO DANH MỤC CHI TIÊU';

  @override
  String get memberContributionTitle => 'ĐÓNG GÓP & CHI TIÊU THÀNH VIÊN';

  @override
  String contributionPercent(String percent) {
    return 'Đóng góp $percent% tổng chi';
  }

  @override
  String get recentExpensesTitle => 'HÓA ĐƠN CHI TIÊU GẦN ĐÂY';

  @override
  String expensesCountBadge(int count) {
    return '$count khoản';
  }

  @override
  String paidByPrefix(String name) {
    return 'Người trả: $name';
  }

  @override
  String get viewExpenseDetailAction => 'Chi tiết →';

  @override
  String get periodThisMonth => 'Tháng này';

  @override
  String get periodLastMonth => 'Tháng trước';

  @override
  String get periodCurrentQuarter => 'Quý này';

  @override
  String get periodByYear => 'Cả năm';

  @override
  String membersCountSubtitle(int memberCount) {
    return '$memberCount thành viên';
  }

  @override
  String get noExpensesRecorded => 'Chưa có khoản chi tiêu nào.';

  @override
  String get noCategoriesRecorded => 'Chưa có dữ liệu danh mục.';

  @override
  String get noLeaderboardData => 'Chưa có dữ liệu đóng góp.';

  @override
  String get loadAnalyticsFailed => 'Không thể tải dữ liệu thống kê';

  @override
  String get retryAction => 'Thử lại';

  @override
  String get youLabel => '(Tôi)';
}
