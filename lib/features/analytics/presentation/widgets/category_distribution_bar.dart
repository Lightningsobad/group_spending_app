import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/expense_statistics_entity.dart';

class CategoryDistributionColors {
  static const List<Color> palette = [
    Color(0xFFF59E0B), // Amber / Orange
    Color(0xFF10B981), // Emerald / Green
    Color(0xFF6366F1), // Indigo
    Color(0xFF06B6D4), // Cyan
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF3B82F6), // Blue
    Color(0xFF94A3B8), // Slate / Grey
  ];

  static Color getColor(int index) {
    return palette[index % palette.length];
  }
}

class CategoryDistributionBar extends StatelessWidget {
  final List<CategoryDistributionEntity> categories;

  const CategoryDistributionBar({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        height: 10,
        decoration: BoxDecoration(
          color: context.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    final totalPercent = categories.fold<double>(
      0.0,
      (sum, item) => sum + item.percentage,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final cat = entry.value;
            final color = CategoryDistributionColors.getColor(index);
            final flex = (totalPercent > 0)
                ? ((cat.percentage / totalPercent) * 1000).round()
                : 1;

            if (flex <= 0) return const SizedBox.shrink();

            return Flexible(
              flex: flex,
              child: Container(
                height: 10,
                color: color,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
