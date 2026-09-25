import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/auth/data/models/auth_response_model.dart';
import 'package:group_spending_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('should correctly deserialize from JSON', () {
      final json = {
        'id': 15,
        'email': 'nguyenvana@example.com',
        'fullName': 'Nguyễn Văn A',
        'phone': '0987654321',
        'avatarUrl': null,
        'role': 'ROLE_USER',
        'isEmailVerified': false,
        'createdAt': '2026-09-24T07:15:20.123Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 15);
      expect(user.email, 'nguyenvana@example.com');
      expect(user.fullName, 'Nguyễn Văn A');
      expect(user.phone, '0987654321');
      expect(user.avatarUrl, isNull);
      expect(user.role, 'ROLE_USER');
      expect(user.isEmailVerified, isFalse);
      expect(user.createdAt, '2026-09-24T07:15:20.123Z');
    });

    test('should correctly serialize to JSON', () {
      const user = UserModel(
        id: 15,
        email: 'nguyenvana@example.com',
        fullName: 'Nguyễn Văn A',
        phone: '0987654321',
        role: 'ROLE_USER',
        isEmailVerified: true,
      );

      final json = user.toJson();

      expect(json['id'], 15);
      expect(json['email'], 'nguyenvana@example.com');
      expect(json['isEmailVerified'], isTrue);
    });
  });

  group('AuthResponseModel Tests', () {
    test('should correctly deserialize AuthResponse from JSON', () {
      final json = {
        'accessToken': 'sample_access_token',
        'refreshToken': 'sample_refresh_token',
        'tokenType': 'Bearer',
        'user': {
          'id': 15,
          'email': 'nguyenvana@example.com',
          'fullName': 'Nguyễn Văn A',
          'role': 'ROLE_USER',
          'isEmailVerified': true,
        },
      };

      final authResponse = AuthResponseModel.fromJson(json);

      expect(authResponse.accessToken, 'sample_access_token');
      expect(authResponse.refreshToken, 'sample_refresh_token');
      expect(authResponse.tokenType, 'Bearer');
      expect(authResponse.user, isNotNull);
      expect(authResponse.user!.fullName, 'Nguyễn Văn A');
      expect(authResponse.user!.isEmailVerified, isTrue);
    });
  });
}
