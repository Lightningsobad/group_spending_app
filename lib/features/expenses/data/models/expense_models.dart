import 'expense_enums.dart';

class ExpenseListItemModel {
  final int id;
  final String title;
  final num amount;
  final num amountVnd;
  final String? expenseDate;
  final String paidBy;
  final int paidByUserId;
  final String status;
  final num myAmountOwed;
  final num myAmountOwedVnd;
  final String categoryName;
  final String? categoryIcon;

  const ExpenseListItemModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.amountVnd,
    this.expenseDate,
    required this.paidBy,
    required this.paidByUserId,
    required this.status,
    required this.myAmountOwed,
    required this.myAmountOwedVnd,
    required this.categoryName,
    this.categoryIcon,
  });

  bool get isPaidByMe => status == 'PAID_BY_ME';

  ExpenseCategoryType get categoryType => ExpenseCategoryType.fromString(categoryName);

  factory ExpenseListItemModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = (json['amount'] as num?) ?? 0;
    final rawAmountVnd = (json['amountVnd'] as num?) ?? (rawAmount * 1000);
    final rawOwed = (json['myAmountOwed'] as num?) ?? 0;
    final rawOwedVnd = (json['myAmountOwedVnd'] as num?) ?? (rawOwed * 1000);

    return ExpenseListItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      amount: rawAmount,
      amountVnd: rawAmountVnd,
      expenseDate: json['expenseDate'] as String?,
      paidBy: (json['paidBy'] as String?) ?? '',
      paidByUserId: (json['paidByUserId'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? '',
      myAmountOwed: rawOwed,
      myAmountOwedVnd: rawOwedVnd,
      categoryName: (json['categoryName'] as String?) ?? 'Others',
      categoryIcon: json['categoryIcon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'amountVnd': amountVnd,
      if (expenseDate != null) 'expenseDate': expenseDate,
      'paidBy': paidBy,
      'paidByUserId': paidByUserId,
      'status': status,
      'myAmountOwed': myAmountOwed,
      'myAmountOwedVnd': myAmountOwedVnd,
      'categoryName': categoryName,
      if (categoryIcon != null) 'categoryIcon': categoryIcon,
    };
  }
}

class GroupExpensesResponseModel {
  final num totalSpending;
  final num totalSpendingVnd;
  final int expenseCount;
  final List<ExpenseListItemModel> expenses;

  const GroupExpensesResponseModel({
    required this.totalSpending,
    required this.totalSpendingVnd,
    required this.expenseCount,
    required this.expenses,
  });

  factory GroupExpensesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = (json['totalSpending'] as num?) ?? 0;
    final rawTotalVnd = (json['totalSpendingVnd'] as num?) ?? (rawTotal * 1000);
    final list = <ExpenseListItemModel>[];
    if (json['expenses'] is List) {
      for (final item in json['expenses'] as List) {
        if (item is Map<String, dynamic>) {
          list.add(ExpenseListItemModel.fromJson(item));
        }
      }
    }

    return GroupExpensesResponseModel(
      totalSpending: rawTotal,
      totalSpendingVnd: rawTotalVnd,
      expenseCount: (json['expenseCount'] as num?)?.toInt() ?? list.length,
      expenses: list,
    );
  }
}

class ExpenseSplitModel {
  final int id;
  final int userId;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final num amountOwed;
  final num amountOwedVnd;
  final bool isPaid;
  final String? status;

  const ExpenseSplitModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.email,
    this.avatarUrl,
    required this.amountOwed,
    required this.amountOwedVnd,
    this.isPaid = false,
    this.status,
  });

  ExpenseSplitStatus get splitStatus => ExpenseSplitStatus.fromString(status, isPaid: isPaid);

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    final rawOwed = (json['amountOwed'] as num?) ?? 0;
    final rawOwedVnd = (json['amountOwedVnd'] as num?) ?? (rawOwed * 1000);
    final isPaid = (json['isPaid'] as bool?) ?? (json['settled'] as bool?) ?? false;

    return ExpenseSplitModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      amountOwed: rawOwed,
      amountOwedVnd: rawOwedVnd,
      isPaid: isPaid,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'amountOwed': amountOwed,
      'amountOwedVnd': amountOwedVnd,
      'isPaid': isPaid,
      if (status != null) 'status': status,
    };
  }
}

class ExpenseDetailModel {
  final int id;
  final int groupId;
  final String? groupName;
  final String title;
  final num totalAmount;
  final num totalAmountVnd;
  final int paidByUserId;
  final String paidByUserName;
  final String? paidByUserAvatar;
  final String? expenseDate;
  final String? receiptUrl;
  final String status;
  final String? notes;
  final int createdByUserId;
  final String? createdByUserName;
  final String categoryName;
  final String? categoryIcon;
  final List<ExpenseSplitModel> splits;
  final int commentCount;
  final String? createdAt;
  final String? updatedAt;

