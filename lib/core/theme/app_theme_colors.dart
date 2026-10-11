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
    );
  }
}

/// Tiện ích lấy nhanh colors từ BuildContext: `context.colors`
extension AppThemeContextExtension on BuildContext {
  AppThemeColors get colors => AppThemeColors.of(this);
}
