import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../data/models/expense_models.dart';

class ExpenseCardWidget extends StatelessWidget {
  final ExpenseListItemModel expense;
  final VoidCallback onTap;
  final VoidCallback? onReceiptTap;

  const ExpenseCardWidget({
    super.key,
    required this.expense,
    required this.onTap,
    this.onReceiptTap,
  });

  String _formatDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '---';
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy - HH:mm').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cat = expense.categoryType;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Category icon, Title, Amount & Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        cat.icon,
                        color: const Color(0xFF2E7D32),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: AppTextStyle.bold(
                              fontSize: 15,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Date & Category tag
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.calendar,
                                size: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateTime(expense.expenseDate),
                                style: AppTextStyle.regular(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.tag,
                                size: 12,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cat.labelVi,
                                style: AppTextStyle.medium(
                                  fontSize: 12,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Amount and chevron
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyUtils.formatVnd(expense.amountVnd),
                          style: AppTextStyle.bold(
                            fontSize: 15,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Bottom row: Payer, Payment Status badge & View Receipt
                Row(
                  children: [
                    // Payer info
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Người trả: ',
                          style: AppTextStyle.regular(fontSize: 12, color: colors.textSecondary),
                          children: [
                            TextSpan(
                              text: expense.isPaidByMe ? '${expense.paidBy} (Bạn)' : expense.paidBy,
                              style: AppTextStyle.bold(fontSize: 12, color: colors.textPrimary),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Payment Status Badge
                    if (expense.isPaidByMe)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.check, size: 12, color: Color(0xFF15803D)),
                            SizedBox(width: 4),
                            Text(
                              'Bạn đã thanh toán',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (expense.myAmountOwedVnd > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Bạn nợ: ${CurrencyUtils.formatVnd(expense.myAmountOwedVnd)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
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
  }
}
