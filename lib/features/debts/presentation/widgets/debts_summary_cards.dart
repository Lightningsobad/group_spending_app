import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';

class DebtsSummaryCards extends StatelessWidget {
  final num totalOwedVnd;
  final num totalReceivableVnd;

  const DebtsSummaryCards({
    super.key,
    required this.totalOwedVnd,
    required this.totalReceivableVnd,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final roseBg = isDark
        ? const Color(0xFF4C0519).withValues(alpha: 0.3)
        : const Color(0xFFFFF1F2);
    final roseBorder = isDark
        ? const Color(0xFF881337).withValues(alpha: 0.5)
        : const Color(0xFFFFE4E6);
    final roseText = isDark ? const Color(0xFFFDA4AF) : const Color(0xFFE11D48);
    final roseAmount = isDark ? const Color(0xFFFECDD3) : const Color(0xFFBE123C);

    final emeraldBg = isDark
        ? const Color(0xFF064E3B).withValues(alpha: 0.3)
        : const Color(0xFFF0FDF4);
    final emeraldBorder = isDark
        ? const Color(0xFF065F46).withValues(alpha: 0.5)
        : const Color(0xFFDCFCE7);
    final emeraldText =
        isDark ? const Color(0xFF6EE7B7) : const Color(0xFF16A34A);
    final emeraldAmount =
        isDark ? const Color(0xFFA7F3D0) : const Color(0xFF15803D);

    final subtext = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Row(
      children: [
        // 1. Thẻ: Bạn đang nợ
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: roseBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: roseBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.trendingDown,
                      size: 14,
                      color: roseText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tr.debtsYouOwe,
                      style: AppTextStyle.bold(
                        fontSize: 12,
                        color: roseText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyUtils.formatVnd(totalOwedVnd),
                  style: AppTextStyle.bold(
                    fontSize: 18,
                    color: roseAmount,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tr.debtsYouOweSubtitle,
                  style: AppTextStyle.regular(
                    fontSize: 10,
                    color: subtext,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 2. Thẻ: Bạn nhận
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: emeraldBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: emeraldBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.trendingUp,
                      size: 14,
                      color: emeraldText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tr.debtsYouReceive,
                      style: AppTextStyle.bold(
                        fontSize: 12,
                        color: emeraldText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyUtils.formatVnd(totalReceivableVnd),
                  style: AppTextStyle.bold(
                    fontSize: 18,
                    color: emeraldAmount,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tr.debtsYouReceiveSubtitle,
                  style: AppTextStyle.regular(
                    fontSize: 10,
                    color: subtext,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
