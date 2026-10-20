import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/fund_entities.dart';

class FundMemberTile extends StatelessWidget {
  final FundMemberEntity member;
  final num amountVnd;
  final bool isAdmin;
  final bool isCooldownActive;
  final int cooldownSeconds;
  final VoidCallback onToggleStatus;
  final VoidCallback onRemind;

  const FundMemberTile({
    super.key,
    required this.member,
    required this.amountVnd,
    required this.isAdmin,
    this.isCooldownActive = false,
    this.cooldownSeconds = 0,
    required this.onToggleStatus,
    required this.onRemind,
  });

  String _formatPaidDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;
    final isPaid = member.isPaid;
    final paidDateText = _formatPaidDate(member.paidAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.cardBorder.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.brandEmerald.withValues(alpha: 0.15),
            backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                ? Text(
                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                    style: AppTextStyle.bold(fontSize: 14, color: colors.brandEmerald),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name and amount/date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.secondary, // 14px
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text.rich(
                  TextSpan(
                    text: CurrencyUtils.formatVnd(amountVnd),
                    style: AppTextStyle.medium(
                      fontSize: AppFontSize.caption, // 12px
                      color: colors.textSecondary,
                    ),
                    children: [
                      if (isPaid && paidDateText.isNotEmpty)
                        TextSpan(
                          text: ' • $paidDateText',
                          style: AppTextStyle.bold(
                            fontSize: AppFontSize.caption, // 12px
                            color: colors.fundAmountText,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status & Action button
          if (isPaid) ...[
            Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.fundStatusCompletedBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.circleCheck,
                    size: 14,
                    color: colors.fundStatusCompletedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tr.statusPaid,
                    style: AppTextStyle.bold(
                      fontSize: AppFontSize.caption, // 12px
                      color: colors.fundStatusCompletedText,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Unpaid toggle button with minimum 48px touch target
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    minWidth: 48,
                  ),
                  child: Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: isAdmin ? onToggleStatus : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: colors.fundStatusUnpaidBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.circleX,
                              size: 14,
                              color: colors.fundStatusUnpaidText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tr.statusUnpaid,
                              style: AppTextStyle.bold(
                                fontSize: AppFontSize.caption, // 12px
                                color: colors.fundStatusUnpaidText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 8), // Gap >= 8px
                  // Remind button with minimum 48x48px touch target
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    child: Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: isCooldownActive ? null : onRemind,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCooldownActive
                                ? colors.surfaceMuted
                                : colors.fundRemindButtonBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCooldownActive
                                ? colors.cardBorder
                                : colors.fundRemindButtonBorder,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.bellRing,
                            size: 16,
                            color: isCooldownActive
                                ? colors.textMuted
                                : colors.fundRemindButtonIcon,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
