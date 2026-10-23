import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/presentation/widgets/group_filter_chip.dart';
import '../../domain/entities/analytics_enums.dart';

class AnalyticsPeriodBar extends StatelessWidget {
  final StatisticsPeriod currentPeriod;
  final ValueChanged<StatisticsPeriod> onPeriodChanged;

  const AnalyticsPeriodBar({
    super.key,
    required this.currentPeriod,
    required this.onPeriodChanged,
  });

  String _getPeriodLabel(BuildContext context, StatisticsPeriod period) {
    final tr = context.l10n;
    final now = DateTime.now();
    final monthStr = now.month.toString().padLeft(2, '0');
    final quarter = ((now.month - 1) ~/ 3) + 1;

    switch (period) {
      case StatisticsPeriod.thisMonth:
        return '${tr.periodThisMonth} $monthStr/${now.year}';
      case StatisticsPeriod.lastMonth:
        return tr.periodLastMonth;
      case StatisticsPeriod.currentQuarter:
        return '${tr.periodCurrentQuarter} $quarter/${now.year}';
      case StatisticsPeriod.byYear:
        return tr.periodByYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: StatisticsPeriod.values.map((period) {
          final isSelected = period == currentPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GroupFilterChip(
              label: _getPeriodLabel(context, period),
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                onPeriodChanged(period);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
