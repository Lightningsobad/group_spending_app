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
  /// **'Nhập họ và tên của bạn'**
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
  /// **'Nhập số điện thoại (tùy chọn)'**
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

  /// No description provided for @noBankData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get noBankData;

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

  /// No description provided for @privacyPolicyCommitmentSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cam kết bảo vệ dữ liệu cá nhân & an toàn tài chính'**
  String get privacyPolicyCommitmentSubtitle;

  /// No description provided for @privacyStandardBadge.
  ///
  /// In vi, this message translates to:
  /// **'BẢO MẬT TIÊU CHUẨN'**
  String get privacyStandardBadge;

  /// No description provided for @privacyUpdatedDate.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật: Tháng 09/2026'**
  String get privacyUpdatedDate;

  /// No description provided for @privacyHeroTitle.
  ///
  /// In vi, this message translates to:
  /// **'Minh bạch thu chi • Bảo mật dữ liệu người dùng'**
  String get privacyHeroTitle;

  /// No description provided for @privacyHeroDescription.
  ///
  /// In vi, this message translates to:
  /// **'FairShare tôn trọng quyền riêng tư của bạn. Mọi khoản chi, thông tin hóa đơn và số tài khoản ngân hàng chỉ phục vụ mục đích phân chia công nợ và đóng quỹ nhóm của các thành viên.'**
  String get privacyHeroDescription;

  /// No description provided for @privacyDataCollectedTitle.
  ///
  /// In vi, this message translates to:
  /// **'1. DỮ LIỆU ỨNG DỤNG THU THẬP'**
  String get privacyDataCollectedTitle;

  /// No description provided for @privacyDataCollectedDesc.
  ///
  /// In vi, this message translates to:
  /// **'Chúng tôi chỉ thu thập các trường thông tin tối thiểu cần thiết để vận hành các tính năng chia tiền nhóm:'**
  String get privacyDataCollectedDesc;

  /// No description provided for @privacyIdentityTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin định danh: '**
  String get privacyIdentityTitle;

  /// No description provided for @privacyIdentityDesc.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên hiển thị, ảnh đại diện và địa chỉ Email để xác thực tài khoản và gửi mã OTP.'**
  String get privacyIdentityDesc;

  /// No description provided for @privacyBankTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản nhận tiền (VietQR): '**
  String get privacyBankTitle;

  /// No description provided for @privacyBankDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tên ngân hàng, số tài khoản và tên chủ sở hữu nhằm tạo mã VietQR chuẩn 1-chạm giúp thành viên khác chuyển khoản trả nợ.'**
  String get privacyBankDesc;

  /// No description provided for @privacyTransactionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu giao dịch nhóm: '**
  String get privacyTransactionTitle;

  /// No description provided for @privacyTransactionDesc.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách hóa đơn, số tiền chi, người trả hộ, tỷ lệ phân bổ và các chiến dịch đóng quỹ chung.'**
  String get privacyTransactionDesc;

  /// No description provided for @privacySecurityTitle.
  ///
  /// In vi, this message translates to:
  /// **'2. AN TOÀN MẬT KHẨU & MÃ HÓA ĐẦU CUỐI'**
  String get privacySecurityTitle;

  /// No description provided for @privacySecurityDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu tài khoản của người dùng được băm một chiều (one-way hashing) kèm salt an toàn, hoàn toàn không thể dịch ngược hay đọc dưới dạng văn bản thô.'**
  String get privacySecurityDesc;

  /// No description provided for @privacyChangePasswordTip.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể tự chủ động thay đổi mật khẩu bất kỳ lúc nào tại màn hình Cài đặt bằng tính năng \"Đổi mật khẩu\".'**
  String get privacyChangePasswordTip;

  /// No description provided for @privacyNoShareTitle.
  ///
  /// In vi, this message translates to:
  /// **'3. CAM KẾT KHÔNG CHIA SẺ DỮ LIỆU'**
  String get privacyNoShareTitle;

  /// No description provided for @privacyNoShareDesc.
  ///
  /// In vi, this message translates to:
  /// **'FairShare cam kết không bán, chia sẻ hoặc thương mại hóa bất kỳ thông tin cá nhân, lịch sử chuyển nợ hay số tiền đóng quỹ của bạn cho bất kỳ đối tác quảng cáo nào.'**
  String get privacyNoShareDesc;

  /// No description provided for @privacyUserRightsTitle.
  ///
  /// In vi, this message translates to:
  /// **'4. QUYỀN LÀM CHỦ DỮ LIỆU CỦA BẠN'**
  String get privacyUserRightsTitle;

  /// No description provided for @privacyRightEditProfile.
  ///
  /// In vi, this message translates to:
  /// **'Xem và chỉnh sửa họ tên, thông tin tài khoản ngân hàng bất kỳ lúc nào.'**
  String get privacyRightEditProfile;

  /// No description provided for @privacyRightTransferAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển quyền Quản trị viên (Admin) cho thành viên khác trong nhóm.'**
  String get privacyRightTransferAdmin;

  /// No description provided for @privacyRightArchiveGroup.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu xóa nhóm hoặc đóng băng lịch sử chi tiêu bằng cách đưa vào Lưu trữ.'**
  String get privacyRightArchiveGroup;

  /// No description provided for @privacyRightLogoutSafe.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất an toàn khỏi thiết bị bất cứ khi nào bạn muốn.'**
  String get privacyRightLogoutSafe;

  /// No description provided for @privacyBackToSettings.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại Cài đặt'**
  String get privacyBackToSettings;

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

  /// No description provided for @chooseGroupToAddExpenseTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nhóm muốn thêm khoản chi'**
  String get chooseGroupToAddExpenseTitle;

  /// No description provided for @filterActiveOnly.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get filterActiveOnly;

  /// No description provided for @filterAllGroupsOnly.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả nhóm'**
  String get filterAllGroupsOnly;

  /// No description provided for @filterAdminOnly.
  ///
  /// In vi, this message translates to:
  /// **'Tôi làm Admin'**
  String get filterAdminOnly;

  /// No description provided for @filterAllTopicsOnly.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả chủ đề'**
  String get filterAllTopicsOnly;

  /// No description provided for @balanceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số dư'**
  String get balanceLabel;

  /// No description provided for @noSuitableGroupQuestion.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nhóm phù hợp?'**
  String get noSuitableGroupQuestion;

  /// No description provided for @cannotAddExpenseToArchivedGroup.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm này đã được lưu trữ, không thể thêm khoản chi.'**
  String get cannotAddExpenseToArchivedGroup;

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
  /// **'MÃ MỜI THAM GIA NHÓM'**
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

  /// No description provided for @backAction.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get backAction;

  /// No description provided for @joinGroupQrTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gia nhập bằng mã / QR'**
  String get joinGroupQrTitle;

  /// No description provided for @joinGroupQrSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia nhóm chi tiêu nhanh chóng bằng cách quét mã QR hoặc nhập mã mời'**
  String get joinGroupQrSubtitle;

  /// No description provided for @scanQrTab.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã QR'**
  String get scanQrTab;

  /// No description provided for @enterCodeTab.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã mời'**
  String get enterCodeTab;

  /// No description provided for @scanQrInstruction.
  ///
  /// In vi, this message translates to:
  /// **'Hướng camera vào mã QR của nhóm để gửi yêu cầu gia nhập'**
  String get scanQrInstruction;

  /// No description provided for @testScanQrAction.
  ///
  /// In vi, this message translates to:
  /// **'Quét thử mã QR'**
  String get testScanQrAction;

  /// No description provided for @uploadQrImageAction.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh mã QR'**
  String get uploadQrImageAction;

  /// No description provided for @invalidQrCodeError.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy mã mời hợp lệ trong mã QR.'**
  String get invalidQrCodeError;

  /// No description provided for @noQrFoundInImage.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy mã QR trong ảnh đã chọn.'**
  String get noQrFoundInImage;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng cấp quyền truy cập Camera để quét mã QR.'**
  String get cameraPermissionRequired;

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

  /// No description provided for @changePasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu tài khoản'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật mật khẩu để bảo vệ an toàn cho tài khoản'**
  String get changePasswordSubtitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu hiện tại'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu đang dùng'**
  String get currentPasswordHint;

  /// No description provided for @newPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 6 ký tự'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu mới'**
  String get confirmNewPasswordLabel;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu mới'**
  String get confirmNewPasswordHint;

  /// No description provided for @passwordSafetyTip.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý: Sử dụng mật khẩu kết hợp chữ hoa, chữ thường và chữ số để tăng độ an toàn.'**
  String get passwordSafetyTip;

  /// No description provided for @changePasswordSubmitButton.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePasswordSubmitButton;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu thành công!'**
  String get changePasswordSuccess;

  /// No description provided for @enterCurrentPasswordPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu hiện tại.'**
  String get enterCurrentPasswordPrompt;

  /// No description provided for @enterNewPasswordPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu mới.'**
  String get enterNewPasswordPrompt;

  /// No description provided for @confirmPasswordMismatchPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp.'**
  String get confirmPasswordMismatchPrompt;

  /// No description provided for @newPasswordSameAsCurrentPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới không được trùng với mật khẩu hiện tại.'**
  String get newPasswordSameAsCurrentPrompt;

  /// No description provided for @groupInfoSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'THÔNG TIN NHÓM'**
  String get groupInfoSectionTitle;

  /// No description provided for @tabExpenses.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get tabExpenses;

  /// No description provided for @tabFunds.
  ///
  /// In vi, this message translates to:
  /// **'Quỹ'**
  String get tabFunds;

  /// No description provided for @tabMembers.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên'**
  String get tabMembers;

  /// No description provided for @categoryLabel.
  ///
  /// In vi, this message translates to:
  /// **'THỂ LOẠI'**
  String get categoryLabel;

  /// No description provided for @createdDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'NGÀY TẠO'**
  String get createdDateLabel;

  /// No description provided for @membersCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH VIÊN'**
  String get membersCountLabel;

  /// No description provided for @copyInviteCodeAction.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép mã mời'**
  String get copyInviteCodeAction;

  /// No description provided for @viewQrCodeTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Xem mã QR'**
  String get viewQrCodeTooltip;

  /// No description provided for @inviteMembersTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mời thành viên vào nhóm'**
  String get inviteMembersTitle;

  /// No description provided for @tabQrCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR Code'**
  String get tabQrCode;

  /// No description provided for @tabQrCodeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Quét trực tiếp khi ở cạnh nhau'**
  String get tabQrCodeSubtitle;

  /// No description provided for @tabCopyCode.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép mã mời'**
  String get tabCopyCode;

  /// No description provided for @tabCopyCodeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Gửi mã văn bản qua tin nhắn, Zalo'**
  String get tabCopyCodeSubtitle;

  /// No description provided for @scanToJoinInstruction.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên quét mã này bằng điện thoại để gửi yêu cầu gia nhập'**
  String get scanToJoinInstruction;

  /// No description provided for @downloadQrAction.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh mã QR'**
  String get downloadQrAction;

  /// No description provided for @downloadQrSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu ảnh mã QR thành công!'**
  String get downloadQrSuccess;

  /// No description provided for @downloadQrFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu ảnh mã QR'**
  String get downloadQrFailed;

  /// No description provided for @shareViaOtherAppsAction.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ qua ứng dụng khác'**
  String get shareViaOtherAppsAction;

  /// No description provided for @closeButton.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get closeButton;

  /// No description provided for @yourBalanceInGroupLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số dư của bạn trong nhóm'**
  String get yourBalanceInGroupLabel;

  /// No description provided for @youReceiveBadge.
  ///
  /// In vi, this message translates to:
  /// **'Bạn nhận'**
  String get youReceiveBadge;

  /// No description provided for @youOweBadge.
  ///
  /// In vi, this message translates to:
  /// **'Bạn nợ'**
  String get youOweBadge;

  /// No description provided for @settledBadge.
  ///
  /// In vi, this message translates to:
  /// **'Cân bằng'**
  String get settledBadge;

  /// No description provided for @totalSpendingCard.
  ///
  /// In vi, this message translates to:
  /// **'Tổng chi tiêu'**
  String get totalSpendingCard;

  /// No description provided for @viewReportAction.
  ///
  /// In vi, this message translates to:
  /// **'Xem báo cáo'**
  String get viewReportAction;

  /// No description provided for @fundCollectedCard.
  ///
  /// In vi, this message translates to:
  /// **'Quỹ đã thu'**
  String get fundCollectedCard;

  /// No description provided for @fundGeneralSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Quỹ chung'**
  String get fundGeneralSubtitle;

  /// No description provided for @quickActionsTitle.
  ///
  /// In vi, this message translates to:
  /// **'LỐI TẮT & THAO TÁC NHANH'**
  String get quickActionsTitle;

  /// No description provided for @viewDebtsAction.
  ///
  /// In vi, this message translates to:
  /// **'Xem công nợ'**
  String get viewDebtsAction;

  /// No description provided for @settleDebtsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tất toán nợ'**
  String get settleDebtsSubtitle;

  /// No description provided for @generalFundAction.
  ///
  /// In vi, this message translates to:
  /// **'Quỹ chung'**
  String get generalFundAction;

  /// No description provided for @collectFundSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thu quỹ chung'**
  String get collectFundSubtitle;

  /// No description provided for @addExpenseAction.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khoản chi'**
  String get addExpenseAction;

  /// No description provided for @splitBillSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chia hóa đơn'**
  String get splitBillSubtitle;

  /// No description provided for @groupSettingsAction.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get groupSettingsAction;

  /// No description provided for @accountAndInterfaceSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản & thiết lập'**
  String get accountAndInterfaceSubtitle;

  /// No description provided for @groupAdminSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'QUẢN TRỊ NHÓM'**
  String get groupAdminSectionTitle;

  /// No description provided for @editGroupInfo.
  ///
  /// In vi, this message translates to:
  /// **'Sửa thông tin'**
  String get editGroupInfo;

  /// No description provided for @totalGeneralFundLabel.
  ///
  /// In vi, this message translates to:
  /// **'TỔNG TIỀN QUỸ CHUNG'**
  String get totalGeneralFundLabel;

  /// No description provided for @collectNewFundAction.
  ///
  /// In vi, this message translates to:
  /// **'Thu quỹ mới'**
  String get collectNewFundAction;

  /// No description provided for @fundProgressLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ thu quỹ'**
  String get fundProgressLabel;

  /// No description provided for @searchFundPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm đợt thu quỹ theo tên...'**
  String get searchFundPlaceholder;

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @filterCollecting.
  ///
  /// In vi, this message translates to:
  /// **'Đang thu'**
  String get filterCollecting;

  /// No description provided for @filterCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get filterCompleted;

  /// No description provided for @filterThisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get filterThisMonth;

  /// No description provided for @filterLastMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng trước'**
  String get filterLastMonth;

  /// No description provided for @filterThisQuarter.
  ///
  /// In vi, this message translates to:
  /// **'Quý này'**
  String get filterThisQuarter;

  /// No description provided for @fundEmptyList.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đợt đóng quỹ nào'**
  String get fundEmptyList;

  /// No description provided for @fundEmptySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn \'Thu quỹ mới\' để phát động chiến dịch thu quỹ cho nhóm.'**
  String get fundEmptySubtitle;

  /// No description provided for @createFundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm đợt thu quỹ'**
  String get createFundTitle;

  /// No description provided for @editFundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa đợt đóng quỹ'**
  String get editFundTitle;

  /// No description provided for @fundNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'TÊN ĐỢT THU QUỸ *'**
  String get fundNameLabel;

  /// No description provided for @fundNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Tiền phòng Tháng 11, Quỹ liên hoan...'**
  String get fundNameHint;

  /// No description provided for @quickSuggestionsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý nhanh:'**
  String get quickSuggestionsLabel;

  /// No description provided for @suggestionRoomAndService.
  ///
  /// In vi, this message translates to:
  /// **'+ Tiền phòng & Dịch vụ'**
  String get suggestionRoomAndService;

  /// No description provided for @suggestionYearEndParty.
  ///
  /// In vi, this message translates to:
  /// **'+ Quỹ tiệc tất niên'**
  String get suggestionYearEndParty;

  /// No description provided for @suggestionBirthday.
  ///
  /// In vi, this message translates to:
  /// **'+ Quỹ sinh nhật'**
  String get suggestionBirthday;

  /// No description provided for @suggestionInternetAndWater.
  ///
  /// In vi, this message translates to:
  /// **'+ Tiền mạng & Nước'**
  String get suggestionInternetAndWater;

  /// No description provided for @fundAmountLabel.
  ///
  /// In vi, this message translates to:
  /// **'SỐ TIỀN THU QUỸ *'**
  String get fundAmountLabel;

  /// No description provided for @perPersonMode.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi người'**
  String get perPersonMode;

  /// No description provided for @totalFundMode.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quỹ'**
  String get totalFundMode;

  /// No description provided for @expectedTotalSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thu dự kiến ({count} người):'**
  String expectedTotalSummary(int count);

  /// No description provided for @targetTotalSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tổng mục tiêu:'**
  String get targetTotalSummary;

  /// No description provided for @dueDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'HẠN NỘP (HẠN CHÓT)'**
  String get dueDateLabel;

  /// No description provided for @fundDescriptionLabel.
  ///
  /// In vi, this message translates to:
  /// **'GHI CHÚ / MỤC ĐÍCH THU QUỸ'**
  String get fundDescriptionLabel;

  /// No description provided for @fundDescriptionHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Tiền phòng chuyển chủ nhà trước ngày 10, phạt nếu nộp trễ...'**
  String get fundDescriptionHint;

  /// No description provided for @participatingMembersLabel.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH VIÊN THAM GIA ({selected}/{total})'**
  String participatingMembersLabel(int selected, int total);

  /// No description provided for @selectAll.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tất cả'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chọn'**
  String get deselectAll;

  /// No description provided for @createFundButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo đợt thu quỹ'**
  String get createFundButton;

  /// No description provided for @saveFundButton.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get saveFundButton;

  /// No description provided for @fundDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết đợt đóng quỹ'**
  String get fundDetailTitle;

  /// No description provided for @statusCollectingBadge.
  ///
  /// In vi, this message translates to:
  /// **'ĐANG THU QUỸ'**
  String get statusCollectingBadge;

  /// No description provided for @statusCompletedBadge.
  ///
  /// In vi, this message translates to:
  /// **'HOÀN THÀNH'**
  String get statusCompletedBadge;

  /// No description provided for @closeFundAction.
  ///
  /// In vi, this message translates to:
  /// **'Đóng quỹ'**
  String get closeFundAction;

  /// No description provided for @dueDatePrefix.
  ///
  /// In vi, this message translates to:
  /// **'Hạn chót đóng quỹ: '**
  String get dueDatePrefix;

  /// No description provided for @collectedAmountLabel.
  ///
  /// In vi, this message translates to:
  /// **'ĐÃ THU ĐƯỢC'**
  String get collectedAmountLabel;

  /// No description provided for @targetAmountLabel.
  ///
  /// In vi, this message translates to:
  /// **'MỤC TIÊU'**
  String get targetAmountLabel;

  /// No description provided for @membersPaidRatio.
  ///
  /// In vi, this message translates to:
  /// **'{paid}/{total} thành viên đã nộp'**
  String membersPaidRatio(int paid, int total);

  /// No description provided for @memberPaymentStatusTitle.
  ///
  /// In vi, this message translates to:
  /// **'TRẠNG THÁI NỘP QUỸ CỦA THÀNH VIÊN'**
  String get memberPaymentStatusTitle;

  /// No description provided for @tapToChangeStatusHint.
  ///
  /// In vi, this message translates to:
  /// **'Bấm để đổi trạng thái'**
  String get tapToChangeStatusHint;

  /// No description provided for @statusPaid.
  ///
  /// In vi, this message translates to:
  /// **'Đã nộp'**
  String get statusPaid;

  /// No description provided for @statusUnpaid.
  ///
  /// In vi, this message translates to:
  /// **'Chưa nộp'**
  String get statusUnpaid;

  /// No description provided for @remindAction.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nộp'**
  String get remindAction;

  /// No description provided for @remindCooldownToast.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đợi {seconds}s trước khi gửi nhắc nhở tiếp theo'**
  String remindCooldownToast(int seconds);

  /// No description provided for @confirmMarkPaidTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận nộp quỹ'**
  String get confirmMarkPaidTitle;

  /// No description provided for @confirmMarkPaidMessage.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận thành viên {name} đã đóng {amount} cho đợt quỹ này?'**
  String confirmMarkPaidMessage(String name, String amount);

  /// No description provided for @confirmDeleteFundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa đợt đóng quỹ'**
  String get confirmDeleteFundTitle;

  /// No description provided for @confirmDeleteFundMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa đợt đóng quỹ này? Mọi dữ liệu về trạng thái nộp tiền của các thành viên sẽ bị xóa vĩnh viễn.'**
  String get confirmDeleteFundMessage;

  /// No description provided for @editFundCampaignAction.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa đợt đóng quỹ'**
  String get editFundCampaignAction;

  /// No description provided for @exportFundCsvAction.
  ///
  /// In vi, this message translates to:
  /// **'Xuất báo cáo CSV đợt thu quỹ'**
  String get exportFundCsvAction;

  /// No description provided for @deleteFundCampaignAction.
  ///
  /// In vi, this message translates to:
  /// **'Xóa đợt đóng quỹ này'**
  String get deleteFundCampaignAction;

  /// No description provided for @mustSelectAtLeastOneMember.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn ít nhất một thành viên tham gia.'**
  String get mustSelectAtLeastOneMember;

  /// No description provided for @minFundAmountError.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền mỗi người tối thiểu là 1.000 đ.'**
  String get minFundAmountError;

  /// No description provided for @paidMemberCannotBeRemoved.
  ///
  /// In vi, this message translates to:
  /// **'Không thể bỏ chọn thành viên đã đóng quỹ ({name}).'**
  String paidMemberCannotBeRemoved(String name);

  /// No description provided for @memberListSectionHeader.
  ///
  /// In vi, this message translates to:
  /// **'DANH SÁCH THÀNH VIÊN'**
  String get memberListSectionHeader;

  /// No description provided for @inviteMoreAction.
  ///
  /// In vi, this message translates to:
  /// **'Mời thêm'**
  String get inviteMoreAction;

  /// No description provided for @searchMemberPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm thành viên...'**
  String get searchMemberPlaceholder;

  /// No description provided for @pendingMembersSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH VIÊN CHỜ DUYỆT'**
  String get pendingMembersSectionTitle;

  /// No description provided for @pendingRequestsCountBadge.
  ///
  /// In vi, this message translates to:
  /// **'{count} yêu cầu'**
  String pendingRequestsCountBadge(int count);

  /// No description provided for @pendingRequestsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu gia nhập nhóm đang chờ phê duyệt'**
  String get pendingRequestsSubtitle;

  /// No description provided for @joinRequestLabel.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu tham gia nhóm'**
  String get joinRequestLabel;

  /// No description provided for @rejectAction.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get rejectAction;

  /// No description provided for @approveAction.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt vào nhóm'**
  String get approveAction;

  /// No description provided for @approveJoinTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chấp thuận cho {name} tham gia nhóm?'**
  String approveJoinTitle(String name);

  /// No description provided for @includePastFundsCheckbox.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đóng các đợt quỹ trước đây của nhóm'**
  String get includePastFundsCheckbox;

  /// No description provided for @includePastFundsHint.
  ///
  /// In vi, this message translates to:
  /// **'Nếu chọn, thành viên mới sẽ được thêm vào danh sách phải đóng của tất cả các đợt quỹ đang mở trước đây.'**
  String get includePastFundsHint;

  /// No description provided for @confirmApproveButton.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận duyệt'**
  String get confirmApproveButton;

  /// No description provided for @touchMemberForFinancialHint.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào thành viên để xem chi tiết tài chính & công nợ'**
  String get touchMemberForFinancialHint;

  /// No description provided for @membersCountHeader.
  ///
  /// In vi, this message translates to:
  /// **'{count} thành viên'**
  String membersCountHeader(int count);

  /// No description provided for @youPill.
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get youPill;

  /// No description provided for @roleLeaderBadge.
  ///
  /// In vi, this message translates to:
  /// **'TRƯỞNG NHÓM'**
  String get roleLeaderBadge;

  /// No description provided for @roleMemberBadge.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH VIÊN'**
  String get roleMemberBadge;

  /// No description provided for @roleLeaderFull.
  ///
  /// In vi, this message translates to:
  /// **'TRƯỞNG NHÓM (ADMIN)'**
  String get roleLeaderFull;

  /// No description provided for @roleMemberFull.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH VIÊN (MEMBER)'**
  String get roleMemberFull;

  /// No description provided for @backToGroup.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại nhóm'**
  String get backToGroup;

  /// No description provided for @onTimeDebtRateLabel.
  ///
  /// In vi, this message translates to:
  /// **'TRẢ ĐÚNG H...'**
  String get onTimeDebtRateLabel;

  /// No description provided for @goodRateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tốt'**
  String get goodRateLabel;

  /// No description provided for @onTimeFundRateLabel.
  ///
  /// In vi, this message translates to:
  /// **'ĐÓNG QUỸ Đ...'**
  String get onTimeFundRateLabel;

  /// No description provided for @personalAndAccountInfoSection.
  ///
  /// In vi, this message translates to:
  /// **'THÔNG TIN CÁ NHÂN & TÀI KHOẢN'**
  String get personalAndAccountInfoSection;

  /// No description provided for @bankAccountTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản ngân hàng'**
  String get bankAccountTitle;

  /// No description provided for @vietQrCodeButton.
  ///
  /// In vi, this message translates to:
  /// **'Mã VietQR'**
  String get vietQrCodeButton;

  /// No description provided for @copyAction.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get copyAction;

  /// No description provided for @copiedAccountNumber.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép số tài khoản'**
  String get copiedAccountNumber;

  /// No description provided for @copiedEmail.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép email'**
  String get copiedEmail;

  /// No description provided for @copiedPhone.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép số điện thoại'**
  String get copiedPhone;

  /// No description provided for @groupDebtStatusSection.
  ///
  /// In vi, this message translates to:
  /// **'TRẠNG THÁI CÔNG NỢ TRONG NHÓM'**
  String get groupDebtStatusSection;

  /// No description provided for @totalRefundedByGroup.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số tiền được nhóm hoàn lại:'**
  String get totalRefundedByGroup;

  /// No description provided for @totalToPayGroup.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số tiền cần chi trả cho nhóm:'**
  String get totalToPayGroup;

  /// No description provided for @netResultLabel.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả ròng:'**
  String get netResultLabel;

  /// No description provided for @participatedExpensesSection.
  ///
  /// In vi, this message translates to:
  /// **'CÁC KHOẢN CHI ĐÃ THAM GIA ({count})'**
  String participatedExpensesSection(int count);

  /// No description provided for @paidFullBadge.
  ///
  /// In vi, this message translates to:
  /// **'Chi trả toàn bộ'**
  String get paidFullBadge;

  /// No description provided for @paidByMemberPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Bởi {name}'**
  String paidByMemberPrefix(String name);

  /// No description provided for @memberSharePrefix.
  ///
  /// In vi, this message translates to:
  /// **'Phần chia: {amount}'**
  String memberSharePrefix(String amount);

  /// No description provided for @kickMemberDangerTitle.
  ///
  /// In vi, this message translates to:
  /// **'XÓA THÀNH VIÊN KHỎI NHÓM'**
  String get kickMemberDangerTitle;

  /// No description provided for @kickMemberDangerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa vĩnh viễn thành viên này khỏi nhóm chi tiêu. Thành viên sẽ không còn quyền truy cập vào các khoản chi và công nợ nhóm.'**
  String get kickMemberDangerSubtitle;

  /// No description provided for @kickMemberButton.
  ///
  /// In vi, this message translates to:
  /// **'Kích khỏi nhóm'**
  String get kickMemberButton;

  /// No description provided for @debtWarningTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo khoản nợ chưa tất toán'**
  String get debtWarningTitle;

  /// No description provided for @debtWarningMessage.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên này hiện còn khoản nợ chưa tất toán ({amount}). Nếu xóa khỏi nhóm, khoản nợ này có thể khó thu hồi. Bạn có chắc chắn muốn xóa thành viên khỏi nhóm?'**
  String debtWarningMessage(String amount);

  /// No description provided for @receivableWarningTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo tiền chưa nhận lại'**
  String get receivableWarningTitle;

  /// No description provided for @receivableWarningMessage.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên này hiện đang có khoản tiền chưa được nhận lại ({amount}). Bạn có chắc chắn muốn tiếp tục xóa khỏi nhóm?'**
  String receivableWarningMessage(String amount);

  /// No description provided for @confirmKickMemberTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa thành viên?'**
  String get confirmKickMemberTitle;

  /// No description provided for @confirmKickMemberMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa {fullName} khỏi nhóm \"{groupName}\"?'**
  String confirmKickMemberMessage(String fullName, String groupName);

  /// No description provided for @stillKickButton.
  ///
  /// In vi, this message translates to:
  /// **'Vẫn xóa'**
  String get stillKickButton;

  /// No description provided for @continueKickButton.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục xóa'**
  String get continueKickButton;

  /// No description provided for @confirmKickButton.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa'**
  String get confirmKickButton;

  /// No description provided for @noBankInfoYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật tài khoản ngân hàng'**
  String get noBankInfoYet;

  /// No description provided for @noExpensesYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tham gia khoản chi nào.'**
  String get noExpensesYet;

  /// No description provided for @leaveGroupSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'RỜI KHỎI NHÓM'**
  String get leaveGroupSectionTitle;

  /// No description provided for @leaveGroupSectionSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Rời khỏi nhóm chi tiêu này. Bạn sẽ không thể xem lại các giao dịch và công nợ của nhóm trừ khi được mời lại.'**
  String get leaveGroupSectionSubtitle;

  /// No description provided for @leaveGroupButton.
  ///
  /// In vi, this message translates to:
  /// **'Rời nhóm'**
  String get leaveGroupButton;

  /// No description provided for @leaveGroupConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận rời khỏi nhóm?'**
  String get leaveGroupConfirmTitle;

  /// No description provided for @leaveGroupConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn rời khỏi nhóm \"{groupName}\"?'**
  String leaveGroupConfirmMessage(String groupName);

  /// No description provided for @deleteGroupSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'XÓA NHÓM'**
  String get deleteGroupSectionTitle;

  /// No description provided for @deleteGroupSectionSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa vĩnh viễn nhóm này cùng toàn bộ chi tiêu, nợ và quỹ liên quan khỏi ứng dụng.'**
  String get deleteGroupSectionSubtitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật thông tin cá nhân'**
  String get editProfileTitle;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ và tài khoản nhận tiền VietQR'**
  String get editProfileSubtitle;

  /// No description provided for @fullNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên không được để trống'**
  String get fullNameRequired;

  /// No description provided for @bankNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng nhận tiền (VietQR)'**
  String get bankNameLabel;

  /// No description provided for @bankNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngân hàng từ danh sách'**
  String get bankNameHint;

  /// No description provided for @selectBankPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngân hàng'**
  String get selectBankPrompt;

  /// No description provided for @searchBankHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo tên, viết tắt hoặc mã BIN...'**
  String get searchBankHint;

  /// No description provided for @bankAccountNumberLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số tài khoản ngân hàng'**
  String get bankAccountNumberLabel;

  /// No description provided for @bankAccountNumberHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tài khoản ngân hàng'**
  String get bankAccountNumberHint;

  /// No description provided for @bankAccountNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên chủ tài khoản'**
  String get bankAccountNameLabel;

  /// No description provided for @bankAccountNameHint.
  ///
  /// In vi, this message translates to:
  /// **'NGUYEN VAN A (in hoa không dấu)'**
  String get bankAccountNameHint;

  /// No description provided for @tapToViewQrHint.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để xem mã VietQR'**
  String get tapToViewQrHint;

  /// No description provided for @tapToSetupBankHint.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để thiết lập tài khoản'**
  String get tapToSetupBankHint;

  /// No description provided for @changeAvatarPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh đại diện'**
  String get changeAvatarPrompt;

  /// No description provided for @chooseFromGallery.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ thư viện'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh mới'**
  String get takePhoto;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật thông tin cá nhân thành công!'**
  String get updateProfileSuccess;

  /// No description provided for @imageTooLargeError.
  ///
  /// In vi, this message translates to:
  /// **'Kích thước ảnh đại diện vượt quá 10MB. Vui lòng chọn ảnh khác.'**
  String get imageTooLargeError;

  /// No description provided for @loadBanksFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải danh sách ngân hàng. Vui lòng kiểm tra kết nối mạng.'**
  String get loadBanksFailed;

  /// No description provided for @noBanksFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy ngân hàng phù hợp'**
  String get noBanksFound;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập địa chỉ email của bạn để nhận mã xác thực đặt lại mật khẩu.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetCodeButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi mã xác thực'**
  String get sendResetCodeButton;

  /// No description provided for @backToLogin.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại đăng nhập'**
  String get backToLogin;

  /// No description provided for @verifyResetPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực đặt lại mật khẩu'**
  String get verifyResetPasswordTitle;

  /// No description provided for @verifyResetPasswordSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mã bảo mật 8 ký tự đã được gửi đến hộp thư:'**
  String get verifyResetPasswordSubtitle;

  /// No description provided for @resetOtpInputLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác thực 8 ký tự'**
  String get resetOtpInputLabel;

  /// No description provided for @resetOtpInputHint.
  ///
  /// In vi, this message translates to:
  /// **'8 ký tự chữ và số (VD: 47285BAF)'**
  String get resetOtpInputHint;

  /// No description provided for @verifyAndProceedButton.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mã & Đặt lại mật khẩu'**
  String get verifyAndProceedButton;

  /// No description provided for @resendCodeIn.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã sau '**
  String get resendCodeIn;

  /// No description provided for @resendCodeNow.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã'**
  String get resendCodeNow;

  /// No description provided for @setNewPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu mới'**
  String get setNewPasswordTitle;

  /// No description provided for @setNewPasswordSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập mật khẩu mới cho tài khoản email:'**
  String get setNewPasswordSubtitle;

  /// No description provided for @savePasswordButton.
  ///
  /// In vi, this message translates to:
  /// **'Lưu mật khẩu mới & Đăng nhập'**
  String get savePasswordButton;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có tối thiểu 6 ký tự.'**
  String get passwordMinLengthError;

  /// No description provided for @resetPasswordSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu thành công! Vui lòng đăng nhập bằng mật khẩu mới.'**
  String get resetPasswordSuccessMessage;

  /// No description provided for @otpInvalidError.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác thực không hợp lệ hoặc đã hết hạn.'**
  String get otpInvalidError;

  /// No description provided for @otpCodeLockedError.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác thực đã bị khóa do nhập sai quá 5 lần. Vui lòng yêu cầu mã mới.'**
  String get otpCodeLockedError;

  /// No description provided for @resetTokenExpiredError.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đặt lại mật khẩu đã hết hạn (5 phút). Vui lòng thực hiện lại từ đầu.'**
  String get resetTokenExpiredError;

  /// No description provided for @resendRateLimitError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chờ hết thời gian đếm ngược trước khi yêu cầu gửi lại mã.'**
  String get resendRateLimitError;
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
