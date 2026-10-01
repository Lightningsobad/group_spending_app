import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/features/settings/data/services/vietqr_bank_service.dart';

class _FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  _FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('VietQrBankService Tests', () {
    test('getBanks returns parsed list on 200 response', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) {
        return ResponseBody.fromString(
          '''
          {
            "code": "00",
            "desc": "Get Bank list successful!",
            "data": [
              {
                "id": 17,
                "name": "Ngân hàng TMCP Công thương Việt Nam",
                "code": "ICB",
                "bin": "970415",
                "shortName": "VietinBank",
                "logo": "https://cdn.vietqr.io/img/ICB.png"
              },
              {
                "id": 21,
                "name": "Ngân hàng TMCP Quân đội",
                "code": "MB",
                "bin": "970422",
                "shortName": "MBBank",
                "logo": "https://cdn.vietqr.io/img/MB.png"
              }
            ]
          }
          ''',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = VietQrBankService(dio: dio);
      final banks = await service.getBanks();

      expect(banks.length, 2);
      expect(banks[0].shortName, 'VietinBank');
      expect(banks[0].bin, '970415');
      expect(banks[1].code, 'MB');
      expect(banks[1].shortName, 'MBBank');
    });

    test('getBanks throws AppException on network failure with no fallback', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Network unreachable',
        );
      });

      final service = VietQrBankService(dio: dio);
      expect(
        () => service.getBanks(),
        throwsA(isA<AppException>()),
      );
    });
  });
}
