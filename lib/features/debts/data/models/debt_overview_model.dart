import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/debt_overview_entity.dart';

class GroupDebtBalanceModel extends GroupDebtBalanceEntity {
  const GroupDebtBalanceModel({
    required super.groupId,
    required super.groupName,
    super.youOwe,
    super.youOweVnd,
    super.youAreOwed,
    super.youAreOwedVnd,
    super.netBalance,
    super.netBalanceVnd,
    super.pendingDebtCount,
  });

  factory GroupDebtBalanceModel.fromJson(Map<String, dynamic> json) {
    final youOwe = (json['youOwe'] as num?) ?? 0;
    final youOweVnd = (json['youOweVnd'] as num?) ?? (youOwe * 1000);

    final youAreOwed = (json['youAreOwed'] as num?) ?? 0;
    final youAreOwedVnd = (json['youAreOwedVnd'] as num?) ?? (youAreOwed * 1000);

    final netBalance = (json['netBalance'] as num?) ?? (youAreOwed - youOwe);
    final netBalanceVnd = (json['netBalanceVnd'] as num?) ?? (youAreOwedVnd - youOweVnd);

    final pendingDebtCount = (json['pendingDebtCount'] as num?)?.toInt() ?? 0;

    return GroupDebtBalanceModel(
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      groupName: (json['groupName'] as String?) ?? '',
      youOwe: youOwe,
      youOweVnd: youOweVnd,
      youAreOwed: youAreOwed,
      youAreOwedVnd: youAreOwedVnd,
      netBalance: netBalance,
      netBalanceVnd: netBalanceVnd,
      pendingDebtCount: pendingDebtCount,
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
      'pendingDebtCount': pendingDebtCount,
    };
  }
}

class PeerDebtDetailModel extends PeerDebtDetailEntity {
  const PeerDebtDetailModel({
    required super.debtId,
    required super.groupId,
    required super.groupName,
    required super.peerId,
    required super.peerName,
    super.peerAvatar,
    super.amount,
    super.amountVnd,
    super.type,
    super.status,
    super.createdAt,
  });

  factory PeerDebtDetailModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?) ?? 0;
    final amountVnd = (json['amountVnd'] as num?) ?? (amount * 1000);

    return PeerDebtDetailModel(
      debtId: (json['debtId'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt() ?? 0,
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      groupName: (json['groupName'] as String?) ?? '',
      peerId: (json['peerId'] as num?)?.toInt() ?? 0,
      peerName: (json['peerName'] as String?) ?? '',
      peerAvatar: json['peerAvatar'] as String?,
      amount: amount,
      amountVnd: amountVnd,
      type: PeerDebtType.fromString(json['type'] as String?),
      status: DebtStatus.fromString(json['status'] as String?),
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'debtId': debtId,
      'groupId': groupId,
      'groupName': groupName,
      'peerId': peerId,
      'peerName': peerName,
      'peerAvatar': peerAvatar,
      'amount': amount,
      'amountVnd': amountVnd,
      'type': type == PeerDebtType.youOwe ? 'YOU_OWE' : 'OWED_TO_YOU',
      'status': status.toServerString(),
      'createdAt': createdAt,
    };
  }
}

class DebtOverviewModel extends DebtOverviewEntity {
  const DebtOverviewModel({
    super.totalOwed,
    super.totalOwedVnd,
    super.totalReceivable,
    super.totalReceivableVnd,
    super.netBalance,
    super.netBalanceVnd,
    List<GroupDebtBalanceModel> super.groupBalances = const [],
    List<PeerDebtDetailModel> super.details = const [],
  });

  factory DebtOverviewModel.fromJson(Map<String, dynamic> json) {
    final totalOwed = (json['totalOwed'] as num?) ?? 0;
    final totalOwedVnd = (json['totalOwedVnd'] as num?) ?? (totalOwed * 1000);

    final totalReceivable = (json['totalReceivable'] as num?) ?? 0;
    final totalReceivableVnd = (json['totalReceivableVnd'] as num?) ?? (totalReceivable * 1000);

    final netBalance = (json['netBalance'] as num?) ?? (totalReceivable - totalOwed);
    final netBalanceVnd = (json['netBalanceVnd'] as num?) ?? (totalReceivableVnd - totalOwedVnd);

    final rawGroupBalances = json['groupBalances'] as List<dynamic>?;
    final groupBalances = rawGroupBalances != null
        ? rawGroupBalances
            .whereType<Map<String, dynamic>>()
            .map((item) => GroupDebtBalanceModel.fromJson(item))
            .toList()
        : const <GroupDebtBalanceModel>[];

    final rawDetails = json['details'] as List<dynamic>?;
    final details = rawDetails != null
        ? rawDetails
            .whereType<Map<String, dynamic>>()
            .map((item) => PeerDebtDetailModel.fromJson(item))
            .toList()
        : const <PeerDebtDetailModel>[];

    return DebtOverviewModel(
      totalOwed: totalOwed,
      totalOwedVnd: totalOwedVnd,
      totalReceivable: totalReceivable,
      totalReceivableVnd: totalReceivableVnd,
      netBalance: netBalance,
      netBalanceVnd: netBalanceVnd,
      groupBalances: groupBalances,
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOwed': totalOwed,
      'totalOwedVnd': totalOwedVnd,
      'totalReceivable': totalReceivable,
      'totalReceivableVnd': totalReceivableVnd,
      'netBalance': netBalance,
      'netBalanceVnd': netBalanceVnd,
      'groupBalances': groupBalances.map((e) {
        if (e is GroupDebtBalanceModel) return e.toJson();
        return {
          'groupId': e.groupId,
          'groupName': e.groupName,
          'youOwe': e.youOwe,
          'youOweVnd': e.youOweVnd,
          'youAreOwed': e.youAreOwed,
          'youAreOwedVnd': e.youAreOwedVnd,
          'netBalance': e.netBalance,
          'netBalanceVnd': e.netBalanceVnd,
        };
      }).toList(),
      'details': details.map((e) {
        if (e is PeerDebtDetailModel) return e.toJson();
        return {
          'debtId': e.debtId,
          'groupId': e.groupId,
          'groupName': e.groupName,
          'peerId': e.peerId,
          'peerName': e.peerName,
          'peerAvatar': e.peerAvatar,
          'amount': e.amount,
          'amountVnd': e.amountVnd,
          'type': e.type == PeerDebtType.youOwe ? 'YOU_OWE' : 'OWED_TO_YOU',
          'status': e.status.toServerString(),
          'createdAt': e.createdAt,
        };
      }).toList(),
    };
  }
}
