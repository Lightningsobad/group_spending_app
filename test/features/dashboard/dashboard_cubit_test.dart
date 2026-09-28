import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:group_spending_app/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_overview_entity.dart';
import 'package:group_spending_app/features/debts/domain/entities/group_debt_entity.dart';
import 'package:group_spending_app/features/debts/domain/repositories/debts_repository.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/domain/repositories/groups_repository.dart';

class FakeDebtsRepository implements DebtsRepository {
  DebtOverviewEntity response = const DebtOverviewEntity(
    totalOwedVnd: 450000,
    totalReceivableVnd: 2450000,
  );
  AppException? exception;
  Duration delay = Duration.zero;

  @override
  Future<DebtOverviewEntity> getDebtOverview() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (exception != null) throw exception!;
    return response;
  }

  @override
  Future<GroupSimplifiedDebtsEntity> getGroupSimplifiedDebts(int groupId) async {
    return const GroupSimplifiedDebtsEntity(
      userBalance: DebtUserBalanceEntity(groupId: 0, groupName: ''),
    );
  }

  @override
  Future<GroupActualDebtsEntity> getGroupActualDebts(
    int groupId, {
    String? status,
  }) async {
    return const GroupActualDebtsEntity(
      userBalance: DebtUserBalanceEntity(groupId: 0, groupName: ''),
    );
  }

  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) async {}

  @override
  Future<void> markDebtAsPaid(int debtId) async {}

  @override
  Future<void> sendDebtReminder(int debtId) async {}
}

class FakeGroupsRepository implements GroupsRepository {
  List<GroupModel> groups = [
    const GroupModel(
      id: 1,
      name: 'Chung cư Sunrise',
      category: 'Apartment',
      ownerId: 1,
      userBalance: 2450000,
    ),
  ];
  AppException? exception;

  @override
  Future<List<GroupModel>> getMyGroups({String? filter, String? search}) async {
    if (exception != null) throw exception!;
    return groups;
  }

  @override
  Future<GroupModel> getGroupDetails(int groupId) async => groups.first;

  @override
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) async =>
      groups.first;

  @override
  Future<GroupModel> updateGroup(
    int groupId, {
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) async =>
      groups.first;

  @override
  Future<void> archiveGroup(int groupId) async {}

  @override
  Future<void> deleteGroup(int groupId) async {}

  @override
  Future<void> joinGroup(String inviteCode) async {}
}

void main() {
  group('DashboardCubit Tests', () {
    late FakeDebtsRepository debtsRepository;
    late FakeGroupsRepository groupsRepository;
    late DashboardCubit cubit;

  setUp(() {
    debtsRepository = FakeDebtsRepository();
    groupsRepository = FakeGroupsRepository();
    cubit = DashboardCubit(
      debtsRepository: debtsRepository,
      groupsRepository: groupsRepository,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state has initial status and default overview', () {
    expect(cubit.state.status, DashboardStatus.initial);
    expect(cubit.state.debtOverview.totalOwedVnd, 0);
    expect(cubit.state.groups, isEmpty);
  });

  test('loadDashboard success updates state with debts overview and groups', () async {
    await cubit.loadDashboard();

    expect(cubit.state.status, DashboardStatus.success);
    expect(cubit.state.debtOverview.totalOwedVnd, 450000);
    expect(cubit.state.debtOverview.totalReceivableVnd, 2450000);
    expect(cubit.state.groups, hasLength(1));
    expect(cubit.state.groups.first.name, 'Chung cư Sunrise');
  });

  test('loadDashboard failure emits failure state with error message', () async {
    debtsRepository.exception = const AppException(message: 'Lỗi tải nợ');

    await cubit.loadDashboard();

    expect(cubit.state.status, DashboardStatus.failure);
    expect(cubit.state.errorMessage, 'Lỗi tải nợ');
  });

  test('reset restores initial state', () async {
    await cubit.loadDashboard();
    expect(cubit.state.status, DashboardStatus.success);

    cubit.reset();
    expect(cubit.state.status, DashboardStatus.initial);
    expect(cubit.state.groups, isEmpty);
  });

  test('drops responses if sessionEpoch changes during in-flight fetch', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final tokenStorage = TokenStorage();
    final sessionCoordinator = SessionCoordinator(tokenStorage: tokenStorage);

    debtsRepository.delay = const Duration(milliseconds: 50);

    final sessionCubit = DashboardCubit(
      debtsRepository: debtsRepository,
      groupsRepository: groupsRepository,
      sessionCoordinator: sessionCoordinator,
    );

    // Start in-flight request
    final future = sessionCubit.loadDashboard();

    // User logs out while request is in-flight -> increments sessionEpoch
    await sessionCoordinator.clearSession();

    await future;

    // Response should be dropped; state should not be success
    expect(sessionCubit.state.status, isNot(DashboardStatus.success));

    await sessionCubit.close();
  });

  test('automatically reloads dashboard when DataSyncCoordinator notifies', () async {
    final syncCoordinator = DataSyncCoordinator();
    final syncCubit = DashboardCubit(
      debtsRepository: debtsRepository,
      groupsRepository: groupsRepository,
      dataSyncCoordinator: syncCoordinator,
    );

    expect(syncCubit.state.status, DashboardStatus.initial);

    // Trigger sync event
    syncCoordinator.notifyDataChanged(DataSyncScope.groups);

    // Wait a tick for async handler
    await Future.delayed(const Duration(milliseconds: 10));

    expect(syncCubit.state.status, DashboardStatus.success);
    expect(syncCubit.state.groups, hasLength(1));

    await syncCubit.close();
  });
});
}
