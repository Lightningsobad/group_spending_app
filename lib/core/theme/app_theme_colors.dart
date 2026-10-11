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

  const AppThemeColors({
    required this.background,
    required this.cardBackground,
    required this.cardBorder,
    required this.surfaceMuted,
    required this.segmentBackground,
    required this.segmentActiveBackground,
    required this.activePillBackground,
    required this.activePillText,
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
    );
  }
}

/// Tiện ích lấy nhanh colors từ BuildContext: `context.colors`
extension AppThemeContextExtension on BuildContext {
  AppThemeColors get colors => AppThemeColors.of(this);
}
