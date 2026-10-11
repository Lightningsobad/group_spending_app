import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class AuthModeSwitcher extends StatelessWidget {
  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  const AuthModeSwitcher({
    super.key,
    required this.isLoginMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.segmentBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder, width: 1.2),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            alignment: isLoginMode
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.segmentActiveBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadowColor,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(true),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyle.extraBold(
                        fontSize: AppFontSize.secondary,
                        color: isLoginMode
                            ? AppColors.emeraldForest
                            : colors.textSecondary,
                      ),
                      child: Text(tr.loginTab),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(false),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyle.extraBold(
                        fontSize: AppFontSize.secondary,
                        color: !isLoginMode
                            ? AppColors.emeraldForest
                            : colors.textSecondary,
                      ),
                      child: Text(tr.registerTab),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
