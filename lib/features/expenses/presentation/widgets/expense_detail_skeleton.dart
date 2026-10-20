import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

/// Skeleton loading layout cho màn hình Chi tiết khoản chi (ExpenseDetailScreen).
/// Tái hiện cấu trúc các thẻ tổng quan, người trả, phân chia và hóa đơn để tránh Content Jumping.
class ExpenseDetailSkeleton extends StatelessWidget {
  const ExpenseDetailSkeleton({super.key});

  Widget _buildSkeletonCard({
    required Widget child,
    required AppThemeColors colors,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Thẻ Tổng quan (Overview Card Skeleton)
            _buildSkeletonCard(
              colors: colors,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppShimmerBox(width: 88, height: 24, borderRadius: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppShimmerBox(width: 14, height: 14, borderRadius: 4),
                          SizedBox(width: 6),
                          AppShimmerBox(width: 110, height: 14, borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  AppShimmerBox(width: 220, height: 22, borderRadius: 6),
                  SizedBox(height: 10),
                  AppShimmerBox(width: 180, height: 32, borderRadius: 8),
                  SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: const [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppShimmerBox(width: 14, height: 14, borderRadius: 4),
                          SizedBox(width: 6),
                          AppShimmerBox(width: 90, height: 13, borderRadius: 4),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppShimmerBox(width: 14, height: 14, borderRadius: 4),
                          SizedBox(width: 6),
                          AppShimmerBox(width: 80, height: 13, borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Thẻ Người thanh toán (Payer Card Skeleton)
            _buildSkeletonCard(
              colors: colors,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppShimmerBox(width: 120, height: 12, borderRadius: 4),
                      AppShimmerBox(width: 76, height: 18, borderRadius: 10),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      AppShimmerBox(width: 44, height: 44, shape: CircleBorder()),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppShimmerBox(width: 140, height: 15, borderRadius: 4),
                            SizedBox(height: 6),
                            AppShimmerBox(width: 150, height: 12, borderRadius: 4),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppShimmerBox(width: 90, height: 15, borderRadius: 4),
                          SizedBox(height: 6),
                          AppShimmerBox(width: 70, height: 12, borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Thẻ Phần chia từng thành viên (Splits Card Skeleton)
            _buildSkeletonCard(
              colors: colors,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppShimmerBox(width: 170, height: 12, borderRadius: 4),
                  const SizedBox(height: 14),
                  ...List.generate(3, (index) {
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 20),
                        const Row(
                          children: [
                            AppShimmerBox(width: 36, height: 36, shape: CircleBorder()),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppShimmerBox(width: 110, height: 14, borderRadius: 4),
                                  SizedBox(height: 6),
                                  AppShimmerBox(width: 90, height: 12, borderRadius: 4),
                                ],
                              ),
                            ),
                            AppShimmerBox(width: 68, height: 24, borderRadius: 12),
                            SizedBox(width: 8),
                            AppShimmerBox(width: 32, height: 32, borderRadius: 8),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Thẻ Hóa đơn / Chứng từ (Receipt Card Skeleton)
            _buildSkeletonCard(
              colors: colors,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppShimmerBox(width: 140, height: 12, borderRadius: 4),
                      AppShimmerBox(width: 60, height: 14, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 12),
                  AppShimmerBox(
                    width: double.infinity,
                    height: 150,
                    borderRadius: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Nút bấm hành động ở đáy (Action Buttons Skeleton)
            const AppShimmerBox(
              width: double.infinity,
              height: 48,
              borderRadius: 16,
            ),
            const SizedBox(height: 10),
            const AppShimmerBox(
              width: double.infinity,
              height: 48,
              borderRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
