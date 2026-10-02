import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/vietqr_bank_model.dart';

class VietQrBankService {
  final Dio _dio;

  VietQrBankService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  /// Gọi trực tiếp API VietQR không cache và không fallback theo yêu cầu.
  Future<List<VietQrBankModel>> getBanks() async {
    try {
      final response = await _dio.get('https://api.vietqr.io/v2/banks');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>?;
        if (list != null) {
          return list
              .map((item) =>
                  VietQrBankModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      throw const AppException(
        message: 'Dữ liệu danh sách ngân hàng không hợp lệ.',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AppException(
          message: 'Kết nối mạng quá hạn khi tải danh sách ngân hàng. Vui lòng thử lại.',
        );
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const AppException(
          message: 'Không thể kết nối đến máy chủ VietQR. Vui lòng kiểm tra kết nối mạng.',
        );
      }
      throw AppException(
        message: e.message ?? 'Lỗi khi tải danh sách ngân hàng.',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Đã xảy ra sự cố khi tải danh sách ngân hàng: $e',
      );
    }
  }
}
