import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../data/models/group_member_models.dart';
import '../../data/models/group_model.dart';
import '../cubit/group_members_cubit.dart';
import '../cubit/group_members_state.dart';
import 'review_join_request_sheet.dart';

class GroupMembersTabView extends StatefulWidget {
  final GroupModel group;
  final bool isAdmin;
  final bool isOwner;
  final int? currentUserId;
  final VoidCallback onInviteMore;
  final ValueChanged<int> onSelectMember;
  final VoidCallback onDeleteGroup;
  final VoidCallback onLeaveGroup;

  const GroupMembersTabView({
    super.key,
    required this.group,
    required this.isAdmin,
    required this.isOwner,
    this.currentUserId,
    required this.onInviteMore,
    required this.onSelectMember,
    required this.onDeleteGroup,
    required this.onLeaveGroup,
  });

  @override
  State<GroupMembersTabView> createState() => _GroupMembersTabViewState();
}

class _GroupMembersTabViewState extends State<GroupMembersTabView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupMembersCubit>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    return BlocBuilder<GroupMembersCubit, GroupMembersState>(
      builder: (context, state) {
        final members = state.members;
        final pendingRequests = state.pendingRequests;
        final showPendingSection = widget.isAdmin &&
            !widget.group.isArchived &&
            pendingRequests.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header: DANH SÁCH THÀNH VIÊN & + Mời thêm (Image 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.users,
                      size: 20,
                      color: Color(0xFF14532D),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr.memberListSectionHeader,
                      style: AppTextStyle.bold(
                        fontSize: 14,
                        color: colors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0FDF4),
                    side: const BorderSide(color: Color(0xFF86EFAC)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: widget.onInviteMore,
                  icon: const Icon(LucideIcons.share2,
                      size: 14, color: Color(0xFF14532D)),
                  label: Text(
                    '+ ${tr.inviteMoreAction}',
                    style: AppTextStyle.bold(
                      fontSize: 12,
                      color: const Color(0xFF14532D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Search Text Field with Debounce (Image 1)
            Container(
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyle.regular(
                  fontSize: 13,
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: tr.searchMemberPlaceholder,
                  hintStyle: AppTextStyle.regular(
                    fontSize: 13,
                    color: colors.textMuted,
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(LucideIcons.x,
                              size: 16, color: colors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            context.read<GroupMembersCubit>().clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {});
                  context.read<GroupMembersCubit>().onSearchChanged(val);
                },
              ),
            ),
            const SizedBox(height: 16),

            // 3. THÀNH VIÊN CHỜ DUYỆT (Chỉ Admin khi có yêu cầu) (Image 1)
            if (showPendingSection) ...[
              _buildPendingRequestsSection(context, pendingRequests),
              const SizedBox(height: 16),
            ],

            // 4. Header danh sách thành viên: "Chạm vào thành viên..." & Số lượng (Image 1 & 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tr.touchMemberForFinancialHint,
                    style: AppTextStyle.regular(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  tr.groupMembersCountTitle(
                    members.isNotEmpty
                        ? members.length
                        : (widget.group.members?.length ?? widget.group.memberCount),
                  ),
                  style: AppTextStyle.bold(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 5. Danh sách thành viên (Image 2)
            if (state.isLoading && members.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.emerald),
                ),
              )
            else if (members.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Text(
                  tr.noMatchingGroupsTitle,
                  style: AppTextStyle.regular(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...members.map((member) => _buildMemberTile(context, member)),

            const SizedBox(height: 20),

            // 6. Thẻ hành động nguy hiểm: XÓA NHÓM (Admin) / RỜI KHỎI NHÓM (Member) (Image 2)
            if (widget.isAdmin || widget.isOwner)
              _buildDeleteGroupCard(context)
            else
              _buildLeaveGroupCard(context),
          ],
        );
      },
    );
  }

  Widget _buildPendingRequestsSection(
    BuildContext context,
    List<GroupJoinRequestModel> requests,
  ) {
    final colors = context.colors;
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.userCheck,
                    size: 16, color: Color(0xFFB45309)),
              ),
              const SizedBox(width: 8),
              Text(
                tr.pendingMembersSectionTitle,
                style: AppTextStyle.bold(
                  fontSize: 13,
                  color: const Color(0xFF92400E),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Text(
                  tr.pendingRequestsCountBadge(requests.length),
                  style: AppTextStyle.bold(
                    fontSize: 10,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tr.pendingRequestsSubtitle,
            style: AppTextStyle.regular(
              fontSize: 11,
              color: const Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 12),

          // Cards
          ...requests.map((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppColors.emerald.withValues(alpha: 0.15),
                        backgroundImage: req.userAvatarUrl != null &&
                                req.userAvatarUrl!.isNotEmpty
                            ? NetworkImage(req.userAvatarUrl!)
                            : null,
                        child: req.userAvatarUrl == null
                            ? Text(
                                req.userFullName.isNotEmpty
                                    ? req.userFullName[0].toUpperCase()
                                    : '?',
                                style: AppTextStyle.bold(
                                  fontSize: 14,
                                  color: AppColors.emeraldForest,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.userFullName,
                              style: AppTextStyle.bold(
                                fontSize: 14,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tr.joinRequestLabel,
                              style: AppTextStyle.regular(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: colors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<GroupMembersCubit>()
                                .reviewJoinRequest(
                                  requestId: req.id,
                                  approved: false,
                                );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.x,
                                  size: 14, color: colors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                tr.rejectAction,
                                style: AppTextStyle.bold(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14532D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            ReviewJoinRequestSheet.show(
                              context,
                              request: req,
                              onConfirm: (includePast) async {
                                await context
                                    .read<GroupMembersCubit>()
                                    .reviewJoinRequest(
                                      requestId: req.id,
                                      approved: true,
                                      includePastFundCollections: includePast,
                                    );
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.check,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                tr.approveAction,
                                style: AppTextStyle.bold(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    GroupMemberSummaryModel member,
  ) {
    final colors = context.colors;
    final tr = context.l10n;
    final isSelf =
        widget.currentUserId != null && widget.currentUserId == member.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onSelectMember(member.userId),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar with online green dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
                    backgroundImage: member.avatarUrl != null &&
                            member.avatarUrl!.isNotEmpty
                        ? NetworkImage(member.avatarUrl!)
                        : null,
                    child: member.avatarUrl == null
                        ? Text(
                            member.fullName.isNotEmpty
                                ? member.fullName[0].toUpperCase()
                                : '?',
                            style: AppTextStyle.bold(
                              fontSize: 15,
                              color: AppColors.emeraldForest,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Name & "Bạn" tag
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.fullName,
                        style: AppTextStyle.bold(
                          fontSize: 14,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tr.youPill,
                          style: AppTextStyle.bold(
                            fontSize: 10,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: member.isAdmin
                      ? const Color(0xFFFEF3C7)
                      : colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (member.isAdmin) ...[
                      const Icon(LucideIcons.shieldCheck,
                          size: 12, color: Color(0xFFB45309)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      member.isAdmin ? tr.roleLeaderBadge : tr.roleMemberBadge,
                      style: AppTextStyle.bold(
                        fontSize: 10,
                        color: member.isAdmin
                            ? const Color(0xFFB45309)
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Chevron right
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteGroupCard(BuildContext context) {
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.trash2,
                    size: 18, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.deleteGroupSectionTitle,
                      style: AppTextStyle.bold(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr.deleteGroupSectionSubtitle,
                      style: AppTextStyle.regular(
                        fontSize: 11,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: widget.onDeleteGroup,
            icon: const Icon(LucideIcons.trash2, size: 16),
            label: Text(
              tr.deleteGroupAction,
              style: AppTextStyle.bold(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveGroupCard(BuildContext context) {
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.logOut,
                    size: 18, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.leaveGroupSectionTitle,
                      style: AppTextStyle.bold(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr.leaveGroupSectionSubtitle,
                      style: AppTextStyle.regular(
                        fontSize: 11,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: widget.onLeaveGroup,
            icon: const Icon(LucideIcons.logOut, size: 16),
            label: Text(
              tr.leaveGroupButton,
              style: AppTextStyle.bold(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
