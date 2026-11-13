import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class GroupFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GroupFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.filterChipActiveBg : colors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colors.filterChipActiveBg : colors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyle.bold(
              fontSize: AppFontSize.caption,
              color: isSelected ? colors.filterChipActiveText : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
