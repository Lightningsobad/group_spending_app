// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FairShare';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get underDevelopment => 'This feature is under development.';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get splashSlogan =>
      'Transparent expense sharing & smart debt reminders';

  @override
  String get authHeaderTitle => 'Group Expense Management\n& Reminders';

  @override
  String get authHeaderSubtitle =>
      'Transparent sharing, gentle reminders, easy fund pooling.';

  @override
  String get loginTab => 'Log In';

  @override
  String get registerTab => 'Sign Up';

  @override
  String get orLoginWithEmail => 'OR LOG IN WITH EMAIL';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Log In to App';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get registerNow => 'Sign up now';

  @override
  String get orRegisterWithEmail => 'OR SIGN UP WITH EMAIL';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneOptionalTag => '(Optional)';

  @override
  String get phoneHint => 'Enter phone number';

  @override
  String get registerButton => 'Create New Account';

  @override
  String get hasAccountPrompt => 'Already have an account? ';

  @override
  String get loginNow => 'Log In';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get googleAuthNotice => 'Google login feature is under development.';

  @override
  String get forgotPasswordNotice =>
      'Forgot password support feature is coming soon.';

  @override
  String get enterEmailPrompt => 'Please enter your email address.';

  @override
  String get enterPasswordPrompt => 'Please enter your password.';

  @override
  String get enterFullNamePrompt => 'Please enter your full name.';

  @override
  String get passwordMinLengthPrompt =>
      'Password must be at least 6 characters.';

  @override
  String get otpTitle => 'Verify Email Address';

  @override
  String get otpSubtitle =>
      'A 6-digit secure OTP code has been sent to your inbox';

  @override
  String get otpInputLabel => 'OTP verification code';

  @override
  String get otpDigitsHint => '6 secure digits';

  @override
  String get verifyAndActivate => 'Verify & Activate';

  @override
  String get enterFullOtpPrompt =>
      'Please enter all 6 digits of the OTP verification code.';

  @override
  String get resendOtpPrompt => 'Didn\'t receive the code? ';

  @override
  String get resendOtpNow => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in (${seconds}s)';
  }

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step/$total';
  }

  @override
  String get skip => 'Skip';

  @override
  String get onboardingSlide1Pill => 'Group Management';

  @override
  String get onboardingSlide1Title => 'CONNECT & MANAGE GROUPS';

  @override
  String get onboardingSlide1Desc =>
      'Easily manage friends, trip expenses and daily living costs transparently and fairly.';

  @override
  String get onboardingSlide2Pill => 'Expense Management';

  @override
  String get onboardingSlide2Title => 'SMART EXPENSE TRACKING';

  @override
  String get onboardingSlide2Desc =>
      'Record expenses swiftly, visualize charts, split bills evenly, and optimize net debts automatically.';

  @override
  String get onboardingSlide3Pill => 'Fund Management';

  @override
  String get onboardingSlide3Title => 'TRANSPARENT GROUP FUNDS';

  @override
  String get onboardingSlide3Desc =>
      'Collect group funds conveniently, track contributions in real time, and manage budget with 100% clarity.';

  @override
  String get onboardingSlide4Pill => 'Reminders & Payment';

  @override
  String get onboardingSlide4Title => 'SPEEDY REMINDERS & PAYMENTS';

  @override
  String get onboardingSlide4Desc =>
      'Send delicate debt reminder nudges, scan VietQR with auto-filled accounts, and settle balances in seconds.';

  @override
  String get greeting => 'Hello,';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabGroups => 'Groups';

  @override
  String get tabDebts => 'Debts';

  @override
  String get tabAnalytics => 'Analytics';

  @override
  String get tabSettings => 'Settings';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'You have no new notifications.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get roleAdmin => 'Group Leader (Admin)';

  @override
  String get roleMember => 'Member';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get vietqrTitle => 'PAYMENT RECEIVING ACCOUNT (VIETQR)';

  @override
  String get defaultBankInfo => 'Techcombank - 19034829104018';

  @override
  String get defaultAccountName => 'NGUYEN NHAT MINH';

  @override
  String get appearanceLanguageSection => 'APPEARANCE & LANGUAGE';

  @override
  String get themeModeTitle => 'Theme Mode';

  @override
  String get themeLightSubtitle => 'Light surface #F8FAFC';

  @override
  String get themeDarkSubtitle => 'Dark surface #0F172A';

  @override
  String get lightThemeLabel => 'Light';

  @override
  String get darkThemeLabel => 'Dark';

  @override
  String get displayLanguageTitle => 'Display Language';

  @override
  String get displayLanguageSubtitle => 'English (All labels)';

  @override
  String get infoSupportSection => 'INFO & SUPPORT';

  @override
  String get aboutAppTitle => 'About FairShare';

  @override
  String get aboutAppSubtitle =>
      'Replay onboarding feature introduction slides';

  @override
  String get privacyPolicyTitle => 'Privacy Policy & Data Safety';

  @override
  String get privacyPolicySubtitle =>
      'Commitment to encryption and account protection (Details)';

  @override
  String get logoutButton => 'Log out account';

  @override
  String get logoutTooltip => 'Log out';

  @override
  String get logoutConfirmTitle => 'Are you sure you want to log out?';
}
