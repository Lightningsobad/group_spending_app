class CategoryDistributionEntity {
  final int categoryId;
  final String categoryName;
  final String? icon;
  final num amountVnd;
  final double percentage;
  final int? expenseCount;

  const CategoryDistributionEntity({
    required this.categoryId,
    required this.categoryName,
    this.icon,
    required this.amountVnd,
    required this.percentage,
    this.expenseCount,
  });
}

class ExpenseStatisticsEntity {
  final String period;
  final String startDate;
  final String endDate;
  final num totalSpendingVnd;
  final int totalExpenseCount;
  final num averageSpendingPerPersonVnd;
  final int totalUniqueMembers;
  final double debtSettlementRate;
  final num? totalDebtAmount;
  final num? settledDebtAmount;
  final int? totalDebtCount;
  final int? settledDebtCount;
  final List<CategoryDistributionEntity> categoryDistributions;
  final int? groupId;
  final String? groupName;

  const ExpenseStatisticsEntity({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalSpendingVnd,
    required this.totalExpenseCount,
    required this.averageSpendingPerPersonVnd,
    required this.totalUniqueMembers,
    required this.debtSettlementRate,
    this.totalDebtAmount,
    this.settledDebtAmount,
    this.totalDebtCount,
    this.settledDebtCount,
    required this.categoryDistributions,
    this.groupId,
    this.groupName,
  });

  const ExpenseStatisticsEntity.empty()
      : period = '',
        startDate = '',
        endDate = '',
        totalSpendingVnd = 0,
        totalExpenseCount = 0,
        averageSpendingPerPersonVnd = 0,
        totalUniqueMembers = 0,
        debtSettlementRate = 0.0,
        totalDebtAmount = null,
        settledDebtAmount = null,
        totalDebtCount = null,
        settledDebtCount = null,
        categoryDistributions = const [],
        groupId = null,
        groupName = null;
}
