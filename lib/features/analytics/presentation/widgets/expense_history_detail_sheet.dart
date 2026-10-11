import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../expenses/data/models/expense_enums.dart';
import '../../domain/entities/expense_history_entity.dart';

class ExpenseHistoryDetailSheet extends StatelessWidget {
  final ExpenseHistoryItemEntity expense;
  final VoidCallback? onViewGroupAnalytics;

  const ExpenseHistoryDetailSheet({
    super.key,
    required this.expense,
    this.onViewGroupAnalytics,
  });

  static Future<void> show(
    BuildContext context, {
    required ExpenseHistoryItemEntity expense,
    VoidCallback? onViewGroupAnalytics,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExpenseHistoryDetailSheet(
        expense: expense,
        onViewGroupAnalytics: onViewGroupAnalytics,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;
    final category = ExpenseCategoryType.fromString(expense.categoryName);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header title & close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.expenseDetailModalTitle,
                style: AppTextStyle.bold(
                  color: colors.textPrimary,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.x, size: 20, color: colors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount display
          Center(
            child: Column(
              children: [
                Text(
                  CurrencyUtils.formatVnd(expense.totalAmountVnd),
                  style: AppTextStyle.extraBold(
                    color: colors.analyticsAccent,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  expense.title,
                  style: AppTextStyle.bold(
                    color: colors.textPrimary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Meta details container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              children: [
                // Category row
                _buildInfoRow(
                  context,
                  icon: category.icon,
                  iconColor: category.themeColor,
                  label: tr.expenseCategoryLabel,
                  value: category.labelVi,
                ),
                Divider(height: 20, thickness: 1, color: colors.divider),

                // Group row
                _buildInfoRow(
                  context,
                  icon: LucideIcons.users,
                  iconColor: colors.analyticsAccent,
                  label: tr.expenseGroupLabel,
                  value: expense.groupName,
                ),
                Divider(height: 20, thickness: 1, color: colors.divider),

                // Date row
                _buildInfoRow(
                  context,
                  icon: LucideIcons.calendar,
                  iconColor: colors.textSecondary,
                  label: tr.expenseDateLabel,
                  value: expense.expenseDate,
                ),
                Divider(height: 20, thickness: 1, color: colors.divider),

                // Paid by row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: colors.badgeSuccessBg,
                      child: Text(
                        NameUtils.getInitials(expense.paidByUserName),
                        style: AppTextStyle.bold(
                          color: colors.badgeSuccessText,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tr.paidByPrefix(expense.paidByUserName),
                      style: AppTextStyle.medium(
                        color: colors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action button
          if (onViewGroupAnalytics != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onViewGroupAnalytics?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.analyticsAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(LucideIcons.arrowRight, size: 18),
                label: Text(
                  tr.viewGroupAnalyticsAction,
                  style: AppTextStyle.bold(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyle.regular(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyle.bold(
            color: colors.textPrimary,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
