import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/group_debt_entity.dart';

class ActualDebtorModel extends ActualDebtorEntity {
  const ActualDebtorModel({
    required super.splitId,
    required super.userId,
    required super.name,
    super.avatarUrl,
    super.isMe,
    super.amount,
    super.amountVnd,
    super.status,
    super.action,
  });

  factory ActualDebtorModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?) ?? 0;
    final amountVnd = (json['amountVnd'] as num?) ?? (amount * 1000);

    return ActualDebtorModel(
      splitId: (json['splitId'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      isMe: (json['isMe'] as bool?) ?? false,
      amount: amount,
      amountVnd: amountVnd,
      status: DebtStatus.fromString(json['status'] as String?),
      action: DebtAction.fromString(json['action'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'splitId': splitId,
      'userId': userId,
      'name': name,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'isMe': isMe,
      'amount': amount,
      'amountVnd': amountVnd,
      'status': status.toServerString(),
      'action': action.name.toUpperCase(),
    };
  }
}

class ActualDebtModel extends ActualDebtEntity {
  const ActualDebtModel({
    required super.expenseId,
    required super.title,
    super.categoryName,
    super.categoryIcon,
    super.totalAmount,
    super.totalAmountVnd,
    super.expenseDate,
    super.createdAt,
    super.paidByUserId,
    super.paidByUserName,
    super.paidByUserAvatar,
    super.isPaidByMe,
    super.debtorCount,
    super.debtors,
  });

  factory ActualDebtModel.fromJson(Map<String, dynamic> json) {
    final totalAmount =
        (json['totalAmount'] as num?) ?? (json['amount'] as num?) ?? 0;
    final totalAmountVnd = (json['totalAmountVnd'] as num?) ??
        (json['amountVnd'] as num?) ??
        (totalAmount * 1000);

    final rawDebtors = json['debtors'] as List<dynamic>? ?? [];
    final debtors = rawDebtors
        .whereType<Map<String, dynamic>>()
        .map((e) => ActualDebtorModel.fromJson(e))
        .toList();

    return ActualDebtModel(
      expenseId: (json['expenseId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      title: (json['title'] as String?) ??
          (json['expenseTitle'] as String?) ??
          '',
      categoryName: (json['categoryName'] as String?) ??
          (json['category'] as String?) ??
          '',
      categoryIcon: json['categoryIcon'] as String?,
      totalAmount: totalAmount,
      totalAmountVnd: totalAmountVnd,
      expenseDate: json['expenseDate'] as String?,
      createdAt: json['createdAt'] as String?,
      paidByUserId: (json['paidByUserId'] as num?)?.toInt() ??
          (json['creditorId'] as num?)?.toInt() ??
          0,
      paidByUserName: (json['paidByUserName'] as String?) ??
          (json['creditorName'] as String?) ??
          '',
      paidByUserAvatar: (json['paidByUserAvatar'] as String?) ??
          (json['creditorAvatar'] as String?),
      isPaidByMe: (json['isPaidByMe'] as bool?) ?? false,
      debtorCount: (json['debtorCount'] as num?)?.toInt() ?? debtors.length,
      debtors: debtors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'title': title,
      'categoryName': categoryName,
      if (categoryIcon != null) 'categoryIcon': categoryIcon,
      'totalAmount': totalAmount,
      'totalAmountVnd': totalAmountVnd,
      if (expenseDate != null) 'expenseDate': expenseDate,
      if (createdAt != null) 'createdAt': createdAt,
      'paidByUserId': paidByUserId,
      'paidByUserName': paidByUserName,
      if (paidByUserAvatar != null) 'paidByUserAvatar': paidByUserAvatar,
      'isPaidByMe': isPaidByMe,
      'debtorCount': debtorCount,
      'debtors': debtors
          .map((d) => d is ActualDebtorModel
              ? d.toJson()
              : {
                  'splitId': d.splitId,
                  'userId': d.userId,
                  'name': d.name,
                  if (d.avatarUrl != null) 'avatarUrl': d.avatarUrl,
                  'isMe': d.isMe,
                  'amount': d.amount,
                  'amountVnd': d.amountVnd,
                  'status': d.status.toServerString(),
                  'action': d.action.name.toUpperCase(),
                })
          .toList(),
    };
  }
}
