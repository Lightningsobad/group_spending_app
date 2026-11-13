class GroupMemberSummaryModel {
  final int userId;
  final String fullName;
  final String role; // 'ADMIN', 'MEMBER'
  final String? avatarUrl;

  const GroupMemberSummaryModel({
    required this.userId,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  factory GroupMemberSummaryModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberSummaryModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'MEMBER',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'role': role,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}

class GroupJoinRequestModel {
  final int id;
  final int groupId;
  final String groupName;
  final int userId;
  final String userFullName;
  final String userEmail;
  final String? userAvatarUrl;
  final String status; // 'PENDING'
  final String requestedAt;
  final String? reviewedAt;

  const GroupJoinRequestModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    this.userAvatarUrl,
    required this.status,
    required this.requestedAt,
    this.reviewedAt,
  });

  factory GroupJoinRequestModel.fromJson(Map<String, dynamic> json) {
    return GroupJoinRequestModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      groupName: (json['groupName'] as String?) ?? '',
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userFullName: (json['userFullName'] as String?) ?? '',
      userEmail: (json['userEmail'] as String?) ?? '',
      userAvatarUrl: json['userAvatarUrl'] as String?,
      status: (json['status'] as String?) ?? 'PENDING',
      requestedAt: (json['requestedAt'] as String?) ?? '',
      reviewedAt: json['reviewedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'userId': userId,
      'userFullName': userFullName,
      'userEmail': userEmail,
      if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
      'status': status,
      'requestedAt': requestedAt,
      if (reviewedAt != null) 'reviewedAt': reviewedAt,
    };
  }
}

class GroupJoinRequestsResult {
  final int groupId;
  final int totalRequests;
  final List<GroupJoinRequestModel> requests;

  const GroupJoinRequestsResult({
    required this.groupId,
    required this.totalRequests,
    required this.requests,
  });

  factory GroupJoinRequestsResult.fromJson(Map<String, dynamic> json) {
    List<GroupJoinRequestModel> list = [];
    if (json['requests'] is List) {
      list = (json['requests'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => GroupJoinRequestModel.fromJson(item))
          .toList();
    }

    return GroupJoinRequestsResult(
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      totalRequests: (json['totalRequests'] as num?)?.toInt() ?? list.length,
      requests: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'totalRequests': totalRequests,
      'requests': requests.map((r) => r.toJson()).toList(),
    };
  }
}

class ParticipatedExpenseModel {
  final int expenseId;
  final String title;
  final num amount;
  final num amountVnd;
  final num myAmountOwed;
  final num myAmountOwedVnd;
  final bool isPaidByMember;
  final String expenseDate;
  final String categoryName;
  final String categoryIcon;

  const ParticipatedExpenseModel({
    required this.expenseId,
    required this.title,
    required this.amount,
    required this.amountVnd,
    required this.myAmountOwed,
    required this.myAmountOwedVnd,
    required this.isPaidByMember,
    required this.expenseDate,
    required this.categoryName,
    required this.categoryIcon,
  });

  factory ParticipatedExpenseModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = (json['amount'] as num?) ?? 0;
    final rawAmountVnd = (json['amountVnd'] as num?) ?? (rawAmount * 1000);
    final rawOwed = (json['myAmountOwed'] as num?) ?? 0;
    final rawOwedVnd = (json['myAmountOwedVnd'] as num?) ?? (rawOwed * 1000);

