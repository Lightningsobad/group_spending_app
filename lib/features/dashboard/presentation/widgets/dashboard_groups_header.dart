import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class DashboardGroupsHeader extends StatelessWidget {
  final int groupCount;
  final VoidCallback? onSeeAll;
  final bool isLoading;

  const DashboardGroupsHeader({
    super.key,
    required this.groupCount,
    this.onSeeAll,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.users,
              size: 18,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              tr.yourGroupsSection,
              style: AppTextStyle.bold(
                fontSize: 13,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        if (!isLoading)
          InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr.seeAllGroupsCount(groupCount),
                  style: AppTextStyle.bold(
                    fontSize: 12,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 14,
                  color: AppColors.emerald,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
