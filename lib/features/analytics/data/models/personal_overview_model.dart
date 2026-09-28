import '../../domain/entities/personal_overview_entity.dart';

class PersonalOverviewModel {
  final num totalSpendingVnd;
  final int activeGroupCount;
  final int totalExpenses;
  final int myExpenseCount;

  const PersonalOverviewModel({
    required this.totalSpendingVnd,
    required this.activeGroupCount,
    required this.totalExpenses,
    required this.myExpenseCount,
  });

  factory PersonalOverviewModel.fromJson(Map<String, dynamic> json) {
    num spendingVnd = 0;
    if (json['totalSpendingVnd'] != null) {
      spendingVnd = (json['totalSpendingVnd'] as num);
    } else if (json['totalSpending'] != null) {
      spendingVnd = (json['totalSpending'] as num) * 1000;
    }

    return PersonalOverviewModel(
      totalSpendingVnd: spendingVnd,
      activeGroupCount: (json['activeGroupCount'] as num?)?.toInt() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toInt() ?? 0,
      myExpenseCount: (json['myExpenseCount'] as num?)?.toInt() ?? 0,
    );
  }

  PersonalOverviewEntity toEntity() {
    return PersonalOverviewEntity(
      totalSpendingVnd: totalSpendingVnd,
      activeGroupCount: activeGroupCount,
      totalExpenses: totalExpenses,
      myExpenseCount: myExpenseCount,
    );
  }
}
