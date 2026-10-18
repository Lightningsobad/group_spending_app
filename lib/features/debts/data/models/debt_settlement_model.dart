import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/debt_settlement_entity.dart';

class DebtSettlementModel extends DebtSettlementEntity {
  const DebtSettlementModel({
    required super.id,
    required super.groupId,
    required super.debtorId,
    super.debtorName = '',
    super.debtorAvatar,
    required super.creditorId,
    super.creditorName = '',
    super.creditorAvatar,
    super.amount,
    super.amountVnd,
    super.status,
    super.paymentProofUrl,
    super.note,
    super.createdAt,
    super.confirmedAt,
  });

  factory DebtSettlementModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?) ?? 0;
    final amountVnd = (json['amountVnd'] as num?) ?? (amount * 1000);
    final rawId = json['id'] ?? json['settlementId'];

    return DebtSettlementModel(
      id: rawId != null ? (rawId as num).toInt() : 0,
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
      paymentProofUrl: json['paymentProofUrl'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] as String?,
      confirmedAt: json['confirmedAt'] as String?,
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
      if (paymentProofUrl != null) 'paymentProofUrl': paymentProofUrl,
      if (note != null) 'note': note,
      if (createdAt != null) 'createdAt': createdAt,
      if (confirmedAt != null) 'confirmedAt': confirmedAt,
    };
  }
}
