import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/group_members_cubit.dart';

import 'groups_cubit_test.dart';

class MockDataSyncCoordinator extends DataSyncCoordinator {
  int notifyCount = 0;
  @override
  void notifyDataChanged([DataSyncScope scope = DataSyncScope.all]) {
    notifyCount++;
    super.notifyDataChanged(scope);
  }
}

void main() {
  group('GroupMembersCubit Tests', () {
    late FakeGroupsRepo groupsRepo;
    late SessionCoordinator sessionCoordinator;
    late MockDataSyncCoordinator dataSyncCoordinator;
    late GroupMembersCubit cubit;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      groupsRepo = FakeGroupsRepo();
      sessionCoordinator = SessionCoordinator(tokenStorage: tokenStorage);
      dataSyncCoordinator = MockDataSyncCoordinator();
      cubit = GroupMembersCubit(
        groupId: 1,
        isAdmin: true,
        groupsRepository: groupsRepo,
        sessionCoordinator: sessionCoordinator,
        dataSyncCoordinator: dataSyncCoordinator,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.groupId, 1);
      expect(cubit.isAdmin, true);
      expect(cubit.state.members, isEmpty);
      expect(cubit.state.pendingRequests, isEmpty);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.selectedMemberDetail, isNull);
    });

    test('loadMembers populates members and pending requests for admin', () async {
      await cubit.loadMembers();

      expect(cubit.state.isLoading, false);
      expect(cubit.state.members.length, 2);
      expect(cubit.state.members.first.fullName, 'Nguyễn Nhật Minh');
      expect(cubit.state.members.first.isAdmin, true);
    });

    test('loadMembers handles AppException gracefully', () async {
      groupsRepo.exception = const AppException(message: 'Lỗi tải thành viên');

      await cubit.loadMembers();

      expect(cubit.state.isLoading, false);
      expect(cubit.state.errorMessage, 'Lỗi tải thành viên');
    });

    test('reviewJoinRequest calls repo, notifies sync, and reloads', () async {
      final success = await cubit.reviewJoinRequest(
        requestId: 10,
        approved: true,
        includePastFundCollections: true,
      );

      expect(success, true);
      expect(cubit.state.successMessage, isNotNull);
      expect(dataSyncCoordinator.notifyCount, 1);
      expect(cubit.state.members.length, 2);
    });

    test('reviewJoinRequest handles rejection and failure', () async {
      groupsRepo.exception = const AppException(message: 'Từ chối thất bại');

      final success = await cubit.reviewJoinRequest(
        requestId: 10,
        approved: false,
      );

      expect(success, false);
      expect(cubit.state.errorMessage, 'Từ chối thất bại');
    });

    test('loadMemberDetail populates selectedMemberDetail in state', () async {
      await cubit.loadMemberDetail(2);

      expect(cubit.state.isLoadingDetail, false);
      expect(cubit.state.selectedMemberDetail, isNotNull);
      expect(cubit.state.selectedMemberDetail!.userId, 2);
      expect(cubit.state.selectedMemberDetail!.bankName, 'Techcombank');
    });

    test('kickMember removes member, reloads, and notifies sync', () async {
      final success = await cubit.kickMember(2);

      expect(success, true);
      expect(cubit.state.successMessage, 'Đã xóa thành viên khỏi nhóm thành công.');
      expect(dataSyncCoordinator.notifyCount, 1);
    });

    test('leaveGroup notifies sync and returns success', () async {
      final success = await cubit.leaveGroup();

      expect(success, true);
      expect(cubit.state.successMessage, 'Đã rời khỏi nhóm thành công.');
      expect(dataSyncCoordinator.notifyCount, 1);
    });

    test('transferOwnership notifies sync and returns success', () async {
      final success = await cubit.transferOwnership(2);

      expect(success, true);
      expect(cubit.state.successMessage, 'Đã chuyển quyền Quản trị viên thành công.');
      expect(dataSyncCoordinator.notifyCount, 1);
    });

    test('drops response if sessionEpoch increments during in-flight loadMembers', () async {
      groupsRepo.delay = const Duration(milliseconds: 50);

      // Start in-flight request
      final future = cubit.loadMembers();
      // Invalidate session
      await sessionCoordinator.clearSession();
      await future;

      // State should not have updated with members
      expect(cubit.state.members, isEmpty);
    });
  });
}
