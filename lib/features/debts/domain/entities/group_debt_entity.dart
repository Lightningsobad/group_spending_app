import 'debt_enums.dart';

class DebtUserBalanceEntity {
  final int groupId;
  final String groupName;
  final String category;
  final num youOwe;
  final num youOweVnd;
  final num youAreOwed;
  final num youAreOwedVnd;
  final num netBalance;
  final num netBalanceVnd;

  const DebtUserBalanceEntity({
    required this.groupId,
    required this.groupName,
    this.category = 'Other',
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
  final String? creditorBankName;
  final String? creditorAccountNumber;
  final String? creditorBankAccountName;
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
    this.creditorBankName,
    this.creditorAccountNumber,
    this.creditorBankAccountName,
    this.amount = 0,
    this.amountVnd = 0,
    this.action = DebtAction.none,
    this.createdAt,
    this.note,
  });

  bool get hasCreditorBankInfo =>
      creditorAccountNumber != null &&
      creditorAccountNumber!.trim().isNotEmpty &&
      creditorBankName != null &&
      creditorBankName!.trim().isNotEmpty;
}

class GroupSimplifiedDebtsEntity {
  final DebtUserBalanceEntity userBalance;
  final List<SimplifiedDebtEntity> simplifiedDebts;

  const GroupSimplifiedDebtsEntity({
    required this.userBalance,
    this.simplifiedDebts = const [],
  });
}

class ActualDebtorEntity {
  final int splitId;
  final int userId;
  final String name;
  final String? avatarUrl;
  final bool isMe;
  final num amount;
  final num amountVnd;
  final DebtStatus status;
  final DebtAction action;

  const ActualDebtorEntity({
    required this.splitId,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.isMe = false,
    this.amount = 0,
    this.amountVnd = 0,
    this.status = DebtStatus.pending,
    this.action = DebtAction.none,
  });
}

class ActualDebtEntity {
  final int expenseId;
  final String title;
  final String categoryName;
  final String? categoryIcon;
  final num totalAmount;
  final num totalAmountVnd;
  final String? expenseDate;
  final String? createdAt;
  final int paidByUserId;
  final String paidByUserName;
  final String? paidByUserAvatar;
  final bool isPaidByMe;
  final int debtorCount;
  final List<ActualDebtorEntity> debtors;

  const ActualDebtEntity({
    required this.expenseId,
    required this.title,
    this.categoryName = '',
    this.categoryIcon,
    this.totalAmount = 0,
    this.totalAmountVnd = 0,
    this.expenseDate,
    this.createdAt,
    this.paidByUserId = 0,
    this.paidByUserName = '',
    this.paidByUserAvatar,
    this.isPaidByMe = false,
    this.debtorCount = 0,
    this.debtors = const [],
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
