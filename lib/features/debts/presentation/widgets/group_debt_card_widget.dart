import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/debt_overview_entity.dart';

class GroupDebtCardWidget extends StatelessWidget {
  final GroupDebtBalanceEntity item;
  final VoidCallback onTap;

  const GroupDebtCardWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  String _inferEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('chung cư') || lower.contains('room') || lower.contains('nhà')) {
      return '🏢';
    } else if (lower.contains('cầu lông') || lower.contains('bóng') || lower.contains('thể thao')) {
      return '🏸';
    } else if (lower.contains('phượt') || lower.contains('du lịch') || lower.contains('đà lạt')) {
      return '🏕️';
    } else if (lower.contains('ăn') || lower.contains('tiệc') || lower.contains('lẩu')) {
      return '🍽️';
    }
    return '👥';
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emoji = _inferEmoji(item.groupName);
    final isSettled = item.netBalanceVnd == 0;
    final isReceiving = item.netBalanceVnd > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Group Emoji Squircle
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF065F46)
                          : const Color(0xFFA7F3D0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Group Name & Status Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.groupName,
                        style: AppTextStyle.bold(
                          fontSize: 14,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (isSettled && item.pendingDebtCount == 0)
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.check,
                              size: 12,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tr.debtsSettledAll,
                                style: AppTextStyle.semiBold(
                                  fontSize: 11,
                                  color: const Color(0xFF16A34A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.clock,
                              size: 12,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tr.debtsPendingCount(
                                  item.pendingDebtCount > 0
                                      ? item.pendingDebtCount
                                      : 1,
                                ),
                                style: AppTextStyle.semiBold(
                                  fontSize: 11,
                                  color: const Color(0xFFD97706),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Amount & Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isSettled
                          ? tr.debtsBalanced
                          : CurrencyUtils.formatVnd(
                              item.netBalanceVnd,
                              showSign: true,
                            ),
                      style: AppTextStyle.bold(
                        fontSize: 14,
                        color: isSettled
                            ? colors.textPrimary
                            : isReceiving
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSettled
                            ? (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9))
                            : isReceiving
                                ? (isDark
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFFECFDF5))
                                : (isDark
                                    ? const Color(0xFF4C0519)
                                    : const Color(0xFFFFF1F2)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isSettled
                            ? tr.badgeBalanced
                            : isReceiving
                                ? tr.badgeYouReceive
                                : tr.badgeYouMustPay,
                        style: AppTextStyle.bold(
                          fontSize: 10,
                          color: isSettled
                              ? (isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569))
                              : isReceiving
                                  ? (isDark
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(0xFF15803D))
                                  : (isDark
                                      ? const Color(0xFFFDA4AF)
                                      : const Color(0xFFBE123C)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),

                // 4. Chevron Right Icon
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
