import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_overview_entity.dart';
import 'package:group_spending_app/features/debts/domain/entities/group_debt_entity.dart';
import 'package:group_spending_app/features/debts/domain/repositories/debts_repository.dart';
import 'package:group_spending_app/features/debts/presentation/cubit/debts_cubit.dart';
import 'package:group_spending_app/features/debts/presentation/cubit/debts_state.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import '../../../groups/groups_cubit_test.dart';

class MockDebtsRepository implements DebtsRepository {
  DebtOverviewEntity overviewResult = const DebtOverviewEntity(
    totalOwedVnd: 450000,
    totalReceivableVnd: 2450000,
    netBalanceVnd: 2000000,
    groupBalances: [
      GroupDebtBalanceEntity(
        groupId: 10,
        groupName: 'Chung cư Sunrise Room',
        netBalanceVnd: 2450000,
        pendingDebtCount: 4,
      ),
      GroupDebtBalanceEntity(
        groupId: 11,
        groupName: 'Đội Cầu Lông Ba Đình',
        netBalanceVnd: -450000,
        pendingDebtCount: 1,
      ),
      GroupDebtBalanceEntity(
        groupId: 12,
        groupName: 'Đi phượt Đà Lạt',
        netBalanceVnd: 0,
        pendingDebtCount: 0,
      ),
    ],
  );

  GroupSimplifiedDebtsEntity simplifiedResult = const GroupSimplifiedDebtsEntity(
    userBalance: DebtUserBalanceEntity(
      groupId: 10,
      groupName: 'Chung cư Sunrise Room',
      netBalanceVnd: 2450000,
    ),
    simplifiedDebts: [
      SimplifiedDebtEntity(
        id: 101,
        debtorId: 2,
        debtorName: 'Minh',
        creditorId: 1,
        creditorName: 'An',
        amountVnd: 150000,
        action: DebtAction.pay,
      ),
    ],
  );

  GroupActualDebtsEntity actualResult = const GroupActualDebtsEntity(
    userBalance: DebtUserBalanceEntity(
      groupId: 10,
      groupName: 'Chung cư Sunrise Room',
      netBalanceVnd: 2450000,
    ),
    actualDebts: [
      ActualDebtEntity(
        expenseId: 201,
        title: 'Tiền Internet',
        totalAmountVnd: 150000,
        paidByUserId: 1,
        paidByUserName: 'An',
        debtors: [
          ActualDebtorEntity(
            splitId: 104,
            userId: 2,
            name: 'Minh',
            amountVnd: 150000,
            status: DebtStatus.pending,
            action: DebtAction.pay,
          ),
        ],
      ),
    ],
  );

  int markAsPaidCalls = 0;
  int confirmCalls = 0;
  int remindCalls = 0;

  @override
  Future<DebtOverviewEntity> getDebtOverview() async => overviewResult;

  @override
  Future<GroupSimplifiedDebtsEntity> getGroupSimplifiedDebts(int groupId) async =>
      simplifiedResult;

  @override
  Future<GroupActualDebtsEntity> getGroupActualDebts(int groupId,
          {String? status}) async =>
      actualResult;

  @override
  Future<void> markDebtAsPaid(int debtId) async {
    markAsPaidCalls++;
  }

  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) async {
    confirmCalls++;
  }

  @override
  Future<void> sendDebtReminder(int debtId) async {
    remindCalls++;
  }
}

class FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => 'fake-token';

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {}
}

