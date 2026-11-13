import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../expenses/data/models/expense_enums.dart';
import '../../domain/entities/expense_statistics_entity.dart';
import 'category_distribution_bar.dart';

class CategoryDistributionList extends StatelessWidget {
  final List<CategoryDistributionEntity> categories;

  const CategoryDistributionList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final cat = entry.value;
        final color = CategoryDistributionColors.getColor(index);
        final categoryType = ExpenseCategoryType.fromString(cat.categoryName);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  categoryType.icon,
                  size: 18,
                  color: categoryType.themeColor,
                ),
              ),
              const SizedBox(width: 10),
              // Color dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // Category name
              Expanded(
                child: Text(
                  cat.categoryName,
                  style: AppTextStyle.bold(
                    color: colors.textPrimary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Percentage
              Text(
                '${cat.percentage.toStringAsFixed(cat.percentage.truncateToDouble() == cat.percentage ? 0 : 1)}%',
                style: AppTextStyle.regular(
                  color: colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              // Amount in VND
              Text(
                CurrencyUtils.formatVnd(cat.amountVnd),
                style: AppTextStyle.bold(
                  color: colors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
