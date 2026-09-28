import 'debt_enums.dart';

class DebtUserBalanceEntity {
  final int groupId;
  final String groupName;
  final num youOwe;
  final num youOweVnd;
  final num youAreOwed;
  final num youAreOwedVnd;
  final num netBalance;
  final num netBalanceVnd;

  const DebtUserBalanceEntity({
    required this.groupId,
    required this.groupName,
    this.youOwe = 0,
    this.youOweVnd = 0,
    this.youAreOwed = 0,
    this.youAreOwedVnd = 0,
    this.netBalance = 0,
    this.netBalanceVnd = 0,
  });

  bool get isSettled => netBalanceVnd == 0;
  bool get isReceiving => netBalanceVnd > 0;
  bool get isOwing => netBalanceVnd < 0;
}

class SimplifiedDebtEntity {
  final int? id;
  final int debtorId;
  final String debtorName;
  final String? debtorAvatar;
  final int creditorId;
  final String creditorName;
  final String? creditorAvatar;
  final num amount;
  final num amountVnd;
  final DebtAction action;
  final String? createdAt;
  final String? note;

  const SimplifiedDebtEntity({
    this.id,
    required this.debtorId,
    required this.debtorName,
    this.debtorAvatar,
    required this.creditorId,
    required this.creditorName,
    this.creditorAvatar,
    this.amount = 0,
    this.amountVnd = 0,
    this.action = DebtAction.none,
    this.createdAt,
    this.note,
  });
}

class GroupSimplifiedDebtsEntity {
  final DebtUserBalanceEntity userBalance;
  final List<SimplifiedDebtEntity> simplifiedDebts;

  const GroupSimplifiedDebtsEntity({
    required this.userBalance,
    this.simplifiedDebts = const [],
  });
}

class ActualDebtEntity {
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
  final String? settledAt;
  final String? createdAt;
  final DebtAction action;
  final String? expenseTitle;
  final String? category;

  const ActualDebtEntity({
    required this.id,
    required this.groupId,
    required this.debtorId,
    required this.debtorName,
    this.debtorAvatar,
    required this.creditorId,
    required this.creditorName,
    this.creditorAvatar,
    this.amount = 0,
    this.amountVnd = 0,
    this.status = DebtStatus.pending,
    this.settledAt,
    this.createdAt,
    this.action = DebtAction.none,
    this.expenseTitle,
    this.category,
  });
}

class GroupActualDebtsEntity {
  final DebtUserBalanceEntity userBalance;
  final List<ActualDebtEntity> actualDebts;

  const GroupActualDebtsEntity({
    required this.userBalance,
    this.actualDebts = const [],
  });
}
