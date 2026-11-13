import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/presentation/widgets/group_category_helper.dart';
import '../../domain/entities/group_debt_entity.dart';

class GroupDebtSummaryCard extends StatelessWidget {
  final DebtUserBalanceEntity userBalance;
  final String? subtitle;

  const GroupDebtSummaryCard({
    super.key,
    required this.userBalance,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    final isSettled = userBalance.netBalanceVnd == 0;
    final isReceiving = userBalance.netBalanceVnd > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Top Row: Icon, Group Name, Subtitle, Status Badge
          Row(
            children: [
              GroupCategoryHelper.buildCategoryBadge(
                context,
                userBalance.category,
                size: 44,
                borderRadius: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userBalance.groupName,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.body,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyle.regular(
                          fontSize: AppFontSize.caption,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSettled
                      ? colors.debtBalancedBg
                      : isReceiving
                          ? colors.debtReceiveBg
                          : colors.debtOweBg,
                  borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 14),
          Divider(height: 1, color: colors.cardBorder),
          const SizedBox(height: 14),

          // 2. Bottom Row: Label & Net Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.yourBalanceInGroup,
                style: AppTextStyle.medium(
                  fontSize: AppFontSize.caption,
                  color: colors.textSecondary,
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    isSettled
                        ? tr.debtsBalanced
                        : CurrencyUtils.formatVnd(
                            userBalance.netBalanceVnd,
                            showSign: true,
                          ),
                    style: AppTextStyle.bold(
                      fontSize: AppFontSize.h3,
                      color: isSettled
                          ? colors.textPrimary
                          : isReceiving
                              ? colors.debtReceiveText
                              : colors.debtOweText,
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
