class AppConfig {
  AppConfig._();

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.groupspending.xyz/api/v1',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '417752871964-3plv3ntal9gjbou5s1bj7n1mqt6u4n2n.apps.googleusercontent.com',
  );

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '417752871964-608qvusfmtjed38t1mkhj7hrbq7095nk.apps.googleusercontent.com',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static void validate() {
    if (baseUrl.trim().isEmpty) {
      throw StateError('API_BASE_URL cannot be empty.');
    }
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw StateError('API_BASE_URL is not a valid URL: $baseUrl');
    }
  }
}
