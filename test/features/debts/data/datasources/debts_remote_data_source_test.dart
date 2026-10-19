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
  ) => handler(options);

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

    test('paySimplifiedDebt sends POST /groups/{groupId}/debts/simplified/pay and returns settlement', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Đã gửi yêu cầu xác nhận tất toán công nợ',
          'data': {
            'id': 501,
            'groupId': 10,
            'debtorId': 2,
            'debtorName': 'Nguyễn Văn Debtor',
            'creditorId': 1,
            'creditorName': 'Trần Văn Creditor',
            'amount': 150,
            'amountVnd': 150000,
            'status': 'WAITING_FOR_CONFIRMATION',
            'note': 'Đã chuyển MBBank',
          },
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = DebtsRemoteDataSourceImpl(apiClient);

      final result = await dataSource.paySimplifiedDebt(
        10,
        creditorId: 1,
        amount: 150000,
        note: 'Đã chuyển MBBank',
      );

      expect(capturedOptions?.method, 'POST');
      expect(capturedOptions?.path, '/groups/10/debts/simplified/pay');
      expect(capturedData['creditorId'], 1);
      expect(capturedData['amount'], 150000);
      expect(capturedData['note'], 'Đã chuyển MBBank');
      expect(result.id, 501);
      expect(result.status, DebtStatus.waitingForConfirmation);
      expect(result.amountVnd, 150000);
    });

    test('confirmDebtSettlement sends POST /debt-settlements/{settlementId}/confirm', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Đã xác nhận tất toán thành công',
          'data': {
            'id': 501,
            'groupId': 10,
            'debtorId': 2,
            'debtorName': 'Nguyễn Văn Debtor',
            'creditorId': 1,
            'creditorName': 'Trần Văn Creditor',
            'amount': 150,
            'amountVnd': 150000,
            'status': 'SETTLED',
          },
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = DebtsRemoteDataSourceImpl(apiClient);

      final result = await dataSource.confirmDebtSettlement(501, confirmed: true);

      expect(capturedOptions?.method, 'POST');
      expect(capturedOptions?.path, '/debt-settlements/501/confirm');
      expect(capturedData['confirmed'], isTrue);
      expect(result.id, 501);
      expect(result.status, DebtStatus.settled);
    });

    test('getGroupDebtSettlements sends GET /groups/{groupId}/debts/settlements and parses list', () async {
      RequestOptions? capturedOptions;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        return jsonResponse({
          'success': true,
          'data': [
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
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = DebtsRemoteDataSourceImpl(apiClient);

      final result = await dataSource.getGroupDebtSettlements(10);

      expect(capturedOptions?.method, 'GET');
      expect(capturedOptions?.path, '/groups/10/debt-settlements');
      expect(result.length, 1);
      expect(result.first.id, 501);
      expect(result.first.isWaitingForConfirmation, isTrue);
    });
  });
}
