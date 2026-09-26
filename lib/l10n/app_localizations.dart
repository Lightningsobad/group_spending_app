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