    return ParticipatedExpenseModel(
      expenseId: (json['expenseId'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      amount: rawAmount,
      amountVnd: rawAmountVnd,
      myAmountOwed: rawOwed,
      myAmountOwedVnd: rawOwedVnd,
      isPaidByMember: (json['isPaidByMember'] as bool?) ?? false,
      expenseDate: (json['expenseDate'] as String?) ?? '',
      categoryName: (json['categoryName'] as String?) ?? '',
      categoryIcon: (json['categoryIcon'] as String?) ?? 'receipt',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'title': title,
      'amount': amount,
      'amountVnd': amountVnd,
      'myAmountOwed': myAmountOwed,
      'myAmountOwedVnd': myAmountOwedVnd,
      'isPaidByMember': isPaidByMember,
      'expenseDate': expenseDate,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
    };
  }
}

class GroupMemberDetailModel {
  final int userId;
  final String fullName;
  final String? avatarUrl;
  final String role; // 'ADMIN', 'MEMBER'
  final String? joinedAt;
  final int groupId;
  final String groupName;
  final String email;
  final String? phone;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final num debtAmount;
  final num debtAmountVnd;
  final num receivableAmount;
  final num receivableAmountVnd;
  final num netBalance;
  final num netBalanceVnd;
  final double debtSettlementRate;
  final double fundContributionOnTimeRate;
  final int participatedExpenseCount;
  final List<ParticipatedExpenseModel> participatedExpenses;

  const GroupMemberDetailModel({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.joinedAt,
    required this.groupId,
    required this.groupName,
    required this.email,
    this.phone,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.debtAmount = 0,
    this.debtAmountVnd = 0,
    this.receivableAmount = 0,
    this.receivableAmountVnd = 0,
    this.netBalance = 0,
    this.netBalanceVnd = 0,
    this.debtSettlementRate = 0.0,
    this.fundContributionOnTimeRate = 0.0,
    this.participatedExpenseCount = 0,
    this.participatedExpenses = const [],
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get hasBankInfo =>
      bankAccountNumber != null && bankAccountNumber!.trim().isNotEmpty;

  factory GroupMemberDetailModel.fromJson(Map<String, dynamic> json) {
    List<ParticipatedExpenseModel> expensesList = [];
    if (json['participatedExpenses'] is List) {
      expensesList = (json['participatedExpenses'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ParticipatedExpenseModel.fromJson(e))
          .toList();
    }

    final rawDebt = (json['debtAmount'] as num?) ?? 0;
    final rawDebtVnd = (json['debtAmountVnd'] as num?) ?? (rawDebt * 1000);
    final rawReceivable = (json['receivableAmount'] as num?) ?? 0;
    final rawReceivableVnd =
        (json['receivableAmountVnd'] as num?) ?? (rawReceivable * 1000);
    final rawNet = (json['netBalance'] as num?) ?? (rawReceivable - rawDebt);
    final rawNetVnd = (json['netBalanceVnd'] as num?) ??
        (rawReceivableVnd - rawDebtVnd);

    return GroupMemberDetailModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: (json['role'] as String?) ?? 'MEMBER',
      joinedAt: json['joinedAt'] as String?,
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      groupName: (json['groupName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      debtAmount: rawDebt,
      debtAmountVnd: rawDebtVnd,
      receivableAmount: rawReceivable,
      receivableAmountVnd: rawReceivableVnd,
      netBalance: rawNet,
      netBalanceVnd: rawNetVnd,
      debtSettlementRate:
          (json['debtSettlementRate'] as num?)?.toDouble() ?? 0.0,
      fundContributionOnTimeRate:
          (json['fundContributionOnTimeRate'] as num?)?.toDouble() ?? 0.0,
      participatedExpenseCount:
          (json['participatedExpenseCount'] as num?)?.toInt() ??
              expensesList.length,
      participatedExpenses: expensesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'role': role,
      if (joinedAt != null) 'joinedAt': joinedAt,
      'groupId': groupId,
      'groupName': groupName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (bankName != null) 'bankName': bankName,
      if (bankAccountNumber != null) 'bankAccountNumber': bankAccountNumber,
      if (bankAccountName != null) 'bankAccountName': bankAccountName,
      'debtAmount': debtAmount,
      'debtAmountVnd': debtAmountVnd,
      'receivableAmount': receivableAmount,
      'receivableAmountVnd': receivableAmountVnd,
      'netBalance': netBalance,
      'netBalanceVnd': netBalanceVnd,
      'debtSettlementRate': debtSettlementRate,
      'fundContributionOnTimeRate': fundContributionOnTimeRate,
      'participatedExpenseCount': participatedExpenseCount,
      'participatedExpenses': participatedExpenses.map((e) => e.toJson()).toList(),
    };
  }
}
