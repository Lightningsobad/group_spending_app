import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../data/models/expense_models.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../cubit/expense_form_cubit.dart';
import '../cubit/expense_form_state.dart';
import '../widgets/add_expense_skeleton.dart';
import '../widgets/ai_receipt_scanner_card.dart';
import '../widgets/category_selector_grid.dart';
import '../widgets/custom_numeric_keypad.dart';
import '../widgets/expense_note_input_field.dart';
import '../widgets/expense_receipt_viewer_dialog.dart';
import '../widgets/split_members_section.dart';
import '../../../../l10n/l10n.dart';

class AddExpenseScreen extends StatefulWidget {
  final GroupModel group;
  final ExpenseDetailModel? expenseToEdit;

  const AddExpenseScreen({
    super.key,
    required this.group,
    this.expenseToEdit,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late GroupModel _currentGroup;
  List<GroupMemberModel> _groupMembers = [];
  bool _isLoadingMembers = false;
  ExpenseFormCubit? _expenseFormCubit;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;
    _titleCtrl = TextEditingController(text: widget.expenseToEdit?.title ?? '');
    _notesCtrl = TextEditingController(text: widget.expenseToEdit?.notes ?? '');

    if (_currentGroup.members != null && _currentGroup.members!.isNotEmpty) {
      _groupMembers = List.from(_currentGroup.members!);
    } else {
      _fetchGroupDetail();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_expenseFormCubit == null) {
      final currentUserId = context.read<AuthCubit>().state.currentUser?.id ?? 0;
      _expenseFormCubit = ExpenseFormCubit(
        context.read<ExpensesRepository>(),
        groupId: _currentGroup.id,
        groupName: _currentGroup.name,
        members: _groupMembers,
        currentUserId: currentUserId,
        expenseToEdit: widget.expenseToEdit,
        dataSyncCoordinator: context.read<DataSyncCoordinator>(),
      );
    }
  }

  Future<void> _fetchGroupDetail() async {
    setState(() => _isLoadingMembers = true);
    final groupsRepo = context.read<GroupsRepository>();
    List<GroupMemberModel>? members = _currentGroup.members;
    GroupModel? detail;

    // 1. Cố gắng lấy chi tiết nhóm qua GroupsCubit nếu có trong context hoặc trực tiếp từ GroupsRepository
    try {
      final groupsCubit = context.read<GroupsCubit>();
      detail = await groupsCubit.loadGroupDetails(_currentGroup.id);
      members = detail?.members;
    } catch (_) {
      try {
        detail = await groupsRepo.getGroupDetails(_currentGroup.id);
        members = detail.members;
      } catch (_) {}
    }

    // 2. Vì API GET /groups/{id} lược bỏ members để tối ưu payload, gọi getGroupMembers để lấy danh sách đầy đủ
    if (members == null || members.isEmpty) {
      try {
        final summaries = await groupsRepo.getGroupMembers(_currentGroup.id);
        if (summaries.isNotEmpty) {
          members = summaries.map((s) => GroupMemberModel.fromSummary(s)).toList();
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        if (detail != null) _currentGroup = detail;
        if (members != null && members.isNotEmpty) {
          _groupMembers = members;
          _currentGroup = _currentGroup.copyWith(members: members);
        }
        _isLoadingMembers = false;
      });
      if (members != null && members.isNotEmpty) {
        final currentUserId = context.read<AuthCubit>().state.currentUser?.id;
        _expenseFormCubit?.updateMembers(members, currentUserId: currentUserId);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _expenseFormCubit?.close();
    super.dispose();
  }

  Future<void> _showChangeGroupSheet() async {
    List<GroupModel> groups = [];
    try {
      groups = context.read<GroupsCubit>().state.groups;
    } catch (_) {}

    if (groups.isEmpty) {
      try {
        final repo = context.read<GroupsRepository>();
        groups = await repo.getMyGroups();
      } catch (_) {}
    }

    if (!mounted) return;
    final colors = context.colors;
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colors.cardBackground,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.selectReceivingGroupTitle,
                    style: AppTextStyle.bold(fontSize: 16, color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: groups.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noGroupsAvailable,
                            style: AppTextStyle.regular(
                              fontSize: AppFontSize.caption,
                              color: colors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final g = groups[index];
                            final isCurrent = g.id == _currentGroup.id;
                            return ListTile(
                              leading: Icon(LucideIcons.building2, color: colors.brandEmerald),
                              title: Text(g.name, style: AppTextStyle.bold(fontSize: AppFontSize.secondary, color: colors.textPrimary)),
                              subtitle: Text(l10n.membersCountSubtitle(g.memberCount), style: AppTextStyle.regular(fontSize: AppFontSize.caption, color: colors.textSecondary)),
                              trailing: isCurrent ? Icon(LucideIcons.check, color: colors.brandEmerald) : null,
                              onTap: () {
                                Navigator.of(ctx).pop();
                                if (!isCurrent) {
                                  setState(() {
                                    _currentGroup = g;
                                    _groupMembers = g.members ?? [];
                                  });
                                  _expenseFormCubit?.updateGroup(g.id, g.name);
                                  if (g.members != null && g.members!.isNotEmpty) {
                                    final currentUserId = context.read<AuthCubit>().state.currentUser?.id;
                                    _expenseFormCubit?.updateMembers(g.members!, currentUserId: currentUserId);
                                  } else {
                                    _fetchGroupDetail();
                                  }
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickReceipt(ImageSource source) async {
    if (_expenseFormCubit?.state.isBusy == true) return;
    final l10n = context.l10n;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final size = await file.length();
      if (size > 10 * 1024 * 1024) {
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: l10n.maxImageSize10Mb,
          type: AppSnackBarType.error,
        );
        return;
      }

      final result = await _expenseFormCubit?.scanAndPrefillReceipt(file);
      if (result != null && mounted) {
        if (_expenseFormCubit != null) {
          _titleCtrl.text = _expenseFormCubit!.state.title;
          _notesCtrl.text = _expenseFormCubit!.state.notes ?? '';
        }
        if (result.isLowConfidence) {
          AppSnackBar.show(
            context,
            message: l10n.receiptLowConfidenceWarning,
            type: AppSnackBarType.warning,
            duration: const Duration(seconds: 4),
          );
        } else {
          AppSnackBar.show(
            context,
            message: l10n.receiptScanSuccess,
            type: AppSnackBarType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: l10n.pickImageError(e.toString()),
          type: AppSnackBarType.error,
        );
      }
    }
  }

  void _viewReceipt() {
    final state = _expenseFormCubit?.state;
    if (state == null) return;
    final l10n = context.l10n;
    final defaultTitle = l10n.expenseReceiptDefaultTitle;
    if (state.receiptUrl != null && state.receiptUrl!.trim().isNotEmpty) {
      ExpenseReceiptViewerDialog.show(
        context,
        receiptUrl: state.receiptUrl!,
        title: state.title.isNotEmpty ? state.title : defaultTitle,
      );
    } else if (state.receiptFile != null) {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        state.title.isNotEmpty ? state.title : defaultTitle,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Image.file(state.receiptFile!, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildCard({
    required Widget child,
    required AppThemeColors colors,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final currentUserId = context.read<AuthCubit>().state.currentUser?.id ?? 0;
    final isEdit = widget.expenseToEdit != null;
    final formCubit = _expenseFormCubit;
    if (formCubit == null) return const SizedBox.shrink();

    return BlocProvider.value(
      value: formCubit,
      child: BlocConsumer<ExpenseFormCubit, ExpenseFormState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppSnackBar.show(
              context,
              message: state.errorMessage!,
              type: AppSnackBarType.error,
            );
            context.read<ExpenseFormCubit>().clearMessages();
          }
          if (state.status == ExpenseFormStatus.success) {
            AppSnackBar.show(
              context,
              message: state.successMessage ?? (isEdit ? l10n.saveChanges : l10n.saveNewExpenseAction),
              type: AppSnackBarType.success,
            );
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final cubit = context.read<ExpenseFormCubit>();

          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.cardBackground,
              elevation: 0,
              leading: IconButton(
                icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                isEdit ? l10n.editExpenseTitle : l10n.addExpense,
                style: AppTextStyle.bold(fontSize: AppFontSize.h4, color: colors.textPrimary),
              ),
              centerTitle: false,
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. NHÓM NHẬN CHI TIÊU
                        _buildCard(
                          colors: colors,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  LucideIcons.building2,
                                  size: 20,
                                  color: colors.brandEmerald,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.expenseReceivingGroupCaps,
                                      style: AppTextStyle.bold(
                                        fontSize: AppFontSize.caption,
                                        letterSpacing: 0.5,
                                        color: colors.brandEmerald,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentGroup.name,
                                      style: AppTextStyle.bold(
                                        fontSize: AppFontSize.secondary,
                                        color: colors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isEdit)
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    minimumSize: const Size(80, 48),
                                    side: BorderSide(color: colors.cardBorder),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _showChangeGroupSheet,
                                  child: Text(
                                    l10n.changeGroupAction,
                                    style: AppTextStyle.bold(
                                      fontSize: 13,
                                      color: colors.brandEmerald,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // QUÉT HÓA ĐƠN AI
                        AiReceiptScannerCard(
                          isScanning: state.isScanningReceipt,
                          receiptFile: state.receiptFile,
                          receiptUrl: state.receiptUrl,
                          scanConfidence: state.scanConfidence,
                          onCapturePressed: state.isBusy ? () {} : () => _pickReceipt(ImageSource.camera),
                          onPickGalleryPressed: state.isBusy ? () {} : () => _pickReceipt(ImageSource.gallery),
                          onRemoveReceipt: state.isBusy ? () {} : cubit.removeReceipt,
                          onViewReceipt: _viewReceipt,
                        ),
                        const SizedBox(height: 14),

                        // 2. SỐ TIỀN CHI TIÊU (VNĐ) + Custom Numeric Keypad
                        _buildCard(
                          colors: colors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expenseAmountVndCaps,
                                style: AppTextStyle.bold(
                                  fontSize: AppFontSize.caption,
                                  letterSpacing: 0.5,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₫',
                                    style: AppTextStyle.bold(
                                      fontSize: 26,
                                      color: colors.brandEmerald,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          CurrencyUtils.formatVnd(state.totalAmountVnd),
                                          style: AppTextStyle.bold(
                                            fontSize: AppFontSize.h1,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(height: 1, color: colors.divider),
                              const SizedBox(height: 12),
                              CustomNumericKeypad(
                                onDigitPressed: cubit.onDigitPressed,
                                onTripleZeroPressed: cubit.onTripleZeroPressed,
                                onClearPressed: cubit.onClearPressed,
                                onDeletePressed: cubit.onDeletePressed,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 3. TÊN KHOẢN CHI & GHI CHÚ
                        _buildCard(
                          colors: colors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expenseTitleCaps,
                                style: AppTextStyle.bold(
                                  fontSize: AppFontSize.caption,
                                  letterSpacing: 0.5,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _titleCtrl,
                                onChanged: cubit.setTitle,
                                style: AppTextStyle.medium(
                                  fontSize: AppFontSize.secondary,
                                  color: colors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.expenseTitleHint,
                                  hintStyle: AppTextStyle.regular(
                                    fontSize: AppFontSize.secondary,
                                    color: colors.textMuted,
                                  ),
                                  filled: true,
                                  fillColor: colors.surfaceMuted,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: colors.cardBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: colors.cardBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: colors.brandEmerald, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                              const SizedBox(height: 14),
                              ExpenseNoteInputField(
                                controller: _notesCtrl,
                                onChanged: cubit.setNotes,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4. DANH MỤC CHI TIÊU
                        _buildCard(
                          colors: colors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expenseCategorySectionCaps,
                                style: AppTextStyle.bold(
                                  fontSize: AppFontSize.caption,
                                  letterSpacing: 0.5,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              CategorySelectorGrid(
                                selectedCategory: state.category,
                                onCategorySelected: cubit.setCategory,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 5. NGƯỜI ĐÃ TRẢ TIỀN (DUY NHẤT 1 NGƯỜI)
                        _buildCard(
                          colors: colors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expensePayerSectionCaps,
                                style: AppTextStyle.bold(
                                  fontSize: AppFontSize.caption,
                                  letterSpacing: 0.5,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_isLoadingMembers && _groupMembers.isEmpty)
                                const AddExpensePayerSkeleton()
                              else if (_groupMembers.isNotEmpty)
                                DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  key: ValueKey<int>(state.paidByUserId),
                                  initialValue: _groupMembers.any((m) => m.userId == state.paidByUserId)
                                      ? state.paidByUserId
                                      : _groupMembers.first.userId,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: colors.surfaceMuted,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: colors.cardBorder),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: colors.cardBorder),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  items: _groupMembers.map((m) {
                                    final isMe = m.userId == currentUserId;
                                    return DropdownMenuItem<int>(
                                      value: m.userId,
                                      child: Text(
                                        '${m.fullName}${isMe ? l10n.youPayerSuffix : ''}${m.email != null ? ' (${m.email})' : ''}',
                                        style: AppTextStyle.bold(
                                          fontSize: AppFontSize.secondary,
                                          color: colors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) cubit.setPayer(val);
                                  },
                                )
                              else
                                Text(
                                  l10n.noMembersInGroup,
                                  style: AppTextStyle.regular(
                                    fontSize: AppFontSize.caption,
                                    color: colors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 6. KHUNG PHÂN CHIA CHI PHÍ
                        _buildCard(
                          colors: colors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expenseSplitSectionCaps,
                                style: AppTextStyle.bold(
                                  fontSize: AppFontSize.caption,
                                  letterSpacing: 0.5,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_isLoadingMembers && _groupMembers.isEmpty)
                                const AddExpenseSplitSkeleton()
                              else if (_groupMembers.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.noMembersToSplit,
                                          style: AppTextStyle.regular(
                                            fontSize: AppFontSize.caption,
                                            color: colors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: _isLoadingMembers ? null : _fetchGroupDetail,
                                          icon: const Icon(LucideIcons.refreshCw, size: 14),
                                          label: const Text('Thử lại tải thành viên'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                SplitMembersSection(
                                  members: _groupMembers,
                                  selectedParticipantUserIds: state.selectedParticipantUserIds,
                                  splitOption: state.splitOption,
                                  paidByUserId: state.paidByUserId,
                                  totalAmountVnd: state.totalAmountVnd,
                                  onSplitOptionChanged: cubit.setSplitOption,
                                  onToggleParticipant: cubit.toggleParticipant,
                                  onSelectAll: cubit.selectAllParticipants,
                                  onDeselectAll: cubit.deselectAllParticipants,
                                  getMemberShareVnd: cubit.state.getMemberShareVnd,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons with SafeArea integration
                Container(
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    border: Border(top: BorderSide(color: colors.cardBorder)),
                    boxShadow: [colors.bottomNavShadow],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                minimumSize: const Size(100, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(color: colors.cardBorder),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                l10n.cancelAction,
                                style: AppTextStyle.bold(
                                  fontSize: 15,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primaryButton,
                                foregroundColor: colors.onPrimaryButton,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                minimumSize: const Size(140, 48),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: (state.isBusy || _isLoadingMembers) ? null : cubit.submitExpense,
                              child: state.isSubmitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.onPrimaryButton,
                                      ),
                                    )
                                  : state.isScanningReceipt
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colors.onPrimaryButton,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Đang quét...',
                                              style: AppTextStyle.bold(
                                                fontSize: 15,
                                                color: colors.onPrimaryButton,
                                              ),
                                            ),
                                          ],
                                        )
                                      : _isLoadingMembers
                                          ? Text(
                                              'Đang tải...',
                                              style: AppTextStyle.bold(
                                                fontSize: 15,
                                                color: colors.onPrimaryButton,
                                              ),
                                            )
                                          : Text(
                                              isEdit ? l10n.saveChanges : l10n.saveNewExpenseAction,
                                              style: AppTextStyle.bold(
                                                fontSize: 15,
                                                color: colors.onPrimaryButton,
                                              ),
                                            ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
