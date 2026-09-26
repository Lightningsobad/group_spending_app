import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'l10n/app_localizations.dart';
import 'core/l10n/locale_cubit.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/session/session_coordinator.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
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
  final ThemeCubit? themeCubit;
  final LocaleCubit? localeCubit;

  const FairShareApp({
    super.key,
    required this.appPreferences,
    required this.tokenStorage,
    this.apiClient,
    this.authRepository,
    this.sessionCoordinator,
    this.themeCubit,
    this.localeCubit,
  });

  @override
  State<FairShareApp> createState() => _FairShareAppState();
}

class _FairShareAppState extends State<FairShareApp> {
  late final SessionCoordinator _sessionCoordinator;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final LocaleCubit _localeCubit;
  late final GoRouter _router;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _sessionCoordinator =
        widget.sessionCoordinator ??
        SessionCoordinator(tokenStorage: widget.tokenStorage);
    _sessionCoordinator.init();

    _themeCubit = widget.themeCubit ?? ThemeCubit(widget.appPreferences);
    _localeCubit = widget.localeCubit ?? LocaleCubit(widget.appPreferences);

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
    _themeCubit.close();
    _localeCubit.close();
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<ThemeCubit>.value(value: _themeCubit),
          BlocProvider<LocaleCubit>.value(value: _localeCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  title: 'FairShare',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  locale: locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  routerConfig: _router,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
