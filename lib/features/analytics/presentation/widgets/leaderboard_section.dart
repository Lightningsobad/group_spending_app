import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardSection extends StatelessWidget {
  final String title;
  final int? memberCount;
  final List<LeaderboardMemberEntity> members;
  final int? currentUserId;

  const LeaderboardSection({
    super.key,
    required this.title,
    this.memberCount,
    required this.members,
    this.currentUserId,
  });

  Widget _buildRankBadge(BuildContext context, int rank) {
    if (rank == 1) {
      return const Text('🥇', style: TextStyle(fontSize: 20));
    }
    if (rank == 2) {
      return const Text('🥈', style: TextStyle(fontSize: 20));
    }
    if (rank == 3) {
      return const Text('🥉', style: TextStyle(fontSize: 20));
    }
    return Container(
      width: 24,
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: AppTextStyle.bold(
          color: context.colors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('🏅', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyle.bold(
                    color: colors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (memberCount != null)
              Text(
                tr.membersCountSubtitle(memberCount!),
                style: AppTextStyle.regular(
                  color: colors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (members.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Text(
              tr.noLeaderboardData,
              style: AppTextStyle.regular(color: colors.textMuted),
            ),
          )
        else
          ...members.map((member) {
            final isCurrentUser =
                currentUserId != null && member.userId == currentUserId;
            final percentFormatted = member.percentage
                .toStringAsFixed(member.percentage.truncateToDouble() == member.percentage ? 0 : 1);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentUser
                      ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                      : colors.cardBorder,
                  width: isCurrentUser ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  _buildRankBadge(context, member.rank),
                  const SizedBox(width: 10),
                  // Avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFDCFCE7),
                    backgroundImage: member.avatarUrl != null &&
                            member.avatarUrl!.isNotEmpty
                        ? NetworkImage(member.avatarUrl!)
                        : null,
                    child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                        ? Text(
                            NameUtils.getInitials(member.fullName),
                            style: AppTextStyle.bold(
                              color: AppColors.emeraldForest,
                              fontSize: 12,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Member name & contribution percent
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCurrentUser
                              ? '${member.fullName} ${tr.youLabel}'
                              : member.fullName,
                          style: AppTextStyle.bold(
                            color: colors.textPrimary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr.contributionPercent(percentFormatted),
                          style: AppTextStyle.regular(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Amount
                  Text(
                    CurrencyUtils.formatVnd(member.contributedAmountVnd),
                    style: AppTextStyle.bold(
                      color: colors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
