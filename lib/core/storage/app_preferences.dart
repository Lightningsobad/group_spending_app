import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _userFullNameKey = 'user_full_name';
  static const String _userEmailKey = 'user_email';

  static const String _themeModeKey = 'theme_mode';
  static const String _appLocaleKey = 'app_locale';

  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  static Future<AppPreferences> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }

  bool getHasSeenOnboarding() {
    return _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<bool> setHasSeenOnboarding(bool value) {
    return _prefs.setBool(_hasSeenOnboardingKey, value);
  }

  String? getUserFullName() {
    return _prefs.getString(_userFullNameKey);
  }

  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  Future<void> saveUserInfo({
    required String fullName,
    required String email,
  }) async {
    await Future.wait([
      _prefs.setString(_userFullNameKey, fullName),
      _prefs.setString(_userEmailKey, email),
    ]);
  }

  Future<void> clearUserInfo() async {
    await Future.wait([
      _prefs.remove(_userFullNameKey),
      _prefs.remove(_userEmailKey),
    ]);
  }

  String getThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'light';
  }

  Future<bool> setThemeMode(String mode) {
    return _prefs.setString(_themeModeKey, mode);
  }

  String getAppLocale() {
    return _prefs.getString(_appLocaleKey) ?? 'vi';
  }

  Future<bool> setAppLocale(String localeCode) {
    return _prefs.setString(_appLocaleKey, localeCode);
  }
}
