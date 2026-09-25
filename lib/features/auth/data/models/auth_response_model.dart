import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthTokensEntity {
  const AuthResponseModel({
    super.accessToken,
    super.refreshToken,
    super.tokenType = 'Bearer',
    super.user,
  });

  factory AuthResponseModel.fromJson(
    Map<String, dynamic> json, {
    bool requireTokens = false,
  }) {
    final accessToken = json['accessToken'] as String?;
    final refreshToken = json['refreshToken'] as String?;

    if (requireTokens) {
      if (accessToken == null || accessToken.trim().isEmpty) {
        throw const AppException(
          message: 'Dữ liệu phản hồi thiếu accessToken bắt buộc.',
        );
      }
    }

    return AuthResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: (json['tokenType'] as String?) ?? 'Bearer',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  AuthTokensEntity toEntity() => this;
}
