import '../../data/models/group_member_models.dart';

enum GroupMembersStatus { initial, loading, success, failure }

class GroupMembersState {
  final GroupMembersStatus status;
  final List<GroupMemberSummaryModel> members;
  final List<GroupJoinRequestModel> pendingRequests;
  final int totalPendingRequests;
  final String searchQuery;
  final bool isSearching;
  final GroupMemberDetailModel? selectedMemberDetail;
  final bool isLoadingDetail;
  final bool isActionProcessing;
  final String? errorMessage;
  final String? successMessage;

  const GroupMembersState({
    this.status = GroupMembersStatus.initial,
    this.members = const [],
    this.pendingRequests = const [],
    this.totalPendingRequests = 0,
    this.searchQuery = '',
    this.isSearching = false,
    this.selectedMemberDetail,
    this.isLoadingDetail = false,
    this.isActionProcessing = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == GroupMembersStatus.loading;

  GroupMembersState copyWith({
    GroupMembersStatus? status,
    List<GroupMemberSummaryModel>? members,
    List<GroupJoinRequestModel>? pendingRequests,
    int? totalPendingRequests,
    String? searchQuery,
    bool? isSearching,
    GroupMemberDetailModel? selectedMemberDetail,
    bool clearSelectedDetail = false,
    bool? isLoadingDetail,
    bool? isActionProcessing,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return GroupMembersState(
      status: status ?? this.status,
      members: members ?? this.members,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      totalPendingRequests: totalPendingRequests ?? this.totalPendingRequests,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      selectedMemberDetail: clearSelectedDetail
          ? null
          : (selectedMemberDetail ?? this.selectedMemberDetail),
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isActionProcessing: isActionProcessing ?? this.isActionProcessing,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
