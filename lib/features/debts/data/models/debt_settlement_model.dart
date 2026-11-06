import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/debt_settlement_entity.dart';

class AllocatedSplitModel extends AllocatedSplitEntity {
  const AllocatedSplitModel({
    required super.expenseSplitId,
    required super.expenseId,
    required super.expenseTitle,
    super.expenseDate,
    required super.payerId,
    super.payerName = '',
    required super.participantId,
    super.participantName = '',
    super.originalAmount,
    super.originalAmountVnd,
    super.settledAmount,
    super.settledAmountVnd,
    super.remainingAmount,
    super.remainingAmountVnd,
    super.allocatedAmount,
    super.allocatedAmountVnd,
    super.allocationType = 'DIRECT',
  });

  factory AllocatedSplitModel.fromJson(Map<String, dynamic> json) {
    final originalAmount = (json['originalAmount'] as num?) ?? 0;
    final originalAmountVnd =
        (json['originalAmountVnd'] as num?) ?? (originalAmount * 1000);
    final settledAmount = (json['settledAmount'] as num?) ?? 0;
    final settledAmountVnd =
        (json['settledAmountVnd'] as num?) ?? (settledAmount * 1000);
    final remainingAmount = (json['remainingAmount'] as num?) ?? 0;
    final remainingAmountVnd =
        (json['remainingAmountVnd'] as num?) ?? (remainingAmount * 1000);
    final allocatedAmount = (json['allocatedAmount'] as num?) ?? 0;
    final allocatedAmountVnd =
        (json['allocatedAmountVnd'] as num?) ?? (allocatedAmount * 1000);

    return AllocatedSplitModel(
      expenseSplitId: (json['expenseSplitId'] as num?)?.toInt() ?? 0,
      expenseId: (json['expenseId'] as num?)?.toInt() ?? 0,
      expenseTitle: (json['expenseTitle'] as String?) ?? '',
      expenseDate: json['expenseDate'] as String?,
      payerId: (json['payerId'] as num?)?.toInt() ?? 0,
      payerName: (json['payerName'] as String?) ?? '',
      participantId: (json['participantId'] as num?)?.toInt() ?? 0,
      participantName: (json['participantName'] as String?) ?? '',
      originalAmount: originalAmount,
      originalAmountVnd: originalAmountVnd,
      settledAmount: settledAmount,
      settledAmountVnd: settledAmountVnd,
      remainingAmount: remainingAmount,
      remainingAmountVnd: remainingAmountVnd,
      allocatedAmount: allocatedAmount,
      allocatedAmountVnd: allocatedAmountVnd,
      allocationType: (json['allocationType'] as String?) ?? 'DIRECT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseSplitId': expenseSplitId,
      'expenseId': expenseId,
      'expenseTitle': expenseTitle,
      if (expenseDate != null) 'expenseDate': expenseDate,
      'payerId': payerId,
      'payerName': payerName,
      'participantId': participantId,
      'participantName': participantName,
      'originalAmount': originalAmount,
      'originalAmountVnd': originalAmountVnd,
      'settledAmount': settledAmount,
      'settledAmountVnd': settledAmountVnd,
      'remainingAmount': remainingAmount,
      'remainingAmountVnd': remainingAmountVnd,
      'allocatedAmount': allocatedAmount,
      'allocatedAmountVnd': allocatedAmountVnd,
      'allocationType': allocationType,
    };
  }
}

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
    super.rejectionReason,
    super.paymentProofUrl,
    super.note,
    super.createdAt,
    super.confirmedAt,
    super.resolvedAt,
    super.action,
    super.allocatedSplits,
  });

  factory DebtSettlementModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?) ?? 0;
    final amountVnd = (json['amountVnd'] as num?) ?? (amount * 1000);
    final rawId = json['id'] ?? json['settlementId'];

    final rawSplits = json['allocatedSplits'] as List<dynamic>? ?? [];
    final allocatedSplits = rawSplits
        .whereType<Map<String, dynamic>>()
        .map((s) => AllocatedSplitModel.fromJson(s))
        .toList();

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
      rejectionReason: json['rejectionReason'] as String?,
      paymentProofUrl: json['paymentProofUrl'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] as String?,
      confirmedAt: json['confirmedAt'] as String?,
      resolvedAt: json['resolvedAt'] as String?,
      action: DebtAction.fromString(json['action'] as String?),
      allocatedSplits: allocatedSplits,
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
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (paymentProofUrl != null) 'paymentProofUrl': paymentProofUrl,
      if (note != null) 'note': note,
      if (createdAt != null) 'createdAt': createdAt,
      if (confirmedAt != null) 'confirmedAt': confirmedAt,
      if (resolvedAt != null) 'resolvedAt': resolvedAt,
      'action': action.name.toUpperCase(),
      'allocatedSplits': allocatedSplits
          .map((s) => s is AllocatedSplitModel
              ? s.toJson()
              : AllocatedSplitModel(
                  expenseSplitId: s.expenseSplitId,
                  expenseId: s.expenseId,
                  expenseTitle: s.expenseTitle,
                  expenseDate: s.expenseDate,
                  payerId: s.payerId,
                  payerName: s.payerName,
                  participantId: s.participantId,
                  participantName: s.participantName,
                  originalAmount: s.originalAmount,
                  originalAmountVnd: s.originalAmountVnd,
                  settledAmount: s.settledAmount,
                  settledAmountVnd: s.settledAmountVnd,
                  remainingAmount: s.remainingAmount,
                  remainingAmountVnd: s.remainingAmountVnd,
                  allocatedAmount: s.allocatedAmount,
                  allocatedAmountVnd: s.allocatedAmountVnd,
                  allocationType: s.allocationType,
                ).toJson())
          .toList(),
    };
  }
}

