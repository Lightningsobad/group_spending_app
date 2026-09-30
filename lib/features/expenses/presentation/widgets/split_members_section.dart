import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../groups/data/models/group_model.dart';
import '../../data/models/expense_enums.dart';

class SplitMembersSection extends StatelessWidget {
  final List<GroupMemberModel> members;
  final Set<int> selectedParticipantUserIds;
  final SplitOption splitOption;
  final int paidByUserId;
  final num totalAmountVnd;
  final ValueChanged<SplitOption> onSplitOptionChanged;
  final ValueChanged<int> onToggleParticipant;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final num Function(int memberUserId) getMemberShareVnd;

  const SplitMembersSection({
    super.key,
    required this.members,
    required this.selectedParticipantUserIds,
    required this.splitOption,
    required this.paidByUserId,
    required this.totalAmountVnd,
    required this.onSplitOptionChanged,
    required this.onToggleParticipant,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.getMemberShareVnd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSplitAll = splitOption == SplitOption.equalAll;
    final activeCount = isSplitAll
        ? members.length
        : members.where((m) => selectedParticipantUserIds.contains(m.userId)).length;
    final perPersonVnd = activeCount > 0 ? (totalAmountVnd / activeCount).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Equal all checkbox banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isSplitAll,
                activeColor: const Color(0xFF14532D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onChanged: (val) {
                  if (val == true) {
                    onSelectAll();
                  } else {
                    onSplitOptionChanged(SplitOption.equalSelected);
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chia đều cho tất cả thành viên (${members.length} thành viên)',
                      style: AppTextStyle.bold(fontSize: 14, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isSplitAll
                          ? 'Mọi người trong nhóm sẽ chia đều số tiền'
                          : 'Đang tùy chỉnh chọn thành viên chia chi phí',
                      style: AppTextStyle.regular(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Select members header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn người cùng chia tiền:',
                    style: AppTextStyle.bold(fontSize: 14, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đã chọn $activeCount/${members.length} người • ${CurrencyUtils.formatVnd(perPersonVnd)} / người',
                    style: AppTextStyle.regular(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            // Quick action buttons
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onSelectAll,
              child: const Text('Tất cả', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onDeselectAll,
              child: const Text('Bỏ chọn', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Member List Cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final member = members[index];
            final isSelected = isSplitAll || selectedParticipantUserIds.contains(member.userId);
            final isPayer = member.userId == paidByUserId;
            final shareAmount = isSelected ? getMemberShareVnd(member.userId) : 0;

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onToggleParticipant(member.userId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0FDF4) : colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : colors.cardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      onChanged: (_) => onToggleParticipant(member.userId),
                    ),
                    const SizedBox(width: 8),
                    // Avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colors.surfaceMuted,
                      backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                          ? NetworkImage(member.avatarUrl!)
                          : null,
                      child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                          ? Text(
                              member.fullName.isNotEmpty
                                  ? member.fullName.substring(0, 1).toUpperCase()
                                  : '?',
                              style: AppTextStyle.bold(fontSize: 14, color: colors.textPrimary),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    // Member Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  member.fullName,
                                  style: AppTextStyle.bold(fontSize: 13, color: colors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isPayer) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Người trả',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (member.email != null && member.email!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              member.email!,
                              style: AppTextStyle.regular(fontSize: 11, color: colors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Share Amount
                    Text(
                      CurrencyUtils.formatVnd(shareAmount),
                      style: AppTextStyle.bold(
                        fontSize: 13,
                        color: isSelected ? const Color(0xFF14532D) : colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
