import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'firebase_options.dart';

Future<void> bootstrap({
  Widget Function(AppPreferences appPreferences, TokenStorage tokenStorage)?
  builder,
}) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  AppConfig.validate();

  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

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
