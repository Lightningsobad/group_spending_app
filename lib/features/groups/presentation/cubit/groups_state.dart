import '../../data/models/group_model.dart';

enum GroupsStatus { initial, loading, success, failure }

class GroupsState {
  final GroupsStatus status;
  final List<GroupModel> groups;
  final String activeFilter; // 'ALL', 'ACTIVE', 'ARCHIVED', 'ADMIN'
  final String searchQuery;
  final GroupModel? selectedGroup;
  final bool isActionLoading;
  final String? errorMessage;
  final String? successMessage;

  const GroupsState({
    this.status = GroupsStatus.initial,
    this.groups = const [],
    this.activeFilter = 'ALL',
    this.searchQuery = '',
    this.selectedGroup,
    this.isActionLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == GroupsStatus.loading;
  bool get isSuccess => status == GroupsStatus.success;

  int get totalCount => groups.length;
  int get activeCount => groups.where((g) => g.isActive).length;
  int get archivedCount => groups.where((g) => g.isArchived).length;
  int get adminCount => groups.where((g) => g.isAdmin).length;

  List<GroupModel> get filteredGroups {
    var result = groups;

    // Apply active filter
    switch (activeFilter) {
      case 'ACTIVE':
        result = result.where((g) => g.isActive).toList();
        break;
      case 'ARCHIVED':
        result = result.where((g) => g.isArchived).toList();
        break;
      case 'ADMIN':
        result = result.where((g) => g.isAdmin).toList();
        break;
      case 'ALL':
      default:
        break;
    }

    // Apply search query if provided
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result.where((g) {
        final matchName = g.name.toLowerCase().contains(query);
        final matchDesc = (g.description ?? '').toLowerCase().contains(query);
        final matchCategory = g.category.toLowerCase().contains(query);
        return matchName || matchDesc || matchCategory;
      }).toList();
    }

    return result;
  }

  GroupsState copyWith({
    GroupsStatus? status,
    List<GroupModel>? groups,
    String? activeFilter,
    String? searchQuery,
    GroupModel? selectedGroup,
    bool? isActionLoading,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedGroup = false,
    bool clearMessages = false,
  }) {
    return GroupsState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGroup: clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
