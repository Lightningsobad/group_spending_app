import '../../domain/entities/auth_tokens_entity.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthTokensEntity {
  const AuthResponseModel({
    super.accessToken,
    super.refreshToken,
    super.tokenType = 'Bearer',
    super.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenType: (json['tokenType'] as String?) ?? 'Bearer',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  AuthTokensEntity toEntity() => this;
}
