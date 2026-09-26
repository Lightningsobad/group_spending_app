import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'FairShare'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @underDevelopment.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng đang được phát triển.'**
  String get underDevelopment;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @splashSlogan.
  ///
  /// In vi, this message translates to:
  /// **'Chia tiền minh bạch & nhắc nợ thông minh'**
  String get splashSlogan;

  /// No description provided for @authHeaderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý & Nhắc nhở Chi tiêu\nNhóm'**
  String get authHeaderTitle;

  /// No description provided for @authHeaderSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chia tiền minh bạch, nhắc nợ tế nhị, đóng quỹ dễ dàng.'**
  String get authHeaderSubtitle;

  /// No description provided for @loginTab.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginTab;

  /// No description provided for @registerTab.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get registerTab;

  /// No description provided for @orLoginWithEmail.
  ///
  /// In vi, this message translates to:
  /// **'HOẶC ĐĂNG NHẬP BẰNG EMAIL'**
  String get orLoginWithEmail;

  /// No description provided for @emailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập địa chỉ email của bạn'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập vào ứng dụng'**
  String get loginButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? '**
  String get noAccountPrompt;

  /// No description provided for @registerNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký ngay'**
  String get registerNow;

  /// No description provided for @orRegisterWithEmail.
  ///
  /// In vi, this message translates to:
  /// **'HOẶC ĐĂNG KÝ BẰNG EMAIL'**
  String get orRegisterWithEmail;

  /// No description provided for @fullNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập họ và tên đầy đủ'**
  String get fullNameHint;

  /// No description provided for @phoneLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phoneLabel;

  /// No description provided for @phoneOptionalTag.
  ///
  /// In vi, this message translates to:
  /// **'(Không bắt buộc / Tùy chọn)'**
  String get phoneOptionalTag;

  /// No description provided for @phoneHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số điện thoại'**
  String get phoneHint;

  /// No description provided for @registerButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản mới'**
  String get registerButton;

  /// No description provided for @hasAccountPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? '**
  String get hasAccountPrompt;

  /// No description provided for @loginNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginNow;

  /// No description provided for @continueWithGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục với Google'**
  String get continueWithGoogle;

  /// No description provided for @googleAuthNotice.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng đăng nhập Google đang được phát triển.'**
  String get googleAuthNotice;

  /// No description provided for @forgotPasswordNotice.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng Quên mật khẩu đang được hỗ trợ.'**
  String get forgotPasswordNotice;

  /// No description provided for @enterEmailPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập địa chỉ email.'**
  String get enterEmailPrompt;

  /// No description provided for @enterPasswordPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu.'**
  String get enterPasswordPrompt;

  /// No description provided for @enterFullNamePrompt.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên.'**
  String get enterFullNamePrompt;

  /// No description provided for @passwordMinLengthPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự.'**
  String get passwordMinLengthPrompt;

  /// No description provided for @otpTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực địa chỉ Email'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP 6 số bảo mật đã được gửi đến hòm thư của bạn'**
  String get otpSubtitle;

  /// No description provided for @otpInputLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác thực OTP'**
  String get otpInputLabel;

  /// No description provided for @otpDigitsHint.
  ///
  /// In vi, this message translates to:
  /// **'6 chữ số bảo mật'**
  String get otpDigitsHint;

  /// No description provided for @verifyAndActivate.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực & Kích hoạt'**
  String get verifyAndActivate;

  /// No description provided for @enterFullOtpPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đủ 6 chữ số mã xác thực OTP.'**
  String get enterFullOtpPrompt;

  /// No description provided for @resendOtpPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Chưa nhận được mã? '**
  String get resendOtpPrompt;

  /// No description provided for @resendOtpNow.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã'**
  String get resendOtpNow;

  /// No description provided for @resendIn.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã sau ({seconds}s)'**
  String resendIn(int seconds);

  /// No description provided for @onboardingStep.
  ///
  /// In vi, this message translates to:
  /// **'Bước {step}/{total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @skip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get skip;

  /// No description provided for @onboardingSlide1Pill.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý nhóm'**
  String get onboardingSlide1Pill;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In vi, this message translates to:
  /// **'KẾT NỐI & QUẢN LÝ NHÓM'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Desc.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý nhóm bạn bè, chuyến du lịch và chia sẻ mọi chi phí sinh hoạt chung một cách dễ dàng, trực quan và công bằng.'**
  String get onboardingSlide1Desc;

  /// No description provided for @onboardingSlide2Pill.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý chi tiêu'**
  String get onboardingSlide2Pill;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In vi, this message translates to:
  /// **'QUẢN LÝ CHI TIÊU THÔNG MINH'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Desc.
  ///
  /// In vi, this message translates to:
  /// **'Ghi nhận chi tiêu nhanh chóng, phân tích biểu đồ trực quan, chia đều hóa đơn và tự động rút gọn công nợ tối ưu.'**
  String get onboardingSlide2Desc;

  /// No description provided for @onboardingSlide3Pill.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý quỹ chung'**
  String get onboardingSlide3Pill;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In vi, this message translates to:
  /// **'QUẢN LÝ QUỸ CHUNG MINH BẠCH'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Desc.
  ///
  /// In vi, this message translates to:
  /// **'Thu quỹ nhóm tiện lợi, theo dõi tiến độ đóng góp theo thời gian thực và quản lý ngân sách an toàn, minh bạch 100%.'**
  String get onboardingSlide3Desc;

  /// No description provided for @onboardingSlide4Pill.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nợ & Thanh toán'**
  String get onboardingSlide4Pill;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In vi, this message translates to:
  /// **'NHẮC NỢ & THANH TOÁN TỐC ĐỘ'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Desc.
  ///
  /// In vi, this message translates to:
  /// **'Gửi thông báo nhắc nợ tinh tế, quét mã VietQR tự động điền tài khoản và hoàn tất quyết toán chỉ trong tích tắc.'**
  String get onboardingSlide4Desc;

  /// No description provided for @greeting.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào,'**
  String get greeting;

  /// No description provided for @tabOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get tabOverview;

  /// No description provided for @tabGroups.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm'**
  String get tabGroups;

  /// No description provided for @tabDebts.
  ///
  /// In vi, this message translates to:
  /// **'Công nợ'**
  String get tabDebts;

  /// No description provided for @tabAnalytics.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get tabAnalytics;

  /// No description provided for @tabSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get tabSettings;

  /// No description provided for @notificationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tổng hợp thông báo'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Hiện bạn chưa có thông báo mới nào.'**
  String get noNotifications;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @roleAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Trưởng nhóm (Admin)'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên'**
  String get roleMember;

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Sửa thông tin'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePassword;

  /// No description provided for @vietqrTitle.
  ///
  /// In vi, this message translates to:
  /// **'TÀI KHOẢN NHẬN TIỀN NỢ (VIETQR)'**
  String get vietqrTitle;

  /// No description provided for @defaultBankInfo.
  ///
  /// In vi, this message translates to:
  /// **'Techcombank - 19034829104018'**
  String get defaultBankInfo;

  /// No description provided for @defaultAccountName.
  ///
  /// In vi, this message translates to:
  /// **'NGUYEN NHAT MINH'**
  String get defaultAccountName;

  /// No description provided for @appearanceLanguageSection.
  ///
  /// In vi, this message translates to:
  /// **'GIAO DIỆN & NGÔN NGỮ'**
  String get appearanceLanguageSection;

  /// No description provided for @themeModeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ giao diện (Theme)'**
  String get themeModeTitle;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nền sáng #F8FAFC'**
  String get themeLightSubtitle;

  /// No description provided for @themeDarkSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nền tối #0F172A'**
  String get themeDarkSubtitle;

  /// No description provided for @lightThemeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Light'**
  String get lightThemeLabel;

  /// No description provided for @darkThemeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Dark'**
  String get darkThemeLabel;

  /// No description provided for @displayLanguageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ hiển thị'**
  String get displayLanguageTitle;

  /// No description provided for @displayLanguageSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt (Toàn bộ nhãn)'**
  String get displayLanguageSubtitle;

  /// No description provided for @infoSupportSection.
  ///
  /// In vi, this message translates to:
  /// **'THÔNG TIN & HỖ TRỢ'**
  String get infoSupportSection;

  /// No description provided for @aboutAppTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu về FairShare'**
  String get aboutAppTitle;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại toàn bộ slide giới thiệu tính năng ứng dụng (Onboarding)'**
  String get aboutAppSubtitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật & Quyền riêng tư'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cam kết mã hóa thông tin & bảo vệ tài khoản (Xem chi tiết)'**
  String get privacyPolicySubtitle;

  /// No description provided for @logoutButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất tài khoản'**
  String get logoutButton;

  /// No description provided for @logoutTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logoutTooltip;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất?'**
  String get logoutConfirmTitle;

  /// No description provided for @financialOverviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'TỔNG QUAN SỐ DƯ TÀI CHÍNH'**
  String get financialOverviewTitle;

  /// No description provided for @youOwe.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang nợ'**
  String get youOwe;

  /// No description provided for @paySoonSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cần thanh toán sớm'**
  String get paySoonSubtitle;

  /// No description provided for @youAreOwed.
  ///
  /// In vi, this message translates to:
  /// **'Bạn nhận'**
  String get youAreOwed;

  /// No description provided for @friendsOweYouSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn bè đang nợ bạn'**
  String get friendsOweYouSubtitle;

  /// No description provided for @addExpense.
  ///
  /// In vi, this message translates to:
  /// **'Thêm chi tiêu'**
  String get addExpense;

  /// No description provided for @addExpenseFeatureNotice.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng Thêm chi tiêu đang được tích hợp.'**
  String get addExpenseFeatureNotice;

  /// No description provided for @createGroupAction.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm'**
  String get createGroupAction;

  /// No description provided for @codeOrQrAction.
  ///
  /// In vi, this message translates to:
  /// **'Mã / QR'**
  String get codeOrQrAction;

  /// No description provided for @yourGroupsSection.
  ///
  /// In vi, this message translates to:
  /// **'CÁC NHÓM CỦA BẠN'**
  String get yourGroupsSection;

  /// No description provided for @seeAllGroupsCount.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả ({count})'**
  String seeAllGroupsCount(int count);

  /// No description provided for @noGroupsJoinedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa tham gia nhóm nào'**
  String get noGroupsJoinedTitle;

  /// No description provided for @noGroupsJoinedSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hãy tạo nhóm mới hoặc gia nhập nhóm qua mã mời để bắt đầu chia tiền cùng bạn bè!'**
  String get noGroupsJoinedSubtitle;

  /// No description provided for @createGroupNow.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm ngay'**
  String get createGroupNow;

  /// No description provided for @notificationsToggledForGroup.
  ///
  /// In vi, this message translates to:
  /// **'Đã thay đổi thông báo cho \"{name}\".'**
  String notificationsToggledForGroup(String name);

  /// No description provided for @groupListHeaderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách nhóm của bạn'**
  String get groupListHeaderTitle;

  /// No description provided for @searchGroupPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm theo tên nhóm, thể loại...'**
  String get searchGroupPlaceholder;

  /// No description provided for @filterAllCount.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả ({count})'**
  String filterAllCount(int count);

  /// No description provided for @filterActiveCount.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động ({count})'**
  String filterActiveCount(int count);

  /// No description provided for @filterArchivedCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu trữ ({count})'**
  String filterArchivedCount(int count);

  /// No description provided for @filterAdminCount.
  ///
  /// In vi, this message translates to:
  /// **'Tôi quản lý ({count})'**
  String filterAdminCount(int count);

  /// No description provided for @noMatchingGroupsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy nhóm phù hợp'**
  String get noMatchingGroupsTitle;

  /// No description provided for @noMatchingGroupsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thử tìm kiếm với từ khóa khác hoặc đổi bộ lọc.'**
  String get noMatchingGroupsSubtitle;

  /// No description provided for @noGroupsInTabTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nhóm trong mục này'**
  String get noGroupsInTabTitle;

  /// No description provided for @noGroupsInTabSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn \"+ Tạo nhóm mới\" để tạo nhóm đầu tiên của bạn!'**
  String get noGroupsInTabSubtitle;

  /// No description provided for @createGroupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm chi tiêu mới'**
  String get createGroupTitle;

  /// No description provided for @createGroupSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt tên nhóm và chọn danh mục để bắt đầu quản lý chi tiêu chung.'**
  String get createGroupSubtitle;

  /// No description provided for @groupNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên nhóm chi tiêu *'**
  String get groupNameLabel;

  /// No description provided for @groupNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên nhóm (VD: Chuyến đi Đà Lạt, Chung cư 402...)'**
  String get groupNameHint;

  /// No description provided for @groupDescLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả nhóm (Tùy chọn)'**
  String get groupDescLabel;

  /// No description provided for @groupDescHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mô tả ngắn về mục đích chi tiêu của nhóm...'**
  String get groupDescHint;

  /// No description provided for @groupCategoryLabel.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục nhóm'**
  String get groupCategoryLabel;

  /// No description provided for @defaultCurrencyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ mặc định'**
  String get defaultCurrencyLabel;

  /// No description provided for @groupNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên nhóm.'**
  String get groupNameRequired;

  /// No description provided for @joinGroupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gia nhập nhóm bằng mã mời'**
  String get joinGroupTitle;

  /// No description provided for @joinGroupSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã mời gồm 6-12 ký tự để tham gia nhóm chi tiêu của bạn bè.'**
  String get joinGroupSubtitle;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã mời nhóm *'**
  String get inviteCodeLabel;

  /// No description provided for @inviteCodeHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: DALAT2024, ROOM402...'**
  String get inviteCodeHint;

  /// No description provided for @inviteCodeRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mã mời.'**
  String get inviteCodeRequired;

  /// No description provided for @joinGroupButton.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia nhóm'**
  String get joinGroupButton;

  /// No description provided for @groupDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết nhóm'**
  String get groupDetailTitle;

  /// No description provided for @groupInviteCodePrefix.
  ///
  /// In vi, this message translates to:
  /// **'Mã mời nhóm:'**
  String get groupInviteCodePrefix;

  /// No description provided for @codeCopiedToClipboard.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép mã mời vào khay nhớ tạm'**
  String get codeCopiedToClipboard;

  /// No description provided for @copyCodeTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép mã'**
  String get copyCodeTooltip;

  /// No description provided for @archiveGroupAction.
  ///
  /// In vi, this message translates to:
  /// **'Lưu trữ nhóm'**
  String get archiveGroupAction;

  /// No description provided for @archiveGroupConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận lưu trữ nhóm?'**
  String get archiveGroupConfirmTitle;

  /// No description provided for @archiveGroupConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm sẽ được chuyển vào mục lưu trữ và chỉ cho phép xem thông tin.'**
  String get archiveGroupConfirmMessage;

  /// No description provided for @archiveConfirmButton.
  ///
  /// In vi, this message translates to:
  /// **'Lưu trữ'**
  String get archiveConfirmButton;

  /// No description provided for @deleteGroupAction.
  ///
  /// In vi, this message translates to:
  /// **'Xóa nhóm'**
  String get deleteGroupAction;

  /// No description provided for @deleteGroupConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa vĩnh viễn nhóm?'**
  String get deleteGroupConfirmTitle;

  /// No description provided for @deleteGroupConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này sẽ xóa toàn bộ chi tiêu, công nợ, quỹ chung và danh sách thành viên của nhóm. Không thể khôi phục!'**
  String get deleteGroupConfirmMessage;

  /// No description provided for @deleteConfirmButton.
  ///
  /// In vi, this message translates to:
  /// **'Xóa nhóm'**
  String get deleteConfirmButton;

  /// No description provided for @editGroupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sửa thông tin nhóm'**
  String get editGroupTitle;

  /// No description provided for @saveChanges.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get saveChanges;

  /// No description provided for @groupMembersTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên nhóm'**
  String get groupMembersTitle;

  /// No description provided for @loadDashboardFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải dữ liệu tổng quan'**
  String get loadDashboardFailed;

  /// No description provided for @loadGroupsFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải danh sách nhóm'**
  String get loadGroupsFailed;

  /// No description provided for @createGroupSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm thành công!'**
  String get createGroupSuccess;

  /// No description provided for @updateGroupSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật nhóm thành công!'**
  String get updateGroupSuccess;

  /// No description provided for @archiveGroupSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm đã được chuyển sang chế độ lưu trữ.'**
  String get archiveGroupSuccess;

  /// No description provided for @deleteGroupSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Xóa nhóm thành công.'**
  String get deleteGroupSuccess;

  /// No description provided for @joinGroupSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia nhóm thành công!'**
  String get joinGroupSuccess;

  /// No description provided for @editGroupAction.
  ///
  /// In vi, this message translates to:
  /// **'Sửa nhóm'**
  String get editGroupAction;

  /// No description provided for @inviteCodeCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'MÃ MỜI THAM GIA'**
  String get inviteCodeCardTitle;

  /// No description provided for @groupFinancialOverviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'TỔNG QUAN TÀI CHÍNH NHÓM'**
  String get groupFinancialOverviewTitle;

  /// No description provided for @yourBalanceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số dư của bạn:'**
  String get yourBalanceLabel;

  /// No description provided for @totalGroupSpendingLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng chi tiêu nhóm:'**
  String get totalGroupSpendingLabel;

  /// No description provided for @totalFundCollectedLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quỹ đã thu:'**
  String get totalFundCollectedLabel;

  /// No description provided for @groupMembersCountTitle.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH VIÊN ({count})'**
  String groupMembersCountTitle(int count);

  /// No description provided for @groupMemberCountSimple.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm có {count} thành viên'**
  String groupMemberCountSimple(int count);

  /// No description provided for @deleteGroupPermanently.
  ///
  /// In vi, this message translates to:
  /// **'Xóa nhóm vĩnh viễn'**
  String get deleteGroupPermanently;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
