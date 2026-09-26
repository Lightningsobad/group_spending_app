import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/domain/repositories/groups_repository.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_state.dart';

class FakeGroupsRepo implements GroupsRepository {
  List<GroupModel> groups = [
    const GroupModel(
      id: 1,
      name: 'Chung cư Sunrise Room',
      category: 'Apartment',
      status: 'ACTIVE',
      role: 'ADMIN',
      ownerId: 1,
      userBalance: 2450000,
    ),
    const GroupModel(
      id: 2,
      name: 'Đội Cầu Lông Ba Đình',
      category: 'Sport & Clubs',
      status: 'ACTIVE',
      role: 'MEMBER',
      ownerId: 3,
      userBalance: -450000,
    ),
    const GroupModel(
      id: 3,
      name: 'Đi phượt Đà Lạt 2024',
      category: 'Travel & Trip',
      status: 'ARCHIVED',
      role: 'ADMIN',
      ownerId: 1,
      userBalance: 0,
    ),
  ];
  AppException? exception;
  Duration delay = Duration.zero;

  @override
  Future<List<GroupModel>> getMyGroups({String? filter, String? search}) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (exception != null) throw exception!;
    return groups;
  }

  @override
  Future<GroupModel> getGroupDetails(int groupId) async {
    return groups.firstWhere((g) => g.id == groupId);
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) async {
    if (exception != null) throw exception!;
    final newGroup = GroupModel(
      id: 99,
      name: name,
      description: description,
      category: category ?? 'Other',
      role: 'ADMIN',
      ownerId: 1,
    );
    groups.add(newGroup);
    return newGroup;
  }

  @override
  Future<GroupModel> updateGroup(
    int groupId, {
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) async {
    if (exception != null) throw exception!;
    final index = groups.indexWhere((g) => g.id == groupId);
    final updated = groups[index].copyWith(name: name, description: description);
    groups[index] = updated;
    return updated;
  }

  @override
  Future<void> archiveGroup(int groupId) async {
    if (exception != null) throw exception!;
    final index = groups.indexWhere((g) => g.id == groupId);
    groups[index] = groups[index].copyWith(status: 'ARCHIVED');
  }

  @override
  Future<void> deleteGroup(int groupId) async {
    if (exception != null) throw exception!;
    groups.removeWhere((g) => g.id == groupId);
  }

  @override
  Future<void> joinGroup(String inviteCode) async {
    if (exception != null) throw exception!;
    if (inviteCode == 'INVALID') {
      throw const AppException(message: 'Mã mời không tồn tại');
    }
  }
}

void main() {
  group('GroupsCubit Tests', () {
    late FakeGroupsRepo repo;
    late GroupsCubit cubit;

    setUp(() {
      repo = FakeGroupsRepo();
      cubit = GroupsCubit(repo);
    });

    tearDown(() {
      cubit.close();
    });

    test('loadGroups populates groups list and counts', () async {
      await cubit.loadGroups();

      expect(cubit.state.status, GroupsStatus.success);
      expect(cubit.state.totalCount, 3);
      expect(cubit.state.activeCount, 2);
      expect(cubit.state.archivedCount, 1);
      expect(cubit.state.adminCount, 2);
    });

    test('filter works correctly for ACTIVE, ARCHIVED, ADMIN', () async {
      await cubit.loadGroups();

      cubit.setFilter('ACTIVE');
      expect(cubit.state.filteredGroups, hasLength(2));

      cubit.setFilter('ARCHIVED');
      expect(cubit.state.filteredGroups, hasLength(1));
      expect(cubit.state.filteredGroups.first.name, 'Đi phượt Đà Lạt 2024');

      cubit.setFilter('ADMIN');
      expect(cubit.state.filteredGroups, hasLength(2));
    });

    test('search filters groups by keyword', () async {
      await cubit.loadGroups();

      cubit.setSearchQuery('Cầu Lông');
      expect(cubit.state.filteredGroups, hasLength(1));
      expect(cubit.state.filteredGroups.first.name, 'Đội Cầu Lông Ba Đình');
    });

    test('createGroup creates group and adds to state', () async {
      await cubit.loadGroups();

      final success = await cubit.createGroup(
        name: 'Nhóm Mới Tạo',
        category: 'Works & Project',
      );

      expect(success, isTrue);
      expect(cubit.state.groups.any((g) => g.name == 'Nhóm Mới Tạo'), isTrue);
      expect(cubit.state.successMessage, contains('thành công'));
    });

    test('updateGroup modifies group in state', () async {
      await cubit.loadGroups();

      final success = await cubit.updateGroup(1, name: 'Sunrise 402 Updated');

      expect(success, isTrue);
      expect(cubit.state.groups.firstWhere((g) => g.id == 1).name, 'Sunrise 402 Updated');
    });

    test('archiveGroup marks group as ARCHIVED', () async {
      await cubit.loadGroups();

      final success = await cubit.archiveGroup(1);

      expect(success, isTrue);
      expect(cubit.state.groups.firstWhere((g) => g.id == 1).isArchived, isTrue);
    });

    test('deleteGroup removes group from state', () async {
      await cubit.loadGroups();

      final success = await cubit.deleteGroup(2);

      expect(success, isTrue);
      expect(cubit.state.groups.any((g) => g.id == 2), isFalse);
    });

    test('joinGroup success reloads groups', () async {
      await cubit.loadGroups();

      final success = await cubit.joinGroup('VALIDCODE');

      expect(success, isTrue);
      expect(cubit.state.successMessage, contains('thành công'));
    });

    test('joinGroup with invalid code emits error', () async {
      final success = await cubit.joinGroup('INVALID');

      expect(success, isFalse);
      expect(cubit.state.errorMessage, 'Mã mời không tồn tại');
    });

    test('reset restores initial state', () async {
      await cubit.loadGroups();
      expect(cubit.state.groups, isNotEmpty);

      cubit.reset();
      expect(cubit.state.groups, isEmpty);
      expect(cubit.state.totalCount, 0);
    });

    test('drops responses if sessionEpoch changes during in-flight loadGroups', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      final sessionCoordinator = SessionCoordinator(tokenStorage: tokenStorage);

      repo.delay = const Duration(milliseconds: 50);

      final sessionCubit = GroupsCubit(
        repo,
        sessionCoordinator: sessionCoordinator,
      );

      final future = sessionCubit.loadGroups();

      // Logout during in-flight fetch
      await sessionCoordinator.clearSession();

      await future;

      // Result dropped, groups remain empty
      expect(sessionCubit.state.groups, isEmpty);

      await sessionCubit.close();
    });

    test('CUD operations notify DataSyncCoordinator', () async {
      final syncCoordinator = DataSyncCoordinator();
      final syncCubit = GroupsCubit(
        repo,
        dataSyncCoordinator: syncCoordinator,
      );

      int syncNotificationsCount = 0;
      syncCoordinator.addListener(() {
        syncNotificationsCount++;
      });

      await syncCubit.createGroup(name: 'New Test Group');
      expect(syncNotificationsCount, 1);

      await syncCubit.updateGroup(1, name: 'Renamed Group');
      expect(syncNotificationsCount, 2);

      await syncCubit.archiveGroup(1);
      expect(syncNotificationsCount, 3);

      await syncCubit.deleteGroup(1);
      expect(syncNotificationsCount, 4);

      await syncCubit.close();
    });
  });
}
