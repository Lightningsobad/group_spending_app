class GroupSummaryModel {
  final int id;
  final String name;
  final num? totalSpending;
  final num? totalSpendingVnd;
  final int memberCount;
  final String? status;
  final String? category;

  const GroupSummaryModel({
    required this.id,
    required this.name,
    this.totalSpending,
    this.totalSpendingVnd,
    this.memberCount = 1,
    this.status,
    this.category,
  });

  num get spendingVnd => totalSpendingVnd ?? ((totalSpending ?? 0) * 1000);

  String get effectiveCategory =>
      (category != null && category!.trim().isNotEmpty) ? category!.trim() : 'Other';

  factory GroupSummaryModel.fromJson(Map<String, dynamic> json) {
    return GroupSummaryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      totalSpending: json['totalSpending'] as num?,
      totalSpendingVnd: json['totalSpendingVnd'] as num?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String?,
      category: (json['category'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (totalSpending != null) 'totalSpending': totalSpending,
      if (totalSpendingVnd != null) 'totalSpendingVnd': totalSpendingVnd,
      'memberCount': memberCount,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
    };
  }
}
