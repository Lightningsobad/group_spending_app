import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/constants/app_colors.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final appPreferences = await AppPreferences.init();
  final tokenStorage = TokenStorage();

  runApp(
    FairShareApp(
      appPreferences: appPreferences,
      tokenStorage: tokenStorage,
    ),
  );
}

class FairShareApp extends StatelessWidget {
  final AppPreferences appPreferences;
  final TokenStorage tokenStorage;

  const FairShareApp({
    super.key,
    required this.appPreferences,
    required this.tokenStorage,
  });

  @override
  Widget build(BuildContext context) {
    late final AuthCubit authCubit;

    final apiClient = ApiClient(
      tokenStorage: tokenStorage,
      onSessionExpired: () {
        authCubit.logout();
      },
    );

    final remoteDataSource = AuthRemoteDataSourceImpl(apiClient);
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      tokenStorage: tokenStorage,
      appPreferences: appPreferences,
    );

    authCubit = AuthCubit(authRepository);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppPreferences>.value(value: appPreferences),
        RepositoryProvider<TokenStorage>.value(value: tokenStorage),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
      ],
      child: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: MaterialApp.router(
          title: 'FairShare',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGreen,
              primary: AppColors.primaryGreen,
              secondary: AppColors.emerald,
              surface: AppColors.backgroundLight,
            ),
            scaffoldBackgroundColor: AppColors.backgroundLight,
            textTheme: GoogleFonts.nunitoTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
