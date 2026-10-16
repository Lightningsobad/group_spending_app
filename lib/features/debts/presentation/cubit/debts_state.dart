import '../../../groups/data/models/group_model.dart';
import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/debt_overview_entity.dart';
import '../../domain/entities/group_debt_entity.dart';

enum DebtsStatus { initial, loading, success, failure }

class DebtsState {
  final DebtsStatus status;
  final DebtOverviewEntity? overview;
  final List<GroupModel> userGroups;
  final DebtOverviewFilter activeFilter;
  final String searchQuery;
  final int? selectedGroupId;
  final String? selectedGroupName;
  final int activeDetailTab; // 0: Nợ tối giản, 1: Nợ thực tế
  final GroupSimplifiedDebtsEntity? simplifiedDebts;
  final GroupActualDebtsEntity? actualDebts;
  final String? actualDebtStatusFilter;
  final bool isDetailLoading;
  final bool isActionSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const DebtsState({
    this.status = DebtsStatus.initial,
    this.overview,
    this.userGroups = const [],
    this.activeFilter = DebtOverviewFilter.all,
    this.searchQuery = '',
    this.selectedGroupId,
    this.selectedGroupName,
    this.activeDetailTab = 0,
    this.simplifiedDebts,
    this.actualDebts,
    this.actualDebtStatusFilter,
    this.isDetailLoading = false,
    this.isActionSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == DebtsStatus.loading;
  bool get isSuccess => status == DebtsStatus.success;
  bool get isFailure => status == DebtsStatus.failure;

  int get totalGroupCount => overview?.groupBalances.length ?? 0;

  int get hasDebtGroupCount =>
      overview?.groupBalances
          .where((e) => e.netBalanceVnd != 0 || e.pendingDebtCount > 0)
          .length ??
      0;

  int get settledGroupCount =>
      overview?.groupBalances
          .where((e) => e.netBalanceVnd == 0 && e.pendingDebtCount == 0)
          .length ??
      0;

  List<GroupDebtBalanceEntity> get filteredGroupBalances {
    final list = overview?.groupBalances ?? const [];
    return list.where((item) {
      // 1. Filter by category/state chip
      switch (activeFilter) {
        case DebtOverviewFilter.hasDebt:
          if (item.netBalanceVnd == 0 && item.pendingDebtCount == 0) {
            return false;
          }
          break;
        case DebtOverviewFilter.settled:
          if (item.netBalanceVnd != 0 || item.pendingDebtCount > 0) {
            return false;
          }
          break;
        case DebtOverviewFilter.all:
          break;
      }

      // 2. Filter by search query
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        if (!item.groupName.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  DebtsState copyWith({
    DebtsStatus? status,
    DebtOverviewEntity? overview,
    List<GroupModel>? userGroups,
    DebtOverviewFilter? activeFilter,
    String? searchQuery,
    int? selectedGroupId,
    String? selectedGroupName,
    int? activeDetailTab,
    GroupSimplifiedDebtsEntity? simplifiedDebts,
    GroupActualDebtsEntity? actualDebts,
    String? actualDebtStatusFilter,
    bool? isDetailLoading,
    bool? isActionSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedGroup = false,
    bool clearGroupDetails = false,
    bool clearMessages = false,
  }) {
    return DebtsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      userGroups: userGroups ?? this.userGroups,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGroupId:
          clearSelectedGroup ? null : (selectedGroupId ?? this.selectedGroupId),
      selectedGroupName: clearSelectedGroup
          ? null
          : (selectedGroupName ?? this.selectedGroupName),
      activeDetailTab: activeDetailTab ?? this.activeDetailTab,
      simplifiedDebts:
          clearGroupDetails ? null : (simplifiedDebts ?? this.simplifiedDebts),
      actualDebts:
          clearGroupDetails ? null : (actualDebts ?? this.actualDebts),
      actualDebtStatusFilter:
          actualDebtStatusFilter ?? this.actualDebtStatusFilter,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      isActionSubmitting: isActionSubmitting ?? this.isActionSubmitting,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
