import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 10),
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
            backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
            backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                ? Text(
                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                    style: AppTextStyle.bold(fontSize: 14, color: AppColors.emeraldForest),
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
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      CurrencyUtils.formatVnd(amountVnd),
                      style: AppTextStyle.medium(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (isPaid && paidDateText.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• $paidDateText',
                        style: AppTextStyle.bold(
                          fontSize: 10,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status & Action button
          if (isPaid) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.circleCheck,
                    size: 13,
                    color: Color(0xFF15803D),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tr.statusPaid,
                    style: AppTextStyle.bold(
                      fontSize: 11,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isAdmin ? onToggleStatus : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.circleX,
                          size: 13,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tr.statusUnpaid,
                          style: AppTextStyle.bold(
                            fontSize: 11,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: isCooldownActive ? null : onRemind,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: isCooldownActive
                            ? colors.surfaceMuted
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCooldownActive
                              ? colors.cardBorder
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Icon(
                        LucideIcons.bellRing,
                        size: 15,
                        color: isCooldownActive
                            ? colors.textMuted
                            : const Color(0xFFD97706),
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
