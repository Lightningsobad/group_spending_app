import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/fund_enums.dart';

class FundFilterBar extends StatelessWidget {
  final FundCollectionStatus? selectedStatus;
  final FundTimeFilter selectedTime;
  final int totalCount;
  final int collectingCount;
  final int completedCount;
  final int filteredCount;
  final ValueChanged<FundCollectionStatus?> onStatusChanged;
  final ValueChanged<FundTimeFilter> onTimeChanged;

  const FundFilterBar({
    super.key,
    required this.selectedStatus,
    required this.selectedTime,
    required this.totalCount,
    required this.collectingCount,
    required this.completedCount,
    required this.filteredCount,
    required this.onStatusChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Status Filter Chips + Counter
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(
                      label: '${tr.filterAll} $totalCount',
                      isSelected: selectedStatus == null,
                      onTap: () => onStatusChanged(null),
                      colors: colors,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      label: '${tr.filterCollecting} $collectingCount',
                      isSelected: selectedStatus == FundCollectionStatus.collecting,
                      onTap: () => onStatusChanged(FundCollectionStatus.collecting),
                      colors: colors,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      label: '${tr.filterCompleted} $completedCount',
                      isSelected: selectedStatus == FundCollectionStatus.completed,
                      onTap: () => onStatusChanged(FundCollectionStatus.completed),
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$filteredCount / $totalCount',
              style: AppTextStyle.bold(
                fontSize: 11,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Time Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterPill(
                label: tr.filterAll,
                isSelected: selectedTime == FundTimeFilter.all,
                onTap: () => onTimeChanged(FundTimeFilter.all),
                colors: colors,
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                label: tr.filterThisMonth,
                isSelected: selectedTime == FundTimeFilter.thisMonth,
                onTap: () => onTimeChanged(FundTimeFilter.thisMonth),
                colors: colors,
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                label: tr.filterLastMonth,
                isSelected: selectedTime == FundTimeFilter.lastMonth,
                onTap: () => onTimeChanged(FundTimeFilter.lastMonth),
                colors: colors,
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                label: tr.filterThisQuarter,
                isSelected: selectedTime == FundTimeFilter.thisQuarter,
                onTap: () => onTimeChanged(FundTimeFilter.thisQuarter),
                colors: colors,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required dynamic colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF14532D) : colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF14532D) : colors.cardBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF14532D).withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyle.bold(
            fontSize: 12,
            color: isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
