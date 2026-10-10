import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../data/models/expense_models.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../cubit/expense_form_cubit.dart';
import '../cubit/expense_form_state.dart';
import '../widgets/ai_receipt_scanner_card.dart';
import '../widgets/category_selector_grid.dart';
import '../widgets/custom_numeric_keypad.dart';
import '../widgets/expense_receipt_viewer_dialog.dart';
import '../widgets/split_members_section.dart';

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
    List<GroupMemberModel>? members = _currentGroup.members;
    GroupModel? detail;
    try {
      detail = await context.read<GroupsCubit>().loadGroupDetails(_currentGroup.id);
      members = detail?.members;
    } catch (_) {}

    if (members == null || members.isEmpty) {
      try {
        final repo = context.read<GroupsRepository>();
        final summaries = await repo.getGroupMembers(_currentGroup.id);
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

  void _showChangeGroupSheet() {
    final groups = context.read<GroupsCubit>().state.groups;
    final colors = context.colors;

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
                    'Chọn nhóm nhận chi tiêu',
                    style: AppTextStyle.bold(fontSize: 16, color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final g = groups[index];
                      final isCurrent = g.id == _currentGroup.id;
                      return ListTile(
                        leading: const Icon(LucideIcons.building2),
                        title: Text(g.name, style: AppTextStyle.bold(fontSize: 14)),
                        subtitle: Text('${g.memberCount} thành viên'),
                        trailing: isCurrent ? const Icon(LucideIcons.check, color: AppColors.emerald) : null,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kích thước ảnh tối đa là 10MB'),
            backgroundColor: AppColors.error,
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh mờ hoặc không nhận dạng được chữ. Ảnh đã được lưu, vui lòng tự nhập số tiền và tiêu đề.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quét hóa đơn thành công! Đã tự động điền thông tin.'),
              backgroundColor: AppColors.emerald,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _viewReceipt() {
    final state = _expenseFormCubit?.state;
    if (state == null) return;
    if (state.receiptUrl != null && state.receiptUrl!.trim().isNotEmpty) {
      ExpenseReceiptViewerDialog.show(
        context,
        receiptUrl: state.receiptUrl!,
        title: state.title.isNotEmpty ? state.title : 'Hóa đơn chi tiêu',
      );
    } else if (state.receiptFile != null) {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      state.title.isNotEmpty ? state.title : 'Hóa đơn chi tiêu',
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
      );
    }
  }

  Widget _buildCard({
    required Widget child,
    required dynamic colors,
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
            color: Colors.black.withValues(alpha: 0.02),
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
    final currentUserId = context.read<AuthCubit>().state.currentUser?.id ?? 0;
    final isEdit = widget.expenseToEdit != null;
    final formCubit = _expenseFormCubit;
    if (formCubit == null) return const SizedBox.shrink();

    return BlocProvider.value(
      value: formCubit,
      child: BlocConsumer<ExpenseFormCubit, ExpenseFormState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<ExpenseFormCubit>().clearMessages();
          }
          if (state.status == ExpenseFormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Thành công'),
                backgroundColor: AppColors.emerald,
              ),
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
                isEdit ? 'Sửa thông tin khoản chi' : 'Thêm chi tiêu',
                style: AppTextStyle.bold(fontSize: 18, color: colors.textPrimary),
              ),
              centerTitle: false,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. NHÓM NHẬN CHI TIÊU (Image 3)
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
                                  child: const Icon(
                                    LucideIcons.building2,
                                    size: 20,
                                    color: Color(0xFF14532D),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NHÓM NHẬN CHI TIÊU',
                                        style: AppTextStyle.bold(
                                          fontSize: 11,
                                          color: const Color(0xFF14532D),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _currentGroup.name,
                                        style: AppTextStyle.bold(
                                          fontSize: 14,
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
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _showChangeGroupSheet,
                                    child: const Text(
                                      'Đổi nhóm',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF14532D)),
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
                            onCapturePressed: () => _pickReceipt(ImageSource.camera),
                            onPickGalleryPressed: () => _pickReceipt(ImageSource.gallery),
                            onRemoveReceipt: cubit.removeReceipt,
                            onViewReceipt: _viewReceipt,
                          ),
                          const SizedBox(height: 14),

                          // 2. SỐ TIỀN CHI TIÊU (VNĐ) + Custom Numeric Keypad (Image 3)
                          _buildCard(
                            colors: colors,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SỐ TIỀN CHI TIÊU (VNĐ)',
                                  style: AppTextStyle.bold(
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '\$',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF14532D),
                                      ),
                                    ),
                                    Text(
                                      CurrencyUtils.formatVnd(state.totalAmountVnd),
                                      style: AppTextStyle.bold(
                                        fontSize: 26,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
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

                          // 3. TÊN KHOẢN CHI & GHI CHÚ (Image 3, 4)
                          _buildCard(
                            colors: colors,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TÊN KHOẢN CHI',
                                  style: AppTextStyle.bold(
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _titleCtrl,
                                  onChanged: cubit.setTitle,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tên khoản chi (ví dụ: Ăn tối Haidilao)...',
                                    hintStyle: AppTextStyle.regular(
                                      fontSize: 13,
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
                                      borderSide: const BorderSide(color: Color(0xFF14532D), width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(LucideIcons.fileText, size: 14, color: colors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'GHI CHÚ',
                                          style: AppTextStyle.bold(
                                            fontSize: 11,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Tùy chọn',
                                      style: AppTextStyle.regular(fontSize: 11, color: colors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _notesCtrl,
                                  onChanged: cubit.setNotes,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập ghi chú thêm cho khoản chi (tùy chọn)...',
                                    hintStyle: AppTextStyle.regular(
                                      fontSize: 13,
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
                                      borderSide: const BorderSide(color: Color(0xFF14532D), width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 4. DANH MỤC CHI TIÊU (Image 4)
                          _buildCard(
                            colors: colors,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DANH MỤC CHI TIÊU',
                                  style: AppTextStyle.bold(
                                    fontSize: 11,
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

                          // 5. NGƯỜI ĐÃ TRẢ TIỀN (DUY NHẤT 1 NGƯỜI) (Image 4)
                          _buildCard(
                            colors: colors,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NGƯỜI ĐÃ TRẢ TIỀN (DUY NHẤT 1 NGƯỜI)',
                                  style: AppTextStyle.bold(
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_isLoadingMembers && _groupMembers.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Đang tải danh sách thành viên...',
                                          style: AppTextStyle.regular(fontSize: 12, color: colors.textMuted),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_groupMembers.isNotEmpty)
                                  DropdownButtonFormField<int>(
                                    value: _groupMembers.any((m) => m.userId == state.paidByUserId)
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
                                          '${m.fullName}${isMe ? ' (Bạn)' : ''}${m.email != null ? ' (${m.email})' : ''}',
                                          style: AppTextStyle.bold(fontSize: 13, color: colors.textPrimary),
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
                                    'Không có thành viên trong nhóm.',
                                    style: AppTextStyle.regular(fontSize: 12, color: colors.textMuted),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 6. KHUNG PHÂN CHIA CHI PHÍ (Image 2)
                          _buildCard(
                            colors: colors,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KHUNG PHÂN CHIA CHI PHÍ',
                                  style: AppTextStyle.bold(
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_isLoadingMembers && _groupMembers.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (_groupMembers.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'Không có thành viên trong nhóm để chia chi phí.',
                                        style: AppTextStyle.regular(fontSize: 12, color: colors.textMuted),
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

                  // Bottom Action Buttons (Image 2)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      border: Border(top: BorderSide(color: colors.cardBorder)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: colors.cardBorder),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Hủy bỏ',
                              style: AppTextStyle.bold(
                                fontSize: 14,
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
                              backgroundColor: const Color(0xFF047857),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: state.isSubmitting ? null : cubit.submitExpense,
                            child: state.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEdit ? 'Lưu thay đổi' : 'Lưu khoản chi mới',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
