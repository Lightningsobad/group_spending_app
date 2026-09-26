import 'package:flutter/material.dart';
import '../../../../l10n/l10n.dart';
import 'group_filter_chip.dart';

class GroupsFilterBar extends StatelessWidget {
  final String activeFilter;
  final int totalCount;
  final int activeCount;
  final int archivedCount;
  final int adminCount;
  final ValueChanged<String> onFilterChanged;

  const GroupsFilterBar({
    super.key,
    required this.activeFilter,
    required this.totalCount,
    required this.activeCount,
    required this.archivedCount,
    required this.adminCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return SingleChildScrollView(
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
    );
  }
}
