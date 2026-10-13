import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

/// Skeleton mô phỏng cấu trúc của ExpenseCardWidget khi đang tải dữ liệu.
class ExpenseCardSkeleton extends StatelessWidget {
  final bool enabled;

  const ExpenseCardSkeleton({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
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
        enabled: enabled,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hàng trên: Icon danh mục, Tiêu đề + Metadata, Số tiền
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(width: 130, height: 16, borderRadius: 6),
                        SizedBox(height: 6),
                        AppShimmerBox(width: 110, height: 12, borderRadius: 4),
                        SizedBox(height: 6),
                        AppShimmerBox(width: 65, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AppShimmerBox(width: 75, height: 16, borderRadius: 6),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: colors.divider,
              ),
              const SizedBox(height: 10),

              // Hàng dưới: Người trả và Badge thanh toán
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppShimmerBox(width: 110, height: 12, borderRadius: 4),
                  AppShimmerBox(width: 100, height: 20, borderRadius: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
