import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

/// Skeleton placeholder cho Dropdown chọn người đã trả tiền khi đang tải thành viên.
class AddExpensePayerSkeleton extends StatelessWidget {
  const AddExpensePayerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.cardBorder),
        ),
        child: const Row(
          children: [
            AppShimmerBox(
              width: 24,
              height: 24,
              shape: CircleBorder(),
            ),
            SizedBox(width: 10),
            AppShimmerBox(
              width: 150,
              height: 14,
              borderRadius: 4,
            ),
            Spacer(),
            AppShimmerBox(
              width: 16,
              height: 16,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder cho Khung phân chia chi phí khi đang tải danh sách thành viên.
class AddExpenseSplitSkeleton extends StatelessWidget {
  final int itemCount;

  const AddExpenseSplitSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Equal all banner skeleton
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmerBox(width: 20, height: 20, borderRadius: 5),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmerBox(width: 220, height: 14, borderRadius: 4),
                      SizedBox(height: 6),
                      AppShimmerBox(width: 160, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Sub-header & action buttons skeleton
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmerBox(width: 160, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    AppShimmerBox(width: 120, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              AppShimmerBox(width: 58, height: 32, borderRadius: 12),
              SizedBox(width: 8),
              AppShimmerBox(width: 68, height: 32, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Member item rows skeleton
          ...List.generate(
            itemCount,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: const Row(
                children: [
                  AppShimmerBox(width: 20, height: 20, borderRadius: 5),
                  SizedBox(width: 10),
                  AppShimmerBox(width: 36, height: 36, shape: CircleBorder()),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(width: 110, height: 14, borderRadius: 4),
                        SizedBox(height: 6),
                        AppShimmerBox(width: 130, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  AppShimmerBox(width: 70, height: 14, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
