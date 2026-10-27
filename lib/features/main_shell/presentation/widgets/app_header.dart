import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import 'notification_modal.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const AppHeader({
    super.key,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final themeCubit = context.watch<ThemeCubit>();
    final localeCubit = context.watch<LocaleCubit>();
    final authState = context.watch<AuthCubit>().state;
    final prefs = context.read<AppPreferences>();

    final isDark = themeCubit.isDarkMode;
    final isEn = localeCubit.isEnglish;

    final user = authState.currentUser;
    final name = (user?.fullName.isNotEmpty == true)
        ? user!.fullName
        : (prefs.getUserFullName() ?? '');
    final avatarUrl = user?.avatarUrl;
    final initials = NameUtils.getInitials(name);

    int unreadCount = 0;
    try {
      unreadCount = context.watch<NotificationsCubit>().state.unreadCount;
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // User Avatar & Name Cluster (tappable to Settings)
          Expanded(
            child: Tooltip(
              message: tr.settingsTitle,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    child: Row(
                      children: [
                        // User Avatar with Online Dot
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.emerald.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF065F46), Color(0xFF047857)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Text(
                                          initials,
                                          style: AppTextStyle.bold(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        initials,
                                        style: AppTextStyle.bold(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colors.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Greeting & Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tr.greeting,
                                style: AppTextStyle.medium(
                                  fontSize: 11,
                                  color: colors.textSecondary,
                                ),
                              ),
                              Text(
                                name,
                                style: AppTextStyle.bold(
                                  fontSize: 15,
                                  color: colors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Actions: Theme, Language, Notifications
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Theme toggle button
              _HeaderIconButton(
                icon: isDark ? LucideIcons.sun : LucideIcons.moon,
                iconColor: colors.themeToggleIcon,
                backgroundColor: colors.cardBackground,
                borderColor: colors.cardBorder,
                tooltip: tr.themeModeTitle,
                onTap: () => themeCubit.toggleTheme(),
              ),
              const SizedBox(width: 8),

              // 2. Language toggle button
              _HeaderIconButton(
                icon: LucideIcons.languages,
                iconColor: colors.iconPrimary,
                backgroundColor: colors.cardBackground,
                borderColor: colors.cardBorder,
                tooltip: tr.displayLanguageTitle,
                badgeText: isEn ? 'EN' : 'VI',
                badgeColor: AppColors.emeraldForest,
                onTap: () => localeCubit.toggleLocale(),
              ),
              const SizedBox(width: 8),

              // 3. Notifications bell button
              _HeaderIconButton(
                icon: LucideIcons.bell,
                iconColor: colors.iconPrimary,
                backgroundColor: colors.cardBackground,
                borderColor: colors.cardBorder,
                tooltip: tr.notificationsTitle,
                badgeText: unreadCount > 0
                    ? (unreadCount > 99 ? '99+' : '$unreadCount')
                    : null,
                badgeColor: AppColors.error,
                hasRedDot: false,
                onTap: () => NotificationModal.show(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String tooltip;
  final String? badgeText;
  final Color? badgeColor;
  final bool hasRedDot;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.tooltip,
    this.badgeText,
    this.badgeColor,
    this.hasRedDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.1),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 18, color: iconColor),
                // Text badge (e.g. VI/EN)
                if (badgeText != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.emeraldForest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText!,
                        style: AppTextStyle.bold(
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Red unread notification dot
                if (hasRedDot)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
