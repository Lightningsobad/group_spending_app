import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class PasswordResetHeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final List<Color>? gradientColors;
  final bool showShield;

  const PasswordResetHeaderIcon({
    super.key,
    required this.icon,
    this.iconColor = AppColors.emeraldForest,
    this.backgroundColor = AppColors.successBg,
    this.gradientColors,
    this.showShield = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: gradientColors == null ? backgroundColor : null,
              gradient: gradientColors != null
                  ? LinearGradient(
                      colors: gradientColors!,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
          ),
          if (showShield)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
