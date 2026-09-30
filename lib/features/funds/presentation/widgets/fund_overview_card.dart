import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/fund_entities.dart';

class FundOverviewCard extends StatelessWidget {
  final GroupFundsOverviewEntity? overview;
  final bool isAdmin;
  final VoidCallback onNewFundTap;

  const FundOverviewCard({
    super.key,
    required this.overview,
    required this.isAdmin,
    required this.onNewFundTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    final collectedVnd = overview?.totalCollectedAmountVnd ?? 0;
    final targetVnd = overview?.totalTargetAmountVnd ?? 0;
    final percentage = overview?.completionPercentage ?? 0.0;
    final progressFraction = (percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.totalGeneralFundLabel,
                      style: AppTextStyle.bold(
                        fontSize: 11,
                        color: colors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: CurrencyUtils.formatVnd(collectedVnd),
                            style: AppTextStyle.bold(
                              fontSize: 19,
                              color: colors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${CurrencyUtils.formatVnd(targetVnd)}',
                            style: AppTextStyle.medium(
                              fontSize: 13,
                              color: colors.textMuted,
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
              if (isAdmin) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onNewFundTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 15, color: Colors.white),
                  label: Text(
                    tr.collectNewFundAction,
                    style: AppTextStyle.bold(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Dual color / Gradient Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 7,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: colors.surfaceMuted,
                  ),
                  FractionallySizedBox(
                    widthFactor: progressFraction,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF059669)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Progress Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.fundProgressLabel,
                style: AppTextStyle.medium(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: AppTextStyle.bold(
                  fontSize: 12,
                  color: percentage >= 100
                      ? const Color(0xFF059669)
                      : const Color(0xFF047857),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
