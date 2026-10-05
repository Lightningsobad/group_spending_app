import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../data/models/group_model.dart';
import '../../domain/repositories/groups_repository.dart';
import 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupsRepository _repository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  GroupsCubit(
    this._repository, {
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const GroupsState());

  void reset() {
    emit(const GroupsState());
  }

  Future<void> loadGroups({bool silent = false}) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    if (!silent) {
      emit(state.copyWith(status: GroupsStatus.loading, clearMessages: true));
    }
    try {
      final groups = await _repository.getMyGroups();
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: GroupsStatus.success,
          groups: groups,
          clearMessages: !silent,
        ),
      );
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: GroupsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: GroupsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setFilter(String filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void setCategory(String category) {
    emit(state.copyWith(activeCategory: category));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<GroupModel?> loadGroupDetails(int groupId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    try {
      final detail = await _repository.getGroupDetails(groupId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return null;
      }
      emit(state.copyWith(selectedGroup: detail));
      return detail;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return null;
      }
      emit(state.copyWith(errorMessage: e.message));
      return null;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return null;
      }
      emit(state.copyWith(errorMessage: e.toString()));
      return null;
    }
  }

  Future<bool> createGroup({
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      final newGroup = await _repository.createGroup(
        name: name,
        description: description,
        category: category,
        defaultCurrency: defaultCurrency,
      );
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      final updatedList = [newGroup, ...state.groups];
      emit(
        state.copyWith(
          isActionLoading: false,
          groups: updatedList,
          successMessage: 'Tạo nhóm "${newGroup.name}" thành công!',
        ),
      );
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> updateGroup(
    int groupId, {
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      final updatedGroup = await _repository.updateGroup(
        groupId,
        name: name,
        description: description,
        category: category,
        defaultCurrency: defaultCurrency,
      );
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      final updatedList = state.groups.map((g) {
        return g.id == groupId ? updatedGroup : g;
      }).toList();

      emit(
        state.copyWith(
          isActionLoading: false,
          groups: updatedList,
          selectedGroup: updatedGroup,
          successMessage: 'Cập nhật nhóm thành công!',
        ),
      );
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> archiveGroup(int groupId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repository.archiveGroup(groupId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      final updatedList = state.groups.map((g) {
        return g.id == groupId ? g.copyWith(status: 'ARCHIVED') : g;
      }).toList();

      emit(
        state.copyWith(
          isActionLoading: false,
          groups: updatedList,
          successMessage: 'Nhóm đã được chuyển sang chế độ lưu trữ.',
        ),
      );
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> deleteGroup(int groupId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repository.deleteGroup(groupId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      final updatedList = state.groups.where((g) => g.id != groupId).toList();
      emit(
        state.copyWith(
          isActionLoading: false,
          groups: updatedList,
          clearSelectedGroup: true,
          successMessage: 'Xóa nhóm thành công.',
        ),
      );
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> joinGroup(String inviteCode) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repository.joinGroup(inviteCode);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          successMessage: 'Tham gia nhóm thành công!',
        ),
      );
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.groups);
      await loadGroups(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }
}
