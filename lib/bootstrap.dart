import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';

Future<void> bootstrap({
  Widget Function(AppPreferences appPreferences, TokenStorage tokenStorage)?
  builder,
}) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  AppConfig.validate();

  final appPreferences = await AppPreferences.init();
  final tokenStorage = TokenStorage();

  final appWidget = builder != null
      ? builder(appPreferences, tokenStorage)
      : FairShareApp(
          appPreferences: appPreferences,
          tokenStorage: tokenStorage,
        );

  runApp(appWidget);
}
