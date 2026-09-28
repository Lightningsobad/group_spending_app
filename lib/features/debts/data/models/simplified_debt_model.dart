import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/group_debt_entity.dart';

class SimplifiedDebtModel extends SimplifiedDebtEntity {
  const SimplifiedDebtModel({
    super.id,
    required super.debtorId,
    required super.debtorName,
    super.debtorAvatar,
    required super.creditorId,
    required super.creditorName,
    super.creditorAvatar,
    super.amount,
    super.amountVnd,
    super.action,
    super.createdAt,
    super.note,
  });

  factory SimplifiedDebtModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?) ?? 0;
    final amountVnd = (json['amountVnd'] as num?) ?? (amount * 1000);
    final rawId = json['id'] ?? json['debtId'];

    return SimplifiedDebtModel(
      id: rawId != null ? (rawId as num).toInt() : null,
      debtorId: (json['debtorId'] as num?)?.toInt() ?? 0,
      debtorName: (json['debtorName'] as String?) ?? '',
      debtorAvatar: json['debtorAvatar'] as String?,
      creditorId: (json['creditorId'] as num?)?.toInt() ?? 0,
      creditorName: (json['creditorName'] as String?) ?? '',
      creditorAvatar: json['creditorAvatar'] as String?,
      amount: amount,
      amountVnd: amountVnd,
      action: DebtAction.fromString(json['action'] as String?),
      createdAt: json['createdAt'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'debtorId': debtorId,
      'debtorName': debtorName,
      if (debtorAvatar != null) 'debtorAvatar': debtorAvatar,
      'creditorId': creditorId,
      'creditorName': creditorName,
      if (creditorAvatar != null) 'creditorAvatar': creditorAvatar,
      'amount': amount,
      'amountVnd': amountVnd,
      'action': action.name.toUpperCase(),
      if (createdAt != null) 'createdAt': createdAt,
      if (note != null) 'note': note,
    };
  }
}
