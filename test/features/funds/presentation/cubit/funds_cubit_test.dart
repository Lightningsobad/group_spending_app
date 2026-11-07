import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_entities.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_enums.dart';
import 'package:group_spending_app/features/funds/domain/repositories/funds_repository.dart';
import 'package:group_spending_app/features/funds/presentation/cubit/funds_cubit.dart';
import 'package:group_spending_app/features/funds/presentation/cubit/funds_state.dart';

class MockFundsRepository implements FundsRepository {
  int callCount = 0;
  String? lastSearch;
  FundCollectionStatus? lastStatus;
  FundTimeFilter? lastTimeFilter;

  GroupFundsOverviewEntity overviewResult = const GroupFundsOverviewEntity(
    groupId: 10,
    totalCollectedAmount: 1500,
    totalCollectedAmountVnd: 1500000,
    totalTargetAmount: 3000,
    totalTargetAmountVnd: 3000000,
    completionPercentage: 50.0,
    funds: [
      FundCollectionItemEntity(
        id: 1,
        name: 'Quỹ ăn uống',
        status: FundCollectionStatus.collecting,
        statusText: 'Đang thu',
        totalTargetAmountVnd: 1000000,
        totalCollectedAmountVnd: 500000,
        totalMemberCount: 10,
        paidCount: 5,
        startDate: '2026-10-01',
      ),
      FundCollectionItemEntity(
        id: 2,
        name: 'Quỹ từ thiện',
        status: FundCollectionStatus.completed,
        statusText: 'Hoàn thành',
        totalTargetAmountVnd: 2000000,
        totalCollectedAmountVnd: 2000000,
        totalMemberCount: 10,
        paidCount: 10,
        startDate: '2026-08-01',
      ),
    ],
  );

  Future<GroupFundsOverviewEntity> Function(
    int groupId,
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  )? customOverviewHandler;

