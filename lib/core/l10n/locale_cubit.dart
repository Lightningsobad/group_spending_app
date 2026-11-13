import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/app_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  final AppPreferences _appPreferences;

  LocaleCubit(this._appPreferences) : super(_loadInitialLocale(_appPreferences));

  static Locale _loadInitialLocale(AppPreferences prefs) {
    final code = prefs.getAppLocale();
    return Locale(code == 'en' ? 'en' : 'vi');
  }

  Future<void> toggleLocale() async {
    final next = state.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    await setLocale(next);
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _appPreferences.setAppLocale(locale.languageCode);
  }

  bool get isVietnamese => state.languageCode == 'vi';
  bool get isEnglish => state.languageCode == 'en';
}
