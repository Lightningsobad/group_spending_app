import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class PasswordResetHeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final bool showShield;

  const PasswordResetHeaderIcon({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.gradientColors,
    this.showShield = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedIconColor = iconColor ?? colors.activePillText;
    final resolvedBgColor = backgroundColor ?? colors.activePillBackground;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: gradientColors == null ? resolvedBgColor : null,
              gradient: gradientColors != null
                  ? LinearGradient(
                      colors: gradientColors!,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors.cardBorder,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: resolvedIconColor,
            ),
          ),
          if (showShield)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.cardBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.shieldCheck,
                  size: 15,
                  color: AppColors.emerald,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
