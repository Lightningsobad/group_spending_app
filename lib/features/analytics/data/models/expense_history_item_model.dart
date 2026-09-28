import '../../domain/entities/expense_history_entity.dart';

class ExpenseHistoryItemModel {
  final int id;
  final int groupId;
  final String groupName;
  final String title;
  final String expenseDate;
  final num totalAmountVnd;
  final String categoryName;
  final String paidByUserName;

  const ExpenseHistoryItemModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.title,
    required this.expenseDate,
    required this.totalAmountVnd,
    required this.categoryName,
    required this.paidByUserName,
  });

  factory ExpenseHistoryItemModel.fromJson(Map<String, dynamic> json) {
    num amtVnd = 0;
    if (json['totalAmountVnd'] != null) {
      amtVnd = json['totalAmountVnd'] as num;
    } else if (json['totalAmount'] != null) {
      amtVnd = (json['totalAmount'] as num) * 1000;
    }

    return ExpenseHistoryItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      groupName: (json['groupName'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      expenseDate: (json['expenseDate'] as String?) ?? '',
      totalAmountVnd: amtVnd,
      categoryName: (json['categoryName'] as String?) ?? '',
      paidByUserName: (json['paidByUserName'] as String?) ?? '',
    );
  }

  ExpenseHistoryItemEntity toEntity() {
    return ExpenseHistoryItemEntity(
      id: id,
      groupId: groupId,
      groupName: groupName,
      title: title,
      expenseDate: expenseDate,
      totalAmountVnd: totalAmountVnd,
      categoryName: categoryName,
      paidByUserName: paidByUserName,
    );
  }
}
