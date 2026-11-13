import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/presentation/widgets/group_category_helper.dart';
import '../../domain/entities/debt_overview_entity.dart';

class GroupDebtCardWidget extends StatelessWidget {
  final GroupDebtBalanceEntity item;
  final VoidCallback onTap;

  const GroupDebtCardWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    final isSettled = item.netBalanceVnd == 0;
    final isReceiving = item.netBalanceVnd > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadowColor,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Group Category Badge Box
                GroupCategoryHelper.buildCategoryBadge(
                  context,
                  item.category,
                  size: 44,
                  borderRadius: 14,
                ),
                const SizedBox(width: 12),

                // 2. Group Name & Status Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.groupName,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.secondary,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (isSettled && item.pendingDebtCount == 0)
                        Row(
                          children: [
                            Icon(
                              LucideIcons.check,
                              size: 13,
                              color: colors.debtReceiveText,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tr.debtsSettledAll,
                                style: AppTextStyle.semiBold(
                                  fontSize: AppFontSize.caption,
                                  color: colors.debtReceiveText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 13,
                              color: colors.debtPendingText,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tr.debtsPendingCount(
                                  item.pendingDebtCount > 0
                                      ? item.pendingDebtCount
                                      : 1,
                                ),
                                style: AppTextStyle.semiBold(
                                  fontSize: AppFontSize.caption,
                                  color: colors.debtPendingText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Amount & Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isSettled
                          ? tr.debtsBalanced
                          : CurrencyUtils.formatVnd(
                              item.netBalanceVnd,
                              showSign: true,
                            ),
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.secondary,
                        color: isSettled
                            ? colors.textPrimary
                            : isReceiving
                                ? colors.debtReceiveText
                                : colors.debtOweText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSettled
                            ? colors.debtBalancedBg
                            : isReceiving
                                ? colors.debtReceiveBg
                                : colors.debtOweBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isSettled
                            ? tr.badgeBalanced
                            : isReceiving
                                ? tr.badgeYouReceive
                                : tr.badgeYouMustPay,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.caption,
                          color: isSettled
                              ? colors.debtBalancedText
                              : isReceiving
                                  ? colors.debtReceiveText
                                  : colors.debtOweText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),

                // 4. Chevron Right Icon
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