class DebtPaymentPreviewModel extends DebtPaymentPreviewEntity {
  const DebtPaymentPreviewModel({
    required super.planToken,
    required super.groupId,
    required super.debtorId,
    super.debtorName = '',
    required super.creditorId,
    super.creditorName = '',
    super.creditorAvatar,
    super.amount,
    super.amountVnd,
    super.expiresAt,
    super.allocatedSplits,
  });

  factory DebtPaymentPreviewModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?) ?? 0;
    final amountVnd = (json['amountVnd'] as num?) ?? (amount * 1000);

    final rawSplits = json['allocatedSplits'] as List<dynamic>? ?? [];
    final allocatedSplits = rawSplits
        .whereType<Map<String, dynamic>>()
        .map((s) => AllocatedSplitModel.fromJson(s))
        .toList();

    return DebtPaymentPreviewModel(
      planToken: (json['planToken'] as String?) ?? '',
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      debtorId: (json['debtorId'] as num?)?.toInt() ?? 0,
      debtorName: (json['debtorName'] as String?) ?? '',
      creditorId: (json['creditorId'] as num?)?.toInt() ?? 0,
      creditorName: (json['creditorName'] as String?) ?? '',
      creditorAvatar: json['creditorAvatar'] as String?,
      amount: amount,
      amountVnd: amountVnd,
      expiresAt: json['expiresAt'] as String?,
      allocatedSplits: allocatedSplits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planToken': planToken,
      'groupId': groupId,
      'debtorId': debtorId,
      'debtorName': debtorName,
      'creditorId': creditorId,
      'creditorName': creditorName,
      if (creditorAvatar != null) 'creditorAvatar': creditorAvatar,
      'amount': amount,
      'amountVnd': amountVnd,
      if (expiresAt != null) 'expiresAt': expiresAt,
      'allocatedSplits': allocatedSplits
          .map((s) => s is AllocatedSplitModel
              ? s.toJson()
              : AllocatedSplitModel(
                  expenseSplitId: s.expenseSplitId,
                  expenseId: s.expenseId,
                  expenseTitle: s.expenseTitle,
                  expenseDate: s.expenseDate,
                  payerId: s.payerId,
                  payerName: s.payerName,
                  participantId: s.participantId,
                  participantName: s.participantName,
                  originalAmount: s.originalAmount,
                  originalAmountVnd: s.originalAmountVnd,
                  settledAmount: s.settledAmount,
                  settledAmountVnd: s.settledAmountVnd,
                  remainingAmount: s.remainingAmount,
                  remainingAmountVnd: s.remainingAmountVnd,
                  allocatedAmount: s.allocatedAmount,
                  allocatedAmountVnd: s.allocatedAmountVnd,
                  allocationType: s.allocationType,
                ).toJson())
          .toList(),
    };
  }
}

class DebtSettlementPageModel extends DebtSettlementPageEntity {
  @override
  final List<DebtSettlementModel> content;

  const DebtSettlementPageModel({
    required this.content,
    required super.pageNumber,
    required super.totalPages,
    required super.totalElements,
    required super.last,
  }) : super(content: content);

  factory DebtSettlementPageModel.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    final items = rawContent
        .whereType<Map<String, dynamic>>()
        .map((item) => DebtSettlementModel.fromJson(item))
        .toList();
    final pageable = json['pageable'] as Map<String, dynamic>?;
    final pageNumber = (pageable?['pageNumber'] as num?)?.toInt() ??
        (json['pageNumber'] as num?)?.toInt() ??
        0;
    final totalPages = (json['totalPages'] as num?)?.toInt() ?? 1;
    final totalElements =
        (json['totalElements'] as num?)?.toInt() ?? items.length;
    final last = (json['last'] as bool?) ?? (pageNumber >= totalPages - 1);

    return DebtSettlementPageModel(
      content: items,
      pageNumber: pageNumber,
      totalPages: totalPages,
      totalElements: totalElements,
      last: last,
    );
  }
}

