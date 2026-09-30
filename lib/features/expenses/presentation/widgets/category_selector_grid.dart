import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/expense_enums.dart';

class CategorySelectorGrid extends StatelessWidget {
  final ExpenseCategoryType selectedCategory;
  final ValueChanged<ExpenseCategoryType> onCategorySelected;

  const CategorySelectorGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categories = ExpenseCategoryType.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.95,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = cat == selectedCategory;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onCategorySelected(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0FDF4) : colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF14532D) : colors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat.icon,
                  size: 24,
                  color: isSelected ? const Color(0xFF14532D) : cat.themeColor,
                ),
                const SizedBox(height: 6),
                Text(
                  cat.labelVi,
                  style: AppTextStyle.bold(
                    fontSize: 11,
                    color: isSelected ? const Color(0xFF14532D) : colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
