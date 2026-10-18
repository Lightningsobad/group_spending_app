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
  final bool isWaitingForConfirmation;

  const SimplifiedDebtCardWidget({
    super.key,
    required this.debt,
    this.currentUserId,
    this.onPay,
    this.onConfirm,
    this.onRemind,
    this.isWaitingForConfirmation = false,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    final isCurrentUserDebtor =
        currentUserId != null && debt.debtorId == currentUserId;
    final isCurrentUserCreditor =
        currentUserId != null && debt.creditorId == currentUserId;

    final effectiveWaiting = isWaitingForConfirmation ||
        debt.action == DebtAction.confirm;

    final effectiveAction = debt.action != DebtAction.none
        ? debt.action
        : (effectiveWaiting
            ? (isCurrentUserCreditor ? DebtAction.confirm : DebtAction.none)
            : (isCurrentUserDebtor
                ? DebtAction.pay
                : (isCurrentUserCreditor
                    ? DebtAction.remind
                    : DebtAction.none)));

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
                  fontSize: AppFontSize.caption,
                  color: colors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: effectiveWaiting
                      ? colors.debtWaitingBg
                      : colors.debtPendingBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  effectiveWaiting
                      ? tr.debtStatusWaiting
                      : tr.debtStatusPending,
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.caption,
                    color: effectiveWaiting
                        ? colors.debtWaitingText
                        : colors.debtPendingText,
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
                      colors: colors,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCurrentUserDebtor
                          ? '${debt.debtorName} (${tr.youTag})'
                          : debt.debtorName,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.secondary,
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
                        fontSize: AppFontSize.caption,
                        color: colors.debtOweText,
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyUtils.formatVnd(debt.amountVnd),
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.h4,
                          color: colors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: colors.debtReceiveText,
                            thickness: 1.5,
                          ),
                        ),
                        Icon(
                          LucideIcons.arrowRight,
                          size: 14,
                          color: colors.debtReceiveText,
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
                      colors: colors,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCurrentUserCreditor
                          ? '${debt.creditorName} (${tr.youTag})'
                          : debt.creditorName,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.secondary,
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
                        fontSize: AppFontSize.caption,
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
              color: colors.debtHintBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.debtHintBorder),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    debt.note ?? 'Gộp nợ tối ưu giữa các thành viên trong nhóm',
                    style: AppTextStyle.medium(
                      fontSize: AppFontSize.caption,
                      color: colors.debtHintText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 4. Action Buttons (PAY / CONFIRM / REMIND)
          if (effectiveWaiting && isCurrentUserDebtor) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.debtWaitingBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 16,
                    color: colors.debtWaitingText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đã chuyển tiền • Chờ xác nhận',
                    style: AppTextStyle.bold(
                      fontSize: AppFontSize.secondary,
                      color: colors.debtWaitingText,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (effectiveAction != DebtAction.none) ...[
            const SizedBox(height: 12),
            _buildActionButtons(context, tr, colors, effectiveAction),
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatar({
    required String name,
    required String? avatarUrl,
    required bool isCurrentUser,
    required AppThemeColors colors,
  }) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colors.debtAvatarBg,
          backgroundImage:
              avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Text(
                  initials,
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.secondary,
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.debtOweText,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: colors.debtYouBadgeBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                'Bạn',
                style: AppTextStyle.bold(
                  fontSize: AppFontSize.caption,
                  color: colors.onPrimaryButton,
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
    AppThemeColors colors, [
    DebtAction? actionOverride,
  ]) {
    final action = actionOverride ?? debt.action;
    switch (action) {
      case DebtAction.pay:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.debtActionPayBg,
            foregroundColor: colors.onPrimaryButton,
            minimumSize: const Size.fromHeight(48),
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
            style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
          ),
        );

      case DebtAction.confirm:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.debtActionConfirmBg,
                  foregroundColor: colors.onPrimaryButton,
                  minimumSize: const Size.fromHeight(48),
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
                  style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.debtActionRejectFg,
                  side: BorderSide(color: colors.debtActionRejectBorder),
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => onConfirm?.call(false),
                icon: const Icon(LucideIcons.x, size: 16),
                label: Text(
                  tr.rejectReceivedAction,
                  style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
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
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onRemind,
          icon: Icon(
            LucideIcons.bell,
            size: 16,
            color: colors.debtActionRemindIcon,
          ),
          label: Text(
            tr.remindDebtAction,
            style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
          ),
        );

      case DebtAction.none:
        return const SizedBox.shrink();
    }
  }
}
