class PersonalOverviewEntity {
  final num totalSpendingVnd;
  final int activeGroupCount;
  final int totalExpenses;
  final int myExpenseCount;

  const PersonalOverviewEntity({
    required this.totalSpendingVnd,
    required this.activeGroupCount,
    required this.totalExpenses,
    required this.myExpenseCount,
  });

  const PersonalOverviewEntity.empty()
      : totalSpendingVnd = 0,
        activeGroupCount = 0,
        totalExpenses = 0,
        myExpenseCount = 0;
}
