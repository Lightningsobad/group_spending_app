import 'package:flutter/material.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/presentation/widgets/group_filter_chip.dart';
import '../../domain/entities/debt_enums.dart';

class DebtsFilterBar extends StatelessWidget {
  final DebtOverviewFilter activeFilter;
  final int totalCount;
  final int hasDebtCount;
  final int settledCount;
  final ValueChanged<DebtOverviewFilter> onFilterChanged;

  const DebtsFilterBar({
    super.key,
    required this.activeFilter,
    required this.totalCount,
    required this.hasDebtCount,
    required this.settledCount,
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
            label: tr.filterDebtAllCount(totalCount),
            isSelected: activeFilter == DebtOverviewFilter.all,
            onTap: () => onFilterChanged(DebtOverviewFilter.all),
          ),
          const SizedBox(width: 8),
          GroupFilterChip(
            label: tr.filterDebtHasDebtCount(hasDebtCount),
            isSelected: activeFilter == DebtOverviewFilter.hasDebt,
            onTap: () => onFilterChanged(DebtOverviewFilter.hasDebt),
          ),
          const SizedBox(width: 8),
          GroupFilterChip(
            label: tr.filterDebtSettledCount(settledCount),
            isSelected: activeFilter == DebtOverviewFilter.settled,
            onTap: () => onFilterChanged(DebtOverviewFilter.settled),
          ),
        ],
      ),
    );
  }
}
