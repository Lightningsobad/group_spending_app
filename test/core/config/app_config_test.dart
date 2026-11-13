import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('Default configuration is valid', () {
      expect(AppConfig.baseUrl, isNotEmpty);
      expect(AppConfig.environment, isNotEmpty);
      expect(() => AppConfig.validate(), returnsNormally);
    });

    test('Timeout values are sane', () {
      expect(AppConfig.connectTimeout, greaterThan(Duration.zero));
      expect(AppConfig.receiveTimeout, greaterThan(Duration.zero));
    });
  });
}
