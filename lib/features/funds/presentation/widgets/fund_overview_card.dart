import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../domain/entities/fund_entities.dart';

class FundOverviewCard extends StatelessWidget {
  final GroupFundsOverviewEntity? overview;
  final bool isAdmin;
  final VoidCallback onNewFundTap;
  final bool isLoading;

  const FundOverviewCard({
    super.key,
    required this.overview,
    required this.isAdmin,
    required this.onNewFundTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    if (isLoading) {
      return _buildSkeleton(colors);
    }

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
                        fontSize: 12,
                        color: colors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: CurrencyUtils.formatVnd(collectedVnd),
                            style: AppTextStyle.bold(
                              fontSize: 20,
                              color: colors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${CurrencyUtils.formatVnd(targetVnd)}',
                            style: AppTextStyle.medium(
                              fontSize: 14,
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
                    backgroundColor: colors.primaryButton,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
                  label: Text(
                    tr.collectNewFundAction,
                    style: AppTextStyle.bold(fontSize: 13, color: Colors.white),
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
              height: 8,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: colors.surfaceMuted,
                  ),
                  FractionallySizedBox(
                    widthFactor: progressFraction,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.fundProgressStart, colors.fundProgressEnd],
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
              Flexible(
                child: Text(
                  tr.fundProgressLabel,
                  style: AppTextStyle.medium(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: AppTextStyle.bold(
                  fontSize: 13,
                  color: colors.fundProgressText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(dynamic colors) {
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
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppShimmerBox(
                        width: 130,
                        height: 12,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 8),
                      AppShimmerBox(
                        width: 170,
                        height: 22,
                        borderRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 8),
                  const AppShimmerBox(
                    width: 110,
                    height: 48,
                    borderRadius: 24,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const AppShimmerBox(
              width: double.infinity,
              height: 8,
              borderRadius: 8,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                AppShimmerBox(
                  width: 90,
                  height: 12,
                  borderRadius: 4,
                ),
                AppShimmerBox(
                  width: 36,
                  height: 13,
                  borderRadius: 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
