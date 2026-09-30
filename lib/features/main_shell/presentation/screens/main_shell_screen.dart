import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../analytics/domain/repositories/analytics_repository.dart';
import '../../../analytics/presentation/cubit/analytics_tab_cubit.dart';
import '../../../analytics/presentation/screens/analytics_tab_screen.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../debts/domain/repositories/debts_repository.dart';
import '../../../debts/presentation/cubit/debts_cubit.dart';
import '../../../debts/presentation/screens/debts_screen.dart';
import '../../../expenses/domain/repositories/expenses_repository.dart';
import '../../../expenses/presentation/cubit/expenses_cubit.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../../groups/presentation/screens/groups_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/app_header.dart';
import '../widgets/main_bottom_nav_bar.dart';

class MainShellScreen extends StatefulWidget {
  final int initialTabIndex;
  final DashboardCubit? dashboardCubit;
  final GroupsCubit? groupsCubit;
  final AnalyticsTabCubit? analyticsTabCubit;
  final DebtsCubit? debtsCubit;
  final ExpensesCubit? expensesCubit;

  const MainShellScreen({
    super.key,
    this.initialTabIndex = 0,
    this.dashboardCubit,
    this.groupsCubit,
    this.analyticsTabCubit,
    this.debtsCubit,
    this.expensesCubit,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  final GlobalKey<GroupsScreenState> _groupsKey = GlobalKey<GroupsScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state.currentUser == null) {
        authCubit.loadUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = context.colors.background;

    final shellScaffold = BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.isUnauthenticated) {
          context.go('/auth');
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Pinned App Header across tabs
              const AppHeader(),
              // Shell body with IndexedStack to preserve tab states
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    DashboardScreen(
                      onNavigateToGroups: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      onNavigateToJoinGroup: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                        _groupsKey.currentState?.openJoinGroup();
                      },
                      onNavigateToGroupDetail: (group) {
                        setState(() {
                          _currentIndex = 1;
                        });
                        _groupsKey.currentState?.openGroupDetail(group);
                      },
                    ),
                    GroupsScreen(
                      key: _groupsKey,
                      onNavigateToDebts: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                    ),
                    const DebtsScreen(),
                    const AnalyticsTabScreen(),
                    const SettingsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );

    DashboardCubit? effectiveDashboardCubit = widget.dashboardCubit;
    if (effectiveDashboardCubit == null) {
      try {
        effectiveDashboardCubit = context.read<DashboardCubit>();
      } catch (_) {
        // Not in ancestor context, will be created via repository provider below
      }
    }

    GroupsCubit? effectiveGroupsCubit = widget.groupsCubit;
    if (effectiveGroupsCubit == null) {
      try {
        effectiveGroupsCubit = context.read<GroupsCubit>();
      } catch (_) {
        // Not in ancestor context, will be created via repository provider below
      }
    }

    DebtsCubit? effectiveDebtsCubit = widget.debtsCubit;
    if (effectiveDebtsCubit == null) {
      try {
        effectiveDebtsCubit = context.read<DebtsCubit>();
      } catch (_) {
        // Not in ancestor context, will be created via repository provider below
      }
    }

    AnalyticsTabCubit? effectiveAnalyticsTabCubit = widget.analyticsTabCubit;
    if (effectiveAnalyticsTabCubit == null) {
      try {
        effectiveAnalyticsTabCubit = context.read<AnalyticsTabCubit>();
      } catch (_) {
        // Not in ancestor context, will be created via repository provider below
      }
    }

    ExpensesCubit? effectiveExpensesCubit = widget.expensesCubit;
    if (effectiveExpensesCubit == null) {
      try {
        effectiveExpensesCubit = context.read<ExpensesCubit>();
      } catch (_) {
        // Not in ancestor context, will be created via repository provider below
      }
    }

    return MultiBlocProvider(
      providers: [
        if (effectiveDashboardCubit != null)
          BlocProvider<DashboardCubit>.value(value: effectiveDashboardCubit)
        else
          BlocProvider<DashboardCubit>(
            create: (context) => DashboardCubit(
              debtsRepository: context.read<DebtsRepository>(),
              groupsRepository: context.read<GroupsRepository>(),
              sessionCoordinator: context.read<SessionCoordinator>(),
              dataSyncCoordinator: context.read<DataSyncCoordinator>(),
            ),
          ),
        if (effectiveGroupsCubit != null)
          BlocProvider<GroupsCubit>.value(value: effectiveGroupsCubit)
        else
          BlocProvider<GroupsCubit>(
            create: (context) => GroupsCubit(
              context.read<GroupsRepository>(),
              sessionCoordinator: context.read<SessionCoordinator>(),
              dataSyncCoordinator: context.read<DataSyncCoordinator>(),
            ),
          ),
        if (effectiveDebtsCubit != null)
          BlocProvider<DebtsCubit>.value(value: effectiveDebtsCubit)
        else
          BlocProvider<DebtsCubit>(
            create: (context) => DebtsCubit(
              context.read<DebtsRepository>(),
              sessionCoordinator: context.read<SessionCoordinator>(),
              dataSyncCoordinator: context.read<DataSyncCoordinator>(),
            ),
          ),
        if (effectiveAnalyticsTabCubit != null)
          BlocProvider<AnalyticsTabCubit>.value(value: effectiveAnalyticsTabCubit)
        else
          BlocProvider<AnalyticsTabCubit>(
            create: (context) => AnalyticsTabCubit(
              analyticsRepository: context.read<AnalyticsRepository>(),
              groupsRepository: context.read<GroupsRepository>(),
              sessionCoordinator: context.read<SessionCoordinator>(),
              dataSyncCoordinator: context.read<DataSyncCoordinator>(),
            ),
          ),
        if (effectiveExpensesCubit != null)
          BlocProvider<ExpensesCubit>.value(value: effectiveExpensesCubit)
        else
          BlocProvider<ExpensesCubit>(
            create: (context) => ExpensesCubit(
              context.read<ExpensesRepository>(),
              sessionCoordinator: context.read<SessionCoordinator>(),
              dataSyncCoordinator: context.read<DataSyncCoordinator>(),
            ),
          ),
      ],
      child: shellScaffold,
    );
  }
}
