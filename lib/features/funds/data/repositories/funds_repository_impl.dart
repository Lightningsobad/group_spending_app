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
    final amountInt = targetAmountPerPersonVnd.toInt();
    if (amountInt < 1000 || amountInt % 1000 != 0) {
      throw ArgumentError('Số tiền mỗi người phải tối thiểu 1.000đ và là bội số của 1.000đ');
    }
    final targetAmountK = amountInt ~/ 1000;
    final request = CreateFundCollectionRequest(
      name: name,
      description: description,
      targetAmountPerPerson: targetAmountK,
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
    final amountInt = targetAmountPerPersonVnd.toInt();
    if (amountInt < 1000 || amountInt % 1000 != 0) {
      throw ArgumentError('Số tiền mỗi người phải tối thiểu 1.000đ và là bội số của 1.000đ');
    }
    final targetAmountK = amountInt ~/ 1000;
    final request = UpdateFundCollectionRequest(
      name: name,
      description: description,
      targetAmountPerPerson: targetAmountK,
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
