import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/group_debt_entity.dart';
import 'settle_debt_dialogs.dart';

class ActualDebtCardWidget extends StatelessWidget {
  final ActualDebtEntity debt;
  final void Function(ActualDebtorEntity debtor)? onDebtorPay;
  final void Function(ActualDebtorEntity debtor, bool confirmed)?
      onDebtorConfirm;
  final void Function(ActualDebtorEntity debtor)? onDebtorRemind;
  final void Function(ActualDebtorEntity debtor)? onDebtorTap;

  const ActualDebtCardWidget({
    super.key,
    required this.debt,
    this.onDebtorPay,
    this.onDebtorConfirm,
    this.onDebtorRemind,
    this.onDebtorTap,
  });

  String _formatExpenseDateTime(String? expenseDate, String? createdAt) {
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        return DateFormat('dd/MM/yyyy - HH:mm').format(dt);
      } catch (_) {}
    }
    if (expenseDate != null && expenseDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(expenseDate);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {}
    }
    return '---';
  }

  String _formatCompactAmount(num amount, num amountVnd) {
    if (amount > 0) {
      final formatted = amount.toString().replaceAll(RegExp(r'\.0$'), '');
      return '${formatted}k';
    }
    if (amountVnd >= 1000) {
      return '${(amountVnd / 1000).round()}k';
    }
    return CurrencyUtils.formatVnd(amountVnd);
  }

  Color _getStatusDotColor(DebtStatus status, AppThemeColors colors) {
    switch (status) {
      case DebtStatus.settled:
        return colors.debtStatusSettledDot;
      case DebtStatus.pending:
        return colors.debtStatusPendingDot;
      case DebtStatus.waitingForConfirmation:
        return colors.debtStatusWaitingDot;
      case DebtStatus.rejected:
        return colors.debtStatusPendingDot;
    }
  }

  void _handleDebtorTap(BuildContext context, ActualDebtorEntity debtor) async {
    if (onDebtorTap != null) {
      onDebtorTap!(debtor);
      return;
    }

    final formattedAmount = CurrencyUtils.formatVnd(debtor.amountVnd);

    switch (debtor.action) {
      case DebtAction.pay:
        final ok = await SettleDebtDialogs.showPayConfirm(
          context,
          creditorName: debt.paidByUserName,
          formattedAmount: formattedAmount,
        );
        if (ok == true) {
          onDebtorPay?.call(debtor);
        }
        break;

      case DebtAction.confirm:
        final confirmed = await SettleDebtDialogs.showConfirmSettled(
          context,
          debtorName: debtor.name,
          formattedAmount: formattedAmount,
          confirmed: true,
        );
        if (confirmed == true) {
          onDebtorConfirm?.call(debtor, true);
        }
        break;

      case DebtAction.remind:
        final ok = await SettleDebtDialogs.showRemindConfirm(
          context,
          debtorName: debtor.name,
          formattedAmount: formattedAmount,
        );
        if (ok == true) {
          onDebtorRemind?.call(debtor);
        }
        break;

      case DebtAction.none:
        _showDebtorDetailSheet(context, debtor);
        break;
    }
  }

  void _showDebtorDetailSheet(BuildContext context, ActualDebtorEntity debtor) {
    final tr = context.l10n;
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String statusLabel;
        Color statusBg;
        Color statusFg;
        switch (debtor.status) {
          case DebtStatus.settled:
            statusLabel = tr.debtStatusSettled;
            statusBg = colors.debtReceiveBg;
            statusFg = colors.debtReceiveText;
            break;
          case DebtStatus.waitingForConfirmation:
            statusLabel = tr.debtStatusWaiting;
            statusBg = colors.debtWaitingBg;
            statusFg = colors.debtWaitingText;
            break;
          case DebtStatus.pending:
            statusLabel = tr.debtStatusPending;
            statusBg = colors.debtPendingBg;
            statusFg = colors.debtPendingText;
            break;
          case DebtStatus.rejected:
            statusLabel = tr.rejectReceivedAction;
            statusBg = colors.debtPendingBg;
            statusFg = colors.debtPendingText;
            break;
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colors.debtAvatarBg,
                      backgroundImage: debtor.avatarUrl != null &&
                              debtor.avatarUrl!.isNotEmpty
                          ? NetworkImage(debtor.avatarUrl!)
                          : null,
                      child: debtor.avatarUrl == null ||
                              debtor.avatarUrl!.isEmpty
                          ? Text(
                              NameUtils.getInitials(debtor.name),
                              style: AppTextStyle.bold(
                                fontSize: AppFontSize.caption,
                                color: colors.textPrimary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debtor.isMe
                                ? '${debtor.name} (${tr.youTag})'
                                : debtor.name,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.body,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            debt.title,
                            style: AppTextStyle.regular(
                              fontSize: AppFontSize.caption,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.caption,
                          color: statusFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số tiền nợ:',
                        style: AppTextStyle.medium(
                          fontSize: AppFontSize.caption,
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatVnd(debtor.amountVnd),
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.body,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Người nhận (Chủ nợ):',
                      style: AppTextStyle.regular(
                        fontSize: AppFontSize.caption,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      debt.isPaidByMe
                          ? '${debt.paidByUserName} (${tr.youTag})'
                          : debt.paidByUserName,
                      style: AppTextStyle.semiBold(
                        fontSize: AppFontSize.caption,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    final formattedDate =
        _formatExpenseDateTime(debt.expenseDate, debt.createdAt);
    final category =
        debt.categoryName.isNotEmpty ? debt.categoryName : 'Ăn uống';
    final debtorCount =
        debt.debtorCount > 0 ? debt.debtorCount : debt.debtors.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top row: Category tag + Date/Time (Left) | "TỔNG CHI" + Amount (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Category chip & date
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.debtReceiveBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.debtReceiveBorder),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.caption,
                        color: colors.debtReceiveText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: AppTextStyle.regular(
                      fontSize: AppFontSize.caption,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Right: TỔNG CHI and amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tr.totalExpenseCaps,
                    style: AppTextStyle.semiBold(
                      fontSize: AppFontSize.caption,
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      CurrencyUtils.formatVnd(debt.totalAmountVnd),
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.body,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Title
          Text(
            debt.title,
            style: AppTextStyle.bold(
              fontSize: AppFontSize.body,
              color: colors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // 3. Payer Info
          Text.rich(
            TextSpan(
              text: tr.paidByLabel,
              style: AppTextStyle.regular(
                fontSize: AppFontSize.caption,
                color: colors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: debt.isPaidByMe
                      ? '${debt.paidByUserName} (${tr.youTag})'
                      : debt.paidByUserName,
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.caption,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),

          // 4. Allocation Section Header: "PHÂN BỐ THEO THÀNH VIÊN:" & "{count} người nợ"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.allocationByMember,
                style: AppTextStyle.semiBold(
                  fontSize: AppFontSize.caption,
                  color: colors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                tr.debtorCountLabel(debtorCount),
                style: AppTextStyle.regular(
                  fontSize: AppFontSize.caption,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 5. Debtor Chips Grid (2 columns)
          if (debt.debtors.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 10) / 2;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: debt.debtors.map((debtor) {
                    return _buildDebtorChip(
                      context: context,
                      debtor: debtor,
                      width: itemWidth,
                      colors: colors,
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDebtorChip({
    required BuildContext context,
    required ActualDebtorEntity debtor,
    required double width,
    required AppThemeColors colors,
  }) {
    final dotColor = _getStatusDotColor(debtor.status, colors);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleDebtorTap(context, debtor),
        child: Container(
          width: width,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colors.debtChipBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 14,
                backgroundColor: colors.debtAvatarBg,
                backgroundImage: debtor.avatarUrl != null &&
                        debtor.avatarUrl!.isNotEmpty
                    ? NetworkImage(debtor.avatarUrl!)
                    : null,
                child: debtor.avatarUrl == null || debtor.avatarUrl!.isEmpty
                    ? Text(
                        NameUtils.getInitials(debtor.name),
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.caption,
                          color: colors.textPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),

              // Debtor Name
              Expanded(
                child: Text(
                  debtor.name,
                  style: AppTextStyle.medium(
                    fontSize: AppFontSize.caption,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),

              // Amount (e.g. 320k)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatCompactAmount(debtor.amount, debtor.amountVnd),
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.secondary,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Status dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