void main() {
  late MockDebtsRepository repository;
  late DataSyncCoordinator syncCoordinator;
  late SessionCoordinator sessionCoordinator;
  late DebtsCubit cubit;

  setUp(() {
    repository = MockDebtsRepository();
    syncCoordinator = DataSyncCoordinator();
    sessionCoordinator = SessionCoordinator(tokenStorage: FakeTokenStorage());
    cubit = DebtsCubit(
      repository,
      dataSyncCoordinator: syncCoordinator,
      sessionCoordinator: sessionCoordinator,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('DebtsCubit Tests', () {
    test('initial state is correct', () {
      expect(cubit.state.status, DebtsStatus.initial);
      expect(cubit.state.overview, isNull);
      expect(cubit.state.selectedGroupId, isNull);
    });

    test('loadOverview loads successfully and populates state', () async {
      await cubit.loadOverview();

      expect(cubit.state.status, DebtsStatus.success);
      expect(cubit.state.overview, isNotNull);
      expect(cubit.state.totalGroupCount, 3);
      expect(cubit.state.hasDebtGroupCount, 2);
      expect(cubit.state.settledGroupCount, 1);
      expect(cubit.state.filteredGroupBalances.length, 3);
    });

    test('filter works correctly for hasDebt and settled', () async {
      await cubit.loadOverview();

      cubit.setFilter(DebtOverviewFilter.hasDebt);
      expect(cubit.state.filteredGroupBalances.length, 2);

      cubit.setFilter(DebtOverviewFilter.settled);
      expect(cubit.state.filteredGroupBalances.length, 1);
      expect(cubit.state.filteredGroupBalances.first.groupName, 'Đi phượt Đà Lạt');
    });

    test('searchQuery filters groups by name', () async {
      await cubit.loadOverview();

      cubit.setSearchQuery('cầu lông');
      expect(cubit.state.filteredGroupBalances.length, 1);
      expect(
        cubit.state.filteredGroupBalances.first.groupName,
        'Đội Cầu Lông Ba Đình',
      );
    });

    test('selectGroup sets selected group and loads details', () async {
      cubit.selectGroup(10, groupName: 'Chung cư Sunrise Room');

      expect(cubit.state.selectedGroupId, 10);
      expect(cubit.state.selectedGroupName, 'Chung cư Sunrise Room');

      // Wait for async loadGroupDebts to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.simplifiedDebts, isNotNull);
      expect(cubit.state.actualDebts, isNotNull);
      expect(cubit.state.isDetailLoading, isFalse);

      // Back to list
      cubit.selectGroup(null);
      expect(cubit.state.selectedGroupId, isNull);
    });

    test('setDetailTab switches between simplified and actual debts', () {
      cubit.setDetailTab(1);
      expect(cubit.state.activeDetailTab, 1);

      cubit.setDetailTab(0);
      expect(cubit.state.activeDetailTab, 0);
    });

    test('markDebtAsPaid calls repository and emits success', () async {
      final success = await cubit.markDebtAsPaid(101);

      expect(success, isTrue);
      expect(repository.markAsPaidCalls, 1);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('confirmDebtSettled calls repository and emits success', () async {
      final success = await cubit.confirmDebtSettled(101, confirmed: true);

      expect(success, isTrue);
      expect(repository.confirmCalls, 1);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('sendDebtReminder calls repository and emits success', () async {
      final success = await cubit.sendDebtReminder(101);

      expect(success, isTrue);
      expect(repository.remindCalls, 1);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('loadOverview with GroupsRepository enriches group category from api', () async {
      final fakeGroupsRepo = FakeGroupsRepo()
        ..groups = [
          const GroupModel(
            id: 10,
            name: 'Chung cư Sunrise Room',
            category: 'Apartment',
            ownerId: 1,
          ),
          const GroupModel(
            id: 11,
            name: 'Đội Cầu Lông Ba Đình',
            category: 'Sport & Clubs',
            ownerId: 1,
          ),
        ];
      final cubitWithGroups =
          DebtsCubit(repository, groupsRepository: fakeGroupsRepo);
      addTearDown(cubitWithGroups.close);

      await cubitWithGroups.loadOverview();

      expect(cubitWithGroups.state.isSuccess, isTrue);
      expect(cubitWithGroups.state.userGroups.length, 2);
      final g10 = cubitWithGroups.state.overview!.groupBalances
          .firstWhere((g) => g.groupId == 10);
      expect(g10.category, 'Apartment');
      final g11 = cubitWithGroups.state.overview!.groupBalances
          .firstWhere((g) => g.groupId == 11);
      expect(g11.category, 'Sport & Clubs');
    });
  });
}
