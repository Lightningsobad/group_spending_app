import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../groups/data/models/group_model.dart';
import '../../data/models/expense_enums.dart';
import '../cubit/expenses_cubit.dart';
import '../cubit/expenses_state.dart';
import '../screens/add_expense_screen.dart';
import '../screens/expense_detail_screen.dart';
import 'expense_card_widget.dart';

class GroupExpensesTabView extends StatefulWidget {
  final GroupModel group;

  const GroupExpensesTabView({
    super.key,
    required this.group,
  });

  @override
  State<GroupExpensesTabView> createState() => _GroupExpensesTabViewState();
}

class _GroupExpensesTabViewState extends State<GroupExpensesTabView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpensesCubit>().loadGroupExpenses(widget.group.id);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _navigateToAddExpense() {
    if (widget.group.isArchived) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhóm này đã được lưu trữ, không thể thêm khoản chi.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          group: widget.group,
        ),
      ),
    );
  }

  void _navigateToDetail(int expenseId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseDetailScreen(
          expenseId: expenseId,
          group: widget.group,
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required dynamic colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF14532D) : colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF14532D) : colors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.bold(
            fontSize: 12,
            color: isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<ExpensesCubit, ExpensesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<ExpensesCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.emerald,
            ),
          );
          context.read<ExpensesCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final expenses = state.expenses;
        final cubit = context.read<ExpensesCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Total Spending Card (Image 1)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TỔNG CHI TIÊU NHÓM',
                          style: AppTextStyle.bold(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyUtils.formatVnd(state.totalSpendingVnd),
                          style: AppTextStyle.bold(
                            fontSize: 22,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.expenseCount} hóa đơn phát sinh',
                          style: AppTextStyle.regular(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14532D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _navigateToAddExpense,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text(
                      'Thêm khoản chi',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Search Field
            Container(
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: cubit.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Tìm khoản chi theo tên...',
                  hintStyle: AppTextStyle.regular(fontSize: 13, color: colors.textMuted),
                  prefixIcon: Icon(LucideIcons.search, size: 18, color: colors.textMuted),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            cubit.onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Row 1: Time filter pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill(
                    label: 'Tất cả',
                    isSelected: state.timeFilter == ExpenseTimeFilter.all,
                    onTap: () => cubit.setTimeFilter(ExpenseTimeFilter.all),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Tháng này',
                    isSelected: state.timeFilter == ExpenseTimeFilter.thisMonth,
                    onTap: () => cubit.setTimeFilter(ExpenseTimeFilter.thisMonth),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Tháng trước',
                    isSelected: state.timeFilter == ExpenseTimeFilter.lastMonth,
                    onTap: () => cubit.setTimeFilter(ExpenseTimeFilter.lastMonth),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Quý này',
                    isSelected: state.timeFilter == ExpenseTimeFilter.thisQuarter,
                    onTap: () => cubit.setTimeFilter(ExpenseTimeFilter.thisQuarter),
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 4. Row 2: Category filter pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill(
                    label: 'Tất cả chủ đề (${state.expenseCount})',
                    isSelected: state.categoryFilter == ExpenseCategoryFilter.all,
                    onTap: () => cubit.setCategoryFilter(ExpenseCategoryFilter.all),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Ăn uống',
                    isSelected: state.categoryFilter == ExpenseCategoryFilter.food,
                    onTap: () => cubit.setCategoryFilter(ExpenseCategoryFilter.food),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Nhà ở & Điện nước',
                    isSelected: state.categoryFilter == ExpenseCategoryFilter.housing,
                    onTap: () => cubit.setCategoryFilter(ExpenseCategoryFilter.housing),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Di chuyển',
                    isSelected: state.categoryFilter == ExpenseCategoryFilter.transport,
                    onTap: () => cubit.setCategoryFilter(ExpenseCategoryFilter.transport),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Mua sắm',
                    isSelected: state.categoryFilter == ExpenseCategoryFilter.shopping,
                    onTap: () => cubit.setCategoryFilter(ExpenseCategoryFilter.shopping),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Giải trí',
                    isSelected: state.categoryFilter == ExpenseCategoryFilter.entertainment,
                    onTap: () => cubit.setCategoryFilter(ExpenseCategoryFilter.entertainment),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Siêu thị',
                    isSelected: state.categoryFilter == ExpenseCategoryFilter.groceries,
                    onTap: () => cubit.setCategoryFilter(ExpenseCategoryFilter.groceries),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Y tế',
                    isSelected: state.categoryFilter == ExpenseCategoryFilter.healthcare,
                    onTap: () => cubit.setCategoryFilter(ExpenseCategoryFilter.healthcare),
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 5. Row 3: Payer/Status filter pills + Counter
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill(
                          label: 'Tất cả',
                          isSelected: state.payerFilter == ExpensePayerFilter.all,
                          onTap: () => cubit.setPayerFilter(ExpensePayerFilter.all),
                          colors: colors,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          label: 'Của tôi',
                          isSelected: state.payerFilter == ExpensePayerFilter.paidByMe,
                          onTap: () => cubit.setPayerFilter(ExpensePayerFilter.paidByMe),
                          colors: colors,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          label: 'Chờ quyết toán',
                          isSelected: state.payerFilter == ExpensePayerFilter.paidByOthers,
                          onTap: () => cubit.setPayerFilter(ExpensePayerFilter.paidByOthers),
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  '${expenses.length} / ${state.expenseCount} khoản chi',
                  style: AppTextStyle.bold(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 6. Expense List / Loading / Empty
            if (state.isLoading && expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.emerald),
                ),
              )
            else if (expenses.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Column(
                  children: [
                    Icon(LucideIcons.receipt, size: 48, color: colors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có khoản chi tiêu nào',
                      style: AppTextStyle.bold(fontSize: 15, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bấm nút bên dưới để tạo khoản chi đầu tiên cho nhóm.',
                      style: AppTextStyle.regular(fontSize: 12, color: colors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14532D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _navigateToAddExpense,
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Thêm khoản chi mới'),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return ExpenseCardWidget(
                    expense: expense,
                    onTap: () => _navigateToDetail(expense.id),
                    onReceiptTap: () {
                      _navigateToDetail(expense.id);
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
