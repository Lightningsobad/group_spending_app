import '../entities/fund_entities.dart';
import '../entities/fund_enums.dart';

abstract class FundsRepository {
  Future<GroupFundsOverviewEntity> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  });

  Future<FundCollectionEntity> createFundCollection(
    int groupId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  });

  Future<FundCollectionEntity> updateFundCollection(
    int fundId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  });

  Future<void> deleteFundCollection(int fundId);

  Future<FundCollectionEntity> getFundCollectionDetails(int fundId);

  Future<FundCollectionEntity> markMemberPaid(int fundId, int targetUserId);

  Future<void> sendFundReminder(int fundId);

  Future<List<int>> exportFundCsv(int fundId);
}
