import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class GroupDebtSegmentedTab extends StatelessWidget {
  final int activeTab; // 0: Nợ tối giản, 1: Nợ thực tế
  final int simplifiedCount;
  final int actualCount;
  final ValueChanged<int> onTabChanged;

  const GroupDebtSegmentedTab({
    super.key,
    required this.activeTab,
    required this.simplifiedCount,
    required this.actualCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          // Tab 0: Nợ tối giản
          Expanded(
            child: _buildTabButton(
              context: context,
              icon: LucideIcons.zap,
              title: tr.simplifiedDebtsTab,
              count: simplifiedCount,
              isSelected: activeTab == 0,
              onTap: () => onTabChanged(0),
              colors: colors,
            ),
          ),
          const SizedBox(width: 4),

          // Tab 1: Nợ thực tế
          Expanded(
            child: _buildTabButton(
              context: context,
              icon: LucideIcons.banknote,
              title: tr.actualDebtsTab,
              count: actualCount,
              isSelected: activeTab == 1,
              onTap: () => onTabChanged(1),
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeColors colors,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colors.cardBorder)
                : Border.all(color: Colors.transparent),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.cardShadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? colors.debtTabBadgeActiveText
                    : colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.caption,
                    color: isSelected ? colors.textPrimary : colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.debtTabBadgeActiveBg
                      : colors.debtTabBadgeInactiveBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.caption,
                    color: isSelected
                        ? colors.debtTabBadgeActiveText
                        : colors.debtTabBadgeInactiveText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
