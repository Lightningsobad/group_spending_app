import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../data/models/expense_enums.dart';

class CategorySelectorGrid extends StatelessWidget {
  final ExpenseCategoryType selectedCategory;
  final ValueChanged<ExpenseCategoryType> onCategorySelected;

  const CategorySelectorGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  String _getCategoryLabel(BuildContext context, ExpenseCategoryType cat) {
    final l10n = context.l10n;
    switch (cat) {
      case ExpenseCategoryType.food:
        return l10n.categoryFood;
      case ExpenseCategoryType.transport:
        return l10n.categoryTransport;
      case ExpenseCategoryType.shopping:
        return l10n.categoryShopping;
      case ExpenseCategoryType.housing:
        return l10n.categoryHousing;
      case ExpenseCategoryType.entertainment:
        return l10n.categoryEntertainment;
      case ExpenseCategoryType.groceries:
        return l10n.categoryGroceries;
      case ExpenseCategoryType.healthcare:
        return l10n.categoryHealthcare;
      case ExpenseCategoryType.others:
        return l10n.categoryOthers;
    }
  }

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
        mainAxisExtent: 74,
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? colors.expenseCardSelectedBg : colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? colors.expenseCardSelectedBorder : colors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat.icon,
                  size: 22,
                  color: isSelected ? colors.brandEmerald : cat.themeColor,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _getCategoryLabel(context, cat),
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.caption,
                        color: isSelected ? colors.brandEmerald : colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
