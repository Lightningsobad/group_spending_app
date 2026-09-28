import 'debt_enums.dart';

class DebtOverviewEntity {
  final num totalOwed;
  final num totalOwedVnd;
  final num totalReceivable;
  final num totalReceivableVnd;
  final num netBalance;
  final num netBalanceVnd;
  final List<GroupDebtBalanceEntity> groupBalances;
  final List<PeerDebtDetailEntity> details;

  const DebtOverviewEntity({
    this.totalOwed = 0,
    this.totalOwedVnd = 0,
    this.totalReceivable = 0,
    this.totalReceivableVnd = 0,
    this.netBalance = 0,
    this.netBalanceVnd = 0,
    this.groupBalances = const [],
    this.details = const [],
  });
}

class GroupDebtBalanceEntity {
  final int groupId;
  final String groupName;
  final num youOwe;
  final num youOweVnd;
  final num youAreOwed;
  final num youAreOwedVnd;
  final num netBalance;
  final num netBalanceVnd;
  final int pendingDebtCount;

  const GroupDebtBalanceEntity({
    required this.groupId,
    required this.groupName,
    this.youOwe = 0,
    this.youOweVnd = 0,
    this.youAreOwed = 0,
    this.youAreOwedVnd = 0,
    this.netBalance = 0,
    this.netBalanceVnd = 0,
    this.pendingDebtCount = 0,
  });

  bool get isSettled => netBalanceVnd == 0;
  bool get isReceiving => netBalanceVnd > 0;
  bool get isOwing => netBalanceVnd < 0;
}

class PeerDebtDetailEntity {
  final int debtId;
  final int groupId;
  final String groupName;
  final int peerId;
  final String peerName;
  final String? peerAvatar;
  final num amount;
  final num amountVnd;
  final PeerDebtType type;
  final DebtStatus status;
  final String? createdAt;

  const PeerDebtDetailEntity({
    required this.debtId,
    required this.groupId,
    required this.groupName,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    this.amount = 0,
    this.amountVnd = 0,
    this.type = PeerDebtType.youOwe,
    this.status = DebtStatus.pending,
    this.createdAt,
  });
}
