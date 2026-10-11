import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/expense_history_entity.dart';

class RecentExpensesSection extends StatelessWidget {
  final List<ExpenseHistoryItemEntity> expenses;
  final ValueChanged<ExpenseHistoryItemEntity>? onTapItem;

  const RecentExpensesSection({
    super.key,
    required this.expenses,
    this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.receiptText,
                  size: 18,
                  color: colors.analyticsAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  tr.recentExpensesTitle,
                  style: AppTextStyle.bold(
                    color: colors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              tr.expensesCountBadge(expenses.length),
              style: AppTextStyle.regular(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Text(
              tr.noExpensesRecorded,
              style: AppTextStyle.regular(color: colors.textMuted),
            ),
          )
        else
          ...expenses.map((expense) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onTapItem?.call(expense),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Receipt icon in theme rounded box
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.badgeSuccessBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.receipt,
                            size: 20,
                            color: colors.badgeSuccessText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.title,
                                style: AppTextStyle.bold(
                                  color: colors.textPrimary,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${expense.expenseDate} • ${tr.paidByPrefix(expense.paidByUserName)}',
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
                        // Amount & Detail link
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyUtils.formatVnd(expense.totalAmountVnd),
                              style: AppTextStyle.bold(
                                color: colors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                tr.viewExpenseDetailAction,
                                style: AppTextStyle.bold(
                                  color: colors.analyticsAccent,
                                  fontSize: 13,
                                ),
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
          }),
      ],
    );
  }
}
