class ExpenseHistoryItemEntity {
  final int id;
  final int groupId;
  final String groupName;
  final String title;
  final String expenseDate;
  final num totalAmountVnd;
  final String categoryName;
  final String paidByUserName;

  const ExpenseHistoryItemEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.title,
    required this.expenseDate,
    required this.totalAmountVnd,
    required this.categoryName,
    required this.paidByUserName,
  });
}
