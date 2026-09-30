import '../../domain/entities/fund_entities.dart';
import '../../domain/entities/fund_enums.dart';

class FundMemberModel extends FundMemberEntity {
  const FundMemberModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.email,
    super.avatarUrl,
    required super.status,
    super.paidAt,
  });

  factory FundMemberModel.fromJson(Map<String, dynamic> json) {
    return FundMemberModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      status: FundMemberStatus.fromString(json['status'] as String?),
      paidAt: json['paidAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'status': status.value,
      if (paidAt != null) 'paidAt': paidAt,
    };
  }
}

class FundCollectionItemModel extends FundCollectionItemEntity {
  const FundCollectionItemModel({
    required super.id,
    required super.name,
    required super.status,
    required super.statusText,
    super.startDate,
    super.totalTargetAmountVnd,
    super.totalCollectedAmountVnd,
    super.paidCount,
    super.totalMemberCount,
  });

  factory FundCollectionItemModel.fromJson(Map<String, dynamic> json) {
    final rawTarget = json['totalTargetAmount'] as num?;
    final rawTargetVnd = json['totalTargetAmountVnd'] as num?;
    final resolvedTargetVnd = rawTargetVnd ?? (rawTarget != null ? rawTarget * 1000 : null);

    final rawCollected = json['totalCollectedAmount'] as num?;
    final rawCollectedVnd = json['totalCollectedAmountVnd'] as num?;
    final resolvedCollectedVnd = rawCollectedVnd ?? (rawCollected != null ? rawCollected * 1000 : null);

    final status = FundCollectionStatus.fromString(json['status'] as String?);

    return FundCollectionItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      status: status,
      statusText: (json['statusText'] as String?) ??
          (status == FundCollectionStatus.completed ? 'Hoàn thành' : 'Đang thu'),
      startDate: json['startDate'] as String?,
      totalTargetAmountVnd: resolvedTargetVnd,
      totalCollectedAmountVnd: resolvedCollectedVnd,
      paidCount: (json['paidCount'] as num?)?.toInt(),
      totalMemberCount: (json['totalMemberCount'] as num?)?.toInt(),
    );
  }
}

class FundCollectionModel extends FundCollectionEntity {
  const FundCollectionModel({
    required super.id,
    required super.groupId,
    required super.name,
    super.description,
    required super.targetAmountPerPerson,
    required super.targetAmountPerPersonVnd,
    super.dueDate,
    super.createdByUserId,
    super.createdByUserName,
    required super.totalTargetAmount,
    required super.totalTargetAmountVnd,
    required super.totalCollectedAmount,
    required super.totalCollectedAmountVnd,
    required super.paidCount,
    required super.totalMemberCount,
    required super.status,
    required super.members,
    super.createdAt,
  });

