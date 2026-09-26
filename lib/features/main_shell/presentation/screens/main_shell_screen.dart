import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/app_header.dart';
import '../widgets/main_bottom_nav_bar.dart';
import '../widgets/tab_placeholder_view.dart';

class MainShellScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainShellScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

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
    final tr = context.l10n;
    final bg = context.colors.background;

    return BlocListener<AuthCubit, AuthState>(
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
                    TabPlaceholderView(
                      title: tr.tabOverview,
                      icon: LucideIcons.layoutGrid,
                      tabIndex: 0,
                    ),
                    TabPlaceholderView(
                      title: tr.tabGroups,
                      icon: LucideIcons.users,
                      tabIndex: 1,
                    ),
                    TabPlaceholderView(
                      title: tr.tabDebts,
                      icon: LucideIcons.arrowLeftRight,
                      tabIndex: 2,
                    ),
                    TabPlaceholderView(
                      title: tr.tabAnalytics,
                      icon: LucideIcons.barChart3,
                      tabIndex: 3,
                    ),
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
  }
}