  const ExpenseDetailModel({
    required this.id,
    required this.groupId,
    this.groupName,
    required this.title,
    required this.totalAmount,
    required this.totalAmountVnd,
    required this.paidByUserId,
    required this.paidByUserName,
    this.paidByUserAvatar,
    this.expenseDate,
    this.receiptUrl,
    required this.status,
    this.notes,
    required this.createdByUserId,
    this.createdByUserName,
    required this.categoryName,
    this.categoryIcon,
    required this.splits,
    this.commentCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  ExpenseCategoryType get categoryType => ExpenseCategoryType.fromString(categoryName);

  factory ExpenseDetailModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = (json['totalAmount'] as num?) ?? (json['amount'] as num?) ?? 0;
    final rawTotalVnd = (json['totalAmountVnd'] as num?) ?? (rawTotal * 1000);

    String catName = 'Others';
    String? catIcon;
    if (json['category'] is Map<String, dynamic>) {
      catName = (json['category']['name'] as String?) ?? 'Others';
      catIcon = json['category']['icon'] as String?;
    } else if (json['categoryName'] is String) {
      catName = json['categoryName'] as String;
      catIcon = json['categoryIcon'] as String?;
    } else if (json['category'] is String) {
      catName = json['category'] as String;
    }

    final splitsList = <ExpenseSplitModel>[];
    if (json['splits'] is List) {
      for (final s in json['splits'] as List) {
        if (s is Map<String, dynamic>) {
          splitsList.add(ExpenseSplitModel.fromJson(s));
        }
      }
    }

    return ExpenseDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      groupName: json['groupName'] as String?,
      title: (json['title'] as String?) ?? '',
      totalAmount: rawTotal,
      totalAmountVnd: rawTotalVnd,
      paidByUserId: (json['paidByUserId'] as num?)?.toInt() ?? 0,
      paidByUserName: (json['paidByUserName'] as String?) ?? (json['paidBy'] as String?) ?? '',
      paidByUserAvatar: json['paidByUserAvatar'] as String?,
      expenseDate: json['expenseDate'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      status: (json['status'] as String?) ?? 'ACTIVE',
      notes: json['notes'] as String?,
      createdByUserId: (json['createdByUserId'] as num?)?.toInt() ?? 0,
      createdByUserName: json['createdByUserName'] as String?,
      categoryName: catName,
      categoryIcon: catIcon,
      splits: splitsList,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      if (groupName != null) 'groupName': groupName,
      'title': title,
      'totalAmount': totalAmount,
      'totalAmountVnd': totalAmountVnd,
      'paidByUserId': paidByUserId,
      'paidByUserName': paidByUserName,
      if (paidByUserAvatar != null) 'paidByUserAvatar': paidByUserAvatar,
      if (expenseDate != null) 'expenseDate': expenseDate,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
      'status': status,
      if (notes != null) 'notes': notes,
      'createdByUserId': createdByUserId,
      if (createdByUserName != null) 'createdByUserName': createdByUserName,
      'categoryName': categoryName,
      if (categoryIcon != null) 'categoryIcon': categoryIcon,
      'splits': splits.map((e) => e.toJson()).toList(),
      'commentCount': commentCount,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}

class CreateExpenseRequest {
  final String title;
  final num totalAmount; // in 'k' (e.g. 150)
  final int paidByUserId;
  final String expenseDate;
  final String? notes;
  final String category;
  final String splitOption;
  final List<int>? participantUserIds;
  final String? receiptUrl;

  const CreateExpenseRequest({
    required this.title,
    required this.totalAmount,
    required this.paidByUserId,
    required this.expenseDate,
    this.notes,
    required this.category,
    this.splitOption = 'EQUAL_ALL',
    this.participantUserIds,
    this.receiptUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'totalAmount': totalAmount,
      'paidByUserId': paidByUserId,
      'expenseDate': expenseDate,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      'category': category,
      'splitOption': splitOption,
      if (participantUserIds != null && participantUserIds!.isNotEmpty)
        'participantUserIds': participantUserIds,
      if (receiptUrl != null && receiptUrl!.trim().isNotEmpty)
        'receiptUrl': receiptUrl!.trim(),
    };
  }
}

class UpdateExpenseRequest {
  final String title;
  final num totalAmount;
  final int paidByUserId;
  final String expenseDate;
  final String? notes;
  final String category;
  final String splitOption;
  final List<int>? participantUserIds;
  final String? receiptUrl;

  const UpdateExpenseRequest({
    required this.title,
    required this.totalAmount,
    required this.paidByUserId,
    required this.expenseDate,
    this.notes,
    required this.category,
    this.splitOption = 'EQUAL_ALL',
    this.participantUserIds,
    this.receiptUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'totalAmount': totalAmount,
      'paidByUserId': paidByUserId,
      'expenseDate': expenseDate,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      'category': category,
      'splitOption': splitOption,
      if (participantUserIds != null && participantUserIds!.isNotEmpty)
        'participantUserIds': participantUserIds,
      if (receiptUrl != null && receiptUrl!.trim().isNotEmpty)
        'receiptUrl': receiptUrl!.trim(),
    };
  }
}
