import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/features/analytics/domain/entities/analytics_enums.dart';
import 'package:group_spending_app/features/analytics/domain/entities/expense_history_entity.dart';
import 'package:group_spending_app/features/analytics/domain/entities/expense_statistics_entity.dart';
import 'package:group_spending_app/features/analytics/domain/entities/leaderboard_entity.dart';
import 'package:group_spending_app/features/analytics/domain/entities/personal_overview_entity.dart';
import 'package:group_spending_app/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/analytics_tab_cubit.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/analytics_tab_state.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/global_analytics_cubit.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/global_analytics_state.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/group_analytics_cubit.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/group_analytics_state.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_enums.dart' as exp_enums;
import 'package:group_spending_app/features/expenses/data/models/expense_models.dart';
import 'package:group_spending_app/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/data/models/group_summary_model.dart';
import 'package:group_spending_app/features/groups/domain/repositories/groups_repository.dart';

class FakeAnalyticsRepository implements AnalyticsRepository {
  bool shouldThrow = false;
  String errorMessage = 'Lỗi kết nối';

  PersonalOverviewEntity mockOverview = const PersonalOverviewEntity(
    totalSpendingVnd: 20490000,
    activeGroupCount: 3,
    totalExpenses: 6,
    myExpenseCount: 3,
  );

  ExpenseStatisticsEntity mockDetails = const ExpenseStatisticsEntity(
    period: 'THIS_MONTH',
    startDate: '2026-09-01',
    endDate: '2026-09-30',
    totalSpendingVnd: 20490000,
    totalExpenseCount: 6,
    averageSpendingPerPersonVnd: 2561250,
    totalUniqueMembers: 8,
    debtSettlementRate: 82.0,
    categoryDistributions: [
      CategoryDistributionEntity(
        categoryId: 1,
        categoryName: 'Ăn uống & Nhà hàng',
        amountVnd: 3278400,
        percentage: 48.0,
      ),
    ],
  );

  List<LeaderboardMemberEntity> mockLeaderboard = const [
    LeaderboardMemberEntity(
      rank: 1,
      userId: 1,
      fullName: 'Nguyễn Nhật Minh',
      contributedAmountVnd: 2868600,
      percentage: 42.0,
    ),
  ];

  List<ExpenseHistoryItemEntity> mockHistory = const [
    ExpenseHistoryItemEntity(
      id: 1,
      groupId: 10,
      groupName: 'Chung cư Sunrise Room',
      title: 'Lẩu Haidilao cuối tuần',
      expenseDate: '2026-09-10',
      totalAmountVnd: 1280000,
      categoryName: 'Ăn uống',
      paidByUserName: 'Nguyễn Nhật Minh',
    ),
  ];

  @override
  Future<PersonalOverviewEntity> getPersonalOverview() async {
    if (shouldThrow) throw AppException(message: errorMessage);
    return mockOverview;
  }

