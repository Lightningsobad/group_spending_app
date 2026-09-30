import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../groups/data/models/group_model.dart';
import '../../data/models/expense_enums.dart';
import '../../data/models/expense_models.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../cubit/expense_detail_cubit.dart';
import '../cubit/expense_detail_state.dart';
import '../widgets/delete_expense_confirm_dialog.dart';
import '../widgets/expense_receipt_viewer_dialog.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final int expenseId;
  final GroupModel group;

  const ExpenseDetailScreen({
    super.key,
    required this.expenseId,
    required this.group,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  String _formatDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '---';
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy - HH:mm').format(dt);
    } catch (_) {
      return rawDate;
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

  Future<void> _handleDelete(BuildContext context, ExpenseDetailCubit cubit) async {
    final confirmed = await DeleteExpenseConfirmDialog.show(context);
    if (confirmed && context.mounted) {
      final success = await cubit.deleteExpense();
      if (success && context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _handleEdit(BuildContext context, ExpenseDetailModel expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          group: widget.group,
          expenseToEdit: expense,
        ),
      ),
    ).then((updated) {
      if (updated == true && context.mounted) {
        context.read<ExpenseDetailCubit>().loadExpenseDetail(widget.expenseId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentUserId = context.read<AuthCubit>().state.currentUser?.id ?? 0;
    final isGroupAdmin = widget.group.isAdmin || (widget.group.ownerId == currentUserId);

    return BlocProvider(
      create: (context) => ExpenseDetailCubit(
        context.read<ExpensesRepository>(),
        dataSyncCoordinator: context.read<DataSyncCoordinator>(),
      )..loadExpenseDetail(widget.expenseId),
      child: BlocConsumer<ExpenseDetailCubit, ExpenseDetailState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<ExpenseDetailCubit>().clearMessages();
          }
          if (state.deleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Xóa khoản chi thành công'),
                backgroundColor: AppColors.emerald,
              ),
            );
          }
        },
        builder: (context, state) {
          final expense = state.expense;
          final cubit = context.read<ExpenseDetailCubit>();

          final canEditOrDelete = expense != null &&
              ((currentUserId != 0 && currentUserId == expense.createdByUserId) || isGroupAdmin);

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
                'Chi tiết khoản chi',
                style: AppTextStyle.bold(fontSize: 18, color: colors.textPrimary),
              ),
              actions: [
                if (canEditOrDelete) ...[
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.pencil, size: 18, color: colors.textPrimary),
                    ),
                    onPressed: () => _handleEdit(context, expense),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                    ),
                    onPressed: () => _handleDelete(context, cubit),
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
            body: state.status == ExpenseDetailStatus.loading && expense == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.emerald),
                  )
                : expense == null
                    ? Center(
                        child: Text(
                          state.errorMessage ?? 'Không tìm thấy thông tin khoản chi.',
                          style: AppTextStyle.medium(fontSize: 14, color: colors.textSecondary),
                        ),
                      )
                    : SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // 1. Thẻ Tổng quan (Image 5)
                                    _buildCard(
                                      colors: colors,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Category & Group row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF0FDF4),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      expense.categoryType.icon,
                                                      size: 14,
                                                      color: const Color(0xFF14532D),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      expense.categoryType.labelVi,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF14532D),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    LucideIcons.building2,
                                                    size: 14,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    expense.groupName ?? widget.group.name,
                                                    style: AppTextStyle.regular(
                                                      fontSize: 12,
                                                      color: colors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Title
                                          Text(
                                            expense.title,
                                            style: AppTextStyle.bold(
                                              fontSize: 20,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Amount
                                          Text(
                                            CurrencyUtils.formatVnd(expense.totalAmountVnd),
                                            style: AppTextStyle.bold(
                                              fontSize: 26,
                                              color: const Color(0xFF14532D),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Date & Participants count
                                          Row(
                                            children: [
                                              const Icon(
                                                LucideIcons.calendar,
                                                size: 14,
                                                color: Color(0xFF94A3B8),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDateTime(expense.expenseDate ?? expense.createdAt),
                                                style: AppTextStyle.regular(
                                                  fontSize: 12,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                LucideIcons.users,
                                                size: 14,
                                                color: Color(0xFF94A3B8),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${expense.splits.length} người tham gia',
                                                style: AppTextStyle.regular(
                                                  fontSize: 12,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // 2. Thẻ Người thanh toán (Image 5)
                                    _buildCard(
                                      colors: colors,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'NGƯỜI THANH TOÁN',
                                                style: AppTextStyle.bold(
                                                  fontSize: 11,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                              if (expense.paidByUserId == currentUserId)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFDCFCE7),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Text(
                                                    'Bạn đã trả',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF15803D),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 22,
                                                backgroundColor: colors.surfaceMuted,
                                                backgroundImage: expense.paidByUserAvatar != null &&
                                                        expense.paidByUserAvatar!.isNotEmpty
                                                    ? NetworkImage(expense.paidByUserAvatar!)
                                                    : null,
                                                child: expense.paidByUserAvatar == null ||
                                                        expense.paidByUserAvatar!.isEmpty
                                                    ? Text(
                                                        expense.paidByUserName.isNotEmpty
                                                            ? expense.paidByUserName.substring(0, 1).toUpperCase()
                                                            : '?',
                                                        style: AppTextStyle.bold(
                                                          fontSize: 16,
                                                          color: colors.textPrimary,
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
                                                      expense.paidByUserId == currentUserId
                                                          ? '${expense.paidByUserName} (Bạn)'
                                                          : expense.paidByUserName,
                                                      style: AppTextStyle.bold(
                                                        fontSize: 14,
                                                        color: colors.textPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Đã chi trả toàn bộ hóa đơn',
                                                      style: AppTextStyle.regular(
                                                        fontSize: 12,
                                                        color: colors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    CurrencyUtils.formatVnd(expense.totalAmountVnd),
                                                    style: AppTextStyle.bold(
                                                      fontSize: 14,
                                                      color: colors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  const Text(
                                                    '100% ứng trước',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF15803D),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // 3. Thẻ Ghi chú (Image 5)
                                    if (expense.notes != null && expense.notes!.trim().isNotEmpty) ...[
                                      _buildCard(
                                        colors: colors,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(LucideIcons.fileText, size: 14, color: colors.textSecondary),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'GHI CHÚ',
                                                  style: AppTextStyle.bold(
                                                    fontSize: 11,
                                                    color: colors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: colors.surfaceMuted,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                expense.notes!,
                                                style: AppTextStyle.regular(
                                                  fontSize: 13,
                                                  color: colors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                    ],

                                    // 4. Thẻ Phần chia từng thành viên (Image 5, 6)
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
                                                  Icon(LucideIcons.users, size: 14, color: colors.textSecondary),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'PHẦN CHIA TỪNG THÀNH VIÊN (${expense.splits.length})',
                                                    style: AppTextStyle.bold(
                                                      fontSize: 11,
                                                      color: colors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Bấm để đổi trạng thái',
                                                style: AppTextStyle.regular(
                                                  fontSize: 11,
                                                  color: colors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: expense.splits.length,
                                            separatorBuilder: (_, _) => const Divider(height: 16),
                                            itemBuilder: (context, index) {
                                              final split = expense.splits[index];
                                              final isMe = split.userId == currentUserId;
                                              final isPayer = split.userId == expense.paidByUserId;
                                              final status = split.splitStatus;

                                              return Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor: colors.surfaceMuted,
                                                    backgroundImage: split.avatarUrl != null &&
                                                            split.avatarUrl!.isNotEmpty
                                                        ? NetworkImage(split.avatarUrl!)
                                                        : null,
                                                    child: split.avatarUrl == null || split.avatarUrl!.isEmpty
                                                        ? Text(
                                                            split.fullName.isNotEmpty
                                                                ? split.fullName.substring(0, 1).toUpperCase()
                                                                : '?',
                                                            style: AppTextStyle.bold(
                                                              fontSize: 13,
                                                              color: colors.textPrimary,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                split.fullName,
                                                                style: AppTextStyle.bold(
                                                                  fontSize: 13,
                                                                  color: colors.textPrimary,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            if (isMe) ...[
                                                              const SizedBox(width: 4),
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(
                                                                    horizontal: 5, vertical: 1),
                                                                decoration: BoxDecoration(
                                                                  color: colors.surfaceMuted,
                                                                  borderRadius: BorderRadius.circular(6),
                                                                ),
                                                                child: const Text('Bạn', style: TextStyle(fontSize: 10)),
                                                              ),
                                                            ],
                                                            if (isPayer) ...[
                                                              const SizedBox(width: 4),
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(
                                                                    horizontal: 5, vertical: 1),
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0xFFDCFCE7),
                                                                  borderRadius: BorderRadius.circular(6),
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
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          'Số tiền: ${CurrencyUtils.formatVnd(split.amountOwedVnd)}',
                                                          style: AppTextStyle.regular(
                                                            fontSize: 12,
                                                            color: colors.textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Status pill
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: status.bgColor,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (status == ExpenseSplitStatus.paid)
                                                          Icon(LucideIcons.check, size: 12, color: status.textColor)
                                                        else if (status == ExpenseSplitStatus.unpaid)
                                                          Icon(LucideIcons.alertCircle, size: 12, color: status.textColor)
                                                        else
                                                          Icon(LucideIcons.clock, size: 12, color: status.textColor),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          status.label,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                            color: status.textColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (status != ExpenseSplitStatus.paid && !isPayer) ...[
                                                    const SizedBox(width: 4),
                                                    IconButton(
                                                      icon: Icon(
                                                        LucideIcons.bell,
                                                        size: 16,
                                                        color: colors.textMuted,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Đã gửi nhắc nhở thanh toán đến ${split.fullName}',
                                                            ),
                                                            backgroundColor: AppColors.emerald,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // 5. Thẻ Hóa đơn / Chứng từ (Image 6)
                                    if (expense.receiptUrl != null && expense.receiptUrl!.isNotEmpty)
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
                                                    Icon(LucideIcons.receipt, size: 14, color: colors.textSecondary),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'HÓA ĐƠN / CHỨNG TỪ',
                                                      style: AppTextStyle.bold(
                                                        fontSize: 11,
                                                        color: colors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: Size.zero,
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  onPressed: () => ExpenseReceiptViewerDialog.show(
                                                    context,
                                                    receiptUrl: expense.receiptUrl!,
                                                    title: expense.title,
                                                  ),
                                                  icon: const Icon(LucideIcons.zoomIn, size: 14, color: Color(0xFF14532D)),
                                                  label: const Text(
                                                    'Phóng to',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF14532D),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            InkWell(
                                              borderRadius: BorderRadius.circular(14),
                                              onTap: () => ExpenseReceiptViewerDialog.show(
                                                context,
                                                receiptUrl: expense.receiptUrl!,
                                                title: expense.title,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(14),
                                                child: Image.network(
                                                  expense.receiptUrl!,
                                                  height: 160,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    height: 100,
                                                    color: colors.surfaceMuted,
                                                    alignment: Alignment.center,
                                                    child: const Text('Không thể tải ảnh hóa đơn'),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 14),

                                    // 6. Action buttons at bottom (Image 6)
                                    if (canEditOrDelete) ...[
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          side: const BorderSide(color: Color(0xFF86EFAC)),
                                          backgroundColor: const Color(0xFFF0FDF4),
                                        ),
                                        onPressed: () => _handleEdit(context, expense),
                                        icon: const Icon(LucideIcons.pencil, size: 16, color: Color(0xFF15803D)),
                                        label: const Text(
                                          'Sửa thông tin khoản chi',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          side: const BorderSide(color: Color(0xFFFECACA)),
                                          backgroundColor: const Color(0xFFFEF2F2),
                                        ),
                                        onPressed: () => _handleDelete(context, cubit),
                                        icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFDC2626)),
                                        label: const Text(
                                          'Xóa khoản chi này',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
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
