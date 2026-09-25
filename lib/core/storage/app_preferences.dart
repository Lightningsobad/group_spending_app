import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _userFullNameKey = 'user_full_name';
  static const String _userEmailKey = 'user_email';

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
}