  @override
  Future<ExpenseStatisticsEntity> getPersonalDetails({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    if (shouldThrow) throw AppException(message: errorMessage);
    return mockDetails;
  }

  @override
  Future<List<LeaderboardMemberEntity>> getGlobalLeaderboard({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    if (shouldThrow) throw AppException(message: errorMessage);
    return mockLeaderboard;
  }

  @override
  Future<ExpenseStatisticsEntity> getGroupStatistics(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    if (shouldThrow) throw AppException(message: errorMessage);
    return mockDetails;
  }

  @override
  Future<List<LeaderboardMemberEntity>> getGroupLeaderboard(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    if (shouldThrow) throw AppException(message: errorMessage);
    return mockLeaderboard;
  }

  @override
  Future<List<ExpenseHistoryItemEntity>> getExpenseHistory({
    ExpenseTimeFilter timeFilter = ExpenseTimeFilter.all,
  }) async {
    if (shouldThrow) throw AppException(message: errorMessage);
    return mockHistory;
  }
}

class FakeGroupsRepository implements GroupsRepository {
  List<GroupSummaryModel> mockSummaries = [
    const GroupSummaryModel(
      id: 1,
      name: 'Chung cư Sunrise Room',
      category: 'Housing',
      totalSpendingVnd: 6830000,
      memberCount: 5,
      status: 'ACTIVE',
    ),
    const GroupSummaryModel(
      id: 2,
      name: 'Đội Cầu Lông Ba Đình',
      category: 'Sport',
      totalSpendingVnd: 6830000,
      memberCount: 6,
      status: 'ARCHIVED',
    ),
  ];

  @override
  Future<List<GroupSummaryModel>> getGroupSummaries({
    String? search,
    String? status,
    String? category,
  }) async {
    var list = mockSummaries;
    if (status != null && status != 'ALL') {
      list = list.where((g) => g.status?.toUpperCase() == status.toUpperCase()).toList();
    }
    if (category != null && category != 'ALL') {
      list = list.where((g) => g.category?.toLowerCase() == category.toLowerCase()).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      list = list.where((g) => g.name.toLowerCase().contains(search.trim().toLowerCase())).toList();
    }
    return list;
  }
  List<GroupModel> mockGroups = [
    const GroupModel(
      id: 1,
      name: 'Chung cư Sunrise Room',
      category: 'Housing',
      totalSpendingVnd: 6830000,
      memberCount: 5,
      ownerId: 1,
    ),
    const GroupModel(
      id: 2,
      name: 'Đội Cầu Lông Ba Đình',
      category: 'Sport',
      totalSpendingVnd: 6830000,
      memberCount: 6,
      ownerId: 2,
      status: 'ARCHIVED',
    ),
  ];

  @override
  Future<List<GroupModel>> getMyGroups({
    String? filter,
    String? category,
    String? search,
  }) async {
    return mockGroups;
  }

  @override
  Future<GroupModel> getGroupDetails(int groupId) async => mockGroups.first;

  @override
  Future<GroupModel> createGroup({required String name, String? description, String? category, String? defaultCurrency}) async => mockGroups.first;

  @override
  Future<GroupModel> updateGroup(int groupId, {required String name, String? description, String? category, String? defaultCurrency}) async => mockGroups.first;

  @override
  Future<void> archiveGroup(int groupId) async {}

  @override
  Future<void> deleteGroup(int groupId) async {}

  @override
  Future<void> joinGroup(String inviteCode) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeExpensesRepository implements ExpensesRepository {
  List<ExpenseListItemModel> mockExpenses = [
    const ExpenseListItemModel(
      id: 101,
      title: 'Lẩu Haidilao cuối tuần',
      amount: 1280,
      amountVnd: 1280000,
      expenseDate: '2026-09-10',
      paidBy: 'Nguyễn Nhật Minh',
      paidByUserId: 1,
      status: 'PAID_BY_ME',
      myAmountOwed: 0,
      myAmountOwedVnd: 0,
      categoryName: 'Food',
    ),
  ];

  exp_enums.ExpenseTimeFilter? lastTimeFilter;

  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(
    int groupId, {
    exp_enums.ExpenseTimeFilter? timeFilter,
    exp_enums.ExpensePayerFilter? payerFilter,
    exp_enums.ExpenseCategoryFilter? categoryFilter,
    String? search,
  }) async {
    lastTimeFilter = timeFilter;
    return GroupExpensesResponseModel(
      totalSpending: 1280,
      totalSpendingVnd: 1280000,
      expenseCount: mockExpenses.length,
      expenses: mockExpenses,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Analytics Cubits Tests', () {
    late FakeAnalyticsRepository analyticsRepo;
    late FakeGroupsRepository groupsRepo;

    setUp(() {
      analyticsRepo = FakeAnalyticsRepository();
      groupsRepo = FakeGroupsRepository();
    });

    group('AnalyticsTabCubit', () {
      test('loadOverview loads overview and groups list successfully', () async {
        final cubit = AnalyticsTabCubit(
          analyticsRepository: analyticsRepo,
          groupsRepository: groupsRepo,
        );

        expect(cubit.state.status, AnalyticsTabStatus.initial);

        await cubit.loadOverview();

        expect(cubit.state.status, AnalyticsTabStatus.success);
        expect(cubit.state.overview.totalSpendingVnd, 20490000);
        expect(cubit.state.groups.length, 2);
        expect(cubit.state.allCount, 2);
        expect(cubit.state.activeCount, 1);
        expect(cubit.state.archivedCount, 1);
      });

      test('setFilter and searchQuery filter groups properly in state', () async {
        final cubit = AnalyticsTabCubit(
          analyticsRepository: analyticsRepo,
          groupsRepository: groupsRepo,
        );
        await cubit.loadOverview();

        await cubit.setFilter('ACTIVE');
        expect(cubit.state.filteredGroups.length, 1);
        expect(cubit.state.filteredGroups.first.name, 'Chung cư Sunrise Room');

        await cubit.setFilter('ARCHIVED');
        expect(cubit.state.filteredGroups.length, 1);
        expect(cubit.state.filteredGroups.first.name, 'Đội Cầu Lông Ba Đình');

        await cubit.setFilter('ALL');
        cubit.setSearchQuery('Sunrise');
        expect(cubit.state.filteredGroups.length, 1);

        cubit.setSearchQuery('NonExisting');
        expect(cubit.state.filteredGroups.isEmpty, isTrue);
      });

      test('handles AppException on failure', () async {
        analyticsRepo.shouldThrow = true;
        final cubit = AnalyticsTabCubit(
          analyticsRepository: analyticsRepo,
          groupsRepository: groupsRepo,
        );

        await cubit.loadOverview();

        expect(cubit.state.status, AnalyticsTabStatus.failure);
        expect(cubit.state.errorMessage, 'Lỗi kết nối');
      });
    });

    group('GlobalAnalyticsCubit', () {
      test('loadAnalytics loads details, leaderboard, and history', () async {
        final cubit = GlobalAnalyticsCubit(
          analyticsRepository: analyticsRepo,
        );

        expect(cubit.state.status, GlobalAnalyticsStatus.initial);

        await cubit.loadAnalytics();

        expect(cubit.state.status, GlobalAnalyticsStatus.success);
        expect(cubit.state.details.totalSpendingVnd, 20490000);
        expect(cubit.state.leaderboard.length, 1);
        expect(cubit.state.recentExpenses.length, 1);
      });

      test('setPeriod triggers reload with new period', () async {
        final cubit = GlobalAnalyticsCubit(
          analyticsRepository: analyticsRepo,
        );

        cubit.setPeriod(StatisticsPeriod.lastMonth);
        expect(cubit.state.period, StatisticsPeriod.lastMonth);
        await cubit.loadAnalytics();
        expect(cubit.state.status, GlobalAnalyticsStatus.success);
      });
    });

    group('GroupAnalyticsCubit', () {
      late FakeExpensesRepository expensesRepo;

      setUp(() {
        expensesRepo = FakeExpensesRepository();
      });

      test('loadGroupAnalytics loads group statistics, leaderboard, and recent expenses', () async {
        final cubit = GroupAnalyticsCubit(
          groupId: 10,
          analyticsRepository: analyticsRepo,
          expensesRepository: expensesRepo,
        );

        expect(cubit.state.status, GroupAnalyticsStatus.initial);

        await cubit.loadGroupAnalytics();

        expect(cubit.state.status, GroupAnalyticsStatus.success);
        expect(cubit.state.groupStatistics.totalSpendingVnd, 20490000);
        expect(cubit.state.leaderboard.length, 1);
        expect(cubit.state.recentExpenses.length, 1);
        expect(cubit.state.recentExpenses.first.title, 'Lẩu Haidilao cuối tuần');
        expect(cubit.state.recentExpenses.first.totalAmountVnd, 1280000);
      });

      test('setPeriod triggers reload with matching ExpenseTimeFilter', () async {
        final cubit = GroupAnalyticsCubit(
          groupId: 10,
          analyticsRepository: analyticsRepo,
          expensesRepository: expensesRepo,
        );

        cubit.setPeriod(StatisticsPeriod.lastMonth);
        expect(cubit.state.period, StatisticsPeriod.lastMonth);
        await cubit.loadGroupAnalytics();

        expect(cubit.state.status, GroupAnalyticsStatus.success);
        expect(expensesRepo.lastTimeFilter, exp_enums.ExpenseTimeFilter.lastMonth);
      });
    });
  });
}
