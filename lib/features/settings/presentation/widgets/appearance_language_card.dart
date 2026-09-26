import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../l10n/l10n.dart';

class AppearanceLanguageCard extends StatelessWidget {
  const AppearanceLanguageCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final themeCubit = context.watch<ThemeCubit>();
    final localeCubit = context.watch<LocaleCubit>();

    final isDark = themeCubit.isDarkMode;
    final isEn = localeCubit.isEnglish;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder, width: 1.2),
        boxShadow: [colors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.appearanceLanguageSection,
            style: AppTextStyle.bold(
              fontSize: 12,
              color: colors.textSlate800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 16),

          // Theme Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.sun,
                  size: 20,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.themeModeTitle,
                      style: AppTextStyle.bold(fontSize: 13, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDark ? tr.themeDarkSubtitle : tr.themeLightSubtitle,
                      style: AppTextStyle.medium(
                        fontSize: 11,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Segmented theme control
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.segmentBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SegmentItem(
                      label: tr.lightThemeLabel,
                      icon: LucideIcons.sun,
                      isActive: !isDark,
                      activeColor: const Color(0xFFD97706),
                      onTap: () => themeCubit.setThemeMode(ThemeMode.light),
                    ),
                    _SegmentItem(
                      label: tr.darkThemeLabel,
                      icon: LucideIcons.moon,
                      isActive: isDark,
                      activeColor: AppColors.emeraldLight,
                      onTap: () => themeCubit.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 16),

          // Language Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.globe,
                  size: 20,
                  color: AppColors.emeraldForest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.displayLanguageTitle,
                      style: AppTextStyle.bold(fontSize: 13, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr.displayLanguageSubtitle,
                      style: AppTextStyle.medium(
                        fontSize: 11,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Segmented language control
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.segmentBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SegmentItem(
                      label: 'VN VI',
                      isActive: !isEn,
                      activeColor: AppColors.emeraldForest,
                      onTap: () => localeCubit.setLocale(const Locale('vi')),
                    ),
                    _SegmentItem(
                      label: 'GB EN',
                      isActive: isEn,
                      activeColor: AppColors.emeraldForest,
                      onTap: () => localeCubit.setLocale(const Locale('en')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.label,
    this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.segmentActiveBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isActive ? activeColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyle.bold(
                fontSize: 11,
                color: isActive ? activeColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
