import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/network/api_client.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/features/groups/data/datasources/groups_remote_data_source.dart';

class StubAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  StubAdapter(this.handler);

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
  late Dio dio;
  late ApiClient apiClient;
  late GroupsRemoteDataSourceImpl dataSource;
  RequestOptions? lastRequestOptions;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    tokenStorage = TokenStorage();
    dio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
    dio.httpClientAdapter = StubAdapter((options) async {
      lastRequestOptions = options;
      return jsonResponse({
        'success': true,
        'message': 'Thành công',
        'data': {
          'id': 10,
          'name': 'Nhóm bóng đá',
          'description': '',
          'defaultCurrency': 'VND',
          'category': 'Sport & Clubs',
          'status': 'ACTIVE',
          'ownerId': 1,
          'role': 'ADMIN',
          'userBalance': 0,
          'memberCount': 1,
        },
      });
    });

    apiClient = ApiClient(tokenStorage: tokenStorage, customDio: dio);
    dataSource = GroupsRemoteDataSourceImpl(apiClient);
  });

  group('GroupsRemoteDataSourceImpl.updateGroup tests', () {
    test('D01: with description trims and sends in payload', () async {
      await dataSource.updateGroup(
        10,
        name: 'Nhóm mới  ',
        description: '  Mô tả mới  ',
      );

      expect(lastRequestOptions, isNotNull);
      expect(lastRequestOptions!.method, 'PUT');
      expect(lastRequestOptions!.path, '/groups/10');
      final payload = lastRequestOptions!.data as Map<String, dynamic>;
      expect(payload['name'], 'Nhóm mới');
      expect(payload['description'], 'Mô tả mới');
    });

    test('D02: clearDescription = true sends empty string in payload', () async {
      await dataSource.updateGroup(
        10,
        name: 'Nhóm bóng đá',
        clearDescription: true,
      );

      expect(lastRequestOptions, isNotNull);
      expect(lastRequestOptions!.method, 'PUT');
      final payload = lastRequestOptions!.data as Map<String, dynamic>;
      expect(payload['name'], 'Nhóm bóng đá');
      expect(payload.containsKey('description'), isTrue);
      expect(payload['description'], '');
    });

    test('D04: clearDescription = false and description = null omits description key', () async {
      await dataSource.updateGroup(
        10,
        name: 'Chỉ đổi tên',
        description: null,
        clearDescription: false,
      );

      expect(lastRequestOptions, isNotNull);
      final payload = lastRequestOptions!.data as Map<String, dynamic>;
      expect(payload['name'], 'Chỉ đổi tên');
      expect(payload.containsKey('description'), isFalse);
    });
  });
}
