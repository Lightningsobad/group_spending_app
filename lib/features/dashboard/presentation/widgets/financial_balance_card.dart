import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';

class FinancialBalanceCard extends StatelessWidget {
  final num totalOwedVnd;
  final num totalReceivableVnd;

  const FinancialBalanceCard({
    super.key,
    required this.totalOwedVnd,
    required this.totalReceivableVnd,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF1E1B4B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.wallet,
                  size: 18,
                  color: Color(0xFF34D399),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                tr.financialOverviewTitle,
                style: AppTextStyle.bold(
                  fontSize: 12,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Two balance boxes
          Row(
            children: [
              // Left: Bạn đang nợ
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.trendingDown,
                            size: 14,
                            color: Color(0xFFF87171),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tr.youOwe,
                            style: AppTextStyle.medium(
                              fontSize: 12,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtils.formatVnd(totalOwedVnd),
                        style: AppTextStyle.bold(
                          fontSize: 18,
                          color: const Color(0xFFF87171),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.paySoonSubtitle,
                        style: AppTextStyle.regular(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Right: Bạn nhận
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.trendingUp,
                            size: 14,
                            color: Color(0xFF34D399),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tr.youAreOwed,
                            style: AppTextStyle.medium(
                              fontSize: 12,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtils.formatVnd(totalReceivableVnd),
                        style: AppTextStyle.bold(
                          fontSize: 18,
                          color: const Color(0xFF34D399),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.friendsOweYouSubtitle,
                        style: AppTextStyle.regular(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