  factory FundCollectionModel.fromJson(Map<String, dynamic> json) {
    final targetPerPerson = (json['targetAmountPerPerson'] as num?) ?? 0;
    final targetPerPersonVnd = (json['targetAmountPerPersonVnd'] as num?) ??
        (targetPerPerson * 1000);

    final totalTarget = (json['totalTargetAmount'] as num?) ?? 0;
    final totalTargetVnd = (json['totalTargetAmountVnd'] as num?) ??
        (totalTarget * 1000);

    final totalCollected = (json['totalCollectedAmount'] as num?) ?? 0;
    final totalCollectedVnd = (json['totalCollectedAmountVnd'] as num?) ??
        (totalCollected * 1000);

    final membersJson = json['members'];
    final List<FundMemberModel> membersList = [];
    if (membersJson is List) {
      for (final m in membersJson) {
        if (m is Map<String, dynamic>) {
          membersList.add(FundMemberModel.fromJson(m));
        }
      }
    }

    final paidCount = (json['paidCount'] as num?)?.toInt() ??
        membersList.where((m) => m.isPaid).length;
    final totalMemberCount = (json['totalMemberCount'] as num?)?.toInt() ??
        membersList.length;

    // Tự động suy ra trạng thái nếu backend không gửi trường status trực tiếp
    FundCollectionStatus status;
    if (json['status'] != null) {
      status = FundCollectionStatus.fromString(json['status'] as String?);
    } else if (totalMemberCount > 0 && paidCount >= totalMemberCount) {
      status = FundCollectionStatus.completed;
    } else {
      status = FundCollectionStatus.collecting;
    }

    return FundCollectionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      targetAmountPerPerson: targetPerPerson,
      targetAmountPerPersonVnd: targetPerPersonVnd,
      dueDate: json['dueDate'] as String?,
      createdByUserId: (json['createdByUserId'] as num?)?.toInt(),
      createdByUserName: json['createdByUserName'] as String?,
      totalTargetAmount: totalTarget,
      totalTargetAmountVnd: totalTargetVnd,
      totalCollectedAmount: totalCollected,
      totalCollectedAmountVnd: totalCollectedVnd,
      paidCount: paidCount,
      totalMemberCount: totalMemberCount,
      status: status,
      members: membersList,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class GroupFundsOverviewModel extends GroupFundsOverviewEntity {
  const GroupFundsOverviewModel({
    required super.groupId,
    required super.totalCollectedAmount,
    required super.totalCollectedAmountVnd,
    required super.totalTargetAmount,
    required super.totalTargetAmountVnd,
    required super.completionPercentage,
    required super.funds,
  });

  factory GroupFundsOverviewModel.fromJson(Map<String, dynamic> json) {
    final rawCollected = (json['totalCollectedAmount'] as num?) ?? 0;
    final rawCollectedVnd = (json['totalCollectedAmountVnd'] as num?) ?? (rawCollected * 1000);

    final rawTarget = (json['totalTargetAmount'] as num?) ?? 0;
    final rawTargetVnd = (json['totalTargetAmountVnd'] as num?) ?? (rawTarget * 1000);

    final completionPct = (json['completionPercentage'] as num?)?.toDouble() ??
        (rawTargetVnd > 0 ? ((rawCollectedVnd / rawTargetVnd) * 100) : 0.0);

    final fundsJson = json['funds'];
    final List<FundCollectionItemModel> fundsList = [];
    if (fundsJson is List) {
      for (final f in fundsJson) {
        if (f is Map<String, dynamic>) {
          fundsList.add(FundCollectionItemModel.fromJson(f));
        }
      }
    }

    return GroupFundsOverviewModel(
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      totalCollectedAmount: rawCollected,
      totalCollectedAmountVnd: rawCollectedVnd,
      totalTargetAmount: rawTarget,
      totalTargetAmountVnd: rawTargetVnd,
      completionPercentage: completionPct > 100.0 ? 100.0 : (completionPct < 0 ? 0.0 : completionPct),
      funds: fundsList,
    );
  }
}

class CreateFundCollectionRequest {
  final String name;
  final String? description;
  final int targetAmountPerPerson; // In 'k'
  final String? dueDate;
  final List<int>? memberUserIds;

  const CreateFundCollectionRequest({
    required this.name,
    this.description,
    required this.targetAmountPerPerson,
    this.dueDate,
    this.memberUserIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'targetAmountPerPerson': targetAmountPerPerson,
      if (dueDate != null && dueDate!.trim().isNotEmpty)
        'dueDate': dueDate!.trim(),
      if (memberUserIds != null && memberUserIds!.isNotEmpty)
        'memberUserIds': memberUserIds,
    };
  }
}

class UpdateFundCollectionRequest {
  final String name;
  final String? description;
  final int targetAmountPerPerson; // In 'k'
  final String? dueDate;
  final List<int>? memberUserIds;

  const UpdateFundCollectionRequest({
    required this.name,
    this.description,
    required this.targetAmountPerPerson,
    this.dueDate,
    this.memberUserIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'targetAmountPerPerson': targetAmountPerPerson,
      if (dueDate != null && dueDate!.trim().isNotEmpty)
        'dueDate': dueDate!.trim(),
      if (memberUserIds != null && memberUserIds!.isNotEmpty)
        'memberUserIds': memberUserIds,
    };
  }
}
