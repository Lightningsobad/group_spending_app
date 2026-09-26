import '../../../debts/data/models/debt_overview_model.dart';
import '../../../groups/data/models/group_model.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState {
  final DashboardStatus status;
  final DebtOverviewModel debtOverview;
  final List<GroupModel> groups;
  final String? errorMessage;
  final bool isRefreshing;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.debtOverview = const DebtOverviewModel(),
    this.groups = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  bool get isLoading => status == DashboardStatus.loading;
  bool get isSuccess => status == DashboardStatus.success;

  DashboardState copyWith({
    DashboardStatus? status,
    DebtOverviewModel? debtOverview,
    List<GroupModel>? groups,
    String? errorMessage,
    bool? isRefreshing,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      debtOverview: debtOverview ?? this.debtOverview,
      groups: groups ?? this.groups,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
