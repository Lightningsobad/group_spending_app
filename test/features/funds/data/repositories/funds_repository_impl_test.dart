import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/funds/data/datasources/funds_remote_data_source.dart';
import 'package:group_spending_app/features/funds/data/models/fund_models.dart';
import 'package:group_spending_app/features/funds/data/repositories/funds_repository_impl.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_enums.dart';

class MockFundsRemoteDataSource implements FundsRemoteDataSource {
  CreateFundCollectionRequest? lastCreateRequest;
  UpdateFundCollectionRequest? lastUpdateRequest;

  final FundCollectionModel dummyFund = const FundCollectionModel(
    id: 101,
    groupId: 1,
    name: 'Test Fund',
    targetAmountPerPerson: 200,
    targetAmountPerPersonVnd: 200000,
    totalTargetAmount: 400,
    totalTargetAmountVnd: 400000,
    totalCollectedAmount: 0,
    totalCollectedAmountVnd: 0,
    paidCount: 0,
    totalMemberCount: 2,
    status: FundCollectionStatus.collecting,
    members: [],
  );

  @override
  Future<FundCollectionModel> createFundCollection(
    int groupId,
    CreateFundCollectionRequest request,
  ) async {
    lastCreateRequest = request;
    return dummyFund;
  }

  @override
  Future<FundCollectionModel> updateFundCollection(
    int fundId,
    UpdateFundCollectionRequest request,
  ) async {
    lastUpdateRequest = request;
    return dummyFund;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('FundsRepositoryImpl Amount Normalization (FUND-02)', () {
    late MockFundsRemoteDataSource mockDataSource;
    late FundsRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockFundsRemoteDataSource();
      repository = FundsRepositoryImpl(remoteDataSource: mockDataSource);
    });

    test('createFundCollection passes integer amount in thousand VND for valid amount', () async {
      await repository.createFundCollection(
        1,
        name: 'Quỹ du lịch',
        targetAmountPerPersonVnd: 250000,
      );

      expect(mockDataSource.lastCreateRequest, isNotNull);
      expect(mockDataSource.lastCreateRequest!.targetAmountPerPerson, 250);
      expect(mockDataSource.lastCreateRequest!.name, 'Quỹ du lịch');
    });

    test('createFundCollection throws ArgumentError for non-multiple of 1000', () async {
      expect(
        () => repository.createFundCollection(
          1,
          name: 'Quỹ lẻ',
          targetAmountPerPersonVnd: 1499,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(mockDataSource.lastCreateRequest, isNull);
    });

    test('createFundCollection throws ArgumentError for amount < 1000', () async {
      expect(
        () => repository.createFundCollection(
          1,
          name: 'Quỹ quá nhỏ',
          targetAmountPerPersonVnd: 500,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(mockDataSource.lastCreateRequest, isNull);
    });

    test('updateFundCollection passes integer amount in thousand VND for valid amount', () async {
      await repository.updateFundCollection(
        101,
        name: 'Quỹ du lịch update',
        targetAmountPerPersonVnd: 100000,
      );

      expect(mockDataSource.lastUpdateRequest, isNotNull);
      expect(mockDataSource.lastUpdateRequest!.targetAmountPerPerson, 100);
      expect(mockDataSource.lastUpdateRequest!.name, 'Quỹ du lịch update');
    });

    test('updateFundCollection throws ArgumentError for non-multiple of 1000', () async {
      expect(
        () => repository.updateFundCollection(
          101,
          name: 'Quỹ lẻ',
          targetAmountPerPersonVnd: 100500,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(mockDataSource.lastUpdateRequest, isNull);
    });

    test('updateFundCollection throws ArgumentError for amount < 1000', () async {
      expect(
        () => repository.updateFundCollection(
          101,
          name: 'Quỹ 0đ',
          targetAmountPerPersonVnd: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(mockDataSource.lastUpdateRequest, isNull);
    });
  });
}
