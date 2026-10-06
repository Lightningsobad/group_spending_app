import '../../domain/entities/group_debt_entity.dart';
import 'actual_debt_model.dart';
import 'simplified_debt_model.dart';

class DebtUserBalanceModel extends DebtUserBalanceEntity {
  const DebtUserBalanceModel({
    required super.groupId,
    required super.groupName,
    super.youOwe,
    super.youOweVnd,
    super.youAreOwed,
    super.youAreOwedVnd,
    super.netBalance,
    super.netBalanceVnd,
  });

  factory DebtUserBalanceModel.fromJson(Map<String, dynamic> json) {
    final youOwe = (json['youOwe'] as num?) ?? 0;
    final youOweVnd = (json['youOweVnd'] as num?) ?? (youOwe * 1000);

    final youAreOwed = (json['youAreOwed'] as num?) ?? 0;
    final youAreOwedVnd = (json['youAreOwedVnd'] as num?) ?? (youAreOwed * 1000);

    final netBalance = (json['netBalance'] as num?) ?? (youAreOwed - youOwe);
    final netBalanceVnd = (json['netBalanceVnd'] as num?) ?? (youAreOwedVnd - youOweVnd);

    return DebtUserBalanceModel(
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      groupName: (json['groupName'] as String?) ?? '',
      youOwe: youOwe,
      youOweVnd: youOweVnd,
      youAreOwed: youAreOwed,
      youAreOwedVnd: youAreOwedVnd,
      netBalance: netBalance,
      netBalanceVnd: netBalanceVnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'youOwe': youOwe,
      'youOweVnd': youOweVnd,
      'youAreOwed': youAreOwed,
      'youAreOwedVnd': youAreOwedVnd,
      'netBalance': netBalance,
      'netBalanceVnd': netBalanceVnd,
    };
  }
}

class GroupSimplifiedDebtsModel extends GroupSimplifiedDebtsEntity {
  const GroupSimplifiedDebtsModel({
    required super.userBalance,
    super.simplifiedDebts = const [],
  });

  factory GroupSimplifiedDebtsModel.fromJson(Map<String, dynamic> json) {
    final userBalanceMap = json['userBalance'] as Map<String, dynamic>? ?? {};
    final userBalance = DebtUserBalanceModel.fromJson(userBalanceMap);

    final rawList = json['simplifiedDebts'] as List<dynamic>? ?? [];
    final simplifiedDebts = rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => SimplifiedDebtModel.fromJson(item))
        .toList();

    return GroupSimplifiedDebtsModel(
      userBalance: userBalance,
      simplifiedDebts: simplifiedDebts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userBalance': userBalance is DebtUserBalanceModel
          ? (userBalance as DebtUserBalanceModel).toJson()
          : {
              'groupId': userBalance.groupId,
              'groupName': userBalance.groupName,
              'youOwe': userBalance.youOwe,
              'youOweVnd': userBalance.youOweVnd,
              'youAreOwed': userBalance.youAreOwed,
              'youAreOwedVnd': userBalance.youAreOwedVnd,
              'netBalance': userBalance.netBalance,
              'netBalanceVnd': userBalance.netBalanceVnd,
            },
      'simplifiedDebts': simplifiedDebts
          .map((e) => e is SimplifiedDebtModel
              ? e.toJson()
              : {
                  if (e.id != null) 'id': e.id,
                  'debtorId': e.debtorId,
                  'debtorName': e.debtorName,
                  'creditorId': e.creditorId,
                  'creditorName': e.creditorName,
                  'amount': e.amount,
                  'amountVnd': e.amountVnd,
                  'action': e.action.name.toUpperCase(),
                })
          .toList(),
    };
  }
}

class GroupActualDebtsModel extends GroupActualDebtsEntity {
  const GroupActualDebtsModel({
    required super.userBalance,
    super.actualDebts = const [],
  });

  factory GroupActualDebtsModel.fromJson(Map<String, dynamic> json) {
    final userBalanceMap = json['userBalance'] as Map<String, dynamic>? ?? {};
    final userBalance = DebtUserBalanceModel.fromJson(userBalanceMap);

    final rawList = json['actualDebts'] as List<dynamic>? ?? [];
    final actualDebts = rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => ActualDebtModel.fromJson(item))
        .toList();

    return GroupActualDebtsModel(
      userBalance: userBalance,
      actualDebts: actualDebts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userBalance': userBalance is DebtUserBalanceModel
          ? (userBalance as DebtUserBalanceModel).toJson()
          : {
              'groupId': userBalance.groupId,
              'groupName': userBalance.groupName,
              'youOwe': userBalance.youOwe,
              'youOweVnd': userBalance.youOweVnd,
              'youAreOwed': userBalance.youAreOwed,
              'youAreOwedVnd': userBalance.youAreOwedVnd,
              'netBalance': userBalance.netBalance,
              'netBalanceVnd': userBalance.netBalanceVnd,
            },
      'actualDebts': actualDebts
          .map((e) => e is ActualDebtModel
              ? e.toJson()
              : ActualDebtModel(
                  expenseId: e.expenseId,
                  title: e.title,
                  categoryName: e.categoryName,
                  categoryIcon: e.categoryIcon,
                  totalAmount: e.totalAmount,
                  totalAmountVnd: e.totalAmountVnd,
                  expenseDate: e.expenseDate,
                  createdAt: e.createdAt,
                  paidByUserId: e.paidByUserId,
                  paidByUserName: e.paidByUserName,
                  paidByUserAvatar: e.paidByUserAvatar,
                  isPaidByMe: e.isPaidByMe,
                  debtorCount: e.debtorCount,
                  debtors: e.debtors,
                ).toJson())
          .toList(),
    };
  }
}
