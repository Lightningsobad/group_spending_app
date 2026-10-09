import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';
import 'l10n/app_localizations.dart';
import 'core/l10n/locale_cubit.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/session/session_coordinator.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_storage.dart';
import 'core/sync/data_sync_coordinator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'features/analytics/data/repositories/analytics_repository_impl.dart';
import 'features/analytics/domain/repositories/analytics_repository.dart';
import 'features/analytics/presentation/cubit/analytics_tab_cubit.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/debts/data/datasources/debts_remote_data_source.dart';
import 'features/debts/data/repositories/debts_repository_impl.dart';
import 'features/debts/domain/repositories/debts_repository.dart';
import 'features/debts/presentation/cubit/debts_cubit.dart';
import 'features/funds/data/datasources/funds_remote_data_source.dart';
import 'features/funds/data/repositories/funds_repository_impl.dart';
import 'features/funds/domain/repositories/funds_repository.dart';
import 'features/funds/presentation/cubit/funds_cubit.dart';
import 'features/expenses/data/datasources/expenses_remote_data_source.dart';
import 'features/expenses/data/repositories/expenses_repository_impl.dart';
import 'features/expenses/domain/repositories/expenses_repository.dart';
import 'features/expenses/presentation/cubit/expenses_cubit.dart';
import 'features/groups/data/datasources/groups_remote_data_source.dart';
import 'features/groups/data/repositories/groups_repository_impl.dart';
import 'features/groups/domain/repositories/groups_repository.dart';
import 'features/groups/presentation/cubit/groups_cubit.dart';
import 'features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'features/notifications/data/repositories/notifications_repository_impl.dart';
import 'features/notifications/domain/repositories/notifications_repository.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/notifications/presentation/widgets/in_app_notification_toast.dart';
import 'features/notifications/services/fcm_service.dart';
import 'features/notifications/services/notification_navigation_handler.dart';
import 'features/notifications/services/stomp_notification_service.dart';

class FairShareApp extends StatefulWidget {
  final AppPreferences appPreferences;
  final TokenStorage tokenStorage;
  final ApiClient? apiClient;
  final AuthRepository? authRepository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;
  final ThemeCubit? themeCubit;
  final LocaleCubit? localeCubit;
  final DebtsRepository? debtsRepository;
  final GroupsRepository? groupsRepository;
  final AnalyticsRepository? analyticsRepository;
  final FundsRepository? fundsRepository;
  final ExpensesRepository? expensesRepository;
  final DashboardCubit? dashboardCubit;
  final GroupsCubit? groupsCubit;
  final AnalyticsTabCubit? analyticsTabCubit;
  final DebtsCubit? debtsCubit;
  final FundsCubit? fundsCubit;
  final ExpensesCubit? expensesCubit;
  final NotificationsRepository? notificationsRepository;
  final NotificationsCubit? notificationsCubit;

  const FairShareApp({
    super.key,
    required this.appPreferences,
    required this.tokenStorage,
    this.apiClient,
    this.authRepository,
    this.sessionCoordinator,
    this.dataSyncCoordinator,
    this.themeCubit,
    this.localeCubit,
    this.debtsRepository,
    this.groupsRepository,
    this.analyticsRepository,
    this.fundsRepository,
    this.expensesRepository,
    this.notificationsRepository,
    this.dashboardCubit,
    this.groupsCubit,
    this.analyticsTabCubit,
    this.debtsCubit,
    this.fundsCubit,
    this.expensesCubit,
    this.notificationsCubit,
  });

  @override
  State<FairShareApp> createState() => _FairShareAppState();
}

class _FairShareAppState extends State<FairShareApp> {
  late final SessionCoordinator _sessionCoordinator;
  late final DataSyncCoordinator _dataSyncCoordinator;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final LocaleCubit _localeCubit;
  late final DebtsRepository _debtsRepository;
  late final GroupsRepository _groupsRepository;
  late final AnalyticsRepository _analyticsRepository;
  late final FundsRepository _fundsRepository;
  late final FundsCubit _fundsCubit;
  late final ExpensesRepository _expensesRepository;
  late final NotificationsRepository _notificationsRepository;
  late final NotificationsCubit _notificationsCubit;
  late final StompNotificationService _stompService;
  late final FcmService _fcmService;
  late final GoRouter _router;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _sessionCoordinator =
        widget.sessionCoordinator ??
        SessionCoordinator(tokenStorage: widget.tokenStorage);
    _sessionCoordinator.init();

    _dataSyncCoordinator =
        widget.dataSyncCoordinator ?? DataSyncCoordinator();

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

