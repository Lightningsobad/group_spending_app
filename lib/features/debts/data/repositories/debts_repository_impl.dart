import '../../domain/repositories/debts_repository.dart';
import '../datasources/debts_remote_data_source.dart';
import '../models/debt_overview_model.dart';

class DebtsRepositoryImpl implements DebtsRepository {
  final DebtsRemoteDataSource remoteDataSource;

  DebtsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DebtOverviewModel> getDebtOverview() {
    return remoteDataSource.getDebtOverview();
  }
}
