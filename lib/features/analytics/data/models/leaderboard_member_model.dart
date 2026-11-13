import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardMemberModel {
  final int rank;
  final int userId;
  final String fullName;
  final String? avatarUrl;
  final String? email;
  final num contributedAmountVnd;
  final double percentage;
  final int? expenseCount;

  const LeaderboardMemberModel({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.email,
    required this.contributedAmountVnd,
    required this.percentage,
    this.expenseCount,
  });

  factory LeaderboardMemberModel.fromJson(Map<String, dynamic> json) {
    num contributedVnd = 0;
    if (json['contributedAmountVnd'] != null) {
      contributedVnd = json['contributedAmountVnd'] as num;
    } else if (json['contributedAmount'] != null) {
      contributedVnd = (json['contributedAmount'] as num) * 1000;
    }

    return LeaderboardMemberModel(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      email: json['email'] as String?,
      contributedAmountVnd: contributedVnd,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      expenseCount: (json['expenseCount'] as num?)?.toInt(),
    );
  }

  LeaderboardMemberEntity toEntity() {
    return LeaderboardMemberEntity(
      rank: rank,
      userId: userId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      email: email,
      contributedAmountVnd: contributedAmountVnd,
      percentage: percentage,
      expenseCount: expenseCount,
    );
  }
}
