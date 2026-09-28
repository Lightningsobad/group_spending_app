import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/group_debt_entity.dart';

class ActualDebtCardWidget extends StatelessWidget {
  final ActualDebtEntity debt;
  final int? currentUserId;
  final VoidCallback? onPay;
  final ValueChanged<bool>? onConfirm;
  final VoidCallback? onRemind;

  const ActualDebtCardWidget({
    super.key,
    required this.debt,
    this.currentUserId,
    this.onPay,
    this.onConfirm,
    this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isCurrentUserDebtor =
        currentUserId != null && debt.debtorId == currentUserId;
    final isCurrentUserCreditor =
        currentUserId != null && debt.creditorId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Header: Category / Expense Title or Date & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (debt.category != null && debt.category!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    debt.category!,
                    style: AppTextStyle.bold(
                      fontSize: 10,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                )
              else
                Text(
                  debt.createdAt ?? 'Vừa xong',
                  style: AppTextStyle.regular(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
              _buildStatusBadge(debt.status, tr, isDark),
            ],
          ),

          if (debt.expenseTitle != null && debt.expenseTitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              debt.expenseTitle!,
              style: AppTextStyle.bold(
                fontSize: 14,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),

          // 2. Middle Row: Debtor -> Amount -> Creditor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Debtor (Left)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      backgroundImage: debt.debtorAvatar != null &&
                              debt.debtorAvatar!.isNotEmpty
                          ? NetworkImage(debt.debtorAvatar!)
                          : null,
                      child: debt.debtorAvatar == null ||
                              debt.debtorAvatar!.isEmpty
                          ? Text(
                              debt.debtorName.isNotEmpty
                                  ? debt.debtorName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyle.bold(
                                fontSize: 13,
                                color: colors.textPrimary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCurrentUserDebtor
                          ? '${debt.debtorName} (${tr.youTag})'
                          : debt.debtorName,
                      style: AppTextStyle.bold(
                        fontSize: 11,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      tr.debtorLabel,
                      style: AppTextStyle.medium(
                        fontSize: 9,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),

              // Amount & Arrow (Center)
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Text(
                      CurrencyUtils.formatVnd(debt.amountVnd),
                      style: AppTextStyle.bold(
                        fontSize: 16,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFF16A34A),
                            thickness: 1.5,
                          ),
                        ),
                        Icon(
                          LucideIcons.arrowRight,
                          size: 14,
                          color: Color(0xFF16A34A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Creditor (Right)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      backgroundImage: debt.creditorAvatar != null &&
                              debt.creditorAvatar!.isNotEmpty
                          ? NetworkImage(debt.creditorAvatar!)
                          : null,
                      child: debt.creditorAvatar == null ||
                              debt.creditorAvatar!.isEmpty
                          ? Text(
                              debt.creditorName.isNotEmpty
                                  ? debt.creditorName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyle.bold(
                                fontSize: 13,
                                color: colors.textPrimary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCurrentUserCreditor
                          ? '${debt.creditorName} (${tr.youTag})'
                          : debt.creditorName,
                      style: AppTextStyle.bold(
                        fontSize: 11,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      tr.creditorLabel,
                      style: AppTextStyle.medium(
                        fontSize: 9,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. Action Buttons (if actionable)
          if (debt.action != DebtAction.none) ...[
            const SizedBox(height: 12),
            _buildActionButtons(context, tr, colors),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    DebtStatus status,
    AppLocalizations tr,
    bool isDark,
  ) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case DebtStatus.settled:
        bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
        fg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF15803D);
        label = tr.debtStatusSettled;
        break;
      case DebtStatus.waitingForConfirmation:
        bg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
        fg = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
        label = tr.debtStatusWaiting;
        break;
      case DebtStatus.pending:
        bg = isDark ? const Color(0xFF713F12) : const Color(0xFFFEF3C7);
        fg = isDark ? const Color(0xFFFDE047) : const Color(0xFFB45309);
        label = tr.debtStatusPending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyle.bold(fontSize: 10, color: fg),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations tr,
    AppThemeColors colors,
  ) {
    switch (debt.action) {
      case DebtAction.pay:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15803D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: onPay,
          icon: const Icon(LucideIcons.send, size: 14),
          label: Text(
            tr.payNowAction,
            style: AppTextStyle.bold(fontSize: 12),
          ),
        );

      case DebtAction.confirm:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () => onConfirm?.call(true),
                icon: const Icon(LucideIcons.check, size: 14),
                label: Text(
                  tr.confirmReceivedAction,
                  style: AppTextStyle.bold(fontSize: 11),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE11D48),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => onConfirm?.call(false),
                icon: const Icon(LucideIcons.x, size: 14),
                label: Text(
                  tr.rejectReceivedAction,
                  style: AppTextStyle.bold(fontSize: 11),
                ),
              ),
            ),
          ],
        );

      case DebtAction.remind:
        return OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.cardBorder),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onRemind,
          icon: const Icon(
            LucideIcons.bell,
            size: 14,
            color: Color(0xFFD97706),
          ),
          label: Text(
            tr.remindDebtAction,
            style: AppTextStyle.bold(fontSize: 12),
          ),
        );

      case DebtAction.none:
        return const SizedBox.shrink();
    }
  }
}
