import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/network/api_client.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/features/debts/data/datasources/debts_remote_data_source.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';

class TestStubAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  TestStubAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Map<String, dynamic> data, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late TokenStorage tokenStorage;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tokenStorage = TokenStorage();
    await tokenStorage.saveTokens(
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );
  });

  group('DebtsRemoteDataSourceImpl simplified debt API tests', () {
    test('sendSimplifiedDebtReminder sends POST /groups/{groupId}/debts/simplified/remind', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Đã gửi lời nhắc nợ',
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = DebtsRemoteDataSourceImpl(apiClient);

      await dataSource.sendSimplifiedDebtReminder(
        10,
        debtorId: 2,
        creditorId: 1,
        expectedAmount: 350,
      );

      expect(capturedOptions?.method, 'POST');
      expect(capturedOptions?.path, '/groups/10/debts/simplified/remind');
      expect(capturedData, isA<Map<String, dynamic>>());
      final map = capturedData as Map<String, dynamic>;
      expect(map['debtorId'], 2);
      expect(map['creditorId'], 1);
      expect(map['expectedAmount'], 350);
      expect(map.containsKey('customMessage'), isFalse);
    });

    test('previewSimplifiedDebtPayment sends POST /groups/{groupId}/debts/simplified/payment-preview', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Lập kế hoạch thanh toán thành công',
          'data': {
            'planToken': 'test_plan_token_123',
            'groupId': 10,
            'debtorId': 1,
            'debtorName': 'Nguyễn Văn A',
            'creditorId': 2,
            'creditorName': 'Trần Văn B',
            'amount': 150,
            'amountVnd': 150000,
            'expiresAt': '2026-10-20T22:00:00Z',
            'allocatedSplits': [
              {
                'expenseSplitId': 12,
                'expenseId': 5,
                'expenseTitle': 'Lẩu Haidilao',
                'payerId': 2,
                'payerName': 'Trần Văn B',
                'participantId': 1,
                'participantName': 'Nguyễn Văn A',
                'originalAmount': 150,
                'originalAmountVnd': 150000,
                'settledAmount': 0,
                'settledAmountVnd': 0,
                'remainingAmount': 150,
                'remainingAmountVnd': 150000,
                'allocatedAmount': 150,
                'allocatedAmountVnd': 150000,
                'allocationType': 'DIRECT',
              }
            ],
          },
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = DebtsRemoteDataSourceImpl(apiClient);

      final result = await dataSource.previewSimplifiedDebtPayment(
        10,
        creditorId: 2,
        expectedAmount: 150,
      );

      expect(capturedOptions?.method, 'POST');
      expect(capturedOptions?.path, '/groups/10/debts/simplified/payment-preview');
      expect(capturedData['creditorId'], 2);
      expect(capturedData['expectedAmount'], 150);
      expect(result.planToken, 'test_plan_token_123');
      expect(result.amountVnd, 150000);
      expect(result.allocatedSplits.length, 1);
      expect(result.allocatedSplits.first.expenseSplitId, 12);
    });

    test('paySimplifiedDebt sends POST /groups/{groupId}/debts/simplified/pay with planToken', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Đã gửi yêu cầu xác nhận trả nợ',
          'data': {
            'id': 501,
            'groupId': 10,
            'debtorId': 1,
            'debtorName': 'Nguyễn Văn Debtor',
            'creditorId': 2,
            'creditorName': 'Trần Văn Creditor',
            'amount': 150,
            'amountVnd': 150000,
            'status': 'WAITING_FOR_CONFIRMATION',
            'action': 'NONE',
          },
        }, statusCode: 201);
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = DebtsRemoteDataSourceImpl(apiClient);

      final result = await dataSource.paySimplifiedDebt(
        10,
        planToken: 'test_plan_token_123',
        idempotencyKey: 'idemp_uuid_001',
      );

      expect(capturedOptions?.method, 'POST');
      expect(capturedOptions?.path, '/groups/10/debts/simplified/pay');
      expect(capturedOptions?.headers['Idempotency-Key'], 'idemp_uuid_001');
      expect(capturedData['planToken'], 'test_plan_token_123');
      expect(result.id, 501);
      expect(result.status, DebtStatus.waitingForConfirmation);
      expect(result.amountVnd, 150000);
    });

    test('confirmDebtSettlement sends POST /debt-settlements/{settlementId}/confirm with reason', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Đã từ chối xác nhận',
          'data': {
            'id': 501,
            'groupId': 10,
            'debtorId': 1,
            'debtorName': 'Nguyễn Văn Debtor',
            'creditorId': 2,
            'creditorName': 'Trần Văn Creditor',
            'amount': 150,
            'amountVnd': 150000,
            'status': 'REJECTED',
            'rejectionReason': 'Chưa thấy tiền vào tài khoản',
            'action': 'NONE',
          },
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = DebtsRemoteDataSourceImpl(apiClient);

      final result = await dataSource.confirmDebtSettlement(
        501,
        confirmed: false,
        reason: 'Chưa thấy tiền vào tài khoản',
      );

      expect(capturedOptions?.method, 'POST');
      expect(capturedOptions?.path, '/debt-settlements/501/confirm');
      expect(capturedData['confirmed'], isFalse);
      expect(capturedData['reason'], 'Chưa thấy tiền vào tài khoản');
      expect(result.id, 501);
      expect(result.status, DebtStatus.rejected);
      expect(result.rejectionReason, 'Chưa thấy tiền vào tài khoản');
    });

    test('getGroupDebtSettlements sends GET /groups/{groupId}/debt-settlements and parses paginated content', () async {
      RequestOptions? capturedOptions;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        return jsonResponse({
          'success': true,
          'data': {
            'content': [
              {
                'id': 501,
                'groupId': 10,
                'debtorId': 2,
                'creditorId': 1,
                'amount': 150,
                'amountVnd': 150000,
                'status': 'WAITING_FOR_CONFIRMATION',
              },
            ],
            'pageable': {'pageNumber': 0, 'pageSize': 20},
            'totalElements': 1,
            'totalPages': 1,
          },
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = DebtsRemoteDataSourceImpl(apiClient);

      final result = await dataSource.getGroupDebtSettlements(10, status: 'WAITING_FOR_CONFIRMATION');

      expect(capturedOptions?.method, 'GET');
      expect(capturedOptions?.path, '/groups/10/debt-settlements');
      expect(capturedOptions?.queryParameters['status'], 'WAITING_FOR_CONFIRMATION');
      expect(result.length, 1);
      expect(result.first.id, 501);
      expect(result.first.isWaitingForConfirmation, isTrue);
    });
  });
}
