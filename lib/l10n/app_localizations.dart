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

  /// No description provided for @tabAnalyticsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo & Thống kê'**
  String get tabAnalyticsTitle;

  /// No description provided for @totalSpendingAllGroups.
  ///
  /// In vi, this message translates to:
  /// **'Tổng chi tất cả nhóm'**
  String get totalSpendingAllGroups;

  /// No description provided for @activeGroupsJoinedCount.
  ///
  /// In vi, this message translates to:
  /// **'Số nhóm tham gia'**
  String get activeGroupsJoinedCount;

  /// No description provided for @groupsUnit.
  ///
  /// In vi, this message translates to:
  /// **'nhóm'**
  String get groupsUnit;

  /// No description provided for @totalInvoicesRecorded.
  ///
  /// In vi, this message translates to:
  /// **'Số hóa đơn đã ghi'**
  String get totalInvoicesRecorded;

  /// No description provided for @invoicesUnit.
  ///
  /// In vi, this message translates to:
  /// **'hóa đơn'**
  String get invoicesUnit;

  /// No description provided for @overallReportBannerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo tổng quan'**
  String get overallReportBannerTitle;

  /// No description provided for @viewOverallReportAction.
  ///
  /// In vi, this message translates to:
  /// **'Xem toàn cảnh'**
  String get viewOverallReportAction;

  /// No description provided for @searchGroupByHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm nhóm theo tên, danh mục...'**
  String get searchGroupByHint;

  /// No description provided for @filterAllTab.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả ({count})'**
  String filterAllTab(int count);

  /// No description provided for @filterActiveTab.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get filterActiveTab;

  /// No description provided for @filterArchivedTab.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu trữ'**
  String get filterArchivedTab;

  /// No description provided for @groupSpendingListTitle.
  ///
  /// In vi, this message translates to:
  /// **'DANH SÁCH NHÓM CHI TIÊU'**
  String get groupSpendingListTitle;

  /// No description provided for @totalSpendingLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng chi tiêu'**
  String get totalSpendingLabel;

  /// No description provided for @overallReportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo tổng quan'**
  String get overallReportTitle;

  /// No description provided for @overallReportSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tổng hợp tất cả nhóm đang tham gia'**
  String get overallReportSubtitle;

  /// No description provided for @financialMetricsTitle.
  ///
  /// In vi, this message translates to:
  /// **'CHỈ SỐ TÀI CHÍNH NHÓM'**
  String get financialMetricsTitle;

  /// No description provided for @totalSpendingMetric.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền chi tiêu'**
  String get totalSpendingMetric;

  /// No description provided for @commonGroupSpendingSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu chung cả nhóm'**
  String get commonGroupSpendingSubtitle;

  /// No description provided for @averagePerPersonMetric.
  ///
  /// In vi, this message translates to:
  /// **'Bình quân đầu người'**
  String get averagePerPersonMetric;

  /// No description provided for @splitEquallySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi thành viên chia đều'**
  String get splitEquallySubtitle;

  /// No description provided for @friendsCountBadge.
  ///
  /// In vi, this message translates to:
  /// **'÷ {count} bạn'**
  String friendsCountBadge(int count);

  /// No description provided for @expenseCountMetric.
  ///
  /// In vi, this message translates to:
  /// **'Số khoản chi'**
  String get expenseCountMetric;

  /// No description provided for @invoicesBadge.
  ///
  /// In vi, this message translates to:
  /// **'Hóa đơn'**
  String get invoicesBadge;

  /// No description provided for @expensesUnit.
  ///
  /// In vi, this message translates to:
  /// **'khoản chi'**
  String get expensesUnit;

  /// No description provided for @recordedAndAuditedSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi nhận & đối soát'**
  String get recordedAndAuditedSubtitle;

  /// No description provided for @settlementRateMetric.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ tất toán'**
  String get settlementRateMetric;

  /// No description provided for @paidRateSuffix.
  ///
  /// In vi, this message translates to:
  /// **'đã trả'**
  String get paidRateSuffix;

  /// No description provided for @groupDebtLabel.
  ///
  /// In vi, this message translates to:
  /// **'Công nợ nhóm'**
  String get groupDebtLabel;

  /// No description provided for @remainingDebtRate.
  ///
  /// In vi, this message translates to:
  /// **'Còn {percent}% tồn'**
  String remainingDebtRate(String percent);

  /// No description provided for @categoryDistributionTitle.
  ///
  /// In vi, this message translates to:
  /// **'PHÂN BỐ THEO DANH MỤC CHI TIÊU'**
  String get categoryDistributionTitle;

  /// No description provided for @memberContributionTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐÓNG GÓP & CHI TIÊU THÀNH VIÊN'**
  String get memberContributionTitle;

  /// No description provided for @contributionPercent.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp {percent}% tổng chi'**
  String contributionPercent(String percent);

  /// No description provided for @recentExpensesTitle.
  ///
  /// In vi, this message translates to:
  /// **'HÓA ĐƠN CHI TIÊU GẦN ĐÂY'**
  String get recentExpensesTitle;

  /// No description provided for @expensesCountBadge.
  ///
  /// In vi, this message translates to:
  /// **'{count} khoản'**
  String expensesCountBadge(int count);

  /// No description provided for @paidByPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Người trả: {name}'**
  String paidByPrefix(String name);

  /// No description provided for @viewExpenseDetailAction.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết →'**
  String get viewExpenseDetailAction;

  /// No description provided for @periodThisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get periodThisMonth;

  /// No description provided for @periodLastMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng trước'**
  String get periodLastMonth;

  /// No description provided for @periodCurrentQuarter.
  ///
  /// In vi, this message translates to:
  /// **'Quý này'**
  String get periodCurrentQuarter;

  /// No description provided for @periodByYear.
  ///
  /// In vi, this message translates to:
  /// **'Cả năm'**
  String get periodByYear;

  /// No description provided for @membersCountSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'{memberCount} thành viên'**
  String membersCountSubtitle(int memberCount);

  /// No description provided for @noExpensesRecorded.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có khoản chi tiêu nào.'**
  String get noExpensesRecorded;

  /// No description provided for @noCategoriesRecorded.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu danh mục.'**
  String get noCategoriesRecorded;

  /// No description provided for @noLeaderboardData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu đóng góp.'**
  String get noLeaderboardData;

  /// No description provided for @loadAnalyticsFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải dữ liệu thống kê'**
  String get loadAnalyticsFailed;

  /// No description provided for @retryAction.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retryAction;

  /// No description provided for @youLabel.
  ///
  /// In vi, this message translates to:
  /// **'(Tôi)'**
  String get youLabel;
  /// No description provided for @debtsGroupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Công nợ theo nhóm'**
  String get debtsGroupTitle;

  /// No description provided for @debtsYouOwe.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang nợ'**
  String get debtsYouOwe;

  /// No description provided for @debtsYouOweSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền bạn cần thanh toán'**
  String get debtsYouOweSubtitle;

  /// No description provided for @debtsYouReceive.
  ///
  /// In vi, this message translates to:
  /// **'Bạn nhận'**
  String get debtsYouReceive;

  /// No description provided for @debtsYouReceiveSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn bè đang nợ bạn'**
  String get debtsYouReceiveSubtitle;

  /// No description provided for @searchDebtGroupPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm nhóm theo tên, danh mục...'**
  String get searchDebtGroupPlaceholder;

  /// No description provided for @filterDebtAllCount.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả nhóm ({count})'**
  String filterDebtAllCount(int count);

  /// No description provided for @filterDebtHasDebtCount.
  ///
  /// In vi, this message translates to:
  /// **'Có công nợ ({count})'**
  String filterDebtHasDebtCount(int count);

  /// No description provided for @filterDebtSettledCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã tất toán ({count})'**
  String filterDebtSettledCount(int count);

  /// No description provided for @debtsPendingCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} khoản nợ cần xử lý'**
  String debtsPendingCount(int count);

  /// No description provided for @debtsSettledAll.
  ///
  /// In vi, this message translates to:
  /// **'Đã tất toán toàn bộ'**
  String get debtsSettledAll;

  /// No description provided for @debtsBalanced.
  ///
  /// In vi, this message translates to:
  /// **'Cân bằng (0 đ)'**
  String get debtsBalanced;

  /// No description provided for @badgeYouReceive.
  ///
  /// In vi, this message translates to:
  /// **'Bạn nhận'**
  String get badgeYouReceive;

  /// No description provided for @badgeYouMustPay.
  ///
  /// In vi, this message translates to:
  /// **'Bạn cần thanh toán'**
  String get badgeYouMustPay;

  /// No description provided for @badgeBalanced.
  ///
  /// In vi, this message translates to:
  /// **'Đã cân bằng'**
  String get badgeBalanced;

  /// No description provided for @simplifiedDebtsTab.
  ///
  /// In vi, this message translates to:
  /// **'Nợ tối giản'**
  String get simplifiedDebtsTab;

  /// No description provided for @actualDebtsTab.
  ///
  /// In vi, this message translates to:
  /// **'Nợ thực tế'**
  String get actualDebtsTab;

  /// No description provided for @simplifiedDebtsBanner.
  ///
  /// In vi, this message translates to:
  /// **'Tối ưu hóa số lượng giao dịch gộp thông minh để thanh toán nhanh gọn nhất.'**
  String get simplifiedDebtsBanner;

  /// No description provided for @actualDebtsBanner.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết các khoản nợ phát sinh theo từng hóa đơn và mục chi tiêu.'**
  String get actualDebtsBanner;

  /// No description provided for @debtsToHandleCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} KHOẢN NỢ CẦN XỬ LÝ'**
  String debtsToHandleCount(int count);

  /// No description provided for @simplifiedDebtAlgorithm.
  ///
  /// In vi, this message translates to:
  /// **'Thuật toán gộp nợ tối giản'**
  String get simplifiedDebtAlgorithm;

  /// No description provided for @payNowAction.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán ngay (100%)'**
  String get payNowAction;

  /// No description provided for @confirmReceivedAction.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận nhận tiền'**
  String get confirmReceivedAction;

  /// No description provided for @rejectReceivedAction.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get rejectReceivedAction;

  /// No description provided for @remindDebtAction.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nợ'**
  String get remindDebtAction;

  /// No description provided for @debtStatusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thanh toán'**
  String get debtStatusPending;

  /// No description provided for @debtStatusWaiting.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xác nhận'**
  String get debtStatusWaiting;

  /// No description provided for @debtStatusSettled.
  ///
  /// In vi, this message translates to:
  /// **'Đã tất toán'**
  String get debtStatusSettled;

  /// No description provided for @debtorLabel.
  ///
  /// In vi, this message translates to:
  /// **'Người nợ'**
  String get debtorLabel;

  /// No description provided for @creditorLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chủ nợ'**
  String get creditorLabel;

  /// No description provided for @youTag.
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get youTag;

  /// No description provided for @backAction.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get backAction;

  /// No description provided for @yourBalanceInGroup.
  ///
  /// In vi, this message translates to:
  /// **'Số dư của bạn trong nhóm:'**
  String get yourBalanceInGroup;

  /// No description provided for @noDebtGroupsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không có nhóm công nợ nào'**
  String get noDebtGroupsTitle;

  /// No description provided for @noDebtGroupsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hiện tại bạn không có khoản công nợ nào cần xử lý.'**
  String get noDebtGroupsSubtitle;

  /// No description provided for @noMatchingDebtGroupsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy nhóm phù hợp'**
  String get noMatchingDebtGroupsTitle;

  /// No description provided for @noMatchingDebtGroupsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thử tìm kiếm với từ khóa khác hoặc đổi bộ lọc.'**
  String get noMatchingDebtGroupsSubtitle;

  /// No description provided for @confirmPayDebtTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đã thanh toán'**
  String get confirmPayDebtTitle;

  /// No description provided for @confirmPayDebtMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã chuyển khoản hoặc trả tiền mặt cho {creditor} số tiền {amount}?'**
  String confirmPayDebtMessage(String creditor, String amount);

  /// No description provided for @confirmReceiveDebtTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận nhận tiền'**
  String get confirmReceiveDebtTitle;

  /// No description provided for @confirmReceiveDebtMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã nhận được số tiền {amount} từ {debtor}?'**
  String confirmReceiveDebtMessage(String debtor, String amount);

  /// No description provided for @rejectReceiveDebtTitle.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối nhận tiền'**
  String get rejectReceiveDebtTitle;

  /// No description provided for @rejectReceiveDebtMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa nhận được số tiền này và muốn yêu cầu {debtor} kiểm tra lại?'**
  String rejectReceiveDebtMessage(String debtor);

  /// No description provided for @confirmRemindDebtTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gửi thông báo nhắc nợ'**
  String get confirmRemindDebtTitle;

  /// No description provided for @confirmRemindDebtMessage.
  ///
  /// In vi, this message translates to:
  /// **'Gửi thông báo nhắc nhở thanh toán khoản nợ {amount} đến {debtor}?'**
  String confirmRemindDebtMessage(String debtor, String amount);

  /// No description provided for @noDebtsInGroupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm chưa có khoản nợ nào'**
  String get noDebtsInGroupTitle;

  /// No description provided for @noDebtsInGroupSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mọi khoản chi tiêu trong nhóm đã được cân bằng hoặc chưa phát sinh nợ.'**
  String get noDebtsInGroupSubtitle;
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
