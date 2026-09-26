import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class GroupsEmptyView extends StatelessWidget {
  final bool isSearching;

  const GroupsEmptyView({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.folderSearch,
            size: 40,
            color: colors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching
                ? tr.noMatchingGroupsTitle
                : tr.noGroupsInTabTitle,
            style: AppTextStyle.bold(
              fontSize: 15,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? tr.noMatchingGroupsSubtitle
                : tr.noGroupsInTabSubtitle,
            style: AppTextStyle.regular(
              fontSize: 13,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
