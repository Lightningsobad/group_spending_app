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
        id: 201,
        groupId: 10,
        debtorId: 2,
        debtorName: 'Minh',
        creditorId: 1,
        creditorName: 'An',
        amountVnd: 150000,
        action: DebtAction.pay,
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
  });
}
