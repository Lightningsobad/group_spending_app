import 'dart:io';
import '../../../groups/data/models/group_model.dart';
import '../../data/models/expense_enums.dart';

enum ExpenseFormStatus { initial, submitting, success, failure }

class ExpenseFormState {
  final ExpenseFormStatus status;
  final int groupId;
  final String groupName;
  final String amountDigits; // e.g. "320000"
  final String title;
  final String? notes;
  final ExpenseCategoryType category;
  final int paidByUserId;
  final SplitOption splitOption;
  final Set<int> selectedParticipantUserIds;
  final List<GroupMemberModel> members;
  final File? receiptFile;
  final String? receiptUrl;
  final bool isScanningReceipt;
  final String? scanConfidence;
  final String? expenseDate;
  final bool isEditMode;
  final int? expenseIdToEdit;
  final String? errorMessage;
  final String? successMessage;

  const ExpenseFormState({
    this.status = ExpenseFormStatus.initial,
    required this.groupId,
    this.groupName = '',
    this.amountDigits = '0',
    this.title = '',
    this.notes,
    this.category = ExpenseCategoryType.food,
    this.paidByUserId = 0,
    this.splitOption = SplitOption.equalAll,
    this.selectedParticipantUserIds = const {},
    this.members = const [],
    this.receiptFile,
    this.receiptUrl,
    this.isScanningReceipt = false,
    this.scanConfidence,
    this.expenseDate,
    this.isEditMode = false,
    this.expenseIdToEdit,
    this.errorMessage,
    this.successMessage,
  });

  bool get isSubmitting => status == ExpenseFormStatus.submitting;

  num get totalAmountVnd {
    final parsed = num.tryParse(amountDigits);
    return parsed ?? 0;
  }

  num get totalAmountK => (totalAmountVnd / 1000);

  bool get isSplitAll => splitOption == SplitOption.equalAll;

  List<GroupMemberModel> get activeSplitMembers {
    if (isSplitAll) return members;
    return members.where((m) => selectedParticipantUserIds.contains(m.userId)).toList();
  }

  int get selectedMembersCount => activeSplitMembers.length;

  num get perPersonShareVnd {
    final count = selectedMembersCount;
    if (count <= 0) return 0;
    return (totalAmountVnd / count).round();
  }

  num getMemberShareVnd(int memberUserId) {
    final active = activeSplitMembers;
    final count = active.length;
    if (count <= 0) return 0;

    final index = active.indexWhere((m) => m.userId == memberUserId);
    if (index == -1) return 0;

    final basic = (totalAmountVnd ~/ count);
    final remainder = (totalAmountVnd % count).toInt();

    return index < remainder ? basic + 1 : basic;
  }

  ExpenseFormState copyWith({
    ExpenseFormStatus? status,
    int? groupId,
    String? groupName,
    String? amountDigits,
    String? title,
    String? notes,
    ExpenseCategoryType? category,
    int? paidByUserId,
    SplitOption? splitOption,
    Set<int>? selectedParticipantUserIds,
    List<GroupMemberModel>? members,
    File? receiptFile,
    String? receiptUrl,
    bool clearReceipt = false,
    bool? isScanningReceipt,
    String? scanConfidence,
    String? expenseDate,
    bool? isEditMode,
    int? expenseIdToEdit,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ExpenseFormState(
      status: status ?? this.status,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      amountDigits: amountDigits ?? this.amountDigits,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      paidByUserId: paidByUserId ?? this.paidByUserId,
      splitOption: splitOption ?? this.splitOption,
      selectedParticipantUserIds: selectedParticipantUserIds ?? this.selectedParticipantUserIds,
      members: members ?? this.members,
      receiptFile: clearReceipt ? null : (receiptFile ?? this.receiptFile),
      receiptUrl: clearReceipt ? null : (receiptUrl ?? this.receiptUrl),
      isScanningReceipt: isScanningReceipt ?? this.isScanningReceipt,
      scanConfidence: clearReceipt ? null : (scanConfidence ?? this.scanConfidence),
      expenseDate: expenseDate ?? this.expenseDate,
      isEditMode: isEditMode ?? this.isEditMode,
      expenseIdToEdit: expenseIdToEdit ?? this.expenseIdToEdit,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
