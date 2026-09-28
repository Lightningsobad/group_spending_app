import '../../domain/entities/expense_statistics_entity.dart';

class CategoryDistributionModel {
  final int categoryId;
  final String categoryName;
  final String? icon;
  final num amountVnd;
  final double percentage;
  final int? expenseCount;

  const CategoryDistributionModel({
    required this.categoryId,
    required this.categoryName,
    this.icon,
    required this.amountVnd,
    required this.percentage,
    this.expenseCount,
  });

  factory CategoryDistributionModel.fromJson(Map<String, dynamic> json) {
    num amtVnd = 0;
    if (json['amountVnd'] != null) {
      amtVnd = json['amountVnd'] as num;
    } else if (json['amount'] != null) {
      amtVnd = (json['amount'] as num) * 1000;
    }

    return CategoryDistributionModel(
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: (json['categoryName'] as String?) ?? '',
      icon: json['icon'] as String?,
      amountVnd: amtVnd,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      expenseCount: (json['expenseCount'] as num?)?.toInt(),
    );
  }

  CategoryDistributionEntity toEntity() {
    return CategoryDistributionEntity(
      categoryId: categoryId,
      categoryName: categoryName,
      icon: icon,
      amountVnd: amountVnd,
      percentage: percentage,
      expenseCount: expenseCount,
    );
  }
}

class ExpenseStatisticsDetailsModel {
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
  final List<CategoryDistributionModel> categoryDistributions;
  final int? groupId;
  final String? groupName;

  const ExpenseStatisticsDetailsModel({
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

  factory ExpenseStatisticsDetailsModel.fromJson(Map<String, dynamic> json) {
    num totalSpendingVnd = 0;
    if (json['totalSpendingVnd'] != null) {
      totalSpendingVnd = json['totalSpendingVnd'] as num;
    } else if (json['totalSpending'] != null) {
      totalSpendingVnd = (json['totalSpending'] as num) * 1000;
    }

    num avgSpendingVnd = 0;
    if (json['averageSpendingPerPersonVnd'] != null) {
      avgSpendingVnd = json['averageSpendingPerPersonVnd'] as num;
    } else if (json['averageSpendingPerPerson'] != null) {
      avgSpendingVnd = (json['averageSpendingPerPerson'] as num) * 1000;
    }

    // Support both totalUniqueMembers (API 3.2) and memberCount (API 3.4)
    final membersCount = (json['totalUniqueMembers'] as num?)?.toInt() ??
        (json['memberCount'] as num?)?.toInt() ??
        0;

    final categoriesRaw = json['categoryDistributions'];
    final List<CategoryDistributionModel> categories = [];
    if (categoriesRaw is List) {
      for (final item in categoriesRaw) {
        if (item is Map<String, dynamic>) {
          categories.add(CategoryDistributionModel.fromJson(item));
        }
      }
    }

    return ExpenseStatisticsDetailsModel(
      period: (json['period'] as String?) ?? '',
      startDate: (json['startDate'] as String?) ?? '',
      endDate: (json['endDate'] as String?) ?? '',
      totalSpendingVnd: totalSpendingVnd,
      totalExpenseCount: (json['totalExpenseCount'] as num?)?.toInt() ?? 0,
      averageSpendingPerPersonVnd: avgSpendingVnd,
      totalUniqueMembers: membersCount,
      debtSettlementRate:
          (json['debtSettlementRate'] as num?)?.toDouble() ?? 0.0,
      totalDebtAmount: json['totalDebtAmount'] as num?,
      settledDebtAmount: json['settledDebtAmount'] as num?,
      totalDebtCount: (json['totalDebtCount'] as num?)?.toInt(),
      settledDebtCount: (json['settledDebtCount'] as num?)?.toInt(),
      categoryDistributions: categories,
      groupId: (json['groupId'] as num?)?.toInt(),
      groupName: json['groupName'] as String?,
    );
  }

  ExpenseStatisticsEntity toEntity() {
    return ExpenseStatisticsEntity(
      period: period,
      startDate: startDate,
      endDate: endDate,
      totalSpendingVnd: totalSpendingVnd,
      totalExpenseCount: totalExpenseCount,
      averageSpendingPerPersonVnd: averageSpendingPerPersonVnd,
      totalUniqueMembers: totalUniqueMembers,
      debtSettlementRate: debtSettlementRate,
      totalDebtAmount: totalDebtAmount,
      settledDebtAmount: settledDebtAmount,
      totalDebtCount: totalDebtCount,
      settledDebtCount: settledDebtCount,
      categoryDistributions:
          categoryDistributions.map((c) => c.toEntity()).toList(),
      groupId: groupId,
      groupName: groupName,
    );
  }
}
