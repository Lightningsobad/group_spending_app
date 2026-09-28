import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/group_debt_entity.dart';

class ActualDebtModel extends ActualDebtEntity {
  const ActualDebtModel({
    required super.id,
    required super.groupId,
    required super.debtorId,
    required super.debtorName,
    super.debtorAvatar,
    required super.creditorId,
    required super.creditorName,
    super.creditorAvatar,
    super.amount,
    super.amountVnd,
    super.status,
    super.settledAt,
    super.createdAt,
    super.action,
    super.expenseTitle,
    super.category,
  });

  factory ActualDebtModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?) ?? 0;
    final amountVnd = (json['amountVnd'] as num?) ?? (amount * 1000);

    return ActualDebtModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      debtorId: (json['debtorId'] as num?)?.toInt() ?? 0,
      debtorName: (json['debtorName'] as String?) ?? '',
      debtorAvatar: json['debtorAvatar'] as String?,
      creditorId: (json['creditorId'] as num?)?.toInt() ?? 0,
      creditorName: (json['creditorName'] as String?) ?? '',
      creditorAvatar: json['creditorAvatar'] as String?,
      amount: amount,
      amountVnd: amountVnd,
      status: DebtStatus.fromString(json['status'] as String?),
      settledAt: json['settledAt'] as String?,
      createdAt: json['createdAt'] as String?,
      action: DebtAction.fromString(json['action'] as String?),
      expenseTitle: json['expenseTitle'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'debtorId': debtorId,
      'debtorName': debtorName,
      if (debtorAvatar != null) 'debtorAvatar': debtorAvatar,
      'creditorId': creditorId,
      'creditorName': creditorName,
      if (creditorAvatar != null) 'creditorAvatar': creditorAvatar,
      'amount': amount,
      'amountVnd': amountVnd,
      'status': status.toServerString(),
      if (settledAt != null) 'settledAt': settledAt,
      if (createdAt != null) 'createdAt': createdAt,
      'action': action.name.toUpperCase(),
      if (expenseTitle != null) 'expenseTitle': expenseTitle,
      if (category != null) 'category': category,
    };
  }
}
