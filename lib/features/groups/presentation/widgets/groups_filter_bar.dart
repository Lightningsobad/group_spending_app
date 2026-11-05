import 'package:flutter/material.dart';
import '../../../../l10n/l10n.dart';
import 'group_category_helper.dart';
import 'group_filter_chip.dart';

class GroupsFilterBar extends StatelessWidget {
  final String activeFilter;
  final String activeCategory;
  final int totalCount;
  final int activeCount;
  final int archivedCount;
  final int adminCount;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String>? onCategoryChanged;

  const GroupsFilterBar({
    super.key,
    required this.activeFilter,
    this.activeCategory = 'ALL',
    required this.totalCount,
    required this.activeCount,
    required this.archivedCount,
    required this.adminCount,
    required this.onFilterChanged,
    this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Status / Role Filter Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GroupFilterChip(
                label: tr.filterAllCount(totalCount),
                isSelected: activeFilter == 'ALL',
                onTap: () => onFilterChanged('ALL'),
              ),
              const SizedBox(width: 8),
              GroupFilterChip(
                label: tr.filterActiveCount(activeCount),
                isSelected: activeFilter == 'ACTIVE',
                onTap: () => onFilterChanged('ACTIVE'),
              ),
              const SizedBox(width: 8),
              GroupFilterChip(
                label: tr.filterArchivedCount(archivedCount),
                isSelected: activeFilter == 'ARCHIVED',
                onTap: () => onFilterChanged('ARCHIVED'),
              ),
              const SizedBox(width: 8),
              GroupFilterChip(
                label: tr.filterAdminCount(adminCount),
                isSelected: activeFilter == 'ADMIN',
                onTap: () => onFilterChanged('ADMIN'),
              ),
            ],
          ),
        ),
        if (onCategoryChanged != null) ...[
          const SizedBox(height: 10),
          // 2. Topic / Category Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GroupFilterChip(
                  label: tr.filterAllTopicsOnly,
                  isSelected: activeCategory == 'ALL' || activeCategory.isEmpty,
                  onTap: () => onCategoryChanged!('ALL'),
                ),
                for (final cat in GroupCategoryHelper.categories) ...[
                  const SizedBox(width: 8),
                  GroupFilterChip(
                    label: GroupCategoryHelper.getLabel(cat, context),
                    isSelected: activeCategory == cat,
                    onTap: () => onCategoryChanged!(cat),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
