import '../../../groups/data/models/group_summary_model.dart';
import '../../domain/entities/personal_overview_entity.dart';

enum AnalyticsTabStatus { initial, loading, success, failure }

class AnalyticsTabState {
  final AnalyticsTabStatus status;
  final bool isRefreshing;
  final PersonalOverviewEntity overview;
  final List<GroupSummaryModel> groups;
  final String filter; // 'ALL', 'ACTIVE', 'ARCHIVED'
  final String searchQuery;
  final int? totalAllCount;
  final int? totalActiveCount;
  final int? totalArchivedCount;
  final String? errorMessage;

  const AnalyticsTabState({
    this.status = AnalyticsTabStatus.initial,
    this.isRefreshing = false,
    this.overview = const PersonalOverviewEntity.empty(),
    this.groups = const [],
    this.filter = 'ALL',
    this.searchQuery = '',
    this.totalAllCount,
    this.totalActiveCount,
    this.totalArchivedCount,
    this.errorMessage,
  });

  bool get isLoading => status == AnalyticsTabStatus.loading;
  bool get isSuccess => status == AnalyticsTabStatus.success;
  bool get isFailure => status == AnalyticsTabStatus.failure;

  List<GroupSummaryModel> get filteredGroups {
    if (searchQuery.trim().isEmpty) return groups;
    final query = searchQuery.trim().toLowerCase();
    return groups.where((g) {
      final nameMatches = g.name.toLowerCase().contains(query);
      final catMatches = g.category?.toLowerCase().contains(query) ?? false;
      return nameMatches || catMatches;
    }).toList();
  }

  int get allCount => totalAllCount ?? (filter == 'ALL' ? groups.length : groups.length);
  int get activeCount => totalActiveCount ?? (filter == 'ACTIVE' ? groups.length : groups.where((g) => g.status?.toUpperCase() != 'ARCHIVED').length);
  int get archivedCount => totalArchivedCount ?? (filter == 'ARCHIVED' ? groups.length : groups.where((g) => g.status?.toUpperCase() == 'ARCHIVED').length);

  AnalyticsTabState copyWith({
    AnalyticsTabStatus? status,
    bool? isRefreshing,
    PersonalOverviewEntity? overview,
    List<GroupSummaryModel>? groups,
    String? filter,
    String? searchQuery,
    int? totalAllCount,
    int? totalActiveCount,
    int? totalArchivedCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnalyticsTabState(
      status: status ?? this.status,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      overview: overview ?? this.overview,
      groups: groups ?? this.groups,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      totalAllCount: totalAllCount ?? this.totalAllCount,
      totalActiveCount: totalActiveCount ?? this.totalActiveCount,
      totalArchivedCount: totalArchivedCount ?? this.totalArchivedCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
