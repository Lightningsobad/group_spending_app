import 'debt_enums.dart';

class AllocatedSplitEntity {
  final int expenseSplitId;
  final int expenseId;
  final String expenseTitle;
  final String? expenseDate;
  final int payerId;
  final String payerName;
  final int participantId;
  final String participantName;
  final num originalAmount;
  final num originalAmountVnd;
  final num settledAmount;
  final num settledAmountVnd;
  final num remainingAmount;
  final num remainingAmountVnd;
  final num allocatedAmount;
  final num allocatedAmountVnd;
  final String allocationType;

  const AllocatedSplitEntity({
    required this.expenseSplitId,
    required this.expenseId,
    required this.expenseTitle,
    this.expenseDate,
    required this.payerId,
    this.payerName = '',
    required this.participantId,
    this.participantName = '',
    this.originalAmount = 0,
    this.originalAmountVnd = 0,
    this.settledAmount = 0,
    this.settledAmountVnd = 0,
    this.remainingAmount = 0,
    this.remainingAmountVnd = 0,
    this.allocatedAmount = 0,
    this.allocatedAmountVnd = 0,
    this.allocationType = 'DIRECT',
  });
}

class DebtSettlementEntity {
  final int id;
  final int groupId;
  final int debtorId;
  final String debtorName;
  final String? debtorAvatar;
  final int creditorId;
  final String creditorName;
  final String? creditorAvatar;
  final num amount;
  final num amountVnd;
  final DebtStatus status;
  final String? rejectionReason;
  final String? paymentProofUrl;
  final String? note;
  final String? createdAt;
  final String? confirmedAt;
  final String? resolvedAt;
  final DebtAction action;
  final List<AllocatedSplitEntity> allocatedSplits;

  const DebtSettlementEntity({
    required this.id,
    required this.groupId,
    required this.debtorId,
    this.debtorName = '',
    this.debtorAvatar,
    required this.creditorId,
    this.creditorName = '',
    this.creditorAvatar,
    this.amount = 0,
    this.amountVnd = 0,
    this.status = DebtStatus.pending,
    this.rejectionReason,
    this.paymentProofUrl,
    this.note,
    this.createdAt,
    this.confirmedAt,
    this.resolvedAt,
    this.action = DebtAction.none,
    this.allocatedSplits = const [],
  });

  bool get isWaitingForConfirmation =>
      status == DebtStatus.waitingForConfirmation;
  bool get isSettled => status == DebtStatus.settled;
  bool get isRejected => status == DebtStatus.rejected;
}

class DebtPaymentPreviewEntity {
  final String planToken;
  final int groupId;
  final int debtorId;
  final String debtorName;
  final int creditorId;
  final String creditorName;
  final String? creditorAvatar;
  final num amount;
  final num amountVnd;
  final String? expiresAt;
  final List<AllocatedSplitEntity> allocatedSplits;

  const DebtPaymentPreviewEntity({
    required this.planToken,
    required this.groupId,
    required this.debtorId,
    this.debtorName = '',
    required this.creditorId,
    this.creditorName = '',
    this.creditorAvatar,
    this.amount = 0,
    this.amountVnd = 0,
    this.expiresAt,
    this.allocatedSplits = const [],
  });
}

class DebtSettlementPageEntity {
  final List<DebtSettlementEntity> content;
  final int pageNumber;
  final int totalPages;
  final int totalElements;
  final bool last;

  const DebtSettlementPageEntity({
    required this.content,
    required this.pageNumber,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });
}

