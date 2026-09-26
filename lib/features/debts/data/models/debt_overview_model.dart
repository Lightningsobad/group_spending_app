class DebtOverviewModel {
  final num totalOwed;
  final num totalOwedVnd;
  final num totalReceivable;
  final num totalReceivableVnd;
  final num netBalance;
  final num netBalanceVnd;
  final List<dynamic> groupBalances;
  final List<dynamic> details;

  const DebtOverviewModel({
    this.totalOwed = 0,
    this.totalOwedVnd = 0,
    this.totalReceivable = 0,
    this.totalReceivableVnd = 0,
    this.netBalance = 0,
    this.netBalanceVnd = 0,
    this.groupBalances = const [],
    this.details = const [],
  });

  factory DebtOverviewModel.fromJson(Map<String, dynamic> json) {
    return DebtOverviewModel(
      totalOwed: (json['totalOwed'] as num?) ?? 0,
      totalOwedVnd: (json['totalOwedVnd'] as num?) ?? 0,
      totalReceivable: (json['totalReceivable'] as num?) ?? 0,
      totalReceivableVnd: (json['totalReceivableVnd'] as num?) ?? 0,
      netBalance: (json['netBalance'] as num?) ?? 0,
      netBalanceVnd: (json['netBalanceVnd'] as num?) ?? 0,
      groupBalances: (json['groupBalances'] as List<dynamic>?) ?? const [],
      details: (json['details'] as List<dynamic>?) ?? const [],
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
      'groupBalances': groupBalances,
      'details': details,
    };
  }
}
