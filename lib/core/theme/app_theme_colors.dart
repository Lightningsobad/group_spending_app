import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Quản lý tập trung toàn bộ mã màu cho 2 theme Light và Dark của các thành phần trong toàn ứng dụng.
/// Sử dụng thông qua: `context.colors.<tên_màu>` hoặc `AppThemeColors.of(context).<tên_màu>`.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  // Nền và thẻ
  final Color background;
  final Color cardBackground;
  final Color cardBorder;
  final Color surfaceMuted;
  final Color segmentBackground;
  final Color segmentActiveBackground;
  final Color activePillBackground;
  final Color activePillText;
  final Color activePillBorder;
  final Color adminBadgeBackground;
  final Color adminBadgeBorder;
  final Color adminBadgeText;
  final Color memberBadgeBackground;
  final Color memberBadgeBorder;
  final Color memberBadgeText;

  // Lỗi & cảnh báo
  final Color errorSurface;
  final Color errorBorder;

  // Phân cách & Viền
  final Color divider;
  final Color avatarDotBorder;

  // Chữ & Icon
  final Color textPrimary;
  final Color textSecondary;
  final Color textSlate800;
  final Color textMuted;
  final Color iconPrimary;
  final Color themeToggleIcon;

  // Bóng đổ
  final Color cardShadowColor;
  final BoxShadow cardShadow;
  final BoxShadow bottomNavShadow;

  // Bottom Nav
  final Color bottomNavBackground;
  final Color bottomNavBorder;
  final Color bottomNavInactive;

  // Analytics & Thống kê
  final Color analyticsAccent;
  final Color analyticsIconBg;
  final Color bannerBackground;
  final Color bannerBorder;

  // Badges & Chỉ số
  final Color badgeSuccessBg;
  final Color badgeSuccessText;
  final Color badgeWarningBg;
  final Color badgeWarningText;
  final Color badgeInfoBg;
  final Color badgeInfoText;

  // Xếp hạng (Leaderboard Ranks)
  final Color rankGoldBg;
  final Color rankGoldText;
  final Color rankSilverBg;
  final Color rankSilverText;
  final Color rankBronzeBg;
  final Color rankBronzeText;
  // Semantic Brand & Badges (Centralized Light / Dark Tokens)
  final Color brandEmerald;
  final Color brandEmeraldBorder;
  final Color brandEmeraldMuted;
  final Color badgeAmber;
  final Color badgeAmberBg;
  final Color badgeIndigo;
  final Color badgeIndigoBg;
  final Color badgeSuccess;
  final Color inputBackground;
  final Color dragHandle;
  // Semantic UI Containers & Actions
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primaryButton;
  final Color onPrimaryButton;
  final Color secondaryActionBg;
  final Color secondaryActionBorder;
  final Color secondaryActionText;

  // Pill Tabs
  final Color tabPillActiveBg;
  final Color tabPillActiveText;

  // Role & Status Badges
  final Color roleAdminBg;
  final Color roleAdminText;
  final Color roleAdminBorder;
  final Color statusActiveBg;
  final Color statusActiveText;
  final Color statusArchivedBg;
  final Color statusArchivedText;
  // Form & Ô nhập liệu (Auth & Dialogs)
  final Color inputFill;
  final Color inputBorder;

  // Nút mạng xã hội (Social Auth)
  final Color socialButtonBg;
  final Color socialButtonBorder;

  // Ô nhập mã OTP
  final Color otpBoxBg;
  final Color otpBoxFilledBg;
  final Color otpBoxBorder;

  // SnackBar Tokens (Success, Error, Warning, Info)
  final Color snackBarSuccessBg;
  final Color snackBarSuccessBorder;
  final Color snackBarSuccessBadge;
  final Color snackBarSuccessIcon;
  final Color snackBarSuccessText;

  final Color snackBarErrorBg;
  final Color snackBarErrorBorder;
  final Color snackBarErrorBadge;
  final Color snackBarErrorIcon;
  final Color snackBarErrorText;

  final Color snackBarWarningBg;
  final Color snackBarWarningBorder;
  final Color snackBarWarningBadge;
  final Color snackBarWarningIcon;
  final Color snackBarWarningText;

  final Color snackBarInfoBg;
  final Color snackBarInfoBorder;
  final Color snackBarInfoBadge;
  final Color snackBarInfoIcon;
  final Color snackBarInfoText;


  // Group Member & Details Semantic Tokens
  final Color memberHeroCardBg;
  final Color memberHeroCardBorder;
  final Color memberStatsBoxBg;
  final Color memberStatsBoxBorder;
  final Color memberOnlineDot;
  final Color memberAvatarBorder;
  final Color badgeWarningIcon;
  final Color dangerSurface;
  final Color dangerBorder;
  final Color dangerIconBg;
  final Color dangerText;
  final Color infoIconBg;
  final Color infoIconColor;

  // Fund Tab Tokens
  final Color fundPiggyBg;
  final Color fundPiggyIcon;
  final Color fundStatusCollectingBg;
  final Color fundStatusCollectingText;
  final Color fundStatusCompletedBg;
  final Color fundStatusCompletedText;
  final Color fundAmountText;
  final Color fundProgressStart;
  final Color fundProgressEnd;
  final Color fundProgressText;
  final Color fundStatusUnpaidBg;
  final Color fundStatusUnpaidText;
  final Color fundRemindButtonBg;
  final Color fundRemindButtonBorder;
  final Color fundRemindButtonIcon;
  final Color fundEditButtonBg;
  final Color fundEditButtonFg;
  final Color fundEditButtonBorder;
  final Color fundCsvButtonBg;
  final Color fundCsvButtonFg;
  final Color fundCsvIcon;
  // Thẻ Chi tiêu (Expense Card & Category)
  final Color expenseCategoryIconBg;
  final Color expenseCategoryIcon;
  final Color expenseCategoryTag;
  final Color expenseBadgeOwedBg;
  final Color expenseBadgeOwedBorder;
  final Color expenseBadgeOwedText;
  // Shimmer Tokens
  final Color shimmerBase;
  final Color shimmerHighlight;

  // Accent Actions & Status Tokens
  final Color warningAccent;
  final Color warningAccentBorder;
  final Color infoAccent;
  final Color orangeAccent;
  final Color errorAccent;
  // --- Debt Feature Semantic Tokens ---
  final Color debtOweBg;
  final Color debtOweBorder;
  final Color debtOweText;
  final Color debtOweAmount;
  final Color debtReceiveBg;
  final Color debtReceiveBorder;
  final Color debtReceiveText;
  final Color debtReceiveAmount;
  final Color debtBalancedBg;
  final Color debtBalancedText;
  final Color debtPendingBg;
  final Color debtPendingText;
  final Color debtWaitingBg;
  final Color debtWaitingText;
  final Color debtHintBg;
  final Color debtHintBorder;
  final Color debtHintText;
  final Color debtChipBg;
  final Color debtAvatarBg;
  final Color debtYouBadgeBorder;
  final Color debtTabBadgeActiveBg;
  final Color debtTabBadgeActiveText;
  final Color debtTabBadgeInactiveBg;
  final Color debtTabBadgeInactiveText;
  final Color debtActionPayBg;
  final Color debtActionConfirmBg;
  final Color debtActionRejectFg;
  final Color debtActionRejectBorder;
  final Color debtActionRemindIcon;
  final Color debtIconContainerBg;
  final Color debtIconContainerBorder;
  final Color debtIconContainerFg;
  final Color debtStatusSettledDot;
  final Color debtStatusPendingDot;
  final Color debtStatusWaitingDot;
  final Color filterChipActiveBg;
  final Color filterChipActiveText;

  // Expense Form, Scanner & Keypad Semantic Tokens
  final Color keypadDigitBg;
  final Color keypadDigitText;
  final Color keypadActionBg;
  final Color keypadActionText;
  final Color keypadClearBg;
  final Color keypadClearText;
  final Color keypadDeleteBg;
  final Color keypadDeleteText;
  final Color scannerHighlightBg;
  final Color scannerHighlightBorder;
  final Color scannerHighlightText;
  final Color expenseCardSelectedBg;
  final Color expenseCardSelectedBorder;

  // Expense Detail Semantic Tokens
  final Color expenseHeroAmount;
  final Color expenseCategoryTagBg;
  final Color expenseCategoryTagBorder;
  final Color expenseCategoryTagText;
  final Color expensePayerBadgeBg;
  final Color expensePayerBadgeText;
  final Color expensePayerAdvanceText;
  final Color expenseSplitPaidBg;
  final Color expenseSplitPaidText;
  final Color expenseSplitUnpaidBg;
  final Color expenseSplitUnpaidText;
  final Color expenseSplitPendingBg;
  final Color expenseSplitPendingText;
  final Color expenseActionEditBg;
  final Color expenseActionEditBorder;
  final Color expenseActionEditText;
  final Color expenseActionDeleteBg;
  final Color expenseActionDeleteBorder;
  final Color expenseActionDeleteText;
  final Color expenseQuickDeleteBg;
  final Color expenseQuickDeleteFg;
  final Color expenseReceiptZoomText;

  // Scanner & QR Mockup Tokens
  final Color scannerBackground;
  final Color scannerCorner;
  final Color qrMockupCard;
  final Color qrMockupFinder;
  final Color qrMockupDot;

  // QR & Group Invite Semantic Tokens
  final Color qrCardBg;
  final Color qrCardBorder;
  final Color qrQuietZoneBg;
  final Color qrQuietZoneBorder;
  final Color qrTabActiveBg;
  final Color qrTabActiveBorder;
  final Color qrTabIconActiveBg;
  final Color qrCodeForeground;
  final Color qrShareButtonBg;
  final Color qrShareButtonFg;
  final Color inviteBannerBg;
  final Color inviteBannerBorder;
  final Color inviteBannerTitle;
  final Color inviteBannerButtonBg;
  final Color inviteBannerButtonFg;

  // Financial Balance Card Semantic Tokens
  final Color financialCardBgStart;
  final Color financialCardBgMiddle;
  final Color financialCardBgEnd;
  final Color financialCardBorder;
  final BoxShadow financialCardShadow;
  final Color financialCardIconBg;
  final Color financialCardIcon;
  final Color financialCardTitle;
  final Color financialCardEyeToggle;
  final Color financialCardBoxBg;
  final Color financialCardBoxBorder;
  final Color financialCardOweIcon;
  final Color financialCardOweLabel;
  final Color financialCardOweAmount;
  final Color financialCardOweSubtitle;
  final Color financialCardReceiveIcon;
  final Color financialCardReceiveLabel;
  final Color financialCardReceiveAmount;
  final Color financialCardReceiveSubtitle;

  const AppThemeColors({
    required this.background,
    required this.cardBackground,
    required this.cardBorder,
    required this.surfaceMuted,
    required this.segmentBackground,
    required this.segmentActiveBackground,
    required this.activePillBackground,
    required this.activePillText,
    required this.activePillBorder,
    required this.adminBadgeBackground,
    required this.adminBadgeBorder,
    required this.adminBadgeText,
    required this.memberBadgeBackground,
    required this.memberBadgeBorder,
    required this.memberBadgeText,
    required this.errorSurface,
    required this.errorBorder,
    required this.divider,
    required this.avatarDotBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textSlate800,
    required this.textMuted,
    required this.iconPrimary,
    required this.themeToggleIcon,
    required this.cardShadowColor,
    required this.cardShadow,
    required this.bottomNavShadow,
    required this.bottomNavBackground,
    required this.bottomNavBorder,
    required this.bottomNavInactive,
    required this.analyticsAccent,
    required this.analyticsIconBg,
    required this.bannerBackground,
    required this.bannerBorder,
    required this.badgeSuccessBg,
    required this.badgeSuccessText,
    required this.badgeWarningBg,
    required this.badgeWarningText,
    required this.badgeInfoBg,
    required this.badgeInfoText,
    required this.rankGoldBg,
    required this.rankGoldText,
    required this.rankSilverBg,
    required this.rankSilverText,
    required this.rankBronzeBg,
    required this.rankBronzeText,
    required this.brandEmerald,
    required this.brandEmeraldBorder,
    required this.brandEmeraldMuted,
    required this.badgeAmber,
    required this.badgeAmberBg,
    required this.badgeIndigo,
    required this.badgeIndigoBg,
    required this.badgeSuccess,
    required this.inputBackground,
    required this.dragHandle,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryButton,
    required this.onPrimaryButton,
    required this.secondaryActionBg,
    required this.secondaryActionBorder,
    required this.secondaryActionText,
    required this.tabPillActiveBg,
    required this.tabPillActiveText,
    required this.roleAdminBg,
    required this.roleAdminText,
    required this.roleAdminBorder,
    required this.statusActiveBg,
    required this.statusActiveText,
    required this.statusArchivedBg,
    required this.statusArchivedText,
    required this.inputFill,
    required this.inputBorder,
    required this.socialButtonBg,
    required this.socialButtonBorder,
    required this.otpBoxBg,
    required this.otpBoxFilledBg,
    required this.otpBoxBorder,
    required this.snackBarSuccessBg,
    required this.snackBarSuccessBorder,
    required this.snackBarSuccessBadge,
    required this.snackBarSuccessIcon,
    required this.snackBarSuccessText,
    required this.snackBarErrorBg,
    required this.snackBarErrorBorder,
    required this.snackBarErrorBadge,
    required this.snackBarErrorIcon,
    required this.snackBarErrorText,
    required this.snackBarWarningBg,
    required this.snackBarWarningBorder,
    required this.snackBarWarningBadge,
    required this.snackBarWarningIcon,
    required this.snackBarWarningText,
    required this.snackBarInfoBg,
    required this.snackBarInfoBorder,
    required this.snackBarInfoBadge,
    required this.snackBarInfoIcon,
    required this.snackBarInfoText,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.memberHeroCardBg,
    required this.memberHeroCardBorder,
    required this.memberStatsBoxBg,
    required this.memberStatsBoxBorder,
    required this.memberOnlineDot,
    required this.memberAvatarBorder,
    required this.badgeWarningIcon,
    required this.dangerSurface,
    required this.dangerBorder,
    required this.dangerIconBg,
    required this.dangerText,
    required this.infoIconBg,
    required this.infoIconColor,
    required this.fundPiggyBg,
    required this.fundPiggyIcon,
    required this.fundStatusCollectingBg,
    required this.fundStatusCollectingText,
    required this.fundStatusCompletedBg,
    required this.fundStatusCompletedText,
    required this.fundAmountText,
    required this.fundProgressStart,
    required this.fundProgressEnd,
    required this.fundProgressText,
    required this.fundStatusUnpaidBg,
    required this.fundStatusUnpaidText,
    required this.fundRemindButtonBg,
    required this.fundRemindButtonBorder,
    required this.fundRemindButtonIcon,
    required this.fundEditButtonBg,
    required this.fundEditButtonFg,
    required this.fundEditButtonBorder,
    required this.fundCsvButtonBg,
    required this.fundCsvButtonFg,
    required this.fundCsvIcon,
    required this.expenseCategoryIconBg,
    required this.expenseCategoryIcon,
    required this.expenseCategoryTag,
    required this.expenseBadgeOwedBg,
    required this.expenseBadgeOwedBorder,
    required this.expenseBadgeOwedText,
    required this.warningAccent,
    required this.warningAccentBorder,
    required this.infoAccent,
    required this.orangeAccent,
    required this.errorAccent,
    required this.debtOweBg,
    required this.debtOweBorder,
    required this.debtOweText,
    required this.debtOweAmount,
    required this.debtReceiveBg,
    required this.debtReceiveBorder,
    required this.debtReceiveText,
    required this.debtReceiveAmount,
    required this.debtBalancedBg,
    required this.debtBalancedText,
    required this.debtPendingBg,
    required this.debtPendingText,
    required this.debtWaitingBg,
    required this.debtWaitingText,
    required this.debtHintBg,
    required this.debtHintBorder,
    required this.debtHintText,
    required this.debtChipBg,
    required this.debtAvatarBg,
    required this.debtYouBadgeBorder,
    required this.debtTabBadgeActiveBg,
    required this.debtTabBadgeActiveText,
    required this.debtTabBadgeInactiveBg,
    required this.debtTabBadgeInactiveText,
    required this.debtActionPayBg,
    required this.debtActionConfirmBg,
    required this.debtActionRejectFg,
    required this.debtActionRejectBorder,
    required this.debtActionRemindIcon,
    required this.debtIconContainerBg,
    required this.debtIconContainerBorder,
    required this.debtIconContainerFg,
    required this.qrCardBg,
    required this.qrCardBorder,
    required this.qrQuietZoneBg,
    required this.qrQuietZoneBorder,
    required this.qrTabActiveBg,
    required this.qrTabActiveBorder,
    required this.qrTabIconActiveBg,
    required this.qrCodeForeground,
    required this.qrShareButtonBg,
    required this.qrShareButtonFg,
    required this.inviteBannerBg,
    required this.inviteBannerBorder,
    required this.inviteBannerTitle,
    required this.inviteBannerButtonBg,
    required this.inviteBannerButtonFg,
    required this.scannerBackground,
    required this.scannerCorner,
    required this.qrMockupCard,
    required this.qrMockupFinder,
    required this.qrMockupDot,
    required this.debtStatusSettledDot,
    required this.debtStatusPendingDot,
    required this.debtStatusWaitingDot,
    required this.filterChipActiveBg,
    required this.filterChipActiveText,
    required this.keypadDigitBg,
    required this.keypadDigitText,
    required this.keypadActionBg,
    required this.keypadActionText,
    required this.keypadClearBg,
    required this.keypadClearText,
    required this.keypadDeleteBg,
    required this.keypadDeleteText,
    required this.scannerHighlightBg,
    required this.scannerHighlightBorder,
    required this.scannerHighlightText,
    required this.expenseCardSelectedBg,
    required this.expenseCardSelectedBorder,
    required this.expenseHeroAmount,
    required this.expenseCategoryTagBg,
    required this.expenseCategoryTagBorder,
    required this.expenseCategoryTagText,
    required this.expensePayerBadgeBg,
    required this.expensePayerBadgeText,
    required this.expensePayerAdvanceText,
    required this.expenseSplitPaidBg,
    required this.expenseSplitPaidText,
    required this.expenseSplitUnpaidBg,
    required this.expenseSplitUnpaidText,
    required this.expenseSplitPendingBg,
    required this.expenseSplitPendingText,
    required this.expenseActionEditBg,
    required this.expenseActionEditBorder,
    required this.expenseActionEditText,
    required this.expenseActionDeleteBg,
    required this.expenseActionDeleteBorder,
    required this.expenseActionDeleteText,
    required this.expenseQuickDeleteBg,
    required this.expenseQuickDeleteFg,
    required this.expenseReceiptZoomText,
    required this.financialCardBgStart,
    required this.financialCardBgMiddle,
    required this.financialCardBgEnd,
    required this.financialCardBorder,
    required this.financialCardShadow,
    required this.financialCardIconBg,
    required this.financialCardIcon,
    required this.financialCardTitle,
    required this.financialCardEyeToggle,
    required this.financialCardBoxBg,
    required this.financialCardBoxBorder,
    required this.financialCardOweIcon,
    required this.financialCardOweLabel,
    required this.financialCardOweAmount,
    required this.financialCardOweSubtitle,
    required this.financialCardReceiveIcon,
    required this.financialCardReceiveLabel,
    required this.financialCardReceiveAmount,
    required this.financialCardReceiveSubtitle,
  });

  /// Bảng màu cho Light Theme
  static const AppThemeColors light = AppThemeColors(
    background: AppColors.backgroundLight,
    cardBackground: Colors.white,
    cardBorder: AppColors.borderLight,
    surfaceMuted: Color(0xFFF8FAFC),
    segmentBackground: Color(0xFFF1F5F9),
    segmentActiveBackground: Colors.white,
    activePillBackground: Color(0xFFDCFCE7),
    activePillText: AppColors.emeraldForest,
    activePillBorder: Colors.transparent,
    adminBadgeBackground: AppColors.roleAdminBg,
    adminBadgeBorder: Color(0xFFFDE68A),
    adminBadgeText: AppColors.roleAdminText,
    memberBadgeBackground: Color(0xFFF8FAFC),
    memberBadgeBorder: AppColors.borderLight,
    memberBadgeText: AppColors.textSecondary,
    errorSurface: AppColors.errorBg,
    errorBorder: AppColors.errorBorder,
    divider: Color(0xFFE2E8F0),
    avatarDotBorder: Colors.white,
    textPrimary: AppColors.textDark,
    textSecondary: AppColors.textSecondary,
    textSlate800: AppColors.textSlate800,
    textMuted: AppColors.textMuted,
    iconPrimary: AppColors.textSlate800,
    themeToggleIcon: AppColors.textSlate800,
    cardShadowColor: Color(0x0A000000), // black with alpha 0.04
    cardShadow: BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    bottomNavShadow: BoxShadow(
      color: Color(0x0D000000), // black with alpha 0.05
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
    bottomNavBackground: Colors.white,
    bottomNavBorder: Color(0xFFE2E8F0),
    bottomNavInactive: AppColors.textSecondary,
    analyticsAccent: AppColors.emerald,
    analyticsIconBg: Color(0xFFECFDF5),
    bannerBackground: Color(0xFFF0FDF4),
    bannerBorder: Color(0xFFBBF7D0),
    badgeSuccessBg: Color(0xFFDCFCE7),
    badgeSuccessText: Color(0xFF15803D),
    badgeWarningBg: Color(0xFFFEF3C7),
    badgeWarningText: Color(0xFFB45309),
    badgeInfoBg: Color(0xFFCFFAFE),
    badgeInfoText: Color(0xFF0E7490),
    rankGoldBg: Color(0xFFFEF3C7),
    rankGoldText: Color(0xFFD97706),
    rankSilverBg: Color(0xFFF1F5F9),
    rankSilverText: Color(0xFF64748B),
    rankBronzeBg: Color(0xFFFFEDD5),
    rankBronzeText: Color(0xFFC2410C),
    brandEmerald: AppColors.emeraldForest,
    brandEmeraldBorder: AppColors.emerald,
    brandEmeraldMuted: Color(0xFFD1FAE5),
    badgeAmber: Color(0xFFD97706),
    badgeAmberBg: Color(0xFFFEF3C7),
    badgeIndigo: Color(0xFF4F46E5),
    badgeIndigoBg: Color(0xFFEEF2FF),
    badgeSuccess: Color(0xFF16A34A),
    inputBackground: Color(0xFFF8FAFC),
    dragHandle: Color(0xFFCBD5E1),
    primaryContainer: Color(0xFFDCFCE7),
    onPrimaryContainer: Color(0xFF15803D),
    primaryButton: Color(0xFF166534),
    onPrimaryButton: Colors.white,
    secondaryActionBg: Color(0xFFF0FDF4),
    secondaryActionBorder: Color(0xFF86EFAC),
    secondaryActionText: Color(0xFF14532D),
    tabPillActiveBg: Color(0xFF14532D),
    tabPillActiveText: Colors.white,
    roleAdminBg: Color(0xFFFEF3C7),
    roleAdminText: Color(0xFFB45309),
    roleAdminBorder: Color(0xFFFDE68A),
    statusActiveBg: Color(0xFFDCFCE7),
    statusActiveText: Color(0xFF15803D),
    statusArchivedBg: Color(0xFFF1F5F9),
    statusArchivedText: Color(0xFF64748B),
    inputFill: Color(0xFFF8FAFC),
    inputBorder: Color(0xFFE2E8F0),
    socialButtonBg: Colors.white,
    socialButtonBorder: Color(0xFFE2E8F0),
    otpBoxBg: Colors.white,
    otpBoxFilledBg: Color(0xFFEFFDF5),
    otpBoxBorder: Color(0xFFE2E8F0),
    snackBarSuccessBg: AppColors.successBg,
    snackBarSuccessBorder: Color(0xFFA7F3D0),
    snackBarSuccessBadge: Color(0xFFD1FAE5),
    snackBarSuccessIcon: AppColors.emeraldDark,
    snackBarSuccessText: AppColors.textDark,
    snackBarErrorBg: AppColors.errorBg,
    snackBarErrorBorder: AppColors.errorBorder,
    snackBarErrorBadge: Color(0xFFFEE2E2),
    snackBarErrorIcon: AppColors.error,
    snackBarErrorText: AppColors.textDark,
    snackBarWarningBg: Color(0xFFFFFBEB),
    snackBarWarningBorder: Color(0xFFFDE68A),
    snackBarWarningBadge: Color(0xFFFEF3C7),
    snackBarWarningIcon: Color(0xFFD97706),
    snackBarWarningText: AppColors.textDark,
    snackBarInfoBg: Color(0xFFF8FAFC),
    snackBarInfoBorder: Color(0xFFE2E8F0),
    snackBarInfoBadge: Color(0xFFE2E8F0),
    snackBarInfoIcon: AppColors.emeraldForest,
    snackBarInfoText: AppColors.textDark,
    shimmerBase: Color(0xFFE2E8F0),
    shimmerHighlight: Color(0xFFF8FAFC),
    memberHeroCardBg: Color(0xFFF0FDF4),
    memberHeroCardBorder: Color(0xFFA7F3D0),
    memberStatsBoxBg: Colors.white,
    memberStatsBoxBorder: Color(0xFFD1FAE5),
    memberOnlineDot: Color(0xFF22C55E),
    memberAvatarBorder: Color(0xFF86EFAC),
    badgeWarningIcon: Color(0xFFD97706),
    dangerSurface: Color(0xFFFFF1F2),
    dangerBorder: Color(0xFFFFE4E6),
    dangerIconBg: Color(0xFFFEE2E2),
    dangerText: Color(0xFFDC2626),
    infoIconBg: Color(0xFFEFF6FF),
    infoIconColor: Color(0xFF2563EB),
    fundPiggyBg: Color(0xFFEFF6FF),
    fundPiggyIcon: Color(0xFF2563EB),
    fundStatusCollectingBg: Color(0xFFDBEAFE),
    fundStatusCollectingText: Color(0xFF1D4ED8),
    fundStatusCompletedBg: Color(0xFFDCFCE7),
    fundStatusCompletedText: Color(0xFF15803D),
    fundAmountText: Color(0xFF047857),
    fundProgressStart: Color(0xFF2563EB),
    fundProgressEnd: Color(0xFF059669),
    fundProgressText: Color(0xFF047857),
    fundStatusUnpaidBg: Color(0xFFFEE2E2),
    fundStatusUnpaidText: Color(0xFFDC2626),
    fundRemindButtonBg: Color(0xFFFEF3C7),
    fundRemindButtonBorder: Color(0xFFFDE68A),
    fundRemindButtonIcon: Color(0xFFD97706),
    fundEditButtonBg: Color(0xFFF0FDF4),
    fundEditButtonFg: Color(0xFF15803D),
    fundEditButtonBorder: Color(0xFF86EFAC),
    fundCsvButtonBg: Color(0xFFF1F5F9),
    fundCsvButtonFg: Color(0xFF334155),
    fundCsvIcon: Color(0xFF16A34A),
    expenseCategoryIconBg: Color(0xFFE8F5E9),
    expenseCategoryIcon: Color(0xFF2E7D32),
    expenseCategoryTag: Color(0xFF10B981),
    expenseBadgeOwedBg: Color(0xFFFEE2E2),
    expenseBadgeOwedBorder: Color(0xFFFECACA),
    expenseBadgeOwedText: Color(0xFFDC2626),
    warningAccent: Color(0xFFD97706),
    warningAccentBorder: Color(0xFFFCD34D),
    infoAccent: Color(0xFF3B82F6),
    orangeAccent: Color(0xFFEA580C),
    errorAccent: AppColors.error,
    debtOweBg: Color(0xFFFFF1F2),
    debtOweBorder: Color(0xFFFFE4E6),
    debtOweText: Color(0xFFE11D48),
    debtOweAmount: Color(0xFFBE123C),
    debtReceiveBg: Color(0xFFF0FDF4),
    debtReceiveBorder: Color(0xFFDCFCE7),
    debtReceiveText: Color(0xFF16A34A),
    debtReceiveAmount: Color(0xFF15803D),
    debtBalancedBg: Color(0xFFF1F5F9),
    debtBalancedText: Color(0xFF475569),
    debtPendingBg: Color(0xFFFEF3C7),
    debtPendingText: Color(0xFFB45309),
    debtWaitingBg: Color(0xFFDBEAFE),
    debtWaitingText: Color(0xFF1D4ED8),
    debtHintBg: Color(0xFFFEF9C3),
    debtHintBorder: Color(0xFFFEF08A),
    debtHintText: Color(0xFF854D0E),
    debtChipBg: Color(0xFFF8FAFC),
    debtAvatarBg: Color(0xFFE2E8F0),
    debtYouBadgeBorder: Colors.white,
    debtTabBadgeActiveBg: Color(0xFFDCFCE7),
    debtTabBadgeActiveText: Color(0xFF15803D),
    debtTabBadgeInactiveBg: Color(0xFFE2E8F0),
    debtTabBadgeInactiveText: Color(0xFF64748B),
    debtActionPayBg: Color(0xFF15803D),
    debtActionConfirmBg: Color(0xFF15803D),
    debtActionRejectFg: Color(0xFFE11D48),
    debtActionRejectBorder: Color(0xFFFECDD3),
    debtActionRemindIcon: Color(0xFFD97706),
    debtIconContainerBg: Color(0xFFDCFCE7),
    debtIconContainerBorder: Color(0xFFA7F3D0),
    debtIconContainerFg: Color(0xFF15803D),
    qrCardBg: Colors.white,
    qrCardBorder: Color(0xFFE2E8F0),
    qrQuietZoneBg: Colors.white,
    qrQuietZoneBorder: Color(0xFFA7F3D0),
    qrTabActiveBg: Color(0xFFF0FDF4),
    qrTabActiveBorder: Color(0xFF15803D),
    qrTabIconActiveBg: Color(0xFF15803D),
    qrCodeForeground: Color(0xFF047857),
    qrShareButtonBg: Color(0xFF14532D),
    qrShareButtonFg: Colors.white,
    inviteBannerBg: Color(0xFFECFDF5),
    inviteBannerBorder: Color(0xFFA7F3D0),
    inviteBannerTitle: Color(0xFF047857),
    inviteBannerButtonBg: Color(0xFF14532D),
    inviteBannerButtonFg: Colors.white,
    scannerBackground: Color(0xFF060B1E),
    scannerCorner: Color(0xFF10B981),
    qrMockupCard: Colors.white,
    qrMockupFinder: Color(0xFF1E293B),
    qrMockupDot: Color(0xFF334155),
    debtStatusSettledDot: Color(0xFF16A34A),
    debtStatusPendingDot: Color(0xFFE11D48),
    debtStatusWaitingDot: Color(0xFFF59E0B),
    filterChipActiveBg: Color(0xFF166534),
    filterChipActiveText: Colors.white,
    keypadDigitBg: Color(0xFFF8FAFC),
    keypadDigitText: AppColors.textDark,
    keypadActionBg: Color(0xFFE2E8F0),
    keypadActionText: Color(0xFF1E293B),
    keypadClearBg: Color(0xFFFEE2E2),
    keypadClearText: Color(0xFFDC2626),
    keypadDeleteBg: Color(0xFFFEF3C7),
    keypadDeleteText: Color(0xFFB45309),
    scannerHighlightBg: Color(0xFFECFDF5),
    scannerHighlightBorder: Color(0xFF6EE7B7),
    scannerHighlightText: Color(0xFF14532D),
    expenseCardSelectedBg: Color(0xFFF0FDF4),
    expenseCardSelectedBorder: Color(0xFF16A34A),
    expenseHeroAmount: Color(0xFF14532D),
    expenseCategoryTagBg: Color(0xFFF0FDF4),
    expenseCategoryTagBorder: Color(0xFF86EFAC),
    expenseCategoryTagText: Color(0xFF14532D),
    expensePayerBadgeBg: Color(0xFFDCFCE7),
    expensePayerBadgeText: Color(0xFF15803D),
    expensePayerAdvanceText: Color(0xFF15803D),
    expenseSplitPaidBg: Color(0xFFDCFCE7),
    expenseSplitPaidText: Color(0xFF15803D),
    expenseSplitUnpaidBg: Color(0xFFFEE2E2),
    expenseSplitUnpaidText: Color(0xFFDC2626),
    expenseSplitPendingBg: Color(0xFFFEF3C7),
    expenseSplitPendingText: Color(0xFFD97706),
    expenseActionEditBg: Color(0xFFF0FDF4),
    expenseActionEditBorder: Color(0xFF86EFAC),
    expenseActionEditText: Color(0xFF15803D),
    expenseActionDeleteBg: Color(0xFFFEF2F2),
    expenseActionDeleteBorder: Color(0xFFFECACA),
    expenseActionDeleteText: Color(0xFFDC2626),
    expenseQuickDeleteBg: Color(0xFFFEE2E2),
    expenseQuickDeleteFg: AppColors.error,
    expenseReceiptZoomText: Color(0xFF14532D),
    financialCardBgStart: AppColors.deepEmeraldDark,
    financialCardBgMiddle: AppColors.deepEmerald,
    financialCardBgEnd: AppColors.deepEmeraldForest,
    financialCardBorder: Color(0x24FFFFFF),
    financialCardShadow: BoxShadow(
      color: Color(0x26042F24),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
    financialCardIconBg: Color(0x1FFFFFFF),
    financialCardIcon: AppColors.emeraldLight,
    financialCardTitle: AppColors.borderLight,
    financialCardEyeToggle: AppColors.borderCard,
    financialCardBoxBg: Color(0x12FFFFFF),
    financialCardBoxBorder: Color(0x1FFFFFFF),
    financialCardOweIcon: AppColors.coralSoft,
    financialCardOweLabel: AppColors.borderLight,
    financialCardOweAmount: AppColors.coralSoft,
    financialCardOweSubtitle: AppColors.textMuted,
    financialCardReceiveIcon: AppColors.mintLight,
    financialCardReceiveLabel: AppColors.borderLight,
    financialCardReceiveAmount: AppColors.mintLight,
    financialCardReceiveSubtitle: AppColors.textMuted,
  );

  /// Bảng màu cho Dark Theme
  static const AppThemeColors dark = AppThemeColors(
    background: AppColors.backgroundDark,
    cardBackground: AppColors.cardDark,
    cardBorder: AppColors.borderDark,
    surfaceMuted: AppColors.backgroundDark,
    segmentBackground: Color(0xFF0F172A),
    segmentActiveBackground: AppColors.cardDark,
    activePillBackground: Color(0xFF064E3B),
    activePillText: AppColors.emeraldLight,
    activePillBorder: Color(0xFF047857),
    adminBadgeBackground: Color(0xFF451A03),
    adminBadgeBorder: Color(0xFF92400E),
    adminBadgeText: Color(0xFFFCD34D),
    memberBadgeBackground: Color(0xFF1E293B),
    memberBadgeBorder: AppColors.borderDark,
    memberBadgeText: Color(0xFFCBD5E1),
    errorSurface: Color(0xFF450A0A),
    errorBorder: Color(0xFF991B1B),
    divider: AppColors.borderDark,
    avatarDotBorder: AppColors.backgroundDark,
    textPrimary: AppColors.textLight,
    textSecondary: AppColors.textLightSecondary,
    textSlate800: AppColors.textLightSecondary,
    textMuted: AppColors.textLightSecondary,
    iconPrimary: AppColors.textLight,
    themeToggleIcon: Color(0xFFFBBF24),
    cardShadowColor: Color(0x4D000000), // black with alpha 0.30
    cardShadow: BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    bottomNavShadow: BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
    bottomNavBackground: AppColors.cardDark,
    bottomNavBorder: AppColors.borderDark,
    bottomNavInactive: AppColors.textLightSecondary,
    analyticsAccent: AppColors.emeraldLight,
    analyticsIconBg: Color(0xFF064E3B),
    bannerBackground: Color(0xFF0F172A),
    bannerBorder: AppColors.borderDark,
    badgeSuccessBg: Color(0xFF064E3B),
    badgeSuccessText: Color(0xFF34D399),
    badgeWarningBg: Color(0xFF451A03),
    badgeWarningText: Color(0xFFFBBF24),
    badgeInfoBg: Color(0xFF083344),
    badgeInfoText: Color(0xFF22D3EE),
    rankGoldBg: Color(0xFF451A03),
    rankGoldText: Color(0xFFFBBF24),
    rankSilverBg: Color(0xFF1E293B),
    rankSilverText: Color(0xFF94A3B8),
    rankBronzeBg: Color(0xFF431407),
    rankBronzeText: Color(0xFFFB923C),
    brandEmerald: AppColors.emeraldLight,
    brandEmeraldBorder: Color(0x9934D399),
    brandEmeraldMuted: Color(0xFF064E3B),
    badgeAmber: Color(0xFFFBBF24),
    badgeAmberBg: Color(0x5978350F),
    badgeIndigo: Color(0xFF818CF8),
    badgeIndigoBg: Color(0x59312E81),
    badgeSuccess: Color(0xFF4ADE80),
    inputBackground: Color(0xFF090D16),
    dragHandle: Color(0xFF475569),
    primaryContainer: Color(0xFF064E3B),
    onPrimaryContainer: Color(0xFF6EE7B7),
    primaryButton: Color(0xFF059669),
    onPrimaryButton: Colors.white,
    secondaryActionBg: Color(0x2610B981),
    secondaryActionBorder: Color(0xFF059669),
    secondaryActionText: Color(0xFF34D399),
    tabPillActiveBg: Color(0xFF047857),
    tabPillActiveText: Colors.white,
    roleAdminBg: Color(0xFF451A03),
    roleAdminText: Color(0xFFFDE047),
    roleAdminBorder: Color(0xFF92400E),
    statusActiveBg: Color(0xFF064E3B),
    statusActiveText: Color(0xFF34D399),
    statusArchivedBg: Color(0xFF334155),
    statusArchivedText: Color(0xFF94A3B8),
    inputFill: Color(0xFF0F172A),
    inputBorder: Color(0xFF334155),
    socialButtonBg: AppColors.cardDark,
    socialButtonBorder: Color(0xFF334155),
    otpBoxBg: Color(0xFF0F172A),
    otpBoxFilledBg: Color(0xFF064E3B),
    otpBoxBorder: Color(0xFF334155),
    snackBarSuccessBg: AppColors.cardDark,
    snackBarSuccessBorder: Color(0xFF065F46),
    snackBarSuccessBadge: Color(0xFF064E3B),
    snackBarSuccessIcon: AppColors.emeraldLight,
    snackBarSuccessText: AppColors.textLight,
    snackBarErrorBg: AppColors.cardDark,
    snackBarErrorBorder: Color(0xFF991B1B),
    snackBarErrorBadge: Color(0xFF7F1D1D),
    snackBarErrorIcon: Color(0xFFF87171),
    snackBarErrorText: AppColors.textLight,
    snackBarWarningBg: AppColors.cardDark,
    snackBarWarningBorder: Color(0xFF92400E),
    snackBarWarningBadge: Color(0xFF78350F),
    snackBarWarningIcon: Color(0xFFFBBF24),
    snackBarWarningText: AppColors.textLight,
    snackBarInfoBg: AppColors.cardDark,
    snackBarInfoBorder: AppColors.borderDark,
    snackBarInfoBadge: Color(0xFF334155),
    snackBarInfoIcon: AppColors.emeraldLight,
    snackBarInfoText: AppColors.textLight,
    shimmerBase: Color(0xFF1E293B),
    shimmerHighlight: Color(0xFF334155),
    memberHeroCardBg: Color(0xFF0F291E),
    memberHeroCardBorder: Color(0xFF065F46),
    memberStatsBoxBg: Color(0xFF1E293B),
    memberStatsBoxBorder: Color(0xFF334155),
    memberOnlineDot: Color(0xFF22C55E),
    memberAvatarBorder: Color(0xFF059669),
    badgeWarningIcon: Color(0xFFFBBF24),
    dangerSurface: Color(0xFF450A0A),
    dangerBorder: Color(0xFF991B1B),
    dangerIconBg: Color(0xFF5A1414),
    dangerText: Color(0xFFF87171),
    infoIconBg: Color(0xFF1E293B),
    infoIconColor: Color(0xFF60A5FA),
    fundPiggyBg: Color(0xFF1E3A8A),
    fundPiggyIcon: Color(0xFF60A5FA),
    fundStatusCollectingBg: Color(0xFF1E3A8A),
    fundStatusCollectingText: Color(0xFF93C5FD),
    fundStatusCompletedBg: Color(0xFF064E3B),
    fundStatusCompletedText: Color(0xFF6EE7B7),
    fundAmountText: Color(0xFF34D399),
    fundProgressStart: Color(0xFF3B82F6),
    fundProgressEnd: Color(0xFF10B981),
    fundProgressText: Color(0xFF34D399),
    fundStatusUnpaidBg: Color(0xFF450A0A),
    fundStatusUnpaidText: Color(0xFFF87171),
    fundRemindButtonBg: Color(0xFF713F12),
    fundRemindButtonBorder: Color(0xFF854D0E),
    fundRemindButtonIcon: Color(0xFFFBBF24),
    fundEditButtonBg: Color(0x33064E3B),
    fundEditButtonFg: Color(0xFF6EE7B7),
    fundEditButtonBorder: Color(0xFF065F46),
    fundCsvButtonBg: Color(0xFF1E293B),
    fundCsvButtonFg: Color(0xFFCBD5E1),
    fundCsvIcon: Color(0xFF34D399),
    expenseCategoryIconBg: Color(0xFF064E3B),
    expenseCategoryIcon: Color(0xFF34D399),
    expenseCategoryTag: Color(0xFF34D399),
    expenseBadgeOwedBg: Color(0xFF450A0A),
    expenseBadgeOwedBorder: Color(0xFF991B1B),
    expenseBadgeOwedText: Color(0xFFF87171),
    warningAccent: Color(0xFFFBBF24),
    warningAccentBorder: Color(0xFF78350F),
    infoAccent: Color(0xFF60A5FA),
    orangeAccent: Color(0xFFFB923C),
    errorAccent: Color(0xFFF87171),
    debtOweBg: Color(0x4D4C0519),
    debtOweBorder: Color(0x80881337),
    debtOweText: Color(0xFFFDA4AF),
    debtOweAmount: Color(0xFFFECDD3),
    debtReceiveBg: Color(0x4D064E3B),
    debtReceiveBorder: Color(0x80065F46),
    debtReceiveText: Color(0xFF6EE7B7),
    debtReceiveAmount: Color(0xFFA7F3D0),
    debtBalancedBg: Color(0xFF334155),
    debtBalancedText: Color(0xFFCBD5E1),
    debtPendingBg: Color(0xFF713F12),
    debtPendingText: Color(0xFFFDE047),
    debtWaitingBg: Color(0xFF1E3A8A),
    debtWaitingText: Color(0xFF93C5FD),
    debtHintBg: Color(0x4D713F12),
    debtHintBorder: Color(0xFF854D0E),
    debtHintText: Color(0xFFFDE047),
    debtChipBg: Color(0xFF1E293B),
    debtAvatarBg: Color(0xFF334155),
    debtYouBadgeBorder: Color(0xFF0F172A),
    debtTabBadgeActiveBg: Color(0xFF064E3B),
    debtTabBadgeActiveText: Color(0xFF6EE7B7),
    debtTabBadgeInactiveBg: Color(0xFF334155),
    debtTabBadgeInactiveText: Color(0xFF94A3B8),
    debtActionPayBg: Color(0xFF059669),
    debtActionConfirmBg: Color(0xFF059669),
    debtActionRejectFg: Color(0xFFFDA4AF),
    debtActionRejectBorder: Color(0xFF881337),
    debtActionRemindIcon: Color(0xFFFBBF24),
    debtIconContainerBg: Color(0x66064E3B),
    debtIconContainerBorder: Color(0xFF065F46),
    debtIconContainerFg: Color(0xFF6EE7B7),
    qrCardBg: Color(0xFF0F172A),
    qrCardBorder: Color(0xFF334155),
    qrQuietZoneBg: Colors.white,
    qrQuietZoneBorder: Color(0xFF065F46),
    qrTabActiveBg: Color(0x59064E3B),
    qrTabActiveBorder: Color(0xFF10B981),
    qrTabIconActiveBg: Color(0xFF059669),
    qrCodeForeground: Color(0xFF047857),
    qrShareButtonBg: Color(0xFF059669),
    qrShareButtonFg: Colors.white,
    inviteBannerBg: Color(0xFF132E27),
    inviteBannerBorder: Color(0xFF065F46),
    inviteBannerTitle: Color(0xFF34D399),
    inviteBannerButtonBg: Color(0xFF059669),
    inviteBannerButtonFg: Colors.white,
    scannerBackground: Color(0xFF060B1E),
    scannerCorner: Color(0xFF34D399),
    qrMockupCard: AppColors.cardDark,
    qrMockupFinder: Color(0xFFE2E8F0),
    qrMockupDot: Color(0xFF94A3B8),
    debtStatusSettledDot: Color(0xFF22C55E),
    debtStatusPendingDot: Color(0xFFF43F5E),
    debtStatusWaitingDot: Color(0xFFFBBF24),
    filterChipActiveBg: Color(0xFF15803D),
    filterChipActiveText: Colors.white,
    keypadDigitBg: Color(0xFF1E293B),
    keypadDigitText: AppColors.textLight,
    keypadActionBg: Color(0xFF334155),
    keypadActionText: Color(0xFFCBD5E1),
    keypadClearBg: Color(0xFF450A0A),
    keypadClearText: Color(0xFFF87171),
    keypadDeleteBg: Color(0xFF451A03),
    keypadDeleteText: Color(0xFFFBBF24),
    scannerHighlightBg: Color(0xFF064E3B),
    scannerHighlightBorder: Color(0xFF047857),
    scannerHighlightText: Color(0xFF6EE7B7),
    expenseCardSelectedBg: Color(0xFF064E3B),
    expenseCardSelectedBorder: Color(0xFF059669),
    expenseHeroAmount: Color(0xFF4ADE80),
    expenseCategoryTagBg: Color(0xFF064E3B),
    expenseCategoryTagBorder: Color(0xFF065F46),
    expenseCategoryTagText: Color(0xFF86EFAC),
    expensePayerBadgeBg: Color(0xFF064E3B),
    expensePayerBadgeText: Color(0xFF6EE7B7),
    expensePayerAdvanceText: Color(0xFF6EE7B7),
    expenseSplitPaidBg: Color(0x4D064E3B),
    expenseSplitPaidText: Color(0xFF6EE7B7),
    expenseSplitUnpaidBg: Color(0x4D4C0519),
    expenseSplitUnpaidText: Color(0xFFFDA4AF),
    expenseSplitPendingBg: Color(0x4D713F12),
    expenseSplitPendingText: Color(0xFFFDE047),
    expenseActionEditBg: Color(0x33064E3B),
    expenseActionEditBorder: Color(0xFF065F46),
    expenseActionEditText: Color(0xFF34D399),
    expenseActionDeleteBg: Color(0x33450A0A),
    expenseActionDeleteBorder: Color(0xFF991B1B),
    expenseActionDeleteText: Color(0xFFF87171),
    expenseQuickDeleteBg: Color(0x33450A0A),
    expenseQuickDeleteFg: Color(0xFFF87171),
    expenseReceiptZoomText: Color(0xFF34D399),
    financialCardBgStart: Color(0xFF03221A),
    financialCardBgMiddle: Color(0xFF04382A),
    financialCardBgEnd: AppColors.deepEmerald,
    financialCardBorder: Color(0x26FFFFFF),
    financialCardShadow: BoxShadow(
      color: Color(0x66000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    financialCardIconBg: Color(0x1FFFFFFF),
    financialCardIcon: AppColors.emeraldLight,
    financialCardTitle: AppColors.borderLight,
    financialCardEyeToggle: AppColors.borderCard,
    financialCardBoxBg: Color(0x14FFFFFF),
    financialCardBoxBorder: Color(0x1FFFFFFF),
    financialCardOweIcon: AppColors.coralSoft,
    financialCardOweLabel: AppColors.borderLight,
    financialCardOweAmount: AppColors.coralSoft,
    financialCardOweSubtitle: AppColors.textLightSecondary,
    financialCardReceiveIcon: AppColors.mintLight,
    financialCardReceiveLabel: AppColors.borderLight,
    financialCardReceiveAmount: AppColors.mintLight,
    financialCardReceiveSubtitle: AppColors.textLightSecondary,
  );

  /// Lấy bảng màu tương ứng với Theme hiện tại
  static AppThemeColors of(BuildContext context) {
    return Theme.of(context).extension<AppThemeColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  ThemeExtension<AppThemeColors> copyWith({
    Color? background,
    Color? cardBackground,
    Color? cardBorder,
    Color? surfaceMuted,
    Color? segmentBackground,
    Color? segmentActiveBackground,
    Color? activePillBackground,
    Color? activePillText,
    Color? activePillBorder,
    Color? adminBadgeBackground,
    Color? adminBadgeBorder,
    Color? adminBadgeText,
    Color? memberBadgeBackground,
    Color? memberBadgeBorder,
    Color? memberBadgeText,
    Color? errorSurface,
    Color? errorBorder,
    Color? divider,
    Color? avatarDotBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textSlate800,
    Color? textMuted,
    Color? iconPrimary,
    Color? themeToggleIcon,
    Color? cardShadowColor,
    BoxShadow? cardShadow,
    BoxShadow? bottomNavShadow,
    Color? bottomNavBackground,
    Color? bottomNavBorder,
    Color? bottomNavInactive,
    Color? analyticsAccent,
    Color? analyticsIconBg,
    Color? bannerBackground,
    Color? bannerBorder,
    Color? badgeSuccessBg,
    Color? badgeSuccessText,
    Color? badgeWarningBg,
    Color? badgeWarningText,
    Color? badgeInfoBg,
    Color? badgeInfoText,
    Color? rankGoldBg,
    Color? rankGoldText,
    Color? rankSilverBg,
    Color? rankSilverText,
    Color? rankBronzeBg,
    Color? rankBronzeText,
    Color? brandEmerald,
    Color? brandEmeraldBorder,
    Color? brandEmeraldMuted,
    Color? badgeAmber,
    Color? badgeAmberBg,
    Color? badgeIndigo,
    Color? badgeIndigoBg,
    Color? badgeSuccess,
    Color? inputBackground,
    Color? dragHandle,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? primaryButton,
    Color? onPrimaryButton,
    Color? secondaryActionBg,
    Color? secondaryActionBorder,
    Color? secondaryActionText,
    Color? tabPillActiveBg,
    Color? tabPillActiveText,
    Color? roleAdminBg,
    Color? roleAdminText,
    Color? roleAdminBorder,
    Color? statusActiveBg,
    Color? statusActiveText,
    Color? statusArchivedBg,
    Color? statusArchivedText,
    Color? inputFill,
    Color? inputBorder,
    Color? socialButtonBg,
    Color? socialButtonBorder,
    Color? otpBoxBg,
    Color? otpBoxFilledBg,
    Color? otpBoxBorder,
    Color? snackBarSuccessBg,
    Color? snackBarSuccessBorder,
    Color? snackBarSuccessBadge,
    Color? snackBarSuccessIcon,
    Color? snackBarSuccessText,
    Color? snackBarErrorBg,
    Color? snackBarErrorBorder,
    Color? snackBarErrorBadge,
    Color? snackBarErrorIcon,
    Color? snackBarErrorText,
    Color? snackBarWarningBg,
    Color? snackBarWarningBorder,
    Color? snackBarWarningBadge,
    Color? snackBarWarningIcon,
    Color? snackBarWarningText,
    Color? snackBarInfoBg,
    Color? snackBarInfoBorder,
    Color? snackBarInfoBadge,
    Color? snackBarInfoIcon,
    Color? snackBarInfoText,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? memberHeroCardBg,
    Color? memberHeroCardBorder,
    Color? memberStatsBoxBg,
    Color? memberStatsBoxBorder,
    Color? memberOnlineDot,
    Color? memberAvatarBorder,
    Color? badgeWarningIcon,
    Color? dangerSurface,
    Color? dangerBorder,
    Color? dangerIconBg,
    Color? dangerText,
    Color? infoIconBg,
    Color? infoIconColor,
    Color? fundPiggyBg,
    Color? fundPiggyIcon,
    Color? fundStatusCollectingBg,
    Color? fundStatusCollectingText,
    Color? fundStatusCompletedBg,
    Color? fundStatusCompletedText,
    Color? fundAmountText,
    Color? fundProgressStart,
    Color? fundProgressEnd,
    Color? fundProgressText,
    Color? fundStatusUnpaidBg,
    Color? fundStatusUnpaidText,
    Color? fundRemindButtonBg,
    Color? fundRemindButtonBorder,
    Color? fundRemindButtonIcon,
    Color? fundEditButtonBg,
    Color? fundEditButtonFg,
    Color? fundEditButtonBorder,
    Color? fundCsvButtonBg,
    Color? fundCsvButtonFg,
    Color? fundCsvIcon,
    Color? expenseCategoryIconBg,
    Color? expenseCategoryIcon,
    Color? expenseCategoryTag,
    Color? expenseBadgeOwedBg,
    Color? expenseBadgeOwedBorder,
    Color? expenseBadgeOwedText,
    Color? warningAccent,
    Color? warningAccentBorder,
    Color? infoAccent,
    Color? orangeAccent,
    Color? errorAccent,
    Color? debtOweBg,
    Color? debtOweBorder,
    Color? debtOweText,
    Color? debtOweAmount,
    Color? debtReceiveBg,
    Color? debtReceiveBorder,
    Color? debtReceiveText,
    Color? debtReceiveAmount,
    Color? debtBalancedBg,
    Color? debtBalancedText,
    Color? debtPendingBg,
    Color? debtPendingText,
    Color? debtWaitingBg,
    Color? debtWaitingText,
    Color? debtHintBg,
    Color? debtHintBorder,
    Color? debtHintText,
    Color? debtChipBg,
    Color? debtAvatarBg,
    Color? debtYouBadgeBorder,
    Color? debtTabBadgeActiveBg,
    Color? debtTabBadgeActiveText,
    Color? debtTabBadgeInactiveBg,
    Color? debtTabBadgeInactiveText,
    Color? debtActionPayBg,
    Color? debtActionConfirmBg,
    Color? debtActionRejectFg,
    Color? debtActionRejectBorder,
    Color? debtActionRemindIcon,
    Color? debtIconContainerBg,
    Color? debtIconContainerBorder,
    Color? debtIconContainerFg,
    Color? qrCardBg,
    Color? qrCardBorder,
    Color? qrQuietZoneBg,
    Color? qrQuietZoneBorder,
    Color? qrTabActiveBg,
    Color? qrTabActiveBorder,
    Color? qrTabIconActiveBg,
    Color? qrCodeForeground,
    Color? qrShareButtonBg,
    Color? qrShareButtonFg,
    Color? inviteBannerBg,
    Color? inviteBannerBorder,
    Color? inviteBannerTitle,
    Color? inviteBannerButtonBg,
    Color? inviteBannerButtonFg,
    Color? scannerBackground,
    Color? scannerCorner,
    Color? qrMockupCard,
    Color? qrMockupFinder,
    Color? qrMockupDot,
    Color? debtStatusSettledDot,
    Color? debtStatusPendingDot,
    Color? debtStatusWaitingDot,
    Color? filterChipActiveBg,
    Color? filterChipActiveText,
    Color? keypadDigitBg,
    Color? keypadDigitText,
    Color? keypadActionBg,
    Color? keypadActionText,
    Color? keypadClearBg,
    Color? keypadClearText,
    Color? keypadDeleteBg,
    Color? keypadDeleteText,
    Color? scannerHighlightBg,
    Color? scannerHighlightBorder,
    Color? scannerHighlightText,
    Color? expenseCardSelectedBg,
    Color? expenseCardSelectedBorder,
    Color? expenseHeroAmount,
    Color? expenseCategoryTagBg,
    Color? expenseCategoryTagBorder,
    Color? expenseCategoryTagText,
    Color? expensePayerBadgeBg,
    Color? expensePayerBadgeText,
    Color? expensePayerAdvanceText,
    Color? expenseSplitPaidBg,
    Color? expenseSplitPaidText,
    Color? expenseSplitUnpaidBg,
    Color? expenseSplitUnpaidText,
    Color? expenseSplitPendingBg,
    Color? expenseSplitPendingText,
    Color? expenseActionEditBg,
    Color? expenseActionEditBorder,
    Color? expenseActionEditText,
    Color? expenseActionDeleteBg,
    Color? expenseActionDeleteBorder,
    Color? expenseActionDeleteText,
    Color? expenseQuickDeleteBg,
    Color? expenseQuickDeleteFg,
    Color? expenseReceiptZoomText,
    Color? financialCardBgStart,
    Color? financialCardBgMiddle,
    Color? financialCardBgEnd,
    Color? financialCardBorder,
    BoxShadow? financialCardShadow,
    Color? financialCardIconBg,
    Color? financialCardIcon,
    Color? financialCardTitle,
    Color? financialCardEyeToggle,
    Color? financialCardBoxBg,
    Color? financialCardBoxBorder,
    Color? financialCardOweIcon,
    Color? financialCardOweLabel,
    Color? financialCardOweAmount,
    Color? financialCardOweSubtitle,
    Color? financialCardReceiveIcon,
    Color? financialCardReceiveLabel,
    Color? financialCardReceiveAmount,
    Color? financialCardReceiveSubtitle,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      segmentBackground: segmentBackground ?? this.segmentBackground,
      segmentActiveBackground:
          segmentActiveBackground ?? this.segmentActiveBackground,
      activePillBackground: activePillBackground ?? this.activePillBackground,
      activePillText: activePillText ?? this.activePillText,
      activePillBorder: activePillBorder ?? this.activePillBorder,
      adminBadgeBackground: adminBadgeBackground ?? this.adminBadgeBackground,
      adminBadgeBorder: adminBadgeBorder ?? this.adminBadgeBorder,
      adminBadgeText: adminBadgeText ?? this.adminBadgeText,
      memberBadgeBackground:
          memberBadgeBackground ?? this.memberBadgeBackground,
      memberBadgeBorder: memberBadgeBorder ?? this.memberBadgeBorder,
      memberBadgeText: memberBadgeText ?? this.memberBadgeText,
      errorSurface: errorSurface ?? this.errorSurface,
      errorBorder: errorBorder ?? this.errorBorder,
      divider: divider ?? this.divider,
      avatarDotBorder: avatarDotBorder ?? this.avatarDotBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textSlate800: textSlate800 ?? this.textSlate800,
      textMuted: textMuted ?? this.textMuted,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      themeToggleIcon: themeToggleIcon ?? this.themeToggleIcon,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      cardShadow: cardShadow ?? this.cardShadow,
      bottomNavShadow: bottomNavShadow ?? this.bottomNavShadow,
      bottomNavBackground: bottomNavBackground ?? this.bottomNavBackground,
      bottomNavBorder: bottomNavBorder ?? this.bottomNavBorder,
      bottomNavInactive: bottomNavInactive ?? this.bottomNavInactive,
      analyticsAccent: analyticsAccent ?? this.analyticsAccent,
      analyticsIconBg: analyticsIconBg ?? this.analyticsIconBg,
      bannerBackground: bannerBackground ?? this.bannerBackground,
      bannerBorder: bannerBorder ?? this.bannerBorder,
      badgeSuccessBg: badgeSuccessBg ?? this.badgeSuccessBg,
      badgeSuccessText: badgeSuccessText ?? this.badgeSuccessText,
      badgeWarningBg: badgeWarningBg ?? this.badgeWarningBg,
      badgeWarningText: badgeWarningText ?? this.badgeWarningText,
      badgeInfoBg: badgeInfoBg ?? this.badgeInfoBg,
      badgeInfoText: badgeInfoText ?? this.badgeInfoText,
      rankGoldBg: rankGoldBg ?? this.rankGoldBg,
      rankGoldText: rankGoldText ?? this.rankGoldText,
      rankSilverBg: rankSilverBg ?? this.rankSilverBg,
      rankSilverText: rankSilverText ?? this.rankSilverText,
      rankBronzeBg: rankBronzeBg ?? this.rankBronzeBg,
      rankBronzeText: rankBronzeText ?? this.rankBronzeText,
      brandEmerald: brandEmerald ?? this.brandEmerald,
      brandEmeraldBorder: brandEmeraldBorder ?? this.brandEmeraldBorder,
      brandEmeraldMuted: brandEmeraldMuted ?? this.brandEmeraldMuted,
      badgeAmber: badgeAmber ?? this.badgeAmber,
      badgeAmberBg: badgeAmberBg ?? this.badgeAmberBg,
      badgeIndigo: badgeIndigo ?? this.badgeIndigo,
      badgeIndigoBg: badgeIndigoBg ?? this.badgeIndigoBg,
      badgeSuccess: badgeSuccess ?? this.badgeSuccess,
      inputBackground: inputBackground ?? this.inputBackground,
      dragHandle: dragHandle ?? this.dragHandle,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      primaryButton: primaryButton ?? this.primaryButton,
      onPrimaryButton: onPrimaryButton ?? this.onPrimaryButton,
      secondaryActionBg: secondaryActionBg ?? this.secondaryActionBg,
      secondaryActionBorder:
          secondaryActionBorder ?? this.secondaryActionBorder,
      secondaryActionText: secondaryActionText ?? this.secondaryActionText,
      tabPillActiveBg: tabPillActiveBg ?? this.tabPillActiveBg,
      tabPillActiveText: tabPillActiveText ?? this.tabPillActiveText,
      roleAdminBg: roleAdminBg ?? this.roleAdminBg,
      roleAdminText: roleAdminText ?? this.roleAdminText,
      roleAdminBorder: roleAdminBorder ?? this.roleAdminBorder,
      statusActiveBg: statusActiveBg ?? this.statusActiveBg,
      statusActiveText: statusActiveText ?? this.statusActiveText,
      statusArchivedBg: statusArchivedBg ?? this.statusArchivedBg,
      statusArchivedText: statusArchivedText ?? this.statusArchivedText,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      socialButtonBg: socialButtonBg ?? this.socialButtonBg,
      socialButtonBorder: socialButtonBorder ?? this.socialButtonBorder,
      otpBoxBg: otpBoxBg ?? this.otpBoxBg,
      otpBoxFilledBg: otpBoxFilledBg ?? this.otpBoxFilledBg,
      otpBoxBorder: otpBoxBorder ?? this.otpBoxBorder,
      snackBarSuccessBg: snackBarSuccessBg ?? this.snackBarSuccessBg,
      snackBarSuccessBorder:
          snackBarSuccessBorder ?? this.snackBarSuccessBorder,
      snackBarSuccessBadge: snackBarSuccessBadge ?? this.snackBarSuccessBadge,
      snackBarSuccessIcon: snackBarSuccessIcon ?? this.snackBarSuccessIcon,
      snackBarSuccessText: snackBarSuccessText ?? this.snackBarSuccessText,
      snackBarErrorBg: snackBarErrorBg ?? this.snackBarErrorBg,
      snackBarErrorBorder: snackBarErrorBorder ?? this.snackBarErrorBorder,
      snackBarErrorBadge: snackBarErrorBadge ?? this.snackBarErrorBadge,
      snackBarErrorIcon: snackBarErrorIcon ?? this.snackBarErrorIcon,
      snackBarErrorText: snackBarErrorText ?? this.snackBarErrorText,
      snackBarWarningBg: snackBarWarningBg ?? this.snackBarWarningBg,
      snackBarWarningBorder:
          snackBarWarningBorder ?? this.snackBarWarningBorder,
      snackBarWarningBadge: snackBarWarningBadge ?? this.snackBarWarningBadge,
      snackBarWarningIcon: snackBarWarningIcon ?? this.snackBarWarningIcon,
      snackBarWarningText: snackBarWarningText ?? this.snackBarWarningText,
      snackBarInfoBg: snackBarInfoBg ?? this.snackBarInfoBg,
      snackBarInfoBorder: snackBarInfoBorder ?? this.snackBarInfoBorder,
      snackBarInfoBadge: snackBarInfoBadge ?? this.snackBarInfoBadge,
      snackBarInfoIcon: snackBarInfoIcon ?? this.snackBarInfoIcon,
      snackBarInfoText: snackBarInfoText ?? this.snackBarInfoText,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      memberHeroCardBg: memberHeroCardBg ?? this.memberHeroCardBg,
      memberHeroCardBorder: memberHeroCardBorder ?? this.memberHeroCardBorder,
      memberStatsBoxBg: memberStatsBoxBg ?? this.memberStatsBoxBg,
      memberStatsBoxBorder: memberStatsBoxBorder ?? this.memberStatsBoxBorder,
      memberOnlineDot: memberOnlineDot ?? this.memberOnlineDot,
      memberAvatarBorder: memberAvatarBorder ?? this.memberAvatarBorder,
      badgeWarningIcon: badgeWarningIcon ?? this.badgeWarningIcon,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      dangerIconBg: dangerIconBg ?? this.dangerIconBg,
      dangerText: dangerText ?? this.dangerText,
      infoIconBg: infoIconBg ?? this.infoIconBg,
      infoIconColor: infoIconColor ?? this.infoIconColor,
      fundPiggyBg: fundPiggyBg ?? this.fundPiggyBg,
      fundPiggyIcon: fundPiggyIcon ?? this.fundPiggyIcon,
      fundStatusCollectingBg:
          fundStatusCollectingBg ?? this.fundStatusCollectingBg,
      fundStatusCollectingText:
          fundStatusCollectingText ?? this.fundStatusCollectingText,
      fundStatusCompletedBg:
          fundStatusCompletedBg ?? this.fundStatusCompletedBg,
      fundStatusCompletedText:
          fundStatusCompletedText ?? this.fundStatusCompletedText,
      fundAmountText: fundAmountText ?? this.fundAmountText,
      fundProgressStart: fundProgressStart ?? this.fundProgressStart,
      fundProgressEnd: fundProgressEnd ?? this.fundProgressEnd,
      fundProgressText: fundProgressText ?? this.fundProgressText,
      fundStatusUnpaidBg: fundStatusUnpaidBg ?? this.fundStatusUnpaidBg,
      fundStatusUnpaidText: fundStatusUnpaidText ?? this.fundStatusUnpaidText,
      fundRemindButtonBg: fundRemindButtonBg ?? this.fundRemindButtonBg,
      fundRemindButtonBorder:
          fundRemindButtonBorder ?? this.fundRemindButtonBorder,
      fundRemindButtonIcon: fundRemindButtonIcon ?? this.fundRemindButtonIcon,
      fundEditButtonBg: fundEditButtonBg ?? this.fundEditButtonBg,
      fundEditButtonFg: fundEditButtonFg ?? this.fundEditButtonFg,
      fundEditButtonBorder:
          fundEditButtonBorder ?? this.fundEditButtonBorder,
      fundCsvButtonBg: fundCsvButtonBg ?? this.fundCsvButtonBg,
      fundCsvButtonFg: fundCsvButtonFg ?? this.fundCsvButtonFg,
      fundCsvIcon: fundCsvIcon ?? this.fundCsvIcon,
      expenseCategoryIconBg:
          expenseCategoryIconBg ?? this.expenseCategoryIconBg,
      expenseCategoryIcon: expenseCategoryIcon ?? this.expenseCategoryIcon,
      expenseCategoryTag: expenseCategoryTag ?? this.expenseCategoryTag,
      expenseBadgeOwedBg: expenseBadgeOwedBg ?? this.expenseBadgeOwedBg,
      expenseBadgeOwedBorder:
          expenseBadgeOwedBorder ?? this.expenseBadgeOwedBorder,
      expenseBadgeOwedText: expenseBadgeOwedText ?? this.expenseBadgeOwedText,
      warningAccent: warningAccent ?? this.warningAccent,
      warningAccentBorder: warningAccentBorder ?? this.warningAccentBorder,
      infoAccent: infoAccent ?? this.infoAccent,
      orangeAccent: orangeAccent ?? this.orangeAccent,
      errorAccent: errorAccent ?? this.errorAccent,
      debtOweBg: debtOweBg ?? this.debtOweBg,
      debtOweBorder: debtOweBorder ?? this.debtOweBorder,
      debtOweText: debtOweText ?? this.debtOweText,
      debtOweAmount: debtOweAmount ?? this.debtOweAmount,
      debtReceiveBg: debtReceiveBg ?? this.debtReceiveBg,
      debtReceiveBorder: debtReceiveBorder ?? this.debtReceiveBorder,
      debtReceiveText: debtReceiveText ?? this.debtReceiveText,
      debtReceiveAmount: debtReceiveAmount ?? this.debtReceiveAmount,
      debtBalancedBg: debtBalancedBg ?? this.debtBalancedBg,
      debtBalancedText: debtBalancedText ?? this.debtBalancedText,
      debtPendingBg: debtPendingBg ?? this.debtPendingBg,
      debtPendingText: debtPendingText ?? this.debtPendingText,
      debtWaitingBg: debtWaitingBg ?? this.debtWaitingBg,
      debtWaitingText: debtWaitingText ?? this.debtWaitingText,
      debtHintBg: debtHintBg ?? this.debtHintBg,
      debtHintBorder: debtHintBorder ?? this.debtHintBorder,
      debtHintText: debtHintText ?? this.debtHintText,
      debtChipBg: debtChipBg ?? this.debtChipBg,
      debtAvatarBg: debtAvatarBg ?? this.debtAvatarBg,
      debtYouBadgeBorder: debtYouBadgeBorder ?? this.debtYouBadgeBorder,
      debtTabBadgeActiveBg: debtTabBadgeActiveBg ?? this.debtTabBadgeActiveBg,
      debtTabBadgeActiveText:
          debtTabBadgeActiveText ?? this.debtTabBadgeActiveText,
      debtTabBadgeInactiveBg:
          debtTabBadgeInactiveBg ?? this.debtTabBadgeInactiveBg,
      debtTabBadgeInactiveText:
          debtTabBadgeInactiveText ?? this.debtTabBadgeInactiveText,
      debtActionPayBg: debtActionPayBg ?? this.debtActionPayBg,
      debtActionConfirmBg: debtActionConfirmBg ?? this.debtActionConfirmBg,
      debtActionRejectFg: debtActionRejectFg ?? this.debtActionRejectFg,
      debtActionRejectBorder:
          debtActionRejectBorder ?? this.debtActionRejectBorder,
      debtActionRemindIcon: debtActionRemindIcon ?? this.debtActionRemindIcon,
      debtIconContainerBg: debtIconContainerBg ?? this.debtIconContainerBg,
      debtIconContainerBorder:
          debtIconContainerBorder ?? this.debtIconContainerBorder,
      debtIconContainerFg: debtIconContainerFg ?? this.debtIconContainerFg,
      qrCardBg: qrCardBg ?? this.qrCardBg,
      qrCardBorder: qrCardBorder ?? this.qrCardBorder,
      qrQuietZoneBg: qrQuietZoneBg ?? this.qrQuietZoneBg,
      qrQuietZoneBorder: qrQuietZoneBorder ?? this.qrQuietZoneBorder,
      qrTabActiveBg: qrTabActiveBg ?? this.qrTabActiveBg,
      qrTabActiveBorder: qrTabActiveBorder ?? this.qrTabActiveBorder,
      qrTabIconActiveBg: qrTabIconActiveBg ?? this.qrTabIconActiveBg,
      qrCodeForeground: qrCodeForeground ?? this.qrCodeForeground,
      qrShareButtonBg: qrShareButtonBg ?? this.qrShareButtonBg,
      qrShareButtonFg: qrShareButtonFg ?? this.qrShareButtonFg,
      inviteBannerBg: inviteBannerBg ?? this.inviteBannerBg,
      inviteBannerBorder: inviteBannerBorder ?? this.inviteBannerBorder,
      inviteBannerTitle: inviteBannerTitle ?? this.inviteBannerTitle,
      inviteBannerButtonBg: inviteBannerButtonBg ?? this.inviteBannerButtonBg,
      inviteBannerButtonFg: inviteBannerButtonFg ?? this.inviteBannerButtonFg,
      scannerBackground: scannerBackground ?? this.scannerBackground,
      scannerCorner: scannerCorner ?? this.scannerCorner,
      qrMockupCard: qrMockupCard ?? this.qrMockupCard,
      qrMockupFinder: qrMockupFinder ?? this.qrMockupFinder,
      qrMockupDot: qrMockupDot ?? this.qrMockupDot,
      debtStatusSettledDot: debtStatusSettledDot ?? this.debtStatusSettledDot,
      debtStatusPendingDot: debtStatusPendingDot ?? this.debtStatusPendingDot,
      debtStatusWaitingDot: debtStatusWaitingDot ?? this.debtStatusWaitingDot,
      filterChipActiveBg: filterChipActiveBg ?? this.filterChipActiveBg,
      filterChipActiveText: filterChipActiveText ?? this.filterChipActiveText,
      keypadDigitBg: keypadDigitBg ?? this.keypadDigitBg,
      keypadDigitText: keypadDigitText ?? this.keypadDigitText,
      keypadActionBg: keypadActionBg ?? this.keypadActionBg,
      keypadActionText: keypadActionText ?? this.keypadActionText,
      keypadClearBg: keypadClearBg ?? this.keypadClearBg,
      keypadClearText: keypadClearText ?? this.keypadClearText,
      keypadDeleteBg: keypadDeleteBg ?? this.keypadDeleteBg,
      keypadDeleteText: keypadDeleteText ?? this.keypadDeleteText,
      scannerHighlightBg: scannerHighlightBg ?? this.scannerHighlightBg,
      scannerHighlightBorder:
          scannerHighlightBorder ?? this.scannerHighlightBorder,
      scannerHighlightText: scannerHighlightText ?? this.scannerHighlightText,
      expenseCardSelectedBg:
          expenseCardSelectedBg ?? this.expenseCardSelectedBg,
      expenseCardSelectedBorder:
          expenseCardSelectedBorder ?? this.expenseCardSelectedBorder,
      expenseHeroAmount: expenseHeroAmount ?? this.expenseHeroAmount,
      expenseCategoryTagBg: expenseCategoryTagBg ?? this.expenseCategoryTagBg,
      expenseCategoryTagBorder:
          expenseCategoryTagBorder ?? this.expenseCategoryTagBorder,
      expenseCategoryTagText:
          expenseCategoryTagText ?? this.expenseCategoryTagText,
      expensePayerBadgeBg: expensePayerBadgeBg ?? this.expensePayerBadgeBg,
      expensePayerBadgeText:
          expensePayerBadgeText ?? this.expensePayerBadgeText,
      expensePayerAdvanceText:
          expensePayerAdvanceText ?? this.expensePayerAdvanceText,
      expenseSplitPaidBg: expenseSplitPaidBg ?? this.expenseSplitPaidBg,
      expenseSplitPaidText: expenseSplitPaidText ?? this.expenseSplitPaidText,
      expenseSplitUnpaidBg: expenseSplitUnpaidBg ?? this.expenseSplitUnpaidBg,
      expenseSplitUnpaidText:
          expenseSplitUnpaidText ?? this.expenseSplitUnpaidText,
      expenseSplitPendingBg:
          expenseSplitPendingBg ?? this.expenseSplitPendingBg,
      expenseSplitPendingText:
          expenseSplitPendingText ?? this.expenseSplitPendingText,
      expenseActionEditBg: expenseActionEditBg ?? this.expenseActionEditBg,
      expenseActionEditBorder:
          expenseActionEditBorder ?? this.expenseActionEditBorder,
      expenseActionEditText:
          expenseActionEditText ?? this.expenseActionEditText,
      expenseActionDeleteBg:
          expenseActionDeleteBg ?? this.expenseActionDeleteBg,
      expenseActionDeleteBorder:
          expenseActionDeleteBorder ?? this.expenseActionDeleteBorder,
      expenseActionDeleteText:
          expenseActionDeleteText ?? this.expenseActionDeleteText,
      expenseQuickDeleteBg: expenseQuickDeleteBg ?? this.expenseQuickDeleteBg,
      expenseQuickDeleteFg: expenseQuickDeleteFg ?? this.expenseQuickDeleteFg,
      expenseReceiptZoomText:
          expenseReceiptZoomText ?? this.expenseReceiptZoomText,
      financialCardBgStart: financialCardBgStart ?? this.financialCardBgStart,
      financialCardBgMiddle:
          financialCardBgMiddle ?? this.financialCardBgMiddle,
      financialCardBgEnd: financialCardBgEnd ?? this.financialCardBgEnd,
      financialCardBorder: financialCardBorder ?? this.financialCardBorder,
      financialCardShadow: financialCardShadow ?? this.financialCardShadow,
      financialCardIconBg: financialCardIconBg ?? this.financialCardIconBg,
      financialCardIcon: financialCardIcon ?? this.financialCardIcon,
      financialCardTitle: financialCardTitle ?? this.financialCardTitle,
      financialCardEyeToggle:
          financialCardEyeToggle ?? this.financialCardEyeToggle,
      financialCardBoxBg: financialCardBoxBg ?? this.financialCardBoxBg,
      financialCardBoxBorder:
          financialCardBoxBorder ?? this.financialCardBoxBorder,
      financialCardOweIcon: financialCardOweIcon ?? this.financialCardOweIcon,
      financialCardOweLabel:
          financialCardOweLabel ?? this.financialCardOweLabel,
      financialCardOweAmount:
          financialCardOweAmount ?? this.financialCardOweAmount,
      financialCardOweSubtitle:
          financialCardOweSubtitle ?? this.financialCardOweSubtitle,
      financialCardReceiveIcon:
          financialCardReceiveIcon ?? this.financialCardReceiveIcon,
      financialCardReceiveLabel:
          financialCardReceiveLabel ?? this.financialCardReceiveLabel,
      financialCardReceiveAmount:
          financialCardReceiveAmount ?? this.financialCardReceiveAmount,
      financialCardReceiveSubtitle:
          financialCardReceiveSubtitle ?? this.financialCardReceiveSubtitle,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
    covariant ThemeExtension<AppThemeColors>? other,
    double t,
  ) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      segmentBackground:
          Color.lerp(segmentBackground, other.segmentBackground, t)!,
      segmentActiveBackground: Color.lerp(
        segmentActiveBackground,
        other.segmentActiveBackground,
        t,
      )!,
      activePillBackground:
          Color.lerp(activePillBackground, other.activePillBackground, t)!,
      activePillText: Color.lerp(activePillText, other.activePillText, t)!,
      activePillBorder:
          Color.lerp(activePillBorder, other.activePillBorder, t)!,
      adminBadgeBackground:
          Color.lerp(adminBadgeBackground, other.adminBadgeBackground, t)!,
      adminBadgeBorder:
          Color.lerp(adminBadgeBorder, other.adminBadgeBorder, t)!,
      adminBadgeText:
          Color.lerp(adminBadgeText, other.adminBadgeText, t)!,
      memberBadgeBackground:
          Color.lerp(memberBadgeBackground, other.memberBadgeBackground, t)!,
      memberBadgeBorder:
          Color.lerp(memberBadgeBorder, other.memberBadgeBorder, t)!,
      memberBadgeText:
          Color.lerp(memberBadgeText, other.memberBadgeText, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      errorBorder: Color.lerp(errorBorder, other.errorBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      avatarDotBorder: Color.lerp(avatarDotBorder, other.avatarDotBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textSlate800: Color.lerp(textSlate800, other.textSlate800, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      themeToggleIcon: Color.lerp(themeToggleIcon, other.themeToggleIcon, t)!,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t)!,
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t)!,
      bottomNavShadow:
          BoxShadow.lerp(bottomNavShadow, other.bottomNavShadow, t)!,
      bottomNavBackground:
          Color.lerp(bottomNavBackground, other.bottomNavBackground, t)!,
      bottomNavBorder: Color.lerp(bottomNavBorder, other.bottomNavBorder, t)!,
      bottomNavInactive:
          Color.lerp(bottomNavInactive, other.bottomNavInactive, t)!,
      analyticsAccent: Color.lerp(analyticsAccent, other.analyticsAccent, t)!,
      analyticsIconBg: Color.lerp(analyticsIconBg, other.analyticsIconBg, t)!,
      bannerBackground: Color.lerp(bannerBackground, other.bannerBackground, t)!,
      bannerBorder: Color.lerp(bannerBorder, other.bannerBorder, t)!,
      badgeSuccessBg: Color.lerp(badgeSuccessBg, other.badgeSuccessBg, t)!,
      badgeSuccessText: Color.lerp(badgeSuccessText, other.badgeSuccessText, t)!,
      badgeWarningBg: Color.lerp(badgeWarningBg, other.badgeWarningBg, t)!,
      badgeWarningText: Color.lerp(badgeWarningText, other.badgeWarningText, t)!,
      badgeInfoBg: Color.lerp(badgeInfoBg, other.badgeInfoBg, t)!,
      badgeInfoText: Color.lerp(badgeInfoText, other.badgeInfoText, t)!,
      rankGoldBg: Color.lerp(rankGoldBg, other.rankGoldBg, t)!,
      rankGoldText: Color.lerp(rankGoldText, other.rankGoldText, t)!,
      rankSilverBg: Color.lerp(rankSilverBg, other.rankSilverBg, t)!,
      rankSilverText: Color.lerp(rankSilverText, other.rankSilverText, t)!,
      rankBronzeBg: Color.lerp(rankBronzeBg, other.rankBronzeBg, t)!,
      rankBronzeText: Color.lerp(rankBronzeText, other.rankBronzeText, t)!,
      brandEmerald: Color.lerp(brandEmerald, other.brandEmerald, t)!,
      brandEmeraldBorder:
          Color.lerp(brandEmeraldBorder, other.brandEmeraldBorder, t)!,
      brandEmeraldMuted:
          Color.lerp(brandEmeraldMuted, other.brandEmeraldMuted, t)!,
      badgeAmber: Color.lerp(badgeAmber, other.badgeAmber, t)!,
      badgeAmberBg: Color.lerp(badgeAmberBg, other.badgeAmberBg, t)!,
      badgeIndigo: Color.lerp(badgeIndigo, other.badgeIndigo, t)!,
      badgeIndigoBg: Color.lerp(badgeIndigoBg, other.badgeIndigoBg, t)!,
      badgeSuccess: Color.lerp(badgeSuccess, other.badgeSuccess, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      dragHandle: Color.lerp(dragHandle, other.dragHandle, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      primaryButton: Color.lerp(primaryButton, other.primaryButton, t)!,
      onPrimaryButton: Color.lerp(onPrimaryButton, other.onPrimaryButton, t)!,
      secondaryActionBg:
          Color.lerp(secondaryActionBg, other.secondaryActionBg, t)!,
      secondaryActionBorder:
          Color.lerp(secondaryActionBorder, other.secondaryActionBorder, t)!,
      secondaryActionText:
          Color.lerp(secondaryActionText, other.secondaryActionText, t)!,
      tabPillActiveBg: Color.lerp(tabPillActiveBg, other.tabPillActiveBg, t)!,
      tabPillActiveText:
          Color.lerp(tabPillActiveText, other.tabPillActiveText, t)!,
      roleAdminBg: Color.lerp(roleAdminBg, other.roleAdminBg, t)!,
      roleAdminText: Color.lerp(roleAdminText, other.roleAdminText, t)!,
      roleAdminBorder: Color.lerp(roleAdminBorder, other.roleAdminBorder, t)!,
      statusActiveBg: Color.lerp(statusActiveBg, other.statusActiveBg, t)!,
      statusActiveText:
          Color.lerp(statusActiveText, other.statusActiveText, t)!,
      statusArchivedBg:
          Color.lerp(statusArchivedBg, other.statusArchivedBg, t)!,
      statusArchivedText:
          Color.lerp(statusArchivedText, other.statusArchivedText, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      socialButtonBg: Color.lerp(socialButtonBg, other.socialButtonBg, t)!,
      socialButtonBorder:
          Color.lerp(socialButtonBorder, other.socialButtonBorder, t)!,
      otpBoxBg: Color.lerp(otpBoxBg, other.otpBoxBg, t)!,
      otpBoxFilledBg: Color.lerp(otpBoxFilledBg, other.otpBoxFilledBg, t)!,
      otpBoxBorder: Color.lerp(otpBoxBorder, other.otpBoxBorder, t)!,
      snackBarSuccessBg:
          Color.lerp(snackBarSuccessBg, other.snackBarSuccessBg, t)!,
      snackBarSuccessBorder:
          Color.lerp(snackBarSuccessBorder, other.snackBarSuccessBorder, t)!,
      snackBarSuccessBadge:
          Color.lerp(snackBarSuccessBadge, other.snackBarSuccessBadge, t)!,
      snackBarSuccessIcon:
          Color.lerp(snackBarSuccessIcon, other.snackBarSuccessIcon, t)!,
      snackBarSuccessText:
          Color.lerp(snackBarSuccessText, other.snackBarSuccessText, t)!,
      snackBarErrorBg: Color.lerp(snackBarErrorBg, other.snackBarErrorBg, t)!,
      snackBarErrorBorder:
          Color.lerp(snackBarErrorBorder, other.snackBarErrorBorder, t)!,
      snackBarErrorBadge:
          Color.lerp(snackBarErrorBadge, other.snackBarErrorBadge, t)!,
      snackBarErrorIcon:
          Color.lerp(snackBarErrorIcon, other.snackBarErrorIcon, t)!,
      snackBarErrorText:
          Color.lerp(snackBarErrorText, other.snackBarErrorText, t)!,
      snackBarWarningBg:
          Color.lerp(snackBarWarningBg, other.snackBarWarningBg, t)!,
      snackBarWarningBorder:
          Color.lerp(snackBarWarningBorder, other.snackBarWarningBorder, t)!,
      snackBarWarningBadge:
          Color.lerp(snackBarWarningBadge, other.snackBarWarningBadge, t)!,
      snackBarWarningIcon:
          Color.lerp(snackBarWarningIcon, other.snackBarWarningIcon, t)!,
      snackBarWarningText:
          Color.lerp(snackBarWarningText, other.snackBarWarningText, t)!,
      snackBarInfoBg: Color.lerp(snackBarInfoBg, other.snackBarInfoBg, t)!,
      snackBarInfoBorder:
          Color.lerp(snackBarInfoBorder, other.snackBarInfoBorder, t)!,
      snackBarInfoBadge:
          Color.lerp(snackBarInfoBadge, other.snackBarInfoBadge, t)!,
      snackBarInfoIcon:
          Color.lerp(snackBarInfoIcon, other.snackBarInfoIcon, t)!,
      snackBarInfoText:
          Color.lerp(snackBarInfoText, other.snackBarInfoText, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      memberHeroCardBg:
          Color.lerp(memberHeroCardBg, other.memberHeroCardBg, t)!,
      memberHeroCardBorder:
          Color.lerp(memberHeroCardBorder, other.memberHeroCardBorder, t)!,
      memberStatsBoxBg:
          Color.lerp(memberStatsBoxBg, other.memberStatsBoxBg, t)!,
      memberStatsBoxBorder:
          Color.lerp(memberStatsBoxBorder, other.memberStatsBoxBorder, t)!,
      memberOnlineDot:
          Color.lerp(memberOnlineDot, other.memberOnlineDot, t)!,
      memberAvatarBorder:
          Color.lerp(memberAvatarBorder, other.memberAvatarBorder, t)!,
      badgeWarningIcon:
          Color.lerp(badgeWarningIcon, other.badgeWarningIcon, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      dangerIconBg: Color.lerp(dangerIconBg, other.dangerIconBg, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      infoIconBg: Color.lerp(infoIconBg, other.infoIconBg, t)!,
      infoIconColor: Color.lerp(infoIconColor, other.infoIconColor, t)!,
      fundPiggyBg: Color.lerp(fundPiggyBg, other.fundPiggyBg, t)!,
      fundPiggyIcon: Color.lerp(fundPiggyIcon, other.fundPiggyIcon, t)!,
      fundStatusCollectingBg:
          Color.lerp(fundStatusCollectingBg, other.fundStatusCollectingBg, t)!,
      fundStatusCollectingText: Color.lerp(
          fundStatusCollectingText, other.fundStatusCollectingText, t)!,
      fundStatusCompletedBg:
          Color.lerp(fundStatusCompletedBg, other.fundStatusCompletedBg, t)!,
      fundStatusCompletedText: Color.lerp(
          fundStatusCompletedText, other.fundStatusCompletedText, t)!,
      fundAmountText: Color.lerp(fundAmountText, other.fundAmountText, t)!,
      fundProgressStart:
          Color.lerp(fundProgressStart, other.fundProgressStart, t)!,
      fundProgressEnd: Color.lerp(fundProgressEnd, other.fundProgressEnd, t)!,
      fundProgressText:
          Color.lerp(fundProgressText, other.fundProgressText, t)!,
      fundStatusUnpaidBg:
          Color.lerp(fundStatusUnpaidBg, other.fundStatusUnpaidBg, t)!,
      fundStatusUnpaidText:
          Color.lerp(fundStatusUnpaidText, other.fundStatusUnpaidText, t)!,
      fundRemindButtonBg:
          Color.lerp(fundRemindButtonBg, other.fundRemindButtonBg, t)!,
      fundRemindButtonBorder:
          Color.lerp(fundRemindButtonBorder, other.fundRemindButtonBorder, t)!,
      fundRemindButtonIcon:
          Color.lerp(fundRemindButtonIcon, other.fundRemindButtonIcon, t)!,
      fundEditButtonBg:
          Color.lerp(fundEditButtonBg, other.fundEditButtonBg, t)!,
      fundEditButtonFg:
          Color.lerp(fundEditButtonFg, other.fundEditButtonFg, t)!,
      fundEditButtonBorder:
          Color.lerp(fundEditButtonBorder, other.fundEditButtonBorder, t)!,
      fundCsvButtonBg: Color.lerp(fundCsvButtonBg, other.fundCsvButtonBg, t)!,
      fundCsvButtonFg: Color.lerp(fundCsvButtonFg, other.fundCsvButtonFg, t)!,
      fundCsvIcon: Color.lerp(fundCsvIcon, other.fundCsvIcon, t)!,
      expenseCategoryIconBg:
          Color.lerp(expenseCategoryIconBg, other.expenseCategoryIconBg, t)!,
      expenseCategoryIcon:
          Color.lerp(expenseCategoryIcon, other.expenseCategoryIcon, t)!,
      expenseCategoryTag:
          Color.lerp(expenseCategoryTag, other.expenseCategoryTag, t)!,
      expenseBadgeOwedBg:
          Color.lerp(expenseBadgeOwedBg, other.expenseBadgeOwedBg, t)!,
      expenseBadgeOwedBorder:
          Color.lerp(expenseBadgeOwedBorder, other.expenseBadgeOwedBorder, t)!,
      expenseBadgeOwedText:
          Color.lerp(expenseBadgeOwedText, other.expenseBadgeOwedText, t)!,
      warningAccent: Color.lerp(warningAccent, other.warningAccent, t)!,
      warningAccentBorder:
          Color.lerp(warningAccentBorder, other.warningAccentBorder, t)!,
      infoAccent: Color.lerp(infoAccent, other.infoAccent, t)!,
      orangeAccent: Color.lerp(orangeAccent, other.orangeAccent, t)!,
      errorAccent: Color.lerp(errorAccent, other.errorAccent, t)!,
      debtOweBg: Color.lerp(debtOweBg, other.debtOweBg, t)!,
      debtOweBorder: Color.lerp(debtOweBorder, other.debtOweBorder, t)!,
      debtOweText: Color.lerp(debtOweText, other.debtOweText, t)!,
      debtOweAmount: Color.lerp(debtOweAmount, other.debtOweAmount, t)!,
      debtReceiveBg: Color.lerp(debtReceiveBg, other.debtReceiveBg, t)!,
      debtReceiveBorder:
          Color.lerp(debtReceiveBorder, other.debtReceiveBorder, t)!,
      debtReceiveText: Color.lerp(debtReceiveText, other.debtReceiveText, t)!,
      debtReceiveAmount:
          Color.lerp(debtReceiveAmount, other.debtReceiveAmount, t)!,
      debtBalancedBg: Color.lerp(debtBalancedBg, other.debtBalancedBg, t)!,
      debtBalancedText:
          Color.lerp(debtBalancedText, other.debtBalancedText, t)!,
      debtPendingBg: Color.lerp(debtPendingBg, other.debtPendingBg, t)!,
      debtPendingText: Color.lerp(debtPendingText, other.debtPendingText, t)!,
      debtWaitingBg: Color.lerp(debtWaitingBg, other.debtWaitingBg, t)!,
      debtWaitingText: Color.lerp(debtWaitingText, other.debtWaitingText, t)!,
      debtHintBg: Color.lerp(debtHintBg, other.debtHintBg, t)!,
      debtHintBorder: Color.lerp(debtHintBorder, other.debtHintBorder, t)!,
      debtHintText: Color.lerp(debtHintText, other.debtHintText, t)!,
      debtChipBg: Color.lerp(debtChipBg, other.debtChipBg, t)!,
      debtAvatarBg: Color.lerp(debtAvatarBg, other.debtAvatarBg, t)!,
      debtYouBadgeBorder:
          Color.lerp(debtYouBadgeBorder, other.debtYouBadgeBorder, t)!,
      debtTabBadgeActiveBg:
          Color.lerp(debtTabBadgeActiveBg, other.debtTabBadgeActiveBg, t)!,
      debtTabBadgeActiveText:
          Color.lerp(debtTabBadgeActiveText, other.debtTabBadgeActiveText, t)!,
      debtTabBadgeInactiveBg:
          Color.lerp(debtTabBadgeInactiveBg, other.debtTabBadgeInactiveBg, t)!,
      debtTabBadgeInactiveText: Color.lerp(
          debtTabBadgeInactiveText, other.debtTabBadgeInactiveText, t)!,
      debtActionPayBg:
          Color.lerp(debtActionPayBg, other.debtActionPayBg, t)!,
      debtActionConfirmBg:
          Color.lerp(debtActionConfirmBg, other.debtActionConfirmBg, t)!,
      debtActionRejectFg:
          Color.lerp(debtActionRejectFg, other.debtActionRejectFg, t)!,
      debtActionRejectBorder:
          Color.lerp(debtActionRejectBorder, other.debtActionRejectBorder, t)!,
      debtActionRemindIcon:
          Color.lerp(debtActionRemindIcon, other.debtActionRemindIcon, t)!,
      debtIconContainerBg:
          Color.lerp(debtIconContainerBg, other.debtIconContainerBg, t)!,
      debtIconContainerBorder: Color.lerp(
          debtIconContainerBorder, other.debtIconContainerBorder, t)!,
      debtIconContainerFg:
          Color.lerp(debtIconContainerFg, other.debtIconContainerFg, t)!,
      qrCardBg: Color.lerp(qrCardBg, other.qrCardBg, t)!,
      qrCardBorder: Color.lerp(qrCardBorder, other.qrCardBorder, t)!,
      qrQuietZoneBg: Color.lerp(qrQuietZoneBg, other.qrQuietZoneBg, t)!,
      qrQuietZoneBorder:
          Color.lerp(qrQuietZoneBorder, other.qrQuietZoneBorder, t)!,
      qrTabActiveBg: Color.lerp(qrTabActiveBg, other.qrTabActiveBg, t)!,
      qrTabActiveBorder:
          Color.lerp(qrTabActiveBorder, other.qrTabActiveBorder, t)!,
      qrTabIconActiveBg:
          Color.lerp(qrTabIconActiveBg, other.qrTabIconActiveBg, t)!,
      qrCodeForeground:
          Color.lerp(qrCodeForeground, other.qrCodeForeground, t)!,
      qrShareButtonBg:
          Color.lerp(qrShareButtonBg, other.qrShareButtonBg, t)!,
      qrShareButtonFg:
          Color.lerp(qrShareButtonFg, other.qrShareButtonFg, t)!,
      inviteBannerBg:
          Color.lerp(inviteBannerBg, other.inviteBannerBg, t)!,
      inviteBannerBorder:
          Color.lerp(inviteBannerBorder, other.inviteBannerBorder, t)!,
      inviteBannerTitle:
          Color.lerp(inviteBannerTitle, other.inviteBannerTitle, t)!,
      inviteBannerButtonBg:
          Color.lerp(inviteBannerButtonBg, other.inviteBannerButtonBg, t)!,
      inviteBannerButtonFg:
          Color.lerp(inviteBannerButtonFg, other.inviteBannerButtonFg, t)!,
      scannerBackground:
          Color.lerp(scannerBackground, other.scannerBackground, t)!,
      scannerCorner: Color.lerp(scannerCorner, other.scannerCorner, t)!,
      qrMockupCard: Color.lerp(qrMockupCard, other.qrMockupCard, t)!,
      qrMockupFinder: Color.lerp(qrMockupFinder, other.qrMockupFinder, t)!,
      qrMockupDot: Color.lerp(qrMockupDot, other.qrMockupDot, t)!,
      debtStatusSettledDot:
          Color.lerp(debtStatusSettledDot, other.debtStatusSettledDot, t)!,
      debtStatusPendingDot:
          Color.lerp(debtStatusPendingDot, other.debtStatusPendingDot, t)!,
      debtStatusWaitingDot:
          Color.lerp(debtStatusWaitingDot, other.debtStatusWaitingDot, t)!,
      filterChipActiveBg:
          Color.lerp(filterChipActiveBg, other.filterChipActiveBg, t)!,
      filterChipActiveText:
          Color.lerp(filterChipActiveText, other.filterChipActiveText, t)!,
      keypadDigitBg: Color.lerp(keypadDigitBg, other.keypadDigitBg, t)!,
      keypadDigitText: Color.lerp(keypadDigitText, other.keypadDigitText, t)!,
      keypadActionBg: Color.lerp(keypadActionBg, other.keypadActionBg, t)!,
      keypadActionText:
          Color.lerp(keypadActionText, other.keypadActionText, t)!,
      keypadClearBg: Color.lerp(keypadClearBg, other.keypadClearBg, t)!,
      keypadClearText: Color.lerp(keypadClearText, other.keypadClearText, t)!,
      keypadDeleteBg: Color.lerp(keypadDeleteBg, other.keypadDeleteBg, t)!,
      keypadDeleteText:
          Color.lerp(keypadDeleteText, other.keypadDeleteText, t)!,
      scannerHighlightBg:
          Color.lerp(scannerHighlightBg, other.scannerHighlightBg, t)!,
      scannerHighlightBorder:
          Color.lerp(scannerHighlightBorder, other.scannerHighlightBorder, t)!,
      scannerHighlightText:
          Color.lerp(scannerHighlightText, other.scannerHighlightText, t)!,
      expenseCardSelectedBg:
          Color.lerp(expenseCardSelectedBg, other.expenseCardSelectedBg, t)!,
      expenseCardSelectedBorder: Color.lerp(
          expenseCardSelectedBorder, other.expenseCardSelectedBorder, t)!,
      expenseHeroAmount:
          Color.lerp(expenseHeroAmount, other.expenseHeroAmount, t)!,
      expenseCategoryTagBg:
          Color.lerp(expenseCategoryTagBg, other.expenseCategoryTagBg, t)!,
      expenseCategoryTagBorder: Color.lerp(
          expenseCategoryTagBorder, other.expenseCategoryTagBorder, t)!,
      expenseCategoryTagText: Color.lerp(
          expenseCategoryTagText, other.expenseCategoryTagText, t)!,
      expensePayerBadgeBg:
          Color.lerp(expensePayerBadgeBg, other.expensePayerBadgeBg, t)!,
      expensePayerBadgeText:
          Color.lerp(expensePayerBadgeText, other.expensePayerBadgeText, t)!,
      expensePayerAdvanceText: Color.lerp(
          expensePayerAdvanceText, other.expensePayerAdvanceText, t)!,
      expenseSplitPaidBg:
          Color.lerp(expenseSplitPaidBg, other.expenseSplitPaidBg, t)!,
      expenseSplitPaidText:
          Color.lerp(expenseSplitPaidText, other.expenseSplitPaidText, t)!,
      expenseSplitUnpaidBg:
          Color.lerp(expenseSplitUnpaidBg, other.expenseSplitUnpaidBg, t)!,
      expenseSplitUnpaidText:
          Color.lerp(expenseSplitUnpaidText, other.expenseSplitUnpaidText, t)!,
      expenseSplitPendingBg:
          Color.lerp(expenseSplitPendingBg, other.expenseSplitPendingBg, t)!,
      expenseSplitPendingText: Color.lerp(
          expenseSplitPendingText, other.expenseSplitPendingText, t)!,
      expenseActionEditBg:
          Color.lerp(expenseActionEditBg, other.expenseActionEditBg, t)!,
      expenseActionEditBorder: Color.lerp(
          expenseActionEditBorder, other.expenseActionEditBorder, t)!,
      expenseActionEditText:
          Color.lerp(expenseActionEditText, other.expenseActionEditText, t)!,
      expenseActionDeleteBg:
          Color.lerp(expenseActionDeleteBg, other.expenseActionDeleteBg, t)!,
      expenseActionDeleteBorder: Color.lerp(
          expenseActionDeleteBorder, other.expenseActionDeleteBorder, t)!,
      expenseActionDeleteText: Color.lerp(
          expenseActionDeleteText, other.expenseActionDeleteText, t)!,
      expenseQuickDeleteBg:
          Color.lerp(expenseQuickDeleteBg, other.expenseQuickDeleteBg, t)!,
      expenseQuickDeleteFg:
          Color.lerp(expenseQuickDeleteFg, other.expenseQuickDeleteFg, t)!,
      expenseReceiptZoomText: Color.lerp(
          expenseReceiptZoomText, other.expenseReceiptZoomText, t)!,
      financialCardBgStart:
          Color.lerp(financialCardBgStart, other.financialCardBgStart, t)!,
      financialCardBgMiddle:
          Color.lerp(financialCardBgMiddle, other.financialCardBgMiddle, t)!,
      financialCardBgEnd:
          Color.lerp(financialCardBgEnd, other.financialCardBgEnd, t)!,
      financialCardBorder:
          Color.lerp(financialCardBorder, other.financialCardBorder, t)!,
      financialCardShadow:
          BoxShadow.lerp(financialCardShadow, other.financialCardShadow, t)!,
      financialCardIconBg:
          Color.lerp(financialCardIconBg, other.financialCardIconBg, t)!,
      financialCardIcon:
          Color.lerp(financialCardIcon, other.financialCardIcon, t)!,
      financialCardTitle:
          Color.lerp(financialCardTitle, other.financialCardTitle, t)!,
      financialCardEyeToggle:
          Color.lerp(financialCardEyeToggle, other.financialCardEyeToggle, t)!,
      financialCardBoxBg:
          Color.lerp(financialCardBoxBg, other.financialCardBoxBg, t)!,
      financialCardBoxBorder:
          Color.lerp(financialCardBoxBorder, other.financialCardBoxBorder, t)!,
      financialCardOweIcon:
          Color.lerp(financialCardOweIcon, other.financialCardOweIcon, t)!,
      financialCardOweLabel:
          Color.lerp(financialCardOweLabel, other.financialCardOweLabel, t)!,
      financialCardOweAmount:
          Color.lerp(financialCardOweAmount, other.financialCardOweAmount, t)!,
      financialCardOweSubtitle: Color.lerp(
          financialCardOweSubtitle, other.financialCardOweSubtitle, t)!,
      financialCardReceiveIcon: Color.lerp(
          financialCardReceiveIcon, other.financialCardReceiveIcon, t)!,
      financialCardReceiveLabel: Color.lerp(
          financialCardReceiveLabel, other.financialCardReceiveLabel, t)!,
      financialCardReceiveAmount: Color.lerp(
          financialCardReceiveAmount, other.financialCardReceiveAmount, t)!,
      financialCardReceiveSubtitle: Color.lerp(
          financialCardReceiveSubtitle, other.financialCardReceiveSubtitle, t)!,
    );
  }
}

/// Tiện ích lấy nhanh colors từ BuildContext: `context.colors`
extension AppThemeContextExtension on BuildContext {
  AppThemeColors get colors => AppThemeColors.of(this);
}