    final debtsRemoteDataSource = DebtsRemoteDataSourceImpl(_apiClient);
    _debtsRepository =
        widget.debtsRepository ??
        DebtsRepositoryImpl(remoteDataSource: debtsRemoteDataSource);

    final groupsRemoteDataSource = GroupsRemoteDataSourceImpl(_apiClient);
    _groupsRepository =
        widget.groupsRepository ??
        GroupsRepositoryImpl(remoteDataSource: groupsRemoteDataSource);

    final analyticsRemoteDataSource = AnalyticsRemoteDataSourceImpl(_apiClient);
    _analyticsRepository =
        widget.analyticsRepository ??
        AnalyticsRepositoryImpl(remoteDataSource: analyticsRemoteDataSource);

    final fundsRemoteDataSource = FundsRemoteDataSourceImpl(_apiClient);
    _fundsRepository =
        widget.fundsRepository ??
        FundsRepositoryImpl(remoteDataSource: fundsRemoteDataSource);

    _fundsCubit =
        widget.fundsCubit ??
        FundsCubit(
          _fundsRepository,
          sessionCoordinator: _sessionCoordinator,
          dataSyncCoordinator: _dataSyncCoordinator,
        );
    final expensesRemoteDataSource = ExpensesRemoteDataSourceImpl(_apiClient);
    _expensesRepository =
        widget.expensesRepository ??
        ExpensesRepositoryImpl(remoteDataSource: expensesRemoteDataSource);

    final notificationsRemoteDataSource =
        NotificationsRemoteDataSourceImpl(_apiClient);
    _notificationsRepository =
        widget.notificationsRepository ??
        NotificationsRepositoryImpl(
          remoteDataSource: notificationsRemoteDataSource,
        );
    _notificationsCubit =
        widget.notificationsCubit ??
        NotificationsCubit(_notificationsRepository);

    _stompService = StompNotificationService(
      dataSyncCoordinator: _dataSyncCoordinator,
      onNotificationReceived: (notification) {
        _notificationsCubit.onNotificationReceived(notification);
        InAppNotificationToast.show(notification);
      },
    );

    _fcmService = FcmService(
      authRepository: _authRepository,
      onNotificationReceived: (notification) {
        _notificationsCubit.onNotificationReceived(notification);
        InAppNotificationToast.show(notification);
      },
      onNotificationTapped: (notification) {
        _notificationsCubit.markAsRead(notification.id);
        NotificationNavigationHandler.handleTap(notification);
      },
    );
    _fcmService.init();

    _sessionCoordinator.addListener(_onSessionChanged);
    if (_sessionCoordinator.isAuthenticated) {
      _notificationsCubit.loadUnreadCount();
      _connectStomp();
      _fcmService.syncToken();
    }

    _router = AppRouter.createRouter(
      routes: buildAppRoutes(
        dashboardCubit: widget.dashboardCubit,
        groupsCubit: widget.groupsCubit,
        analyticsTabCubit: widget.analyticsTabCubit,
        debtsCubit: widget.debtsCubit,
        expensesCubit: widget.expensesCubit,
      ),
      sessionCoordinator: _sessionCoordinator,
    );
  }

  void _connectStomp() {
    _authRepository.getCurrentUser().then((user) {
      if (!_isDisposed && _sessionCoordinator.isAuthenticated) {
        _stompService.connect(userId: user.id);
      }
    }).catchError((_) {});
  }

  void _onSessionChanged() {
    if (_sessionCoordinator.isAuthenticated) {
      _notificationsCubit.loadUnreadCount();
      _connectStomp();
      _fcmService.syncToken();
    } else {
      _stompService.disconnect();
      _notificationsCubit.clear();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sessionCoordinator.removeListener(_onSessionChanged);
    _stompService.disconnect();
    _fcmService.dispose();
    _notificationsCubit.close();
    _fundsCubit.close();
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
        ChangeNotifierProvider<SessionCoordinator>.value(value: _sessionCoordinator),
        ChangeNotifierProvider<DataSyncCoordinator>.value(value: _dataSyncCoordinator),
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<DebtsRepository>.value(value: _debtsRepository),
        RepositoryProvider<GroupsRepository>.value(value: _groupsRepository),
        RepositoryProvider<AnalyticsRepository>.value(value: _analyticsRepository),
        RepositoryProvider<FundsRepository>.value(value: _fundsRepository),
        RepositoryProvider<ExpensesRepository>.value(value: _expensesRepository),
        RepositoryProvider<NotificationsRepository>.value(value: _notificationsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<ThemeCubit>.value(value: _themeCubit),
          BlocProvider<LocaleCubit>.value(value: _localeCubit),
          BlocProvider<FundsCubit>.value(value: _fundsCubit),
          BlocProvider<NotificationsCubit>.value(value: _notificationsCubit),
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
