import '../../domain/entities/fund_entities.dart';
import '../../domain/entities/fund_enums.dart';

enum FundsStatus { initial, loading, success, failure }

class FundsState {
  final FundsStatus status;
  final int? currentGroupId;
  final GroupFundsOverviewEntity? overview;
  final String searchQuery;
  final FundCollectionStatus? selectedStatusFilter; // null = Tất cả
  final FundTimeFilter selectedTimeFilter;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const FundsState({
    this.status = FundsStatus.initial,
    this.currentGroupId,
    this.overview,
    this.searchQuery = '',
    this.selectedStatusFilter,
    this.selectedTimeFilter = FundTimeFilter.all,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == FundsStatus.loading;
  bool get isSuccess => status == FundsStatus.success;
  bool get isFailure => status == FundsStatus.failure;

  int get totalFundsCount => overview?.funds.length ?? 0;
  int get collectingCount =>
      overview?.funds.where((f) => f.isCollecting).length ?? 0;
  int get completedCount =>
      overview?.funds.where((f) => f.isCompleted).length ?? 0;

  List<FundCollectionItemEntity> get filteredFunds {
    final list = overview?.funds ?? const [];
    return list.where((f) {
      if (selectedStatusFilter != null && f.status != selectedStatusFilter) {
        return false;
      }
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        if (!f.name.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  FundsState copyWith({
    FundsStatus? status,
    int? currentGroupId,
    GroupFundsOverviewEntity? overview,
    String? searchQuery,
    FundCollectionStatus? selectedStatusFilter,
    bool clearStatusFilter = false,
    FundTimeFilter? selectedTimeFilter,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return FundsState(
      status: status ?? this.status,
      currentGroupId: currentGroupId ?? this.currentGroupId,
      overview: overview ?? this.overview,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: clearStatusFilter
          ? null
          : (selectedStatusFilter ?? this.selectedStatusFilter),
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
