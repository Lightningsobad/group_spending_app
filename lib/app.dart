import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_routes.dart';
import 'core/constants/app_colors.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/session/session_coordinator.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

class FairShareApp extends StatefulWidget {
  final AppPreferences appPreferences;
  final TokenStorage tokenStorage;
  final ApiClient? apiClient;
  final AuthRepository? authRepository;
  final SessionCoordinator? sessionCoordinator;

  const FairShareApp({
    super.key,
    required this.appPreferences,
    required this.tokenStorage,
    this.apiClient,
    this.authRepository,
    this.sessionCoordinator,
  });

  @override
  State<FairShareApp> createState() => _FairShareAppState();
}

class _FairShareAppState extends State<FairShareApp> {
  late final SessionCoordinator _sessionCoordinator;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final AuthCubit _authCubit;
  late final GoRouter _router;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _sessionCoordinator =
        widget.sessionCoordinator ??
        SessionCoordinator(tokenStorage: widget.tokenStorage);
    _sessionCoordinator.init();

    _apiClient =
        widget.apiClient ??
        ApiClient(
          tokenStorage: widget.tokenStorage,
          sessionCoordinator: _sessionCoordinator,
          onSessionExpired: () {
            if (!_isDisposed) {
              _authCubit.logout();
            }
          },
        );

    final remoteDataSource = AuthRemoteDataSourceImpl(_apiClient);
    _authRepository =
        widget.authRepository ??
        AuthRepositoryImpl(
          remoteDataSource: remoteDataSource,
          tokenStorage: widget.tokenStorage,
          appPreferences: widget.appPreferences,
          sessionCoordinator: _sessionCoordinator,
        );

    _authCubit = AuthCubit(_authRepository);

    _router = AppRouter.createRouter(
      routes: buildAppRoutes(),
      sessionCoordinator: _sessionCoordinator,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppPreferences>.value(value: widget.appPreferences),
        RepositoryProvider<TokenStorage>.value(value: widget.tokenStorage),
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
      ],
      child: BlocProvider<AuthCubit>.value(
        value: _authCubit,
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
            textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
          ),
          routerConfig: _router,
        ),
      ),
    );
  }
}
