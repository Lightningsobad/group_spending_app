import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/group_debt_entity.dart';

class GroupDebtSummaryCard extends StatelessWidget {
  final DebtUserBalanceEntity userBalance;
  final String? subtitle;

  const GroupDebtSummaryCard({
    super.key,
    required this.userBalance,
    this.subtitle,
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

    final emoji = _inferEmoji(userBalance.groupName);
    final isSettled = userBalance.netBalanceVnd == 0;
    final isReceiving = userBalance.netBalanceVnd > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Top Row: Icon, Group Name, Subtitle, Status Badge
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userBalance.groupName,
                      style: AppTextStyle.bold(
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyle.regular(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSettled
                      ? tr.badgeBalanced
                      : isReceiving
                          ? tr.badgeYouReceive
                          : tr.badgeYouMustPay,
                  style: AppTextStyle.bold(
                    fontSize: 11,
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
          const SizedBox(height: 14),
          Divider(height: 1, color: colors.cardBorder),
          const SizedBox(height: 14),

          // 2. Bottom Row: Label & Net Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.yourBalanceInGroup,
                style: AppTextStyle.medium(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                isSettled
                    ? tr.debtsBalanced
                    : CurrencyUtils.formatVnd(
                        userBalance.netBalanceVnd,
                        showSign: true,
                      ),
                style: AppTextStyle.bold(
                  fontSize: 16,
                  color: isSettled
                      ? colors.textPrimary
                      : isReceiving
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE11D48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
