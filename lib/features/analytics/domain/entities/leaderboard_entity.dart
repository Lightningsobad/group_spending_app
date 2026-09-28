class LeaderboardMemberEntity {
  final int rank;
  final int userId;
  final String fullName;
  final String? avatarUrl;
  final String? email;
  final num contributedAmountVnd;
  final double percentage;
  final int? expenseCount;

  const LeaderboardMemberEntity({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.email,
    required this.contributedAmountVnd,
    required this.percentage,
    this.expenseCount,
  });
}
