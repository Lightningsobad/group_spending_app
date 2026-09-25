class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://api.groupspending.xyz/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
