import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/group_debt_entity.dart';

class SimplifiedDebtCardWidget extends StatelessWidget {
  final SimplifiedDebtEntity debt;
  final int? currentUserId;
  final VoidCallback? onPay;
  final ValueChanged<bool>? onConfirm;
  final VoidCallback? onRemind;

  const SimplifiedDebtCardWidget({
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Row: Time & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                debt.createdAt ?? 'Vừa xong',
                style: AppTextStyle.regular(
                  fontSize: 11,
                  color: colors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tr.debtStatusPending,
                  style: AppTextStyle.bold(
                    fontSize: 10,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Middle Row: Debtor -> Amount & Arrow -> Creditor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Debtor (Left)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildUserAvatar(
                      name: debt.debtorName,
                      avatarUrl: debt.debtorAvatar,
                      isCurrentUser: isCurrentUserDebtor,
                      isDark: isDark,
                      colors: colors,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCurrentUserDebtor
                          ? '${debt.debtorName} (${tr.youTag})'
                          : debt.debtorName,
                      style: AppTextStyle.bold(
                        fontSize: 12,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      tr.debtorLabel,
                      style: AppTextStyle.semiBold(
                        fontSize: 10,
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
                        fontSize: 17,
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
                    _buildUserAvatar(
                      name: debt.creditorName,
                      avatarUrl: debt.creditorAvatar,
                      isCurrentUser: isCurrentUserCreditor,
                      isDark: isDark,
                      colors: colors,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCurrentUserCreditor
                          ? '${debt.creditorName} (${tr.youTag})'
                          : debt.creditorName,
                      style: AppTextStyle.bold(
                        fontSize: 12,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      tr.creditorLabel,
                      style: AppTextStyle.semiBold(
                        fontSize: 10,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Hint / Reason Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF713F12).withValues(alpha: 0.3)
                  : const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF854D0E)
                    : const Color(0xFFFEF08A),
              ),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    debt.note ?? 'Gộp nợ tối ưu giữa các thành viên trong nhóm',
                    style: AppTextStyle.medium(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFFFDE047)
                          : const Color(0xFF854D0E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 4. Action Buttons (PAY / CONFIRM / REMIND)
          if (debt.action != DebtAction.none) ...[
            const SizedBox(height: 12),
            _buildActionButtons(context, tr, colors, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatar({
    required String name,
    required String? avatarUrl,
    required bool isCurrentUser,
    required bool isDark,
    required AppThemeColors colors,
  }) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          backgroundImage:
              avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Text(
                  initials,
                  style: AppTextStyle.bold(
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                )
              : null,
        ),
        if (isCurrentUser)
          Positioned(
            bottom: -2,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  width: 1.5,
                ),
              ),
              child: const Text(
                'Bạn',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations tr,
    AppThemeColors colors,
    bool isDark,
  ) {
    switch (debt.action) {
      case DebtAction.pay:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15803D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          onPressed: onPay,
          icon: const Icon(LucideIcons.send, size: 16),
          label: Text(
            tr.payNowAction,
            style: AppTextStyle.bold(fontSize: 13),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => onConfirm?.call(true),
                icon: const Icon(LucideIcons.check, size: 16),
                label: Text(
                  tr.confirmReceivedAction,
                  style: AppTextStyle.bold(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE11D48),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => onConfirm?.call(false),
                icon: const Icon(LucideIcons.x, size: 16),
                label: Text(
                  tr.rejectReceivedAction,
                  style: AppTextStyle.bold(fontSize: 12),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onRemind,
          icon: const Icon(
            LucideIcons.bell,
            size: 16,
            color: Color(0xFFD97706),
          ),
          label: Text(
            tr.remindDebtAction,
            style: AppTextStyle.bold(fontSize: 13),
          ),
        );

      case DebtAction.none:
        return const SizedBox.shrink();
    }
  }
}
