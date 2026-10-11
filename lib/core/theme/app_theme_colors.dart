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
    );
  }
}

/// Tiện ích lấy nhanh colors từ BuildContext: `context.colors`
extension AppThemeContextExtension on BuildContext {
  AppThemeColors get colors => AppThemeColors.of(this);
}
