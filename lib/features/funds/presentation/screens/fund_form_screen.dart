import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
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
  final int? fundId;
  final GroupModel? group;
  final FundCollectionEntity? initialFund;
  final bool isEdit;
  final VoidCallback? onBack;
  final VoidCallback? onSuccess;

  const FundFormScreen({
    super.key,
    required this.groupId,
    this.fundId,
    this.group,
    this.initialFund,
    this.isEdit = false,
    this.onBack,
    this.onSuccess,
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
  String? _membersError;
  String? _groupName;

  bool _isLoadingFund = false;
  String? _fundLoadError;
  FundCollectionEntity? _loadedFund;
  bool _isGroupMismatch = false;

  FundCollectionEntity? get _effectiveFund => widget.initialFund ?? _loadedFund;

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

    if (widget.initialFund != null) {
      _populateFundData(widget.initialFund!);
    } else if (widget.isEdit && (widget.fundId != null || widget.groupId > 0)) {
      _isLoadingFund = true;
    } else {
      _amountController.text = '200000';
      if (_members.isNotEmpty) {
        for (final m in _members) {
          _selectedUserIds.add(m.userId);
        }
      }
    }

    _isLoadingMembers = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEdit && widget.initialFund == null && widget.fundId != null) {
        _loadFundDetails(widget.fundId!);
      }
      _loadMembers();
    });
  }

  Future<void> _loadFundDetails(int fundId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingFund = true;
      _fundLoadError = null;
      _isGroupMismatch = false;
    });

    try {
      final repo = context.read<FundsRepository>();
      final fund = await repo.getFundCollectionDetails(fundId);
      if (!mounted) return;

      if (fund.groupId != widget.groupId) {
        setState(() {
          _isLoadingFund = false;
          _isGroupMismatch = true;
          _fundLoadError = 'Đợt thu quỹ không thuộc nhóm này';
        });
        return;
      }

      setState(() {
        _loadedFund = fund;
        _isLoadingFund = false;
        _populateFundData(fund);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFund = false;
        _fundLoadError = e is AppException ? e.message : 'Không thể tải thông tin đợt quỹ';
      });
    }
  }

  void _populateFundData(FundCollectionEntity fund) {
    if (_nameController.text.isEmpty) {
      _nameController.text = fund.name;
    }
    if (_descController.text.isEmpty && fund.description != null) {
      _descController.text = fund.description!;
    }
    _amountController.text = fund.targetAmountPerPersonVnd.round().toString();

    if (fund.dueDate != null && fund.dueDate!.isNotEmpty) {
      try {
        _selectedDueDate = DateTime.parse(fund.dueDate!);
      } catch (_) {}
    }

    _selectedUserIds.clear();
    _paidUserIds.clear();
    for (final m in fund.members) {
      _selectedUserIds.add(m.userId);
      if (m.isPaid) {
        _paidUserIds.add(m.userId);
      }
    }
    _mergeMembers(fund.members);
  }

  void _mergeMembers(List<FundMemberEntity> fundMembers) {
    final existingIds = _members.map((m) => m.userId).toSet();
    for (final fm in fundMembers) {
      if (!existingIds.contains(fm.userId)) {
        _members.add(GroupMemberModel(
          id: fm.userId,
          userId: fm.userId,
          fullName: fm.fullName,
          avatarUrl: fm.avatarUrl,
          role: 'MEMBER',
        ));
        existingIds.add(fm.userId);
      }
    }
  }

  Future<void> _loadMembers() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMembers = true;
      _membersError = null;
    });
    List<GroupMemberModel> fetched = [];
    String? fetchedGroupName;
    try {
      final repo = context.read<GroupsRepository>();
      final summaries = await repo.getGroupMembers(widget.groupId);
      if (summaries.isNotEmpty) {
        fetched = summaries.map((s) => GroupMemberModel.fromSummary(s)).toList();
      }
    } catch (_) {}

    if (mounted && (fetched.isEmpty || _groupName == null || _groupName!.isEmpty)) {
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
          _members = fetched;
          final fund = _effectiveFund;
          if (fund != null) {
            _mergeMembers(fund.members);
          } else if (!widget.isEdit && _selectedUserIds.isEmpty) {
            for (final m in _members) {
              _selectedUserIds.add(m.userId);
            }
          }
        } else if (_members.isEmpty) {
          _membersError = 'Không thể tải danh sách thành viên nhóm';
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
      final totalK = (_enteredAmount + 999) ~/ 1000;
      final perPersonK = ((totalK + count - 1) ~/ count).clamp(1, 1000000000);
      return perPersonK * 1000;
    }
  }

  num get _calculatedTotalTargetVnd {
    return _calculatedPerPersonVnd * _selectedUserIds.length;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _selectedDueDate != null
        ? DateTime(_selectedDueDate!.year, _selectedDueDate!.month, _selectedDueDate!.day)
        : today.add(const Duration(days: 7));

    final defaultFirstDate = today.subtract(const Duration(days: 30));
    final defaultLastDate = today.add(const Duration(days: 365 * 2));

    final firstDate = initial.isBefore(defaultFirstDate)
        ? initial.subtract(const Duration(days: 365))
        : defaultFirstDate;
    final lastDate = initial.isAfter(defaultLastDate)
        ? initial.add(const Duration(days: 365))
        : defaultLastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
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
      AppSnackBar.show(
        context,
        message: tr.fundNameLabel,
        type: AppSnackBarType.error,
      );
      return;
    }

    if (_amountMode == FundAmountMode.perPerson) {
      final enteredInt = _enteredAmount.toInt();
      if (enteredInt < 1000) {
        AppSnackBar.show(
          context,
          message: tr.minFundAmountError,
          type: AppSnackBarType.error,
        );
        return;
      }
      if (enteredInt % 1000 != 0) {
        AppSnackBar.show(
          context,
          message: 'Số tiền mỗi người phải là bội số của 1.000 đ',
          type: AppSnackBarType.error,
        );
        return;
      }
    } else {
      if (_enteredAmount < 1000) {
        AppSnackBar.show(
          context,
          message: 'Tổng số tiền tối thiểu là 1.000 đ',
          type: AppSnackBarType.error,
        );
        return;
      }
    }

    if (_selectedUserIds.isEmpty) {
      AppSnackBar.show(
        context,
        message: tr.mustSelectAtLeastOneMember,
        type: AppSnackBarType.error,
      );
      return;
    }

    if (_isGroupMismatch) {
      AppSnackBar.show(
        context,
        message: 'Đợt thu quỹ không thuộc nhóm này',
        type: AppSnackBarType.error,
      );
      return;
    }

    if (widget.isEdit && _isLoadingFund) {
      AppSnackBar.show(
        context,
        message: 'Đang tải thông tin quỹ, vui lòng đợi',
        type: AppSnackBarType.error,
      );
      return;
    }

    final dueDateStr = _selectedDueDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDueDate!)
        : null;

    final cubit = cubitContext.read<FundDetailCubit>();
    bool success = false;

    if (widget.isEdit) {
      final effectiveFundId = widget.initialFund?.id ?? widget.fundId ?? _loadedFund?.id;
      if (effectiveFundId == null || effectiveFundId <= 0) {
        AppSnackBar.show(
          context,
          message: 'Không tìm thấy thông tin đợt quỹ để cập nhật',
          type: AppSnackBarType.error,
        );
        return;
      }
      success = await cubit.updateFund(
        effectiveFundId,
        name: name,
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        targetAmountPerPersonVnd: _calculatedPerPersonVnd,
        dueDate: dueDateStr,
        memberUserIds: _selectedUserIds.toList(),
      );
    } else {
      success = await cubit.createFund(
        widget.groupId,
        name: name,
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        targetAmountPerPersonVnd: _calculatedPerPersonVnd,
        dueDate: dueDateStr,
        memberUserIds: _selectedUserIds.toList(),
      );
    }

    if (success && mounted) {
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FundDetailCubit>(
      create: (ctx) {
        DataSyncCoordinator? syncCoordinator;
        try {
          syncCoordinator = ctx.read<DataSyncCoordinator>();
        } catch (_) {}
        return FundDetailCubit(
          ctx.read<FundsRepository>(),
          dataSyncCoordinator: syncCoordinator,
        );
      },
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
                AppSnackBar.show(
                  ctx,
                  message: state.errorMessage!,
                  type: AppSnackBarType.error,
                );
                ctx.read<FundDetailCubit>().clearMessages();
              }
              if (state.successMessage != null) {
                AppSnackBar.show(
                  ctx,
                  message: state.successMessage!,
                  type: AppSnackBarType.success,
                );
                ctx.read<FundDetailCubit>().clearMessages();
              }
            },
            builder: (ctx, state) {
              final isSubmitting = state.isSubmitting;
              final clampedScaler = MediaQuery.textScalerOf(innerContext).clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.25,
              );

              return PopScope(
                canPop: widget.onBack == null,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    _handleBack();
                  }
                },
                child: MediaQuery(
                  data: MediaQuery.of(innerContext).copyWith(textScaler: clampedScaler),
                  child: Scaffold(
                    backgroundColor: colors.background,
                    body: SafeArea(
                      top: true,
                      bottom: true,
                      child: Column(
                        children: [
                          // Header (Back button, Title, Subtitle)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _handleBack,
                                      child: Center(
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: colors.surfaceMuted,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: colors.cardBorder),
                                          ),
                                          child: Icon(
                                            LucideIcons.arrowLeft,
                                            size: 18,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isEdit
                                            ? tr.editFundTitle
                                            : tr.createFundTitle,
                                        style: AppTextStyle.bold(
                                          fontSize: AppFontSize.h4,
                                          color: colors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (groupName.isNotEmpty)
                                        Text(
                                          groupName,
                                          style: AppTextStyle.bold(
                                            fontSize: AppFontSize.caption,
                                            color: colors.brandEmerald,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_isLoadingFund)
                          Expanded(child: _buildFundLoadingState(colors))
                        else if (_fundLoadError != null)
                          Expanded(child: _buildFundErrorState(colors))
                        else
                          // Form Body
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
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
                                          fontSize: AppFontSize.caption,
                                          color: colors.textMuted,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _nameController,
                                        style: AppTextStyle.bold(
                                          fontSize: AppFontSize.secondary,
                                          color: colors.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: tr.fundNameHint,
                                          hintStyle: AppTextStyle.regular(
                                            fontSize: AppFontSize.secondary,
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
                                            style: AppTextStyle.medium(
                                              fontSize: AppFontSize.caption,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
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
                                          Expanded(
                                            child: Text(
                                              tr.fundAmountLabel,
                                              style: AppTextStyle.bold(
                                                fontSize: AppFontSize.caption,
                                                color: colors.textMuted,
                                                letterSpacing: 0.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Mode toggle
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: colors.surfaceMuted,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
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
                                                fontSize: AppFontSize.h2,
                                                color: colors.textMuted,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                controller: _amountController,
                                                keyboardType: TextInputType.number,
                                                style: AppTextStyle.bold(
                                                  fontSize: AppFontSize.h2,
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
                                      const SizedBox(height: 12),

                                      // Quick amount chips
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _quickAmountPresets.map((amt) {
                                          final isSelected = _enteredAmount == amt;
                                          return Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(10),
                                              onTap: () {
                                                setState(() {
                                                  _amountController.text = amt.round().toString();
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? colors.secondaryActionBg
                                                      : colors.surfaceMuted,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? colors.secondaryActionBorder
                                                        : colors.cardBorder,
                                                  ),
                                                ),
                                                child: Text(
                                                  CurrencyUtils.formatVnd(amt),
                                                  style: AppTextStyle.bold(
                                                    fontSize: AppFontSize.caption,
                                                    color: isSelected
                                                        ? colors.secondaryActionText
                                                        : colors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 14),

                                      // Summary Box
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.surfaceMuted.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: colors.cardBorder.withValues(alpha: 0.5)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        tr.expectedTotalSummary(_selectedUserIds.length),
                                                        style: AppTextStyle.regular(
                                                          fontSize: AppFontSize.caption,
                                                          color: colors.textSecondary,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        CurrencyUtils.formatVnd(_calculatedTotalTargetVnd),
                                                        style: AppTextStyle.bold(
                                                          fontSize: AppFontSize.body,
                                                          color: colors.fundAmountText,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        _amountMode == FundAmountMode.totalFund
                                                            ? tr.targetTotalSummary
                                                            : tr.perPersonMode,
                                                        style: AppTextStyle.regular(
                                                          fontSize: AppFontSize.caption,
                                                          color: colors.textSecondary,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        CurrencyUtils.formatVnd(
                                                          _amountMode == FundAmountMode.totalFund
                                                              ? _enteredAmount
                                                              : _calculatedPerPersonVnd,
                                                        ),
                                                        style: AppTextStyle.bold(
                                                          fontSize: AppFontSize.body,
                                                          color: colors.textPrimary,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (_amountMode == FundAmountMode.totalFund && _selectedUserIds.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: colors.brandEmeraldMuted.withValues(alpha: 0.3),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(LucideIcons.info, size: 13, color: colors.brandEmerald),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        'Mức mỗi người: ${CurrencyUtils.formatVnd(_calculatedPerPersonVnd)}/người (làm tròn lên theo nghìn đồng)',
                                                        style: AppTextStyle.medium(
                                                          fontSize: AppFontSize.caption,
                                                          color: colors.brandEmerald,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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
                                          Expanded(
                                            child: Text(
                                              tr.dueDateLabel,
                                              style: AppTextStyle.bold(
                                                fontSize: AppFontSize.caption,
                                                color: colors.textMuted,
                                                letterSpacing: 0.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                            vertical: 13,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.cardBackground,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: colors.cardBorder),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _selectedDueDate != null
                                                      ? DateFormat('dd/MM/yyyy').format(_selectedDueDate!)
                                                      : 'Chọn hạn chót nộp tiền',
                                                  style: AppTextStyle.medium(
                                                    fontSize: AppFontSize.secondary,
                                                    color: _selectedDueDate != null
                                                        ? colors.textPrimary
                                                        : colors.textMuted,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
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
                                          Expanded(
                                            child: Text(
                                              tr.fundDescriptionLabel,
                                              style: AppTextStyle.bold(
                                                fontSize: AppFontSize.caption,
                                                color: colors.textMuted,
                                                letterSpacing: 0.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _descController,
                                        maxLines: 3,
                                        style: AppTextStyle.regular(
                                          fontSize: AppFontSize.secondary,
                                          color: colors.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: tr.fundDescriptionHint,
                                          hintStyle: AppTextStyle.regular(
                                            fontSize: AppFontSize.caption,
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
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(LucideIcons.users, size: 14, color: colors.textMuted),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    tr.participatingMembersLabel(
                                                      _selectedUserIds.length,
                                                      members.length,
                                                    ),
                                                    style: AppTextStyle.bold(
                                                      fontSize: AppFontSize.caption,
                                                      color: colors.textMuted,
                                                      letterSpacing: 0.5,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: _toggleSelectAll,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                child: Text(
                                                  _selectedUserIds.length == members.length
                                                      ? tr.deselectAll
                                                      : tr.selectAll,
                                                  style: AppTextStyle.bold(
                                                    fontSize: AppFontSize.caption,
                                                    color: colors.brandEmerald,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      if (_isLoadingMembers && members.isEmpty)
                                        _buildMembersSkeleton(colors)
                                      else if (_membersError != null && members.isEmpty)
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                                            child: Column(
                                              children: [
                                                Icon(LucideIcons.alertCircle, size: 36, color: colors.errorAccent),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _membersError!,
                                                  style: AppTextStyle.medium(fontSize: AppFontSize.secondary, color: colors.textSecondary),
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
                                                  style: AppTextStyle.medium(fontSize: AppFontSize.secondary, color: colors.textSecondary),
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

                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(8),
                                            onTap: isPaid
                                                ? null
                                                : () {
                                                    setState(() {
                                                      if (isSelected) {
                                                        _selectedUserIds.remove(member.userId);
                                                      } else {
                                                        _selectedUserIds.add(member.userId);
                                                      }
                                                    });
                                                  },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
                                                    radius: 18,
                                                    backgroundColor: colors.brandEmeraldMuted,
                                                    backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                                                        ? NetworkImage(member.avatarUrl!)
                                                        : null,
                                                    child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                                                        ? Text(
                                                            member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                                                            style: AppTextStyle.bold(
                                                              fontSize: AppFontSize.secondary,
                                                              color: colors.brandEmerald,
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
                                                          '${member.fullName}${isMe ? ' (Bạn)' : ''}',
                                                          style: AppTextStyle.bold(
                                                            fontSize: AppFontSize.secondary,
                                                            color: colors.textPrimary,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          CurrencyUtils.formatVnd(_calculatedPerPersonVnd),
                                                          style: AppTextStyle.regular(
                                                            fontSize: AppFontSize.caption,
                                                            color: colors.textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Checkbox(
                                                    value: isSelected,
                                                    activeColor: colors.primaryButton,
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
                                            ),
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
                                        onPressed: _handleBack,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          minimumSize: const Size.fromHeight(48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          side: BorderSide(color: colors.cardBorder),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            tr.cancel,
                                            style: AppTextStyle.bold(
                                              fontSize: AppFontSize.secondary,
                                              color: colors.textSecondary,
                                            ),
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
                                          backgroundColor: colors.primaryButton,
                                          foregroundColor: colors.onPrimaryButton,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          minimumSize: const Size.fromHeight(48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 0,
                                        ),
                                        icon: isSubmitting
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: colors.onPrimaryButton,
                                                ),
                                              )
                                            : Icon(LucideIcons.check, size: 16, color: colors.onPrimaryButton),
                                        label: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            widget.isEdit
                                                ? tr.saveFundButton
                                                : tr.createFundButton,
                                            style: AppTextStyle.bold(
                                              fontSize: AppFontSize.secondary,
                                              color: colors.onPrimaryButton,
                                            ),
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
    required AppThemeColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSuggestionChip(String text, AppThemeColors colors) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final cleanText = text.replaceFirst('+', '').trim();
          setState(() {
            _nameController.text = cleanText;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Text(
            text,
            style: AppTextStyle.medium(
              fontSize: AppFontSize.caption,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTogglePill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeColors colors,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? colors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.cardShadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: AppTextStyle.bold(
              fontSize: AppFontSize.caption,
              color: isSelected ? colors.brandEmerald : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembersSkeleton(AppThemeColors colors) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          4,
          (index) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.cardBorder.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Row(
              children: [
                const AppShimmerBox(
                  width: 36,
                  height: 36,
                  borderRadius: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppShimmerBox(
                        width: 120,
                        height: 14,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 6),
                      AppShimmerBox(
                        width: 70,
                        height: 11,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                const AppShimmerBox(
                  width: 20,
                  height: 20,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFundLoadingState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colors.brandEmerald),
          const SizedBox(height: 16),
          Text(
            'Đang tải thông tin đợt quỹ...',
            style: AppTextStyle.medium(
              fontSize: AppFontSize.secondary,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundErrorState(AppThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.errorSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.alertCircle,
                size: 40,
                color: colors.errorAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fundLoadError ?? 'Không thể tải thông tin đợt quỹ',
              style: AppTextStyle.bold(
                fontSize: AppFontSize.body,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (!_isGroupMismatch && widget.fundId != null)
              ElevatedButton.icon(
                onPressed: () => _loadFundDetails(widget.fundId!),
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryButton,
                  foregroundColor: colors.onPrimaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              OutlinedButton(
                onPressed: _handleBack,
                child: const Text('Quay lại'),
              ),
          ],
        ),
      ),
    );
  }
}

