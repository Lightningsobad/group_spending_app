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

  @override
  String get financialOverviewTitle => 'FINANCIAL BALANCE OVERVIEW';

  @override
  String get youOwe => 'You owe';

  @override
  String get paySoonSubtitle => 'Due soon';

  @override
  String get youAreOwed => 'You receive';

  @override
  String get friendsOweYouSubtitle => 'Friends owe you';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addExpenseFeatureNotice =>
      'Add expense feature is being integrated.';

  @override
  String get createGroupAction => 'Create group';

  @override
  String get codeOrQrAction => 'Code / QR';

  @override
  String get yourGroupsSection => 'YOUR GROUPS';

  @override
  String seeAllGroupsCount(int count) {
    return 'See all ($count)';
  }

  @override
  String get noGroupsJoinedTitle => 'You haven\'t joined any groups yet';

  @override
  String get noGroupsJoinedSubtitle =>
      'Create a new group or join with an invite code to start splitting expenses with friends!';

  @override
  String get createGroupNow => 'Create a group now';

  @override
  String notificationsToggledForGroup(String name) {
    return 'Notifications updated for \"$name\".';
  }

  @override
  String get groupListHeaderTitle => 'Your group list';

  @override
  String get searchGroupPlaceholder => 'Search by group name, category...';

  @override
  String filterAllCount(int count) {
    return 'All ($count)';
  }

  @override
  String filterActiveCount(int count) {
    return 'Active ($count)';
  }

  @override
  String filterArchivedCount(int count) {
    return 'Archived ($count)';
  }

  @override
  String filterAdminCount(int count) {
    return 'Managed by me ($count)';
  }

  @override
  String get noMatchingGroupsTitle => 'No matching groups found';

  @override
  String get noMatchingGroupsSubtitle =>
      'Try searching with a different keyword or change filter.';

  @override
  String get noGroupsInTabTitle => 'No groups in this section';

  @override
  String get noGroupsInTabSubtitle =>
      'Tap \"+ Create new group\" to start your first group!';

  @override
  String get createGroupTitle => 'Create new expense group';

  @override
  String get createGroupSubtitle =>
      'Enter group name and category to manage shared expenses.';

  @override
  String get groupNameLabel => 'Expense group name *';

  @override
  String get groupNameHint => 'Enter group name (e.g., Dalat Trip, Apt 402...)';

  @override
  String get groupDescLabel => 'Group description (Optional)';

  @override
  String get groupDescHint =>
      'Enter a brief note about this group\'s expenses...';

  @override
  String get groupCategoryLabel => 'Group category';

  @override
  String get defaultCurrencyLabel => 'Default currency';

  @override
  String get groupNameRequired => 'Please enter a group name.';

  @override
  String get joinGroupTitle => 'Join group via invite code';

  @override
  String get joinGroupSubtitle =>
      'Enter a 6-12 character code to join your friends\' group.';

  @override
  String get inviteCodeLabel => 'Group invite code *';

  @override
  String get inviteCodeHint => 'E.g., DALAT2024, ROOM402...';

  @override
  String get inviteCodeRequired => 'Please enter an invite code.';

  @override
  String get joinGroupButton => 'Join group';

  @override
  String get groupDetailTitle => 'Group details';

  @override
  String get groupInviteCodePrefix => 'Group code:';

  @override
  String get codeCopiedToClipboard => 'Invite code copied to clipboard';

  @override
  String get copyCodeTooltip => 'Copy code';

  @override
  String get archiveGroupAction => 'Archive group';

  @override
  String get archiveGroupConfirmTitle => 'Confirm archiving group?';

  @override
  String get archiveGroupConfirmMessage =>
      'Group will be moved to archives and become read-only.';

  @override
  String get archiveConfirmButton => 'Archive';

  @override
  String get deleteGroupAction => 'Delete group';

  @override
  String get deleteGroupConfirmTitle => 'Confirm permanent deletion?';

  @override
  String get deleteGroupConfirmMessage =>
      'This action will permanently remove all expenses, debts, funds, and member records. Cannot be undone!';

  @override
  String get deleteConfirmButton => 'Delete group';

  @override
  String get editGroupTitle => 'Edit group information';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get groupMembersTitle => 'Group members';

  @override
  String get loadDashboardFailed => 'Failed to load dashboard overview';

  @override
  String get loadGroupsFailed => 'Failed to load group list';

  @override
  String get createGroupSuccess => 'Group created successfully!';

  @override
  String get updateGroupSuccess => 'Group updated successfully!';

  @override
  String get archiveGroupSuccess => 'Group has been moved to archives.';

  @override
  String get deleteGroupSuccess => 'Group deleted successfully.';

  @override
  String get joinGroupSuccess => 'Joined group successfully!';

  @override
  String get editGroupAction => 'Edit group';

  @override
  String get inviteCodeCardTitle => 'INVITE CODE';

  @override
  String get groupFinancialOverviewTitle => 'GROUP FINANCIAL OVERVIEW';

  @override
  String get yourBalanceLabel => 'Your balance:';

  @override
  String get totalGroupSpendingLabel => 'Total group spending:';

  @override
  String get totalFundCollectedLabel => 'Total fund collected:';

  @override
  String groupMembersCountTitle(int count) {
    return 'MEMBERS ($count)';
  }

  @override
  String groupMemberCountSimple(int count) {
    return 'Group has $count members';
  }

  @override
  String get deleteGroupPermanently => 'Delete group permanently';

  @override
  String get backAction => 'Back';

  @override
  String get joinGroupQrTitle => 'Join via Code / QR';

  @override
  String get joinGroupQrSubtitle =>
      'Quickly join a group by scanning a QR code or entering an invite code';

  @override
  String get scanQrTab => 'Scan QR Code';

  @override
  String get enterCodeTab => 'Enter Invite Code';

  @override
  String get scanQrInstruction =>
      'Point your camera at the group\'s QR code to send a join request';

  @override
  String get testScanQrAction => 'Test Scan QR';

  @override
  String get uploadQrImageAction => 'Upload QR Image';

  @override
  String get invalidQrCodeError =>
      'No valid invite code found in this QR code.';

  @override
  String get noQrFoundInImage => 'No QR code found in the selected image.';

  @override
  String get cameraPermissionRequired =>
      'Please grant camera permission to scan QR codes.';
  String get tabAnalyticsTitle => 'Reports & Statistics';

  @override
  String get totalSpendingAllGroups => 'Total spending all groups';

  @override
  String get activeGroupsJoinedCount => 'Active groups joined';

  @override
  String get groupsUnit => 'groups';

  @override
  String get totalInvoicesRecorded => 'Recorded expenses';

  @override
  String get invoicesUnit => 'invoices';

  @override
  String get overallReportBannerTitle => 'Overall Report';

  @override
  String get viewOverallReportAction => 'View Overview';

  @override
  String get searchGroupByHint => 'Search group by name, category...';

  @override
  String filterAllTab(int count) {
    return 'All ($count)';
  }

  @override
  String get filterActiveTab => 'Active';

  @override
  String get filterArchivedTab => 'Archived';

  @override
  String get groupSpendingListTitle => 'GROUP SPENDING LIST';

  @override
  String get totalSpendingLabel => 'Total spending';

  @override
  String get overallReportTitle => 'Overall Report';

  @override
  String get overallReportSubtitle => 'Summary of all active groups';

  @override
  String get financialMetricsTitle => 'GROUP FINANCIAL METRICS';

  @override
  String get totalSpendingMetric => 'Total spending amount';

  @override
  String get commonGroupSpendingSubtitle => 'Shared spending across groups';

  @override
  String get averagePerPersonMetric => 'Average per person';

  @override
  String get splitEquallySubtitle => 'Split equally per member';

  @override
  String friendsCountBadge(int count) {
    return '÷ $count friends';
  }

  @override
  String get expenseCountMetric => 'Expense count';

  @override
  String get invoicesBadge => 'Invoices';

  @override
  String get expensesUnit => 'expenses';

  @override
  String get recordedAndAuditedSubtitle => 'Recorded & verified';

  @override
  String get settlementRateMetric => 'Settlement rate';

  @override
  String get paidRateSuffix => 'paid';

  @override
  String get groupDebtLabel => 'Group debt';

  @override
  String remainingDebtRate(String percent) {
    return '$percent% remaining';
  }

  @override
  String get categoryDistributionTitle => 'CATEGORY DISTRIBUTION';

  @override
  String get memberContributionTitle => 'MEMBER CONTRIBUTIONS';

  @override
  String contributionPercent(String percent) {
    return '$percent% of total spending';
  }

  @override
  String get recentExpensesTitle => 'RECENT EXPENSES';

  @override
  String expensesCountBadge(int count) {
    return '$count items';
  }

  @override
  String paidByPrefix(String name) {
    return 'Paid by: $name';
  }

  @override
  String get viewExpenseDetailAction => 'Details →';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodCurrentQuarter => 'This quarter';

  @override
  String get periodByYear => 'Full year';

  @override
  String membersCountSubtitle(int memberCount) {
    return '$memberCount members';
  }

  @override
  String get noExpensesRecorded => 'No expenses recorded yet.';

  @override
  String get noCategoriesRecorded => 'No category data available.';

  @override
  String get noLeaderboardData => 'No contribution data available.';

  @override
  String get loadAnalyticsFailed => 'Failed to load analytics data';

  @override
  String get retryAction => 'Retry';

  @override
  String get youLabel => '(Me)';
  String get debtsGroupTitle => 'Debts by Group';

  @override
  String get debtsYouOwe => 'You owe';

  @override
  String get debtsYouOweSubtitle => 'Total amount you need to pay';

  @override
  String get debtsYouReceive => 'You receive';

  @override
  String get debtsYouReceiveSubtitle => 'Friends owe you';

  @override
  String get searchDebtGroupPlaceholder => 'Search group by name, category...';

  @override
  String filterDebtAllCount(int count) {
    return 'All groups ($count)';
  }

  @override
  String filterDebtHasDebtCount(int count) {
    return 'Has debt ($count)';
  }

  @override
  String filterDebtSettledCount(int count) {
    return 'Settled ($count)';
  }

  @override
  String debtsPendingCount(int count) {
    return '$count debts need settlement';
  }

  @override
  String get debtsSettledAll => 'All settled';

  @override
  String get debtsBalanced => 'Balanced (0 đ)';

  @override
  String get badgeYouReceive => 'You receive';

  @override
  String get badgeYouMustPay => 'You need to pay';

  @override
  String get badgeBalanced => 'Balanced';

  @override
  String get simplifiedDebtsTab => 'Simplified Debts';

  @override
  String get actualDebtsTab => 'Actual Debts';

  @override
  String get simplifiedDebtsBanner =>
      'Optimize cash flow transactions for fastest settlement.';

  @override
  String get actualDebtsBanner =>
      'Detailed debts arising from each bill and spending item.';

  @override
  String debtsToHandleCount(int count) {
    return '$count DEBTS NEED SETTLEMENT';
  }

  @override
  String get simplifiedDebtAlgorithm => 'Simplified debt algorithm';

  @override
  String get payNowAction => 'Pay now (100%)';

  @override
  String get confirmReceivedAction => 'Confirm received';

  @override
  String get rejectReceivedAction => 'Decline';

  @override
  String get remindDebtAction => 'Remind';

  @override
  String get debtStatusPending => 'Unpaid';

  @override
  String get debtStatusWaiting => 'Awaiting confirmation';

  @override
  String get debtStatusSettled => 'Settled';

  @override
  String get debtorLabel => 'Debtor';

  @override
  String get creditorLabel => 'Creditor';

  @override
  String get youTag => 'You';

  @override
  String get backAction => 'Back';

  @override
  String get yourBalanceInGroup => 'Your balance in group:';

  @override
  String get noDebtGroupsTitle => 'No debt groups';

  @override
  String get noDebtGroupsSubtitle =>
      'You currently have no pending debts to handle.';

  @override
  String get noMatchingDebtGroupsTitle => 'No matching groups found';

  @override
  String get noMatchingDebtGroupsSubtitle =>
      'Try searching with other keywords or change filter.';

  @override
  String get confirmPayDebtTitle => 'Confirm payment sent';

  @override
  String confirmPayDebtMessage(String creditor, String amount) {
    return 'Have you transferred or paid in cash to $creditor the amount of $amount?';
  }

  @override
  String get confirmReceiveDebtTitle => 'Confirm money received';

  @override
  String confirmReceiveDebtMessage(String debtor, String amount) {
    return 'Have you received $amount from $debtor?';
  }

  @override
  String get rejectReceiveDebtTitle => 'Decline payment confirmation';

  @override
  String rejectReceiveDebtMessage(String debtor) {
    return 'You have not received this payment and want to ask $debtor to check again?';
  }

  @override
  String get confirmRemindDebtTitle => 'Send debt reminder';

  @override
  String confirmRemindDebtMessage(String debtor, String amount) {
    return 'Send a reminder notification for debt of $amount to $debtor?';
  }

  @override
  String get noDebtsInGroupTitle => 'No debts in this group';

  @override
  String get noDebtsInGroupSubtitle =>
      'All expenses in this group are balanced or no debts have incurred.';
}
