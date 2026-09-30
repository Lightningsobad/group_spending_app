import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../domain/repositories/groups_repository.dart';
import 'group_members_state.dart';

class GroupMembersCubit extends Cubit<GroupMembersState> {
  final int groupId;
  final bool isAdmin;
  final GroupsRepository groupsRepository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  Timer? _debounceTimer;
  int _searchRequestId = 0;

  GroupMembersCubit({
    required this.groupId,
    this.isAdmin = false,
    required this.groupsRepository,
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const GroupMembersState()) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    if (!isClosed) {
      loadMembers(silent: true);
      if (isAdmin) {
        loadPendingJoinRequests(silent: true);
      }
    }
  }

  Future<void> init() async {
    await loadMembers();
    if (isAdmin) {
      await loadPendingJoinRequests();
    }
  }

  Future<void> loadMembers({String? query, bool silent = false}) async {
    final currentReqId = ++_searchRequestId;
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;

    if (!silent) {
      emit(
        state.copyWith(
          status: GroupMembersStatus.loading,
          searchQuery: query ?? state.searchQuery,
          isSearching: query != null && query.trim().isNotEmpty,
          clearMessages: true,
        ),
      );
    }

    try {
      final members = await groupsRepository.getGroupMembers(
        groupId,
        name: query,
      );

      if (isClosed ||
          currentReqId != _searchRequestId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      emit(
        state.copyWith(
          status: GroupMembersStatus.success,
          members: members,
          searchQuery: query ?? state.searchQuery,
          isSearching: query != null && query.trim().isNotEmpty,
        ),
      );
    } on AppException catch (e) {
      if (isClosed || currentReqId != _searchRequestId) return;
      emit(
        state.copyWith(
          status: GroupMembersStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed || currentReqId != _searchRequestId) return;
      emit(
        state.copyWith(
          status: GroupMembersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      loadMembers(query: query.trim(), silent: false);
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    loadMembers(query: '', silent: false);
  }

  Future<void> loadPendingJoinRequests({bool silent = false}) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    try {
      final result = await groupsRepository.getPendingJoinRequests(groupId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          pendingRequests: result.requests,
          totalPendingRequests: result.totalRequests,
        ),
      );
    } catch (_) {
      // Ignore background pending requests failure
    }
  }

  Future<bool> reviewJoinRequest({
    required int requestId,
    required bool approved,
    bool includePastFundCollections = false,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionProcessing: true, clearMessages: true));
    try {
      await groupsRepository.reviewJoinRequest(
        requestId,
        approved: approved,
        includePastFundCollections: includePastFundCollections,
      );

      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionProcessing: false,
          successMessage: approved
              ? 'Đã duyệt thành viên vào nhóm!'
              : 'Đã từ chối yêu cầu gia nhập.',
        ),
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      await loadPendingJoinRequests(silent: true);
      if (approved) {
        await loadMembers(silent: true);
      }
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isActionProcessing: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isActionProcessing: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> loadMemberDetail(int targetUserId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isLoadingDetail: true, clearSelectedDetail: true));
    try {
      final detail = await groupsRepository.getMemberDetails(
        groupId,
        targetUserId,
      );
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          isLoadingDetail: false,
          selectedMemberDetail: detail,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingDetail: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingDetail: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> kickMember(int targetUserId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionProcessing: true, clearMessages: true));
    try {
      await groupsRepository.removeMember(groupId, targetUserId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      final updatedMembers =
          state.members.where((m) => m.userId != targetUserId).toList();
      emit(
        state.copyWith(
          isActionProcessing: false,
          members: updatedMembers,
          clearSelectedDetail: true,
          successMessage: 'Đã xóa thành viên khỏi nhóm thành công.',
        ),
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      await loadMembers(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isActionProcessing: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isActionProcessing: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> leaveGroup() async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionProcessing: true, clearMessages: true));
    try {
      await groupsRepository.leaveGroup(groupId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionProcessing: false,
          successMessage: 'Đã rời khỏi nhóm thành công.',
        ),
      );
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isActionProcessing: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isActionProcessing: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> transferOwnership(int newOwnerId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionProcessing: true, clearMessages: true));
    try {
      await groupsRepository.transferOwnership(groupId, newOwnerId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionProcessing: false,
          successMessage: 'Đã chuyển quyền Quản trị viên thành công.',
        ),
      );
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      await loadMembers(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isActionProcessing: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isActionProcessing: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    dataSyncCoordinator?.removeListener(_onDataSync);
    return super.close();
  }
}
