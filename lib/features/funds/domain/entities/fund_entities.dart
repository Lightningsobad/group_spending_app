import 'fund_enums.dart';

class FundMemberEntity {
  final int id;
  final int userId;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final FundMemberStatus status;
  final String? paidAt;

  const FundMemberEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    this.email,
    this.avatarUrl,
    required this.status,
    this.paidAt,
  });

  bool get isPaid => status == FundMemberStatus.paid;
  bool get isPending => status == FundMemberStatus.pending;
}

class FundCollectionItemEntity {
  final int id;
  final String name;
  final FundCollectionStatus status;
  final String statusText;
  final String? startDate;
  final num? totalTargetAmountVnd;
  final num? totalCollectedAmountVnd;
  final int? paidCount;
  final int? totalMemberCount;

  const FundCollectionItemEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.statusText,
    this.startDate,
    this.totalTargetAmountVnd,
    this.totalCollectedAmountVnd,
    this.paidCount,
    this.totalMemberCount,
  });

  bool get isCollecting => status == FundCollectionStatus.collecting;
  bool get isCompleted => status == FundCollectionStatus.completed;
}

class FundCollectionEntity {
  final int id;
  final int groupId;
  final String name;
  final String? description;
  final num targetAmountPerPerson;
  final num targetAmountPerPersonVnd;
  final String? dueDate;
  final int? createdByUserId;
  final String? createdByUserName;
  final num totalTargetAmount;
  final num totalTargetAmountVnd;
  final num totalCollectedAmount;
  final num totalCollectedAmountVnd;
  final int paidCount;
  final int totalMemberCount;
  final FundCollectionStatus status;
  final List<FundMemberEntity> members;
  final String? createdAt;

  const FundCollectionEntity({
    required this.id,
    required this.groupId,
    required this.name,
    this.description,
    required this.targetAmountPerPerson,
    required this.targetAmountPerPersonVnd,
    this.dueDate,
    this.createdByUserId,
    this.createdByUserName,
    required this.totalTargetAmount,
    required this.totalTargetAmountVnd,
    required this.totalCollectedAmount,
    required this.totalCollectedAmountVnd,
    required this.paidCount,
    required this.totalMemberCount,
    required this.status,
    required this.members,
    this.createdAt,
  });

  bool get isCompleted => status == FundCollectionStatus.completed;
  bool get isCollecting => status == FundCollectionStatus.collecting;

  double get completionPercentage {
    if (totalTargetAmountVnd <= 0) return 0.0;
    final pct = (totalCollectedAmountVnd / totalTargetAmountVnd) * 100;
    return pct > 100.0 ? 100.0 : (pct < 0.0 ? 0.0 : pct);
  }
}

class GroupFundsOverviewEntity {
  final int groupId;
  final num totalCollectedAmount;
  final num totalCollectedAmountVnd;
  final num totalTargetAmount;
  final num totalTargetAmountVnd;
  final double completionPercentage;
  final List<FundCollectionItemEntity> funds;

  const GroupFundsOverviewEntity({
    required this.groupId,
    required this.totalCollectedAmount,
    required this.totalCollectedAmountVnd,
    required this.totalTargetAmount,
    required this.totalTargetAmountVnd,
    required this.completionPercentage,
    required this.funds,
  });
}
