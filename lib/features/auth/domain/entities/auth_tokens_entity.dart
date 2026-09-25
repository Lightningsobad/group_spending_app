import 'user_entity.dart';

class AuthTokensEntity {
  final String? accessToken;
  final String? refreshToken;
  final String tokenType;
  final UserEntity? user;

  const AuthTokensEntity({
    this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.user,
  });
}
