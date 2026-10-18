import 'debt_enums.dart';

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
  final String? paymentProofUrl;
  final String? note;
  final String? createdAt;
  final String? confirmedAt;

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
    this.paymentProofUrl,
    this.note,
    this.createdAt,
    this.confirmedAt,
  });

  bool get isWaitingForConfirmation =>
      status == DebtStatus.waitingForConfirmation;
  bool get isSettled => status == DebtStatus.settled;
  bool get isRejected => status == DebtStatus.rejected;
}
