import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_entities.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_enums.dart';
import 'package:group_spending_app/features/funds/domain/repositories/funds_repository.dart';
import 'package:group_spending_app/features/funds/presentation/cubit/fund_detail_cubit.dart';
import 'package:group_spending_app/features/funds/presentation/cubit/fund_detail_state.dart';

class MockDetailFundsRepository implements FundsRepository {
  FundCollectionEntity detailResult = const FundCollectionEntity(
    id: 101,
    groupId: 5,
    name: 'Quỹ du lịch',
    description: 'Chi phí dã ngoại',
    targetAmountPerPerson: 100,
    targetAmountPerPersonVnd: 100000,
    dueDate: '2026-10-20',
    totalTargetAmount: 200,
    totalTargetAmountVnd: 200000,
    totalCollectedAmount: 100,
    totalCollectedAmountVnd: 100000,
    paidCount: 1,
    totalMemberCount: 2,
    status: FundCollectionStatus.collecting,
    members: [
      FundMemberEntity(
        id: 1,
        userId: 1,
        fullName: 'Nguyễn Văn A',
        status: FundMemberStatus.paid,
      ),
      FundMemberEntity(
        id: 2,
        userId: 2,
        fullName: 'Trần Văn B',
        status: FundMemberStatus.pending,
      ),
    ],
  );

  bool reminderSent = false;
  bool deleted = false;

  @override
  Future<GroupFundsOverviewEntity> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  }) async {
    throw UnimplementedError();
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
    return detailResult;
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
    return detailResult;
  }

  @override
  Future<void> deleteFundCollection(int fundId) async {
    deleted = true;
  }

  @override
  Future<FundCollectionEntity> getFundCollectionDetails(int fundId) async {
    return detailResult;
  }

  @override
  Future<FundCollectionEntity> markMemberPaid(int fundId, int targetUserId) async {
    return detailResult;
  }

  @override
  Future<void> sendFundReminder(int fundId) async {
    reminderSent = true;
  }

  @override
  Future<List<int>> exportFundCsv(int fundId) async {
    return [10, 20, 30];
  }
}

void main() {
  group('FundDetailCubit Test', () {
    late MockDetailFundsRepository mockRepo;
    late DataSyncCoordinator syncCoordinator;
    late FundDetailCubit cubit;

    setUp(() {
      mockRepo = MockDetailFundsRepository();
      syncCoordinator = DataSyncCoordinator();
      cubit = FundDetailCubit(
        mockRepo,
        dataSyncCoordinator: syncCoordinator,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('loadFundDetails populates fund details', () async {
      await cubit.loadFundDetails(101);

      expect(cubit.state.status, FundDetailStatus.success);
      expect(cubit.state.fund?.name, 'Quỹ du lịch');
      expect(cubit.state.fund?.paidCount, 1);
      expect(cubit.state.fund?.totalMemberCount, 2);
      expect(cubit.state.canSendReminder, isTrue);
    });

    test('createFund creates and updates state', () async {
      final success = await cubit.createFund(
        5,
        name: 'Quỹ dã ngoại',
        targetAmountPerPersonVnd: 100000,
      );

      expect(success, isTrue);
      expect(cubit.state.status, FundDetailStatus.success);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('markMemberPaid marks member as paid', () async {
      await cubit.loadFundDetails(101);
      final success = await cubit.markMemberPaid(2);

      expect(success, isTrue);
      expect(cubit.state.isSubmitting, isFalse);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('sendReminder triggers reminder cooldown timer', () async {
      await cubit.loadFundDetails(101);
      await cubit.sendReminder();

      expect(mockRepo.reminderSent, isTrue);
      expect(cubit.state.remindCooldownSeconds, 60);
      expect(cubit.state.canSendReminder, isFalse);
    });

    test('deleteFund deletes fund collection and marks isDeleted', () async {
      await cubit.loadFundDetails(101);
      final success = await cubit.deleteFund();

      expect(success, isTrue);
      expect(mockRepo.deleted, isTrue);
      expect(cubit.state.isDeleted, isTrue);
    });
  });
}
