import '../../../groups/data/models/group_model.dart';
import '../../domain/entities/personal_overview_entity.dart';

enum AnalyticsTabStatus { initial, loading, success, failure }

class AnalyticsTabState {
  final AnalyticsTabStatus status;
  final bool isRefreshing;
  final PersonalOverviewEntity overview;
  final List<GroupModel> groups;
  final String filter; // 'ALL', 'ACTIVE', 'ARCHIVED'
  final String searchQuery;
  final String? errorMessage;

  const AnalyticsTabState({
    this.status = AnalyticsTabStatus.initial,
    this.isRefreshing = false,
    this.overview = const PersonalOverviewEntity.empty(),
    this.groups = const [],
    this.filter = 'ALL',
    this.searchQuery = '',
    this.errorMessage,
  });

  bool get isLoading => status == AnalyticsTabStatus.loading;
  bool get isSuccess => status == AnalyticsTabStatus.success;
  bool get isFailure => status == AnalyticsTabStatus.failure;

  List<GroupModel> get filteredGroups {
    return groups.where((g) {
      if (filter == 'ACTIVE' && g.isArchived) return false;
      if (filter == 'ARCHIVED' && !g.isArchived) return false;
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final nameMatches = g.name.toLowerCase().contains(query);
        final catMatches = g.category.toLowerCase().contains(query);
        return nameMatches || catMatches;
      }
      return true;
    }).toList();
  }

  int get allCount => groups.length;
  int get activeCount => groups.where((g) => !g.isArchived).length;
  int get archivedCount => groups.where((g) => g.isArchived).length;

  AnalyticsTabState copyWith({
    AnalyticsTabStatus? status,
    bool? isRefreshing,
    PersonalOverviewEntity? overview,
    List<GroupModel>? groups,
    String? filter,
    String? searchQuery,
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
