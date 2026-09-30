import '../../domain/entities/fund_entities.dart';
import '../../domain/entities/fund_enums.dart';
import '../../domain/repositories/funds_repository.dart';
import '../datasources/funds_remote_data_source.dart';
import '../models/fund_models.dart';

class FundsRepositoryImpl implements FundsRepository {
  final FundsRemoteDataSource remoteDataSource;

  FundsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<GroupFundsOverviewEntity> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  }) {
    return remoteDataSource.getGroupFundsOverview(
      groupId,
      search: search,
      timeFilter: timeFilter,
      status: status,
    );
  }

  @override
  Future<FundCollectionEntity> createFundCollection(
    int groupId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) {
    final targetAmountK = (targetAmountPerPersonVnd / 1000).round();
    final request = CreateFundCollectionRequest(
      name: name,
      description: description,
      targetAmountPerPerson: targetAmountK < 1 ? 1 : targetAmountK,
      dueDate: dueDate,
      memberUserIds: memberUserIds,
    );
    return remoteDataSource.createFundCollection(groupId, request);
  }

  @override
  Future<FundCollectionEntity> updateFundCollection(
    int fundId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) {
    final targetAmountK = (targetAmountPerPersonVnd / 1000).round();
    final request = UpdateFundCollectionRequest(
      name: name,
      description: description,
      targetAmountPerPerson: targetAmountK < 1 ? 1 : targetAmountK,
      dueDate: dueDate,
      memberUserIds: memberUserIds,
    );
    return remoteDataSource.updateFundCollection(fundId, request);
  }

  @override
  Future<void> deleteFundCollection(int fundId) {
    return remoteDataSource.deleteFundCollection(fundId);
  }

  @override
  Future<FundCollectionEntity> getFundCollectionDetails(int fundId) {
    return remoteDataSource.getFundCollectionDetails(fundId);
  }

  @override
  Future<FundCollectionEntity> markMemberPaid(int fundId, int targetUserId) {
    return remoteDataSource.markMemberPaid(fundId, targetUserId);
  }

  @override
  Future<void> sendFundReminder(int fundId) {
    return remoteDataSource.sendFundReminder(fundId);
  }

  @override
  Future<List<int>> exportFundCsv(int fundId) {
    return remoteDataSource.exportFundCsv(fundId);
  }
}
