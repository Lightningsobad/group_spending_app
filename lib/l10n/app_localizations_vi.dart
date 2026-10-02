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
  String get fullNameHint => 'Nhập họ và tên của bạn';

  @override
  String get phoneLabel => 'Số điện thoại';

  @override
  String get phoneOptionalTag => '(Không bắt buộc / Tùy chọn)';

  @override
  String get phoneHint => 'Nhập số điện thoại (tùy chọn)';

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
  String get noBankData => 'Chưa có dữ liệu';

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
  String get privacyPolicyCommitmentSubtitle =>
      'Cam kết bảo vệ dữ liệu cá nhân & an toàn tài chính';

  @override
  String get privacyStandardBadge => 'BẢO MẬT TIÊU CHUẨN';

  @override
  String get privacyUpdatedDate => 'Cập nhật: Tháng 09/2026';

  @override
  String get privacyHeroTitle =>
      'Minh bạch thu chi • Bảo mật dữ liệu người dùng';

  @override
  String get privacyHeroDescription =>
      'FairShare tôn trọng quyền riêng tư của bạn. Mọi khoản chi, thông tin hóa đơn và số tài khoản ngân hàng chỉ phục vụ mục đích phân chia công nợ và đóng quỹ nhóm của các thành viên.';

  @override
  String get privacyDataCollectedTitle => '1. DỮ LIỆU ỨNG DỤNG THU THẬP';

  @override
  String get privacyDataCollectedDesc =>
      'Chúng tôi chỉ thu thập các trường thông tin tối thiểu cần thiết để vận hành các tính năng chia tiền nhóm:';

  @override
  String get privacyIdentityTitle => 'Thông tin định danh: ';

  @override
  String get privacyIdentityDesc =>
      'Họ và tên hiển thị, ảnh đại diện và địa chỉ Email để xác thực tài khoản và gửi mã OTP.';

  @override
  String get privacyBankTitle => 'Tài khoản nhận tiền (VietQR): ';

  @override
  String get privacyBankDesc =>
      'Tên ngân hàng, số tài khoản và tên chủ sở hữu nhằm tạo mã VietQR chuẩn 1-chạm giúp thành viên khác chuyển khoản trả nợ.';

  @override
  String get privacyTransactionTitle => 'Dữ liệu giao dịch nhóm: ';

  @override
  String get privacyTransactionDesc =>
      'Danh sách hóa đơn, số tiền chi, người trả hộ, tỷ lệ phân bổ và các chiến dịch đóng quỹ chung.';

  @override
  String get privacySecurityTitle => '2. AN TOÀN MẬT KHẨU & MÃ HÓA ĐẦU CUỐI';

  @override
  String get privacySecurityDesc =>
      'Mật khẩu tài khoản của người dùng được băm một chiều (one-way hashing) kèm salt an toàn, hoàn toàn không thể dịch ngược hay đọc dưới dạng văn bản thô.';

  @override
  String get privacyChangePasswordTip =>
      'Bạn có thể tự chủ động thay đổi mật khẩu bất kỳ lúc nào tại màn hình Cài đặt bằng tính năng \"Đổi mật khẩu\".';

  @override
  String get privacyNoShareTitle => '3. CAM KẾT KHÔNG CHIA SẺ DỮ LIỆU';

  @override
  String get privacyNoShareDesc =>
      'FairShare cam kết không bán, chia sẻ hoặc thương mại hóa bất kỳ thông tin cá nhân, lịch sử chuyển nợ hay số tiền đóng quỹ của bạn cho bất kỳ đối tác quảng cáo nào.';

  @override
  String get privacyUserRightsTitle => '4. QUYỀN LÀM CHỦ DỮ LIỆU CỦA BẠN';

  @override
  String get privacyRightEditProfile =>
      'Xem và chỉnh sửa họ tên, thông tin tài khoản ngân hàng bất kỳ lúc nào.';

  @override
  String get privacyRightTransferAdmin =>
      'Chuyển quyền Quản trị viên (Admin) cho thành viên khác trong nhóm.';

  @override
  String get privacyRightArchiveGroup =>
      'Yêu cầu xóa nhóm hoặc đóng băng lịch sử chi tiêu bằng cách đưa vào Lưu trữ.';

  @override
  String get privacyRightLogoutSafe =>
      'Đăng xuất an toàn khỏi thiết bị bất cứ khi nào bạn muốn.';

  @override
  String get privacyBackToSettings => 'Quay lại Cài đặt';

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
  String get inviteCodeCardTitle => 'MÃ MỜI THAM GIA NHÓM';

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
  String get backAction => 'Quay lại';

  @override
  String get joinGroupQrTitle => 'Gia nhập bằng mã / QR';

  @override
  String get joinGroupQrSubtitle =>
      'Tham gia nhóm chi tiêu nhanh chóng bằng cách quét mã QR hoặc nhập mã mời';

  @override
  String get scanQrTab => 'Quét mã QR';

  @override
  String get enterCodeTab => 'Nhập mã mời';

  @override
  String get scanQrInstruction =>
      'Hướng camera vào mã QR của nhóm để gửi yêu cầu gia nhập';

  @override
  String get testScanQrAction => 'Quét thử mã QR';

  @override
  String get uploadQrImageAction => 'Tải ảnh mã QR';

  @override
  String get invalidQrCodeError => 'Không tìm thấy mã mời hợp lệ trong mã QR.';

  @override
  String get noQrFoundInImage => 'Không tìm thấy mã QR trong ảnh đã chọn.';

  @override
  String get cameraPermissionRequired =>
      'Vui lòng cấp quyền truy cập Camera để quét mã QR.';

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

  @override
  String get debtsGroupTitle => 'Công nợ theo nhóm';

  @override
  String get debtsYouOwe => 'Bạn đang nợ';

  @override
  String get debtsYouOweSubtitle => 'Tổng tiền bạn cần thanh toán';

  @override
  String get debtsYouReceive => 'Bạn nhận';

  @override
  String get debtsYouReceiveSubtitle => 'Bạn bè đang nợ bạn';

  @override
  String get searchDebtGroupPlaceholder =>
      'Tìm kiếm nhóm theo tên, danh mục...';

  @override
  String filterDebtAllCount(int count) {
    return 'Tất cả nhóm ($count)';
  }

  @override
  String filterDebtHasDebtCount(int count) {
    return 'Có công nợ ($count)';
  }

  @override
  String filterDebtSettledCount(int count) {
    return 'Đã tất toán ($count)';
  }

  @override
  String debtsPendingCount(int count) {
    return '$count khoản nợ cần xử lý';
  }

  @override
  String get debtsSettledAll => 'Đã tất toán toàn bộ';

  @override
  String get debtsBalanced => 'Cân bằng (0 đ)';

  @override
  String get badgeYouReceive => 'Bạn nhận';

  @override
  String get badgeYouMustPay => 'Bạn cần thanh toán';

  @override
  String get badgeBalanced => 'Đã cân bằng';

  @override
  String get simplifiedDebtsTab => 'Nợ tối giản';

  @override
  String get actualDebtsTab => 'Nợ thực tế';

  @override
  String get simplifiedDebtsBanner =>
      'Tối ưu hóa số lượng giao dịch gộp thông minh để thanh toán nhanh gọn nhất.';

  @override
  String get actualDebtsBanner =>
      'Chi tiết các khoản nợ phát sinh theo từng hóa đơn và mục chi tiêu.';

  @override
  String debtsToHandleCount(int count) {
    return '$count KHOẢN NỢ CẦN XỬ LÝ';
  }

  @override
  String get simplifiedDebtAlgorithm => 'Thuật toán gộp nợ tối giản';

  @override
  String get payNowAction => 'Thanh toán ngay (100%)';

  @override
  String get confirmReceivedAction => 'Xác nhận nhận tiền';

  @override
  String get rejectReceivedAction => 'Từ chối';

  @override
  String get remindDebtAction => 'Nhắc nợ';

  @override
  String get debtStatusPending => 'Chưa thanh toán';

  @override
  String get debtStatusWaiting => 'Chờ xác nhận';

  @override
  String get debtStatusSettled => 'Đã tất toán';

  @override
  String get debtorLabel => 'Người nợ';

  @override
  String get creditorLabel => 'Chủ nợ';

  @override
  String get youTag => 'Bạn';

  @override
  String get yourBalanceInGroup => 'Số dư của bạn trong nhóm:';

  @override
  String get noDebtGroupsTitle => 'Không có nhóm công nợ nào';

  @override
  String get noDebtGroupsSubtitle =>
      'Hiện tại bạn không có khoản công nợ nào cần xử lý.';

  @override
  String get noMatchingDebtGroupsTitle => 'Không tìm thấy nhóm phù hợp';

  @override
  String get noMatchingDebtGroupsSubtitle =>
      'Thử tìm kiếm với từ khóa khác hoặc đổi bộ lọc.';

  @override
  String get confirmPayDebtTitle => 'Xác nhận đã thanh toán';

  @override
  String confirmPayDebtMessage(String creditor, String amount) {
    return 'Bạn đã chuyển khoản hoặc trả tiền mặt cho $creditor số tiền $amount?';
  }

  @override
  String get confirmReceiveDebtTitle => 'Xác nhận nhận tiền';

  @override
  String confirmReceiveDebtMessage(String debtor, String amount) {
    return 'Bạn đã nhận được số tiền $amount từ $debtor?';
  }

  @override
  String get rejectReceiveDebtTitle => 'Từ chối nhận tiền';

  @override
  String rejectReceiveDebtMessage(String debtor) {
    return 'Bạn chưa nhận được số tiền này và muốn yêu cầu $debtor kiểm tra lại?';
  }

  @override
  String get confirmRemindDebtTitle => 'Gửi thông báo nhắc nợ';

  @override
  String confirmRemindDebtMessage(String debtor, String amount) {
    return 'Gửi thông báo nhắc nhở thanh toán khoản nợ $amount đến $debtor?';
  }

  @override
  String get noDebtsInGroupTitle => 'Nhóm chưa có khoản nợ nào';

  @override
  String get noDebtsInGroupSubtitle =>
      'Mọi khoản chi tiêu trong nhóm đã được cân bằng hoặc chưa phát sinh nợ.';

  @override
  String get changePasswordTitle => 'Đổi mật khẩu tài khoản';

  @override
  String get changePasswordSubtitle =>
      'Cập nhật mật khẩu để bảo vệ an toàn cho tài khoản';

  @override
  String get currentPasswordLabel => 'Mật khẩu hiện tại';

  @override
  String get currentPasswordHint => 'Nhập mật khẩu đang dùng';

  @override
  String get newPasswordLabel => 'Mật khẩu mới';

  @override
  String get newPasswordHint => 'Tối thiểu 6 ký tự';

  @override
  String get confirmNewPasswordLabel => 'Xác nhận mật khẩu mới';

  @override
  String get confirmNewPasswordHint => 'Nhập lại mật khẩu mới';

  @override
  String get passwordSafetyTip =>
      'Gợi ý: Sử dụng mật khẩu kết hợp chữ hoa, chữ thường và chữ số để tăng độ an toàn.';

  @override
  String get changePasswordSubmitButton => 'Đổi mật khẩu';

  @override
  String get changePasswordSuccess => 'Đổi mật khẩu thành công!';

  @override
  String get enterCurrentPasswordPrompt => 'Vui lòng nhập mật khẩu hiện tại.';

  @override
  String get enterNewPasswordPrompt => 'Vui lòng nhập mật khẩu mới.';

  @override
  String get confirmPasswordMismatchPrompt => 'Mật khẩu xác nhận không khớp.';

  @override
  String get newPasswordSameAsCurrentPrompt =>
      'Mật khẩu mới không được trùng với mật khẩu hiện tại.';

  @override
  String get groupInfoSectionTitle => 'THÔNG TIN NHÓM';

  @override
  String get tabExpenses => 'Chi tiêu';

  @override
  String get tabFunds => 'Quỹ';

  @override
  String get tabMembers => 'Thành viên';

  @override
  String get categoryLabel => 'THỂ LOẠI';

  @override
  String get createdDateLabel => 'NGÀY TẠO';

  @override
  String get membersCountLabel => 'THÀNH VIÊN';

  @override
  String get copyInviteCodeAction => 'Sao chép mã mời';

  @override
  String get viewQrCodeTooltip => 'Xem mã QR';

  @override
  String get inviteMembersTitle => 'Mời thành viên vào nhóm';

  @override
  String get tabQrCode => 'Mã QR Code';

  @override
  String get tabQrCodeSubtitle => 'Quét trực tiếp khi ở cạnh nhau';

  @override
  String get tabCopyCode => 'Sao chép mã mời';

  @override
  String get tabCopyCodeSubtitle => 'Gửi mã văn bản qua tin nhắn, Zalo';

  @override
  String get scanToJoinInstruction =>
      'Thành viên quét mã này bằng điện thoại để gửi yêu cầu gia nhập';

  @override
  String get downloadQrAction => 'Tải ảnh mã QR';

  @override
  String get downloadQrSuccess => 'Đã lưu ảnh mã QR thành công!';

  @override
  String get downloadQrFailed => 'Không thể lưu ảnh mã QR';

  @override
  String get shareViaOtherAppsAction => 'Chia sẻ qua ứng dụng khác';

  @override
  String get closeButton => 'Đóng';

  @override
  String get yourBalanceInGroupLabel => 'Số dư của bạn trong nhóm';

  @override
  String get youReceiveBadge => 'Bạn nhận';

  @override
  String get youOweBadge => 'Bạn nợ';

  @override
  String get settledBadge => 'Cân bằng';

  @override
  String get totalSpendingCard => 'Tổng chi tiêu';

  @override
  String get viewReportAction => 'Xem báo cáo';

  @override
  String get fundCollectedCard => 'Quỹ đã thu';

  @override
  String get fundGeneralSubtitle => 'Quỹ chung';

  @override
  String get quickActionsTitle => 'LỐI TẮT & THAO TÁC NHANH';

  @override
  String get viewDebtsAction => 'Xem công nợ';

  @override
  String get settleDebtsSubtitle => 'Tất toán nợ';

  @override
  String get generalFundAction => 'Quỹ chung';

  @override
  String get collectFundSubtitle => 'Thu quỹ chung';

  @override
  String get addExpenseAction => 'Thêm khoản chi';

  @override
  String get splitBillSubtitle => 'Chia hóa đơn';

  @override
  String get groupSettingsAction => 'Cài đặt';

  @override
  String get accountAndInterfaceSubtitle => 'Tài khoản & thiết lập';

  @override
  String get groupAdminSectionTitle => 'QUẢN TRỊ NHÓM';

  @override
  String get editGroupInfo => 'Sửa thông tin';

  @override
  String get totalGeneralFundLabel => 'TỔNG TIỀN QUỸ CHUNG';

  @override
  String get collectNewFundAction => 'Thu quỹ mới';

  @override
  String get fundProgressLabel => 'Tiến độ thu quỹ';

  @override
  String get searchFundPlaceholder => 'Tìm kiếm đợt thu quỹ theo tên...';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterCollecting => 'Đang thu';

  @override
  String get filterCompleted => 'Hoàn thành';

  @override
  String get filterThisMonth => 'Tháng này';

  @override
  String get filterLastMonth => 'Tháng trước';

  @override
  String get filterThisQuarter => 'Quý này';

  @override
  String get fundEmptyList => 'Chưa có đợt đóng quỹ nào';

  @override
  String get fundEmptySubtitle =>
      'Nhấn \'Thu quỹ mới\' để phát động chiến dịch thu quỹ cho nhóm.';

  @override
  String get createFundTitle => 'Thêm đợt thu quỹ';

  @override
  String get editFundTitle => 'Chỉnh sửa đợt đóng quỹ';

  @override
  String get fundNameLabel => 'TÊN ĐỢT THU QUỸ *';

  @override
  String get fundNameHint => 'VD: Tiền phòng Tháng 11, Quỹ liên hoan...';

  @override
  String get quickSuggestionsLabel => 'Gợi ý nhanh:';

  @override
  String get suggestionRoomAndService => '+ Tiền phòng & Dịch vụ';

  @override
  String get suggestionYearEndParty => '+ Quỹ tiệc tất niên';

  @override
  String get suggestionBirthday => '+ Quỹ sinh nhật';

  @override
  String get suggestionInternetAndWater => '+ Tiền mạng & Nước';

  @override
  String get fundAmountLabel => 'SỐ TIỀN THU QUỸ *';

  @override
  String get perPersonMode => 'Mỗi người';

  @override
  String get totalFundMode => 'Tổng quỹ';

  @override
  String expectedTotalSummary(int count) {
    return 'Tổng thu dự kiến ($count người):';
  }

  @override
  String get targetTotalSummary => 'Tổng mục tiêu:';

  @override
  String get dueDateLabel => 'HẠN NỘP (HẠN CHÓT)';

  @override
  String get fundDescriptionLabel => 'GHI CHÚ / MỤC ĐÍCH THU QUỸ';

  @override
  String get fundDescriptionHint =>
      'VD: Tiền phòng chuyển chủ nhà trước ngày 10, phạt nếu nộp trễ...';

  @override
  String participatingMembersLabel(int selected, int total) {
    return 'THÀNH VIÊN THAM GIA ($selected/$total)';
  }

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get deselectAll => 'Bỏ chọn';

  @override
  String get createFundButton => 'Tạo đợt thu quỹ';

  @override
  String get saveFundButton => 'Lưu thay đổi';

  @override
  String get fundDetailTitle => 'Chi tiết đợt đóng quỹ';

  @override
  String get statusCollectingBadge => 'ĐANG THU QUỸ';

  @override
  String get statusCompletedBadge => 'HOÀN THÀNH';

  @override
  String get closeFundAction => 'Đóng quỹ';

  @override
  String get dueDatePrefix => 'Hạn chót đóng quỹ: ';

  @override
  String get collectedAmountLabel => 'ĐÃ THU ĐƯỢC';

  @override
  String get targetAmountLabel => 'MỤC TIÊU';

  @override
  String membersPaidRatio(int paid, int total) {
    return '$paid/$total thành viên đã nộp';
  }

  @override
  String get memberPaymentStatusTitle => 'TRẠNG THÁI NỘP QUỸ CỦA THÀNH VIÊN';

  @override
  String get tapToChangeStatusHint => 'Bấm để đổi trạng thái';

  @override
  String get statusPaid => 'Đã nộp';

  @override
  String get statusUnpaid => 'Chưa nộp';

  @override
  String get remindAction => 'Nhắc nộp';

  @override
  String remindCooldownToast(int seconds) {
    return 'Vui lòng đợi ${seconds}s trước khi gửi nhắc nhở tiếp theo';
  }

  @override
  String get confirmMarkPaidTitle => 'Xác nhận nộp quỹ';

  @override
  String confirmMarkPaidMessage(String name, String amount) {
    return 'Xác nhận thành viên $name đã đóng $amount cho đợt quỹ này?';
  }

  @override
  String get confirmDeleteFundTitle => 'Xóa đợt đóng quỹ';

  @override
  String get confirmDeleteFundMessage =>
      'Bạn có chắc chắn muốn xóa đợt đóng quỹ này? Mọi dữ liệu về trạng thái nộp tiền của các thành viên sẽ bị xóa vĩnh viễn.';

  @override
  String get editFundCampaignAction => 'Chỉnh sửa đợt đóng quỹ';

  @override
  String get exportFundCsvAction => 'Xuất báo cáo CSV đợt thu quỹ';

  @override
  String get deleteFundCampaignAction => 'Xóa đợt đóng quỹ này';

  @override
  String get mustSelectAtLeastOneMember =>
      'Vui lòng chọn ít nhất một thành viên tham gia.';

  @override
  String get minFundAmountError => 'Số tiền mỗi người tối thiểu là 1.000 đ.';

  @override
  String paidMemberCannotBeRemoved(String name) {
    return 'Không thể bỏ chọn thành viên đã đóng quỹ ($name).';
  }

  @override
  String get memberListSectionHeader => 'DANH SÁCH THÀNH VIÊN';

  @override
  String get inviteMoreAction => 'Mời thêm';

  @override
  String get searchMemberPlaceholder => 'Tìm kiếm thành viên...';

  @override
  String get pendingMembersSectionTitle => 'THÀNH VIÊN CHỜ DUYỆT';

  @override
  String pendingRequestsCountBadge(int count) {
    return '$count yêu cầu';
  }

  @override
  String get pendingRequestsSubtitle =>
      'Yêu cầu gia nhập nhóm đang chờ phê duyệt';

  @override
  String get joinRequestLabel => 'Yêu cầu tham gia nhóm';

  @override
  String get rejectAction => 'Từ chối';

  @override
  String get approveAction => 'Duyệt vào nhóm';

  @override
  String approveJoinTitle(String name) {
    return 'Chấp thuận cho $name tham gia nhóm?';
  }

  @override
  String get includePastFundsCheckbox =>
      'Yêu cầu đóng các đợt quỹ trước đây của nhóm';

  @override
  String get includePastFundsHint =>
      'Nếu chọn, thành viên mới sẽ được thêm vào danh sách phải đóng của tất cả các đợt quỹ đang mở trước đây.';

  @override
  String get confirmApproveButton => 'Xác nhận duyệt';

  @override
  String get touchMemberForFinancialHint =>
      'Chạm vào thành viên để xem chi tiết tài chính & công nợ';

  @override
  String membersCountHeader(int count) {
    return '$count thành viên';
  }

  @override
  String get youPill => 'Bạn';

  @override
  String get roleLeaderBadge => 'TRƯỞNG NHÓM';

  @override
  String get roleMemberBadge => 'THÀNH VIÊN';

  @override
  String get roleLeaderFull => 'TRƯỞNG NHÓM (ADMIN)';

  @override
  String get roleMemberFull => 'THÀNH VIÊN (MEMBER)';

  @override
  String get backToGroup => 'Quay lại nhóm';

  @override
  String get onTimeDebtRateLabel => 'TRẢ ĐÚNG H...';

  @override
  String get goodRateLabel => 'Tốt';

  @override
  String get onTimeFundRateLabel => 'ĐÓNG QUỸ Đ...';

  @override
  String get personalAndAccountInfoSection => 'THÔNG TIN CÁ NHÂN & TÀI KHOẢN';

  @override
  String get bankAccountTitle => 'Tài khoản ngân hàng';

  @override
  String get vietQrCodeButton => 'Mã VietQR';

  @override
  String get copyAction => 'Sao chép';

  @override
  String get copiedAccountNumber => 'Đã sao chép số tài khoản';

  @override
  String get copiedEmail => 'Đã sao chép email';

  @override
  String get copiedPhone => 'Đã sao chép số điện thoại';

  @override
  String get groupDebtStatusSection => 'TRẠNG THÁI CÔNG NỢ TRONG NHÓM';

  @override
  String get totalRefundedByGroup => 'Tổng số tiền được nhóm hoàn lại:';

  @override
  String get totalToPayGroup => 'Tổng số tiền cần chi trả cho nhóm:';

  @override
  String get netResultLabel => 'Kết quả ròng:';

  @override
  String participatedExpensesSection(int count) {
    return 'CÁC KHOẢN CHI ĐÃ THAM GIA ($count)';
  }

  @override
  String get paidFullBadge => 'Chi trả toàn bộ';

  @override
  String paidByMemberPrefix(String name) {
    return 'Bởi $name';
  }

  @override
  String memberSharePrefix(String amount) {
    return 'Phần chia: $amount';
  }

  @override
  String get kickMemberDangerTitle => 'XÓA THÀNH VIÊN KHỎI NHÓM';

  @override
  String get kickMemberDangerSubtitle =>
      'Xóa vĩnh viễn thành viên này khỏi nhóm chi tiêu. Thành viên sẽ không còn quyền truy cập vào các khoản chi và công nợ nhóm.';

  @override
  String get kickMemberButton => 'Kích khỏi nhóm';

  @override
  String get debtWarningTitle => 'Cảnh báo khoản nợ chưa tất toán';

  @override
  String debtWarningMessage(String amount) {
    return 'Thành viên này hiện còn khoản nợ chưa tất toán ($amount). Nếu xóa khỏi nhóm, khoản nợ này có thể khó thu hồi. Bạn có chắc chắn muốn xóa thành viên khỏi nhóm?';
  }

  @override
  String get receivableWarningTitle => 'Cảnh báo tiền chưa nhận lại';

  @override
  String receivableWarningMessage(String amount) {
    return 'Thành viên này hiện đang có khoản tiền chưa được nhận lại ($amount). Bạn có chắc chắn muốn tiếp tục xóa khỏi nhóm?';
  }

  @override
  String get confirmKickMemberTitle => 'Xác nhận xóa thành viên?';

  @override
  String confirmKickMemberMessage(String fullName, String groupName) {
    return 'Bạn có chắc chắn muốn xóa $fullName khỏi nhóm \"$groupName\"?';
  }

  @override
  String get stillKickButton => 'Vẫn xóa';

  @override
  String get continueKickButton => 'Tiếp tục xóa';

  @override
  String get confirmKickButton => 'Xác nhận xóa';

  @override
  String get noBankInfoYet => 'Chưa cập nhật tài khoản ngân hàng';

  @override
  String get noExpensesYet => 'Chưa tham gia khoản chi nào.';

  @override
  String get leaveGroupSectionTitle => 'RỜI KHỎI NHÓM';

  @override
  String get leaveGroupSectionSubtitle =>
      'Rời khỏi nhóm chi tiêu này. Bạn sẽ không thể xem lại các giao dịch và công nợ của nhóm trừ khi được mời lại.';

  @override
  String get leaveGroupButton => 'Rời nhóm';

  @override
  String get leaveGroupConfirmTitle => 'Xác nhận rời khỏi nhóm?';

  @override
  String leaveGroupConfirmMessage(String groupName) {
    return 'Bạn có chắc chắn muốn rời khỏi nhóm \"$groupName\"?';
  }

  @override
  String get deleteGroupSectionTitle => 'XÓA NHÓM';

  @override
  String get deleteGroupSectionSubtitle =>
      'Xóa vĩnh viễn nhóm này cùng toàn bộ chi tiêu, nợ và quỹ liên quan khỏi ứng dụng.';

  @override
  String get editProfileTitle => 'Cập nhật thông tin cá nhân';

  @override
  String get editProfileSubtitle =>
      'Chỉnh sửa hồ sơ và tài khoản nhận tiền VietQR';

  @override
  String get fullNameRequired => 'Họ và tên không được để trống';

  @override
  String get bankNameLabel => 'Ngân hàng nhận tiền (VietQR)';

  @override
  String get bankNameHint => 'Chọn ngân hàng từ danh sách';

  @override
  String get selectBankPrompt => 'Chọn ngân hàng';

  @override
  String get searchBankHint => 'Tìm theo tên, viết tắt hoặc mã BIN...';

  @override
  String get bankAccountNumberLabel => 'Số tài khoản ngân hàng';

  @override
  String get bankAccountNumberHint => 'Nhập số tài khoản ngân hàng';

  @override
  String get bankAccountNameLabel => 'Tên chủ tài khoản';

  @override
  String get bankAccountNameHint => 'NGUYEN VAN A (in hoa không dấu)';

  @override
  String get tapToViewQrHint => 'Chạm để xem mã VietQR';

  @override
  String get tapToSetupBankHint => 'Chạm để thiết lập tài khoản';

  @override
  String get changeAvatarPrompt => 'Đổi ảnh đại diện';

  @override
  String get chooseFromGallery => 'Chọn từ thư viện';

  @override
  String get takePhoto => 'Chụp ảnh mới';

  @override
  String get updateProfileSuccess => 'Cập nhật thông tin cá nhân thành công!';

  @override
  String get imageTooLargeError =>
      'Kích thước ảnh đại diện vượt quá 10MB. Vui lòng chọn ảnh khác.';

  @override
  String get loadBanksFailed =>
      'Không thể tải danh sách ngân hàng. Vui lòng kiểm tra kết nối mạng.';

  @override
  String get noBanksFound => 'Không tìm thấy ngân hàng phù hợp';
}
