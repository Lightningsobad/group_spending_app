import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../data/models/expense_enums.dart';
import '../../data/models/expense_models.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../cubit/expense_detail_cubit.dart';
import '../cubit/expense_detail_state.dart';
import '../widgets/delete_expense_confirm_dialog.dart';
import '../widgets/expense_detail_skeleton.dart';
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
    GroupsCubit? groupsCubit;
    try {
      groupsCubit = context.read<GroupsCubit>();
    } catch (_) {}

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => groupsCubit != null
            ? BlocProvider<GroupsCubit>.value(
                value: groupsCubit,
                child: AddExpenseScreen(
                  group: widget.group,
                  expenseToEdit: expense,
                ),
              )
            : AddExpenseScreen(
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
            AppSnackBar.showError(context, state.errorMessage!);
            context.read<ExpenseDetailCubit>().clearMessages();
          }
          if (state.deleteSuccess) {
            AppSnackBar.showSuccess(context, 'Xóa khoản chi thành công');
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
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Chi tiết khoản chi',
                style: AppTextStyle.bold(fontSize: AppFontSize.h4, color: colors.textPrimary),
              ),
              actions: [
                if (canEditOrDelete) ...[
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.pencil, size: 18, color: colors.textPrimary),
                    ),
                    onPressed: () => _handleEdit(context, expense),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colors.expenseQuickDeleteBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.trash2, size: 18, color: colors.expenseQuickDeleteFg),
                    ),
                    onPressed: () => _handleDelete(context, cubit),
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: MediaQuery.withClampedTextScaling(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.3,
                child: state.status == ExpenseDetailStatus.loading && expense == null
                    ? const ExpenseDetailSkeleton()
                    : expense == null
                        ? Center(
                            child: Text(
                              state.errorMessage ?? 'Không tìm thấy thông tin khoản chi.',
                              style: AppTextStyle.medium(fontSize: AppFontSize.secondary, color: colors.textSecondary),
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // 1. Thẻ Tổng quan
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
                                                    color: colors.expenseCategoryTagBg,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: colors.expenseCategoryTagBorder),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        expense.categoryType.icon,
                                                        size: 14,
                                                        color: colors.expenseCategoryTagText,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        expense.categoryType.labelVi,
                                                        style: AppTextStyle.bold(
                                                          fontSize: AppFontSize.caption,
                                                          color: colors.expenseCategoryTagText,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        LucideIcons.building2,
                                                        size: 14,
                                                        color: colors.textSecondary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          expense.groupName ?? widget.group.name,
                                                          style: AppTextStyle.regular(
                                                            fontSize: AppFontSize.caption,
                                                            color: colors.textSecondary,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            // Title
                                            Text(
                                              expense.title,
                                              style: AppTextStyle.bold(
                                                fontSize: AppFontSize.h3,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Amount
                                            Text(
                                              CurrencyUtils.formatVnd(expense.totalAmountVnd),
                                              style: AppTextStyle.bold(
                                                fontSize: AppFontSize.h1,
                                                color: colors.expenseHeroAmount,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Date & Participants count
                                            Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      LucideIcons.calendar,
                                                      size: 14,
                                                      color: colors.textMuted,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _formatDateTime(expense.expenseDate ?? expense.createdAt),
                                                      style: AppTextStyle.regular(
                                                        fontSize: AppFontSize.caption,
                                                        color: colors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text('•', style: TextStyle(color: colors.textMuted)),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      LucideIcons.users,
                                                      size: 14,
                                                      color: colors.textMuted,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${expense.splits.length} người tham gia',
                                                      style: AppTextStyle.regular(
                                                        fontSize: AppFontSize.caption,
                                                        color: colors.textSecondary,
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

                                      // 2. Thẻ Người thanh toán
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
                                                    'NGƯỜI THANH TOÁN',
                                                    style: AppTextStyle.bold(
                                                      fontSize: AppFontSize.caption,
                                                      color: colors.textSecondary,
                                                      letterSpacing: 0.5,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (expense.paidByUserId == currentUserId)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: colors.expensePayerBadgeBg,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      'Bạn đã trả',
                                                      style: AppTextStyle.bold(
                                                        fontSize: AppFontSize.caption,
                                                        color: colors.expensePayerBadgeText,
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
                                                            fontSize: AppFontSize.body,
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
                                                          fontSize: AppFontSize.secondary,
                                                          color: colors.textPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Đã chi trả toàn bộ hóa đơn',
                                                        style: AppTextStyle.regular(
                                                          fontSize: AppFontSize.caption,
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
                                                        fontSize: AppFontSize.secondary,
                                                        color: colors.textPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '100% ứng trước',
                                                      style: AppTextStyle.bold(
                                                        fontSize: AppFontSize.caption,
                                                        color: colors.expensePayerAdvanceText,
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

                                      // 3. Thẻ Ghi chú
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
                                                      fontSize: AppFontSize.caption,
                                                      color: colors.textSecondary,
                                                      letterSpacing: 0.5,
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
                                                    fontSize: AppFontSize.secondary,
                                                    color: colors.textPrimary,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                      ],

                                      // 4. Thẻ Phần chia từng thành viên
                                      _buildCard(
                                        colors: colors,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(LucideIcons.users, size: 14, color: colors.textSecondary),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'PHẦN CHIA TỪNG THÀNH VIÊN (${expense.splits.length})',
                                                    style: AppTextStyle.bold(
                                                      fontSize: AppFontSize.caption,
                                                      color: colors.textSecondary,
                                                      letterSpacing: 0.5,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
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
                                                                fontSize: AppFontSize.caption,
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
                                                          Wrap(
                                                            crossAxisAlignment: WrapCrossAlignment.center,
                                                            spacing: 6,
                                                            runSpacing: 2,
                                                            children: [
                                                              Text(
                                                                split.fullName,
                                                                style: AppTextStyle.bold(
                                                                  fontSize: AppFontSize.secondary,
                                                                  color: colors.textPrimary,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              if (isMe)
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                      horizontal: 6, vertical: 2),
                                                                  decoration: BoxDecoration(
                                                                    color: colors.surfaceMuted,
                                                                    borderRadius: BorderRadius.circular(6),
                                                                    border: Border.all(color: colors.cardBorder),
                                                                  ),
                                                                  child: Text(
                                                                    'Bạn',
                                                                    style: AppTextStyle.bold(
                                                                      fontSize: AppFontSize.caption,
                                                                      color: colors.textSecondary,
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (isPayer)
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                      horizontal: 6, vertical: 2),
                                                                  decoration: BoxDecoration(
                                                                    color: colors.expensePayerBadgeBg,
                                                                    borderRadius: BorderRadius.circular(6),
                                                                  ),
                                                                  child: Text(
                                                                    'Người trả',
                                                                    style: AppTextStyle.bold(
                                                                      fontSize: AppFontSize.caption,
                                                                      color: colors.expensePayerBadgeText,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            'Số tiền: ${CurrencyUtils.formatVnd(split.amountOwedVnd)}',
                                                            style: AppTextStyle.regular(
                                                              fontSize: AppFontSize.caption,
                                                              color: colors.textSecondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Status pill
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: status.resolveBgColor(colors),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          if (status == ExpenseSplitStatus.paid)
                                                            Icon(LucideIcons.check, size: 12, color: status.resolveTextColor(colors))
                                                          else if (status == ExpenseSplitStatus.unpaid)
                                                            Icon(LucideIcons.alertCircle, size: 12, color: status.resolveTextColor(colors))
                                                          else
                                                            Icon(LucideIcons.clock, size: 12, color: status.resolveTextColor(colors)),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            status.label,
                                                            style: AppTextStyle.bold(
                                                              fontSize: AppFontSize.caption,
                                                              color: status.resolveTextColor(colors),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (status != ExpenseSplitStatus.paid && !isPayer) ...[
                                                      const SizedBox(width: 8),
                                                      Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          borderRadius: BorderRadius.circular(12),
                                                          onTap: () {
                                                            AppSnackBar.showSuccess(
                                                              context,
                                                              'Đã gửi nhắc nhở thanh toán đến ${split.fullName}',
                                                            );
                                                          },
                                                          child: Container(
                                                            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                                            alignment: Alignment.center,
                                                            child: Icon(
                                                              LucideIcons.bell,
                                                              size: 18,
                                                              color: colors.textMuted,
                                                            ),
                                                          ),
                                                        ),
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

                                      // 5. Thẻ Hóa đơn / Chứng từ
                                      if (expense.receiptUrl != null && expense.receiptUrl!.isNotEmpty)
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
                                                        Icon(LucideIcons.receipt, size: 14, color: colors.textSecondary),
                                                        const SizedBox(width: 6),
                                                        Flexible(
                                                          child: Text(
                                                            'HÓA ĐƠN / CHỨNG TỪ',
                                                            style: AppTextStyle.bold(
                                                              fontSize: AppFontSize.caption,
                                                              color: colors.textSecondary,
                                                              letterSpacing: 0.5,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextButton.icon(
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                      minimumSize: const Size(48, 48),
                                                    ),
                                                    onPressed: () => ExpenseReceiptViewerDialog.show(
                                                      context,
                                                      receiptUrl: expense.receiptUrl!,
                                                      title: expense.title,
                                                    ),
                                                    icon: Icon(LucideIcons.zoomIn, size: 15, color: colors.expenseReceiptZoomText),
                                                    label: Text(
                                                      'Phóng to',
                                                      style: AppTextStyle.bold(
                                                        fontSize: AppFontSize.caption,
                                                        color: colors.expenseReceiptZoomText,
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
                                                      child: Text(
                                                        'Không thể tải ảnh hóa đơn',
                                                        style: AppTextStyle.regular(
                                                          fontSize: AppFontSize.caption,
                                                          color: colors.textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 14),

                                      // 6. Action buttons at bottom
                                      if (canEditOrDelete) ...[
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(48),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            side: BorderSide(color: colors.expenseActionEditBorder),
                                            backgroundColor: colors.expenseActionEditBg,
                                          ),
                                          onPressed: () => _handleEdit(context, expense),
                                          icon: Icon(LucideIcons.pencil, size: 16, color: colors.expenseActionEditText),
                                          label: Text(
                                            'Sửa thông tin khoản chi',
                                            style: AppTextStyle.bold(
                                              fontSize: AppFontSize.secondary,
                                              color: colors.expenseActionEditText,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(48),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            side: BorderSide(color: colors.expenseActionDeleteBorder),
                                            backgroundColor: colors.expenseActionDeleteBg,
                                          ),
                                          onPressed: () => _handleDelete(context, cubit),
                                          icon: Icon(LucideIcons.trash2, size: 16, color: colors.expenseActionDeleteText),
                                          label: Text(
                                            'Xóa khoản chi này',
                                            style: AppTextStyle.bold(
                                              fontSize: AppFontSize.secondary,
                                              color: colors.expenseActionDeleteText,
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
            ),
          );
        },
      ),
    );
  }
}
