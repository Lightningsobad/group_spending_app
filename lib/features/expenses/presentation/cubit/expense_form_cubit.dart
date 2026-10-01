import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../groups/data/models/group_model.dart';
import '../../data/models/expense_enums.dart';
import '../../data/models/expense_models.dart';
import '../../domain/repositories/expenses_repository.dart';
import 'expense_form_state.dart';

class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  final ExpensesRepository _repository;
  final DataSyncCoordinator? dataSyncCoordinator;

  static const num maxAllowedAmountVnd = 1000000000; // 1 tỷ VNĐ

  ExpenseFormCubit(
    this._repository, {
    required int groupId,
    String groupName = '',
    List<GroupMemberModel> members = const [],
    int currentUserId = 0,
    ExpenseDetailModel? expenseToEdit,
    this.dataSyncCoordinator,
  }) : super(
          ExpenseFormState(
            groupId: groupId,
            groupName: groupName,
            members: members,
            paidByUserId: expenseToEdit?.paidByUserId ??
                (members.any((m) => m.userId == currentUserId)
                    ? currentUserId
                    : (members.isNotEmpty ? members.first.userId : currentUserId)),
            amountDigits: expenseToEdit != null
                ? expenseToEdit.totalAmountVnd.round().toString()
                : '0',
            title: expenseToEdit?.title ?? '',
            notes: expenseToEdit?.notes,
            category: expenseToEdit != null
                ? expenseToEdit.categoryType
                : ExpenseCategoryType.food,
            splitOption: (expenseToEdit != null &&
                    expenseToEdit.splits.length < members.length &&
                    expenseToEdit.splits.isNotEmpty)
                ? SplitOption.equalSelected
                : SplitOption.equalAll,
            selectedParticipantUserIds: expenseToEdit != null
                ? expenseToEdit.splits.map((s) => s.userId).toSet()
                : members.map((m) => m.userId).toSet(),
            isEditMode: expenseToEdit != null,
            expenseIdToEdit: expenseToEdit?.id,
          ),
        );

  void onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    var current = state.amountDigits;
    if (current == '0') {
      current = digit;
    } else {
      current = current + digit;
    }

    final parsed = num.tryParse(current) ?? 0;
    if (parsed > maxAllowedAmountVnd) {
      emit(state.copyWith(
        amountDigits: maxAllowedAmountVnd.toString(),
        errorMessage: 'Số tiền tối đa cho một khoản là 1 tỷ VNĐ',
      ));
      return;
    }

    emit(state.copyWith(amountDigits: current, clearMessages: true));
  }

  void onTripleZeroPressed() {
    HapticFeedback.lightImpact();
    var current = state.amountDigits;
    if (current == '0' || current.isEmpty) return;

    current = '${current}000';
    final parsed = num.tryParse(current) ?? 0;
    if (parsed > maxAllowedAmountVnd) {
      emit(state.copyWith(
        amountDigits: maxAllowedAmountVnd.toString(),
        errorMessage: 'Số tiền tối đa cho một khoản là 1 tỷ VNĐ',
      ));
      return;
    }

    emit(state.copyWith(amountDigits: current, clearMessages: true));
  }

  void onDeletePressed() {
    HapticFeedback.lightImpact();
    var current = state.amountDigits;
    if (current.length <= 1) {
      current = '0';
    } else {
      current = current.substring(0, current.length - 1);
    }
    emit(state.copyWith(amountDigits: current, clearMessages: true));
  }

  void onClearPressed() {
    HapticFeedback.mediumImpact();
    emit(state.copyWith(amountDigits: '0', clearMessages: true));
  }

  void setTitle(String value) {
    emit(state.copyWith(title: value, clearMessages: true));
  }

  void setNotes(String? value) {
    emit(state.copyWith(notes: value, clearMessages: true));
  }

  void setCategory(ExpenseCategoryType cat) {
    HapticFeedback.selectionClick();
    emit(state.copyWith(category: cat, clearMessages: true));
  }

  void updateGroup(int groupId, String groupName) {
    emit(state.copyWith(groupId: groupId, groupName: groupName, clearMessages: true));
  }

  void updateMembers(List<GroupMemberModel> members, {int? currentUserId}) {
    final effectiveCurrentUserId = currentUserId ?? 0;
    final int newPaidByUserId;
    if (state.paidByUserId != 0 && members.any((m) => m.userId == state.paidByUserId)) {
      newPaidByUserId = state.paidByUserId;
    } else if (members.any((m) => m.userId == effectiveCurrentUserId)) {
      newPaidByUserId = effectiveCurrentUserId;
    } else if (members.isNotEmpty) {
      newPaidByUserId = members.first.userId;
    } else {
      newPaidByUserId = 0;
    }

    final Set<int> newSelected;
    if (state.splitOption == SplitOption.equalAll || state.selectedParticipantUserIds.isEmpty) {
      newSelected = members.map((m) => m.userId).toSet();
    } else {
      final availableIds = members.map((m) => m.userId).toSet();
      newSelected = state.selectedParticipantUserIds.intersection(availableIds);
      if (newSelected.isEmpty && members.isNotEmpty) {
        newSelected.addAll(availableIds);
      }
    }

    emit(state.copyWith(
      members: members,
      paidByUserId: newPaidByUserId,
      selectedParticipantUserIds: newSelected,
      clearMessages: true,
    ));
  }

  void setPayer(int userId) {
    emit(state.copyWith(paidByUserId: userId, clearMessages: true));
  }

  void setSplitOption(SplitOption option) {
    emit(state.copyWith(splitOption: option, clearMessages: true));
  }

  void toggleParticipant(int userId) {
    final updated = Set<int>.from(state.selectedParticipantUserIds);
    if (updated.contains(userId)) {
      updated.remove(userId);
    } else {
      updated.add(userId);
    }

    final newOption = updated.length == state.members.length
        ? SplitOption.equalAll
        : SplitOption.equalSelected;

    emit(state.copyWith(
      selectedParticipantUserIds: updated,
      splitOption: newOption,
      clearMessages: true,
    ));
  }

  void selectAllParticipants() {
    final all = state.members.map((m) => m.userId).toSet();
    emit(state.copyWith(
      selectedParticipantUserIds: all,
      splitOption: SplitOption.equalAll,
      clearMessages: true,
    ));
  }

  void deselectAllParticipants() {
    emit(state.copyWith(
      selectedParticipantUserIds: <int>{},
      splitOption: SplitOption.equalSelected,
      clearMessages: true,
    ));
  }

  void setReceiptFile(File? file) {
    emit(state.copyWith(receiptFile: file, clearMessages: true));
  }

  void removeReceiptFile() {
    emit(state.copyWith(clearReceipt: true, clearMessages: true));
  }

  Future<bool> submitExpense() async {
    // 1. Validation
    if (state.title.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập tên khoản chi'));
      return false;
    }
    if (state.totalAmountVnd < 1000) {
      emit(state.copyWith(errorMessage: 'Số tiền tối thiểu là 1.000 VNĐ (1k)'));
      return false;
    }
    if (state.totalAmountVnd > maxAllowedAmountVnd) {
      emit(state.copyWith(errorMessage: 'Số tiền tối đa là 1 tỷ VNĐ (1.000.000k)'));
      return false;
    }
    if (state.paidByUserId == 0) {
      emit(state.copyWith(errorMessage: 'Vui lòng chọn người thanh toán'));
      return false;
    }
    if (state.splitOption == SplitOption.equalSelected &&
        state.selectedParticipantUserIds.isEmpty) {
      emit(state.copyWith(errorMessage: 'Vui lòng chọn ít nhất một thành viên để chia tiền'));
      return false;
    }

    emit(state.copyWith(status: ExpenseFormStatus.submitting, clearMessages: true));

    final nowStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      if (state.isEditMode && state.expenseIdToEdit != null) {
        final updateReq = UpdateExpenseRequest(
          title: state.title.trim(),
          totalAmount: state.totalAmountK,
          paidByUserId: state.paidByUserId,
          expenseDate: nowStr,
          notes: state.notes,
          category: state.category.apiValue,
          splitOption: state.splitOption.key,
          participantUserIds: state.splitOption == SplitOption.equalSelected
              ? state.selectedParticipantUserIds.toList()
              : null,
        );

        await _repository.updateExpense(
          state.expenseIdToEdit!,
          updateReq,
          receiptFile: state.receiptFile,
        );
      } else {
        final createReq = CreateExpenseRequest(
          title: state.title.trim(),
          totalAmount: state.totalAmountK,
          paidByUserId: state.paidByUserId,
          expenseDate: nowStr,
          notes: state.notes,
          category: state.category.apiValue,
          splitOption: state.splitOption.key,
          participantUserIds: state.splitOption == SplitOption.equalSelected
              ? state.selectedParticipantUserIds.toList()
              : null,
        );

        await _repository.createExpense(
          state.groupId,
          createReq,
          receiptFile: state.receiptFile,
        );
      }

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.all);

      if (isClosed) return true;
      emit(state.copyWith(
        status: ExpenseFormStatus.success,
        successMessage: state.isEditMode
            ? 'Cập nhật khoản chi thành công'
            : 'Tạo khoản chi tiêu thành công',
      ));
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: ExpenseFormStatus.failure,
        errorMessage: e.message,
      ));
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: ExpenseFormStatus.failure,
        errorMessage: 'Lỗi khi lưu khoản chi: $e',
      ));
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }
}