  @override
  Future<GroupFundsOverviewEntity> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  }) async {
    callCount++;
    lastSearch = search;
    lastStatus = status;
    lastTimeFilter = timeFilter;
    if (customOverviewHandler != null) {
      return customOverviewHandler!(groupId, search, timeFilter, status);
    }
    return overviewResult;
  }

  @override
  Future<FundCollectionEntity> createFundCollection(
    int groupId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<FundCollectionEntity> updateFundCollection(
    int fundId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFundCollection(int fundId) async {}

  @override
  Future<FundCollectionEntity> getFundCollectionDetails(int fundId) async {
    throw UnimplementedError();
  }

  @override
  Future<FundCollectionEntity> markMemberPaid(int fundId, int targetUserId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> sendFundReminder(int fundId) async {}

  @override
  Future<List<int>> exportFundCsv(int fundId) async {
    return [1, 2, 3];
  }
}

void main() {
  group('FundsCubit Test', () {
    late MockFundsRepository mockRepo;
    late FundsCubit cubit;

    setUp(() {
      mockRepo = MockFundsRepository();
      cubit = FundsCubit(mockRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state.status, FundsStatus.initial);
      expect(cubit.state.overview, isNull);
      expect(cubit.state.filteredFunds, isEmpty);
      expect(cubit.state.searchQuery, isEmpty);
      expect(cubit.state.selectedStatusFilter, isNull);
      expect(cubit.state.selectedTimeFilter, FundTimeFilter.all);
    });

    test('loadGroupFunds fetches overview and populates funds', () async {
      await cubit.loadGroupFunds(10);

      expect(cubit.state.status, FundsStatus.success);
      expect(cubit.state.currentGroupId, 10);
      expect(cubit.state.overview?.totalCollectedAmountVnd, 1500000);
      expect(cubit.state.filteredFunds.length, 2);
    });

    test('status filter filters funds properly in state and calls repo', () async {
      await cubit.loadGroupFunds(10);

      cubit.setStatusFilter(FundCollectionStatus.collecting);
      expect(cubit.state.selectedStatusFilter, FundCollectionStatus.collecting);
      expect(cubit.state.filteredFunds.length, 1);
      expect(cubit.state.filteredFunds.first.name, 'Quỹ ăn uống');

      cubit.setStatusFilter(FundCollectionStatus.completed);
      expect(cubit.state.selectedStatusFilter, FundCollectionStatus.completed);
      expect(cubit.state.filteredFunds.length, 1);
      expect(cubit.state.filteredFunds.first.name, 'Quỹ từ thiện');

      cubit.setStatusFilter(null);
      expect(cubit.state.selectedStatusFilter, isNull);
      expect(cubit.state.filteredFunds.length, 2);
    });

    test('search query filters funds client-side and reloads after debounce', () async {
      await cubit.loadGroupFunds(10);
      final initialCalls = mockRepo.callCount;

      cubit.setSearchQuery('từ thiện');
      // Client-side filtering is instantaneous
      expect(cubit.state.searchQuery, 'từ thiện');
      expect(cubit.state.filteredFunds.length, 1);
      expect(cubit.state.filteredFunds.first.name, 'Quỹ từ thiện');

      // Debounce reloads from server
      await Future.delayed(const Duration(milliseconds: 400));
      expect(mockRepo.callCount, greaterThan(initialCalls));
    });

    test('reset clears state', () async {
      await cubit.loadGroupFunds(10);
      expect(cubit.state.filteredFunds, isNotEmpty);

      cubit.reset();
      expect(cubit.state.status, FundsStatus.initial);
      expect(cubit.state.overview, isNull);
    });

    test('clearMessages removes errorMessage and successMessage', () {
      cubit.emit(
        cubit.state.copyWith(
          errorMessage: 'Error occurred',
          successMessage: 'Done',
        ),
      );
      expect(cubit.state.errorMessage, 'Error occurred');
      expect(cubit.state.successMessage, 'Done');

      cubit.clearMessages();
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.successMessage, isNull);
    });

    test('FUND-03: slow response from Group A does not overwrite newer Group B data', () async {
      final completerA = Completer<GroupFundsOverviewEntity>();
      const overviewB = GroupFundsOverviewEntity(
        groupId: 20,
        totalCollectedAmount: 200,
        totalCollectedAmountVnd: 200000,
        totalTargetAmount: 200,
        totalTargetAmountVnd: 200000,
        completionPercentage: 100.0,
        funds: [
          FundCollectionItemEntity(
            id: 201,
            name: 'Quỹ Group B',
            status: FundCollectionStatus.completed,
            statusText: 'Hoàn thành',
          ),
        ],
      );

      mockRepo.customOverviewHandler = (groupId, search, timeFilter, status) {
        if (groupId == 10) {
          return completerA.future;
        } else {
          return Future.value(overviewB);
        }
      };

      // 1. Trigger load for Group 10 (slow)
      final futureA = cubit.loadGroupFunds(10);
      expect(cubit.state.currentGroupId, 10);
      expect(cubit.state.status, FundsStatus.loading);

      // 2. User quickly switches to Group 20 (fast)
      await cubit.loadGroupFunds(20);
      expect(cubit.state.currentGroupId, 20);
      expect(cubit.state.status, FundsStatus.success);
      expect(cubit.state.filteredFunds.first.name, 'Quỹ Group B');

      // 3. Group 10 finally completes
      completerA.complete(mockRepo.overviewResult);
      await futureA;

      // State MUST remain Group 20 data, not overwritten by Group 10!
      expect(cubit.state.currentGroupId, 20);
      expect(cubit.state.filteredFunds.first.name, 'Quỹ Group B');
      expect(cubit.state.overview?.groupId, 20);
    });

    test('FUND-03: old in-flight filter response completing after newer filter does not overwrite state', () async {
      final completerCollecting = Completer<GroupFundsOverviewEntity>();
      const completedOverview = GroupFundsOverviewEntity(
        groupId: 10,
        totalCollectedAmount: 100,
        totalCollectedAmountVnd: 100000,
        totalTargetAmount: 100,
        totalTargetAmountVnd: 100000,
        completionPercentage: 100.0,
        funds: [
          FundCollectionItemEntity(
            id: 2,
            name: 'Quỹ Hoàn thành',
            status: FundCollectionStatus.completed,
            statusText: 'Hoàn thành',
          ),
        ],
      );

      mockRepo.customOverviewHandler = (groupId, search, timeFilter, status) {
        if (status == FundCollectionStatus.collecting) {
          return completerCollecting.future;
        } else {
          return Future.value(completedOverview);
        }
      };

      await cubit.loadGroupFunds(10);

      // Trigger slow collecting filter
      cubit.setStatusFilter(FundCollectionStatus.collecting);

      // Quickly change to completed filter (fast)
      cubit.setStatusFilter(FundCollectionStatus.completed);
      await Future.delayed(Duration.zero);

      expect(cubit.state.selectedStatusFilter, FundCollectionStatus.completed);
      expect(cubit.state.filteredFunds.first.name, 'Quỹ Hoàn thành');

      // Now slow collecting filter arrives
      completerCollecting.complete(mockRepo.overviewResult);
      await Future.delayed(Duration.zero);

      // State must not be overwritten
      expect(cubit.state.selectedStatusFilter, FundCollectionStatus.completed);
      expect(cubit.state.filteredFunds.first.name, 'Quỹ Hoàn thành');
    });

    test('FUND-03: in-flight response completing after reset() is discarded', () async {
      final completer = Completer<GroupFundsOverviewEntity>();
      mockRepo.customOverviewHandler = (groupId, search, timeFilter, status) => completer.future;

      final future = cubit.loadGroupFunds(10);
      expect(cubit.state.status, FundsStatus.loading);

      cubit.reset();
      expect(cubit.state.status, FundsStatus.initial);
      expect(cubit.state.overview, isNull);

      completer.complete(mockRepo.overviewResult);
      await future;

      // State remains initial, not overwritten by delayed response
      expect(cubit.state.status, FundsStatus.initial);
      expect(cubit.state.overview, isNull);
    });
  });
}
