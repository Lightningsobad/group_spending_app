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

  // Semantic Brand & Badges (Centralized Light / Dark Tokens)
  final Color brandEmerald;
  final Color brandEmeraldBorder;
  final Color brandEmeraldMuted;
  final Color badgeAmber;
  final Color badgeAmberBg;
  final Color badgeIndigo;
  final Color badgeIndigoBg;
  final Color badgeSuccess;
  final Color badgeSuccessBg;
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
    required this.brandEmerald,
    required this.brandEmeraldBorder,
    required this.brandEmeraldMuted,
    required this.badgeAmber,
    required this.badgeAmberBg,
    required this.badgeIndigo,
    required this.badgeIndigoBg,
    required this.badgeSuccess,
    required this.badgeSuccessBg,
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
    brandEmerald: AppColors.emeraldForest,
    brandEmeraldBorder: AppColors.emerald,
    brandEmeraldMuted: Color(0xFFD1FAE5),
    badgeAmber: Color(0xFFD97706),
    badgeAmberBg: Color(0xFFFEF3C7),
    badgeIndigo: Color(0xFF4F46E5),
    badgeIndigoBg: Color(0xFFEEF2FF),
    badgeSuccess: Color(0xFF16A34A),
    badgeSuccessBg: Color(0xFFDCFCE7),
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
    brandEmerald: AppColors.emeraldLight,
    brandEmeraldBorder: Color(0x9934D399),
    brandEmeraldMuted: Color(0xFF064E3B),
    badgeAmber: Color(0xFFFBBF24),
    badgeAmberBg: Color(0x5978350F),
    badgeIndigo: Color(0xFF818CF8),
    badgeIndigoBg: Color(0x59312E81),
    badgeSuccess: Color(0xFF4ADE80),
    badgeSuccessBg: Color(0x66064E3B),
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
    Color? brandEmerald,
    Color? brandEmeraldBorder,
    Color? brandEmeraldMuted,
    Color? badgeAmber,
    Color? badgeAmberBg,
    Color? badgeIndigo,
    Color? badgeIndigoBg,
    Color? badgeSuccess,
    Color? badgeSuccessBg,
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
      brandEmerald: brandEmerald ?? this.brandEmerald,
      brandEmeraldBorder: brandEmeraldBorder ?? this.brandEmeraldBorder,
      brandEmeraldMuted: brandEmeraldMuted ?? this.brandEmeraldMuted,
      badgeAmber: badgeAmber ?? this.badgeAmber,
      badgeAmberBg: badgeAmberBg ?? this.badgeAmberBg,
      badgeIndigo: badgeIndigo ?? this.badgeIndigo,
      badgeIndigoBg: badgeIndigoBg ?? this.badgeIndigoBg,
      badgeSuccess: badgeSuccess ?? this.badgeSuccess,
      badgeSuccessBg: badgeSuccessBg ?? this.badgeSuccessBg,
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
      badgeSuccessBg: Color.lerp(badgeSuccessBg, other.badgeSuccessBg, t)!,
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
    );
  }
}

/// Tiện ích lấy nhanh colors từ BuildContext: `context.colors`
extension AppThemeContextExtension on BuildContext {
  AppThemeColors get colors => AppThemeColors.of(this);
}
