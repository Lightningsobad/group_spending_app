import 'group_member_models.dart';

class GroupMemberModel {
  final int id;
  final int userId;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String role; // 'ADMIN', 'MEMBER'
  final bool isMuted;
  final String? joinedAt;

  const GroupMemberModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.email,
    this.avatarUrl,
    required this.role,
    this.isMuted = false,
    this.joinedAt,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  factory GroupMemberModel.fromSummary(GroupMemberSummaryModel summary) {
    return GroupMemberModel(
      id: summary.userId,
      userId: summary.userId,
      fullName: summary.fullName,
      role: summary.role,
      avatarUrl: summary.avatarUrl,
    );
  }

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: (json['role'] as String?) ?? 'MEMBER',
      isMuted: (json['isMuted'] as bool?) ?? false,
      joinedAt: json['joinedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'role': role,
      'isMuted': isMuted,
      if (joinedAt != null) 'joinedAt': joinedAt,
    };
  }
}

class GroupModel {
  final int id;
  final String name;
  final String? description;
  final String defaultCurrency;
  final String category;
  final String? inviteCode;
  final String? codeExpiredAt;
  final String status; // 'ACTIVE', 'ARCHIVED'
  final int ownerId;
  final String? ownerName;
  final String role; // 'ADMIN', 'MEMBER'
  final num userBalance;
  final int pendingDebtCount;
  final num? totalSpending;
  final num? totalSpendingVnd;
  final num? totalFundCollected;
  final num? totalFundCollectedVnd;
  final int memberCount;
  final String? createdAt;
  final List<GroupMemberModel>? members;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.defaultCurrency = 'VND',
    this.category = 'Other',
    this.inviteCode,
    this.codeExpiredAt,
    this.status = 'ACTIVE',
    required this.ownerId,
    this.ownerName,
    this.role = 'MEMBER',
    this.userBalance = 0,
    this.pendingDebtCount = 0,
    this.totalSpending,
    this.totalSpendingVnd,
    this.totalFundCollected,
    this.totalFundCollectedVnd,
    this.memberCount = 1,
    this.createdAt,
    this.members,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isArchived => status.toUpperCase() == 'ARCHIVED';
  bool get isActive => !isArchived;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    List<GroupMemberModel>? membersList;
    if (json['members'] is List) {
      membersList = (json['members'] as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => GroupMemberModel.fromJson(m))
          .toList();
    }

    return GroupModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      defaultCurrency: (json['defaultCurrency'] as String?) ?? 'VND',
      category: (json['category'] as String?) ?? 'Other',
      inviteCode: json['inviteCode'] as String?,
      codeExpiredAt: json['codeExpiredAt'] as String?,
      status: (json['status'] as String?) ?? 'ACTIVE',
      ownerId: (json['ownerId'] as num?)?.toInt() ?? 0,
      ownerName: json['ownerName'] as String?,
      role: (json['role'] as String?) ?? 'MEMBER',
      userBalance: (json['userBalance'] as num?) ?? 0,
      pendingDebtCount: (json['pendingDebtCount'] as num?)?.toInt() ?? 0,
      totalSpending: json['totalSpending'] as num?,
      totalSpendingVnd: json['totalSpendingVnd'] as num?,
      totalFundCollected: json['totalFundCollected'] as num?,
      totalFundCollectedVnd: json['totalFundCollectedVnd'] as num?,
      memberCount: (json['memberCount'] as num?)?.toInt() ??
          (membersList != null && membersList.isNotEmpty ? membersList.length : 1),
      createdAt: json['createdAt'] as String?,
      members: membersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'defaultCurrency': defaultCurrency,
      'category': category,
      if (inviteCode != null) 'inviteCode': inviteCode,
      if (codeExpiredAt != null) 'codeExpiredAt': codeExpiredAt,
      'status': status,
      'ownerId': ownerId,
      if (ownerName != null) 'ownerName': ownerName,
      'role': role,
      'userBalance': userBalance,
      'pendingDebtCount': pendingDebtCount,
      if (totalSpending != null) 'totalSpending': totalSpending,
      if (totalSpendingVnd != null) 'totalSpendingVnd': totalSpendingVnd,
      if (totalFundCollected != null) 'totalFundCollected': totalFundCollected,
      if (totalFundCollectedVnd != null) 'totalFundCollectedVnd': totalFundCollectedVnd,
      'memberCount': memberCount,
      if (createdAt != null) 'createdAt': createdAt,
      if (members != null) 'members': members!.map((m) => m.toJson()).toList(),
    };
  }

  GroupModel copyWith({
    int? id,
    String? name,
    String? description,
    String? defaultCurrency,
    String? category,
    String? inviteCode,
    String? codeExpiredAt,
    String? status,
    int? ownerId,
    String? ownerName,
    String? role,
    num? userBalance,
    int? pendingDebtCount,
    num? totalSpending,
    num? totalSpendingVnd,
    num? totalFundCollected,
    num? totalFundCollectedVnd,
    int? memberCount,
    String? createdAt,
    List<GroupMemberModel>? members,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      category: category ?? this.category,
      inviteCode: inviteCode ?? this.inviteCode,
      codeExpiredAt: codeExpiredAt ?? this.codeExpiredAt,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      role: role ?? this.role,
      userBalance: userBalance ?? this.userBalance,
      pendingDebtCount: pendingDebtCount ?? this.pendingDebtCount,
      totalSpending: totalSpending ?? this.totalSpending,
      totalSpendingVnd: totalSpendingVnd ?? this.totalSpendingVnd,
      totalFundCollected: totalFundCollected ?? this.totalFundCollected,
      totalFundCollectedVnd: totalFundCollectedVnd ?? this.totalFundCollectedVnd,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }
}
