import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
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
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: StatisticsPeriod.values.map((period) {
          final isSelected = period == currentPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onPeriodChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1) // Indigo/Purple accent
                      : colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : colors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  _getPeriodLabel(context, period),
                  style: isSelected
                      ? AppTextStyle.bold(
                          color: Colors.white,
                          fontSize: 13,
                        )
                      : AppTextStyle.semiBold(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
