import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/app_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final AppPreferences _appPreferences;

  ThemeCubit(this._appPreferences) : super(_loadInitialMode(_appPreferences));

  static ThemeMode _loadInitialMode(AppPreferences prefs) {
    final saved = prefs.getThemeMode();
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _appPreferences.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
