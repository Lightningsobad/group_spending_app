import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/widgets/group_category_helper.dart';

class AnalyticsGroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onTap;

  const AnalyticsGroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    final spendingVnd = group.totalSpendingVnd ??
        (group.totalSpending != null ? group.totalSpending! * 1000 : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [colors.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top row: Category icon, Name, Chevron button
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: GroupCategoryHelper.buildIcon(
                        group.category,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: AppTextStyle.bold(
                                    color: colors.textPrimary,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (group.isArchived) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.badgeWarningBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tr.filterArchivedTab,
                                    style: AppTextStyle.bold(
                                      color: colors.badgeWarningText,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${group.category} • ${tr.membersCountSubtitle(group.memberCount)}',
                            style: AppTextStyle.regular(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.divider,
                ),
                const SizedBox(height: 12),
                // Bottom row: "Tổng chi tiêu" + Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr.totalSpendingLabel,
                      style: AppTextStyle.regular(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatVnd(spendingVnd),
                      style: AppTextStyle.extraBold(
                        color: colors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
