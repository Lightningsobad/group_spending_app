import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../domain/entities/fund_entities.dart';
import '../../domain/repositories/funds_repository.dart';
import '../cubit/fund_detail_cubit.dart';
import '../cubit/fund_detail_state.dart';

enum FundAmountMode { perPerson, totalFund }

class FundFormScreen extends StatefulWidget {
  final int groupId;
  final GroupModel? group;
  final FundCollectionEntity? initialFund;
  final bool isEdit;

  const FundFormScreen({
    super.key,
    required this.groupId,
    this.group,
    this.initialFund,
    this.isEdit = false,
  });

  @override
  State<FundFormScreen> createState() => _FundFormScreenState();
}

class _FundFormScreenState extends State<FundFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  FundAmountMode _amountMode = FundAmountMode.perPerson;
  DateTime? _selectedDueDate;
  final Set<int> _selectedUserIds = {};
  final Set<int> _paidUserIds = {};
  List<GroupMemberModel> _members = [];
  bool _isLoadingMembers = false;
  String? _groupName;

  final List<num> _quickAmountPresets = [
    50000,
    100000,
    200000,
    500000,
    1000000,
    2500000,
  ];

  @override
  void initState() {
    super.initState();
    _groupName = widget.group?.name;
    if (widget.group?.members != null && widget.group!.members!.isNotEmpty) {
      _members = List.from(widget.group!.members!);
    }
    _initData();
    if (_members.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMembers();
      });
    }
  }

  void _initData() {
    final initialFund = widget.initialFund;
    if (widget.isEdit && initialFund != null) {
      _nameController.text = initialFund.name;
      _descController.text = initialFund.description ?? '';
      _amountController.text = initialFund.targetAmountPerPersonVnd.round().toString();

      if (initialFund.dueDate != null && initialFund.dueDate!.isNotEmpty) {
        try {
          _selectedDueDate = DateTime.parse(initialFund.dueDate!);
        } catch (_) {}
      }

      for (final m in initialFund.members) {
        _selectedUserIds.add(m.userId);
        if (m.isPaid) {
          _paidUserIds.add(m.userId);
        }
      }
      if (_members.isEmpty && initialFund.members.isNotEmpty) {
        _members = initialFund.members
            .map((m) => GroupMemberModel(
                  id: m.userId,
                  userId: m.userId,
                  fullName: m.fullName,
                  avatarUrl: m.avatarUrl,
                  role: 'MEMBER',
                ))
            .toList();
      }
    } else {
      _amountController.text = '200000';
      if (_members.isNotEmpty) {
        for (final m in _members) {
          _selectedUserIds.add(m.userId);
        }
      }
    }
  }

  Future<void> _loadMembers() async {
    if (!mounted) return;
    setState(() => _isLoadingMembers = true);
    List<GroupMemberModel> fetched = [];
    String? fetchedGroupName;
    try {
      final repo = context.read<GroupsRepository>();
      final summaries = await repo.getGroupMembers(widget.groupId);
      if (summaries.isNotEmpty) {
        fetched = summaries.map((s) => GroupMemberModel.fromSummary(s)).toList();
      }
    } catch (_) {}

    if (fetched.isEmpty || _groupName == null || _groupName!.isEmpty) {
      try {
        final detail = await context.read<GroupsCubit>().loadGroupDetails(widget.groupId);
        if (detail != null) {
          fetchedGroupName = detail.name;
          if (fetched.isEmpty && detail.members != null && detail.members!.isNotEmpty) {
            fetched = detail.members!;
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        if (fetchedGroupName != null && (_groupName == null || _groupName!.isEmpty)) {
          _groupName = fetchedGroupName;
        }
        if (fetched.isNotEmpty) {
          if (widget.isEdit && widget.initialFund != null) {
            final existingIds = fetched.map((m) => m.userId).toSet();
            for (final fm in widget.initialFund!.members) {
              if (!existingIds.contains(fm.userId)) {
                fetched.add(GroupMemberModel(
                  id: fm.userId,
                  userId: fm.userId,
                  fullName: fm.fullName,
                  avatarUrl: fm.avatarUrl,
                  role: 'MEMBER',
                ));
              }
            }
          }
          _members = fetched;

          if (!widget.isEdit && _selectedUserIds.isEmpty) {
            for (final m in _members) {
              _selectedUserIds.add(m.userId);
            }
          }
        }
        _isLoadingMembers = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  num get _enteredAmount {
    final clean = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return num.tryParse(clean) ?? 0;
  }

  num get _calculatedPerPersonVnd {
    if (_amountMode == FundAmountMode.perPerson) {
      return _enteredAmount;
    } else {
      final count = _selectedUserIds.length;
      if (count <= 0) return 0;
      return (_enteredAmount / count).round();
    }
  }

  num get _calculatedTotalTargetVnd {
    if (_amountMode == FundAmountMode.totalFund) {
      return _enteredAmount;
    } else {
      return _enteredAmount * _selectedUserIds.length;
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _toggleSelectAll() {
    final members = _members;
    setState(() {
      if (_selectedUserIds.length == members.length) {
        // Deselect all except PAID members
        _selectedUserIds.clear();
        _selectedUserIds.addAll(_paidUserIds);
      } else {
        // Select all
        for (final m in members) {
          _selectedUserIds.add(m.userId);
        }
      }
    });
  }

  Future<void> _submit(BuildContext cubitContext) async {
    final tr = context.l10n;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr.fundNameLabel),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final perPersonVnd = _calculatedPerPersonVnd;
    if (perPersonVnd < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr.minFundAmountError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr.mustSelectAtLeastOneMember),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final dueDateStr = _selectedDueDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDueDate!)
        : null;

    final cubit = cubitContext.read<FundDetailCubit>();
    bool success = false;

    if (widget.isEdit && widget.initialFund != null) {
      success = await cubit.updateFund(
        widget.initialFund!.id,
        name: name,
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        targetAmountPerPersonVnd: perPersonVnd,
        dueDate: dueDateStr,
        memberUserIds: _selectedUserIds.toList(),
      );
    } else {
      success = await cubit.createFund(
        widget.groupId,
        name: name,
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        targetAmountPerPersonVnd: perPersonVnd,
        dueDate: dueDateStr,
        memberUserIds: _selectedUserIds.toList(),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FundDetailCubit>(
      create: (ctx) => FundDetailCubit(
        ctx.read<FundsRepository>(),
      ),
      child: Builder(
        builder: (innerContext) {
          final colors = innerContext.colors;
          final tr = innerContext.l10n;
          final currentUserId = innerContext.watch<AuthCubit>().state.currentUser?.id;
          final groupName = _groupName ?? widget.group?.name ?? '';
          final members = _members;

          return BlocConsumer<FundDetailCubit, FundDetailState>(
            listenWhen: (prev, curr) =>
                prev.errorMessage != curr.errorMessage ||
                prev.successMessage != curr.successMessage,
            listener: (ctx, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.error,
                  ),
                );
                ctx.read<FundDetailCubit>().clearMessages();
              }
              if (state.successMessage != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: AppColors.emerald,
                  ),
                );
                ctx.read<FundDetailCubit>().clearMessages();
              }
            },
            builder: (ctx, state) {
              final isSubmitting = state.isSubmitting;

              return Scaffold(
                backgroundColor: colors.background,
                body: SafeArea(
                  child: Column(
                    children: [
                      // Header (Back button, Title, Subtitle, Submit Pill)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.arrowLeft,
                                  size: 18,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.isEdit
                                        ? tr.editFundTitle
                                        : tr.createFundTitle,
                                    style: AppTextStyle.bold(
                                      fontSize: 18,
                                      color: colors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (groupName.isNotEmpty)
                                    Text(
                                      groupName,
                                      style: AppTextStyle.bold(
                                        fontSize: 11,
                                        color: const Color(0xFF047857),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: isSubmitting ? null : () => _submit(ctx),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF14532D),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: isSubmitting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(LucideIcons.check, size: 15, color: Colors.white),
                              label: Text(
                                widget.isEdit ? tr.confirm : tr.createGroupAction,
                                style: AppTextStyle.bold(fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form Body
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. TÊN ĐỢT THU QUỸ
                              _buildCard(
                                colors: colors,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr.fundNameLabel,
                                      style: AppTextStyle.bold(
                                        fontSize: 11,
                                        color: colors.textMuted,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _nameController,
                                      style: AppTextStyle.bold(
                                        fontSize: 14,
                                        color: colors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: tr.fundNameHint,
                                        hintStyle: AppTextStyle.regular(
                                          fontSize: 13,
                                          color: colors.textMuted,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colors.cardBorder),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colors.cardBorder),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          tr.quickSuggestionsLabel,
                                          style: AppTextStyle.regular(
                                            fontSize: 11,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        _buildSuggestionChip(
                                          tr.suggestionRoomAndService,
                                          colors,
                                        ),
                                        _buildSuggestionChip(
                                          tr.suggestionYearEndParty,
                                          colors,
                                        ),
                                        _buildSuggestionChip(
                                          tr.suggestionBirthday,
                                          colors,
                                        ),
                                        _buildSuggestionChip(
                                          tr.suggestionInternetAndWater,
                                          colors,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 2. SỐ TIỀN THU QUỸ
                              _buildCard(
                                colors: colors,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          tr.fundAmountLabel,
                                          style: AppTextStyle.bold(
                                            fontSize: 11,
                                            color: colors.textMuted,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        // Mode toggle
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: colors.surfaceMuted,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildTogglePill(
                                                title: tr.perPersonMode,
                                                isSelected:
                                                    _amountMode == FundAmountMode.perPerson,
                                                onTap: () => setState(
                                                  () => _amountMode = FundAmountMode.perPerson,
                                                ),
                                                colors: colors,
                                              ),
                                              _buildTogglePill(
                                                title: tr.totalFundMode,
                                                isSelected:
                                                    _amountMode == FundAmountMode.totalFund,
                                                onTap: () => setState(
                                                  () => _amountMode = FundAmountMode.totalFund,
                                                ),
                                                colors: colors,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Big amount input
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceMuted.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: colors.cardBorder),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'đ',
                                            style: AppTextStyle.bold(
                                              fontSize: 22,
                                              color: colors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              controller: _amountController,
                                              keyboardType: TextInputType.number,
                                              style: AppTextStyle.bold(
                                                fontSize: 24,
                                                color: colors.textPrimary,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Quick amount chips
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: _quickAmountPresets.map((amt) {
                                        final isSelected = _enteredAmount == amt;
                                        return InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () {
                                            setState(() {
                                              _amountController.text = amt.round().toString();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFFF0FDF4)
                                                  : colors.surfaceMuted,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF10B981)
                                                    : colors.cardBorder,
                                              ),
                                            ),
                                            child: Text(
                                              CurrencyUtils.formatVnd(amt),
                                              style: AppTextStyle.bold(
                                                fontSize: 11,
                                                color: isSelected
                                                    ? const Color(0xFF047857)
                                                    : colors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 12),

                                    // Summary Box
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceMuted.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tr.expectedTotalSummary(_selectedUserIds.length),
                                                style: AppTextStyle.regular(
                                                  fontSize: 11,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                CurrencyUtils.formatVnd(_calculatedTotalTargetVnd),
                                                style: AppTextStyle.bold(
                                                  fontSize: 15,
                                                  color: const Color(0xFF047857),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                tr.targetTotalSummary,
                                                style: AppTextStyle.regular(
                                                  fontSize: 11,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                CurrencyUtils.formatVnd(_calculatedTotalTargetVnd),
                                                style: AppTextStyle.bold(
                                                  fontSize: 15,
                                                  color: colors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 3. HẠN NỘP (HẠN CHÓT)
                              _buildCard(
                                colors: colors,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(LucideIcons.calendar, size: 14, color: colors.textMuted),
                                        const SizedBox(width: 6),
                                        Text(
                                          tr.dueDateLabel,
                                          style: AppTextStyle.bold(
                                            fontSize: 11,
                                            color: colors.textMuted,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _pickDueDate,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.cardBackground,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: colors.cardBorder),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _selectedDueDate != null
                                                  ? DateFormat('dd/MM/yyyy').format(_selectedDueDate!)
                                                  : 'Chọn hạn chót nộp tiền',
                                              style: AppTextStyle.medium(
                                                fontSize: 13,
                                                color: _selectedDueDate != null
                                                    ? colors.textPrimary
                                                    : colors.textMuted,
                                              ),
                                            ),
                                            Icon(
                                              LucideIcons.calendar,
                                              size: 16,
                                              color: colors.textSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 4. GHI CHÚ / MỤC ĐÍCH THU QUỸ
                              _buildCard(
                                colors: colors,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(LucideIcons.fileText, size: 14, color: colors.textMuted),
                                        const SizedBox(width: 6),
                                        Text(
                                          tr.fundDescriptionLabel,
                                          style: AppTextStyle.bold(
                                            fontSize: 11,
                                            color: colors.textMuted,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _descController,
                                      maxLines: 3,
                                      style: AppTextStyle.regular(
                                        fontSize: 13,
                                        color: colors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: tr.fundDescriptionHint,
                                        hintStyle: AppTextStyle.regular(
                                          fontSize: 12,
                                          color: colors.textMuted,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colors.cardBorder),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colors.cardBorder),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 5. THÀNH VIÊN THAM GIA
                              _buildCard(
                                colors: colors,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(LucideIcons.users, size: 14, color: colors.textMuted),
                                            const SizedBox(width: 6),
                                            Text(
                                              tr.participatingMembersLabel(
                                                _selectedUserIds.length,
                                                members.length,
                                              ),
                                              style: AppTextStyle.bold(
                                                fontSize: 11,
                                                color: colors.textMuted,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: _toggleSelectAll,
                                          child: Text(
                                            _selectedUserIds.length == members.length
                                                ? tr.deselectAll
                                                : tr.selectAll,
                                            style: AppTextStyle.bold(
                                              fontSize: 12,
                                              color: const Color(0xFF047857),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    if (_isLoadingMembers && members.isEmpty)
                                      const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 24.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (members.isEmpty)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                                          child: Column(
                                            children: [
                                              Icon(LucideIcons.users, size: 36, color: colors.textMuted),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Không có thành viên nào trong nhóm',
                                                style: AppTextStyle.medium(fontSize: 13, color: colors.textSecondary),
                                              ),
                                              const SizedBox(height: 8),
                                              TextButton.icon(
                                                onPressed: _loadMembers,
                                                icon: const Icon(LucideIcons.refreshCw, size: 14),
                                                label: const Text('Thử lại'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      // Member list
                                      ...members.map((member) {
                                      final isSelected = _selectedUserIds.contains(member.userId);
                                      final isPaid = _paidUserIds.contains(member.userId);
                                      final isMe = currentUserId != null && currentUserId == member.userId;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: colors.cardBorder.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 17,
                                              backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
                                              backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                                                  ? NetworkImage(member.avatarUrl!)
                                                  : null,
                                              child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                                                  ? Text(
                                                      member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                                                      style: AppTextStyle.bold(fontSize: 13, color: AppColors.emeraldForest),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${member.fullName}${isMe ? ' (Bạn)' : ''}',
                                                    style: AppTextStyle.bold(
                                                      fontSize: 13,
                                                      color: colors.textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    CurrencyUtils.formatVnd(_calculatedPerPersonVnd),
                                                    style: AppTextStyle.regular(
                                                      fontSize: 11,
                                                      color: colors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Checkbox(
                                              value: isSelected,
                                              activeColor: const Color(0xFF2563EB),
                                              onChanged: isPaid
                                                  ? null // Cannot uncheck members who already paid
                                                  : (val) {
                                                      setState(() {
                                                        if (val == true) {
                                                          _selectedUserIds.add(member.userId);
                                                        } else {
                                                          _selectedUserIds.remove(member.userId);
                                                        }
                                                      });
                                                    },
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bottom Buttons: "Hủy bỏ" & "Tạo đợt thu quỹ / Lưu thay đổi"
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 13),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        side: BorderSide(color: colors.cardBorder),
                                      ),
                                      child: Text(
                                        tr.cancel,
                                        style: AppTextStyle.bold(
                                          fontSize: 13,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: isSubmitting ? null : () => _submit(ctx),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF14532D),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 13),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      icon: isSubmitting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(LucideIcons.check, size: 16, color: Colors.white),
                                      label: Text(
                                        widget.isEdit
                                            ? tr.saveFundButton
                                            : tr.createFundButton,
                                        style: AppTextStyle.bold(
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required dynamic colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSuggestionChip(String text, dynamic colors) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        final cleanText = text.replaceFirst('+', '').trim();
        setState(() {
          _nameController.text = cleanText;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Text(
          text,
          style: AppTextStyle.medium(
            fontSize: 11,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTogglePill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required dynamic colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? colors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: AppTextStyle.bold(
            fontSize: 11,
            color: isSelected ? const Color(0xFF047857) : colors.textMuted,
          ),
        ),
      ),
    );
  }
}
