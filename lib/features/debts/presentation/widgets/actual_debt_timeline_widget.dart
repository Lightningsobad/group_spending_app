import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/group_debt_entity.dart';
import 'actual_debt_card_widget.dart';

class _TimelineDateGroup {
  final DateTime? date;
  final List<ActualDebtEntity> debts;

  const _TimelineDateGroup({
    required this.date,
    required this.debts,
  });

  num get totalExpenseVnd =>
      debts.fold(0, (sum, item) => sum + item.totalAmountVnd);
}

class _NodeIndicatorInfo {
  final Color color;
  final IconData? icon;

  const _NodeIndicatorInfo({
    required this.color,
    this.icon,
  });
}

class ActualDebtTimelineWidget extends StatelessWidget {
  final List<ActualDebtEntity> debts;
  final void Function(ActualDebtorEntity debtor)? onDebtorPay;
  final void Function(ActualDebtorEntity debtor, bool confirmed)?
      onDebtorConfirm;
  final void Function(ActualDebtorEntity debtor)? onDebtorRemind;
  final void Function(ActualDebtorEntity debtor)? onDebtorTap;
  final bool isSubmitting;

  const ActualDebtTimelineWidget({
    super.key,
    required this.debts,
    this.onDebtorPay,
    this.onDebtorConfirm,
    this.onDebtorRemind,
    this.onDebtorTap,
    this.isSubmitting = false,
  });

  static DateTime? _parseExpenseDate(ActualDebtEntity debt) {
    if (debt.createdAt != null && debt.createdAt!.isNotEmpty) {
      final dt = DateTime.tryParse(debt.createdAt!);
      if (dt != null) return dt;
    }
    if (debt.expenseDate != null && debt.expenseDate!.isNotEmpty) {
      final dt = DateTime.tryParse(debt.expenseDate!);
      if (dt != null) return dt;
    }
    return null;
  }

  static DateTime _normalizeDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  List<_TimelineDateGroup> _groupDebts() {
    final paired = debts
        .map((d) => (debt: d, dt: _parseExpenseDate(d)))
        .toList();

    paired.sort((a, b) {
      if (a.dt != null && b.dt != null) {
        return b.dt!.compareTo(a.dt!);
      }
      if (a.dt != null) return -1;
      if (b.dt != null) return 1;
      return 0;
    });

    final Map<DateTime?, List<ActualDebtEntity>> groups = {};
    for (final item in paired) {
      final dayKey = item.dt != null ? _normalizeDay(item.dt!) : null;
      groups.putIfAbsent(dayKey, () => []).add(item.debt);
    }

    return groups.entries
        .map((e) => _TimelineDateGroup(date: e.key, debts: e.value))
        .toList();
  }

  String _formatDateHeader(BuildContext context, DateTime? date) {
    final tr = context.l10n;
    if (date == null) {
      return tr.timelineOtherDate;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final dateFormatted = DateFormat('dd/MM/yyyy').format(date);
    if (date == today) {
      return '${tr.timelineToday} • $dateFormatted';
    } else if (date == yesterday) {
      return '${tr.timelineYesterday} • $dateFormatted';
    }
    return dateFormatted;
  }

  _NodeIndicatorInfo _resolveNodeInfo(
      ActualDebtEntity debt, AppThemeColors colors) {
    final hasWaiting = debt.debtors.any((d) =>
        d.status == DebtStatus.waitingForConfirmation ||
        d.action == DebtAction.confirm);
    final hasPayAction = debt.debtors.any((d) => d.action == DebtAction.pay);
    final allSettled = debt.debtors.isNotEmpty &&
        debt.debtors.every((d) => d.status == DebtStatus.settled);

    if (allSettled) {
      return _NodeIndicatorInfo(
        color: colors.debtStatusSettledDot,
        icon: LucideIcons.check,
      );
    } else if (hasWaiting || hasPayAction) {
      return _NodeIndicatorInfo(
        color: colors.debtStatusWaitingDot,
        icon: LucideIcons.clock,
      );
    } else {
      return _NodeIndicatorInfo(
        color: colors.debtStatusPendingDot,
        icon: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) return const SizedBox.shrink();

    final tr = context.l10n;
    final colors = context.colors;
    final groups = _groupDebts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: groups.map((group) {
        final dateTitle = _formatDateHeader(context, group.date);
        final totalVndFormatted =
            CurrencyUtils.formatVnd(group.totalExpenseVnd);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Date Group Header
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              dateTitle,
                              style: AppTextStyle.bold(
                                fontSize: AppFontSize.caption,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colors.cardBorder),
                            ),
                            child: Text(
                              tr.timelineBillsCount(group.debts.length),
                              style: AppTextStyle.medium(
                                fontSize: 10,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        tr.timelineDailyTotal(totalVndFormatted),
                        style: AppTextStyle.semiBold(
                          fontSize: AppFontSize.caption,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Timeline Items
              ...group.debts.asMap().entries.map((entry) {
                final index = entry.key;
                final debt = entry.value;
                final isFirst = index == 0;
                final isLast = index == group.debts.length - 1;
                final nodeInfo = _resolveNodeInfo(debt, colors);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Connecting vertical spine line
                    Positioned(
                      left: 11,
                      top: isFirst ? 20 : 0,
                      bottom: isLast ? null : 0,
                      height: isLast ? 20 : null,
                      child: Container(
                        width: 2,
                        color: colors.cardBorder,
                      ),
                    ),

                    // Node indicator
                    Positioned(
                      left: 4,
                      top: 14,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: nodeInfo.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.cardBackground,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: nodeInfo.color.withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: nodeInfo.icon != null
                            ? Center(
                                child: Icon(
                                  nodeInfo.icon,
                                  size: 9,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),

                    // Content Card
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: ActualDebtCardWidget(
                        debt: debt,
                        isSubmitting: isSubmitting,
                        margin: const EdgeInsets.only(bottom: 14),
                        onDebtorPay: onDebtorPay,
                        onDebtorConfirm: onDebtorConfirm,
                        onDebtorRemind: onDebtorRemind,
                        onDebtorTap: onDebtorTap,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }
}
