import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';

enum SessionStatus { initial, authenticated, unauthenticated, sessionExpired }

/// Điều phối phiên ứng dụng trung lập tại core/session.
/// Không phụ thuộc vào feature/auth, UserEntity hay Dio.
class SessionCoordinator extends ChangeNotifier {
  final TokenStorage tokenStorage;
  SessionStatus _status = SessionStatus.initial;
  int _sessionEpoch = 0;

  SessionCoordinator({required this.tokenStorage});

  SessionStatus get status => _status;
  int get sessionEpoch => _sessionEpoch;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  Future<void> init() async {
    final token = await tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _status = SessionStatus.authenticated;
    } else {
      _status = SessionStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Lưu token an toàn chỉ khi epoch của response khớp với thế hệ phiên hiện tại.
  /// Ngăn chặn response cũ ghi đè dữ liệu sau khi người dùng đã logout hoặc chuyển màn hình.
  Future<bool> commitTokens({
    required String accessToken,
    required String refreshToken,
    required int forEpoch,
  }) async {
    if (forEpoch != _sessionEpoch) {
      return false;
    }

    await tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    if (forEpoch == _sessionEpoch) {
      _status = SessionStatus.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Đăng xuất hoặc kết thúc phiên; tăng thế hệ phiên để vô hiệu hóa response cũ đang bay.
  Future<void> clearSession({bool isExpired = false}) async {
    _sessionEpoch++;
    await tokenStorage.clearTokens();
    _status = isExpired
        ? SessionStatus.sessionExpired
        : SessionStatus.unauthenticated;
    notifyListeners();
  }

  /// Tăng thế hệ phiên thủ công (khi hủy bỏ một luồng xác thực)
  int advanceEpoch() {
    _sessionEpoch++;
    return _sessionEpoch;
  }
}
