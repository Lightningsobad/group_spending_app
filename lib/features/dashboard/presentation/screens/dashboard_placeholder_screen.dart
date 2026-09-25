import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class DashboardPlaceholderScreen extends StatelessWidget {
  const DashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isUnauthenticated) {
          context.go('/auth');
        }
      },
      builder: (context, state) {
        final prefs = context.read<AppPreferences>();
        final name = state.currentUser?.fullName ??
            prefs.getUserFullName() ??
            'Người dùng FairShare';
        final email = state.currentUser?.email ??
            prefs.getUserEmail() ??
            '';

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: AppColors.logoGradient,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'FairShare',
                  style: AppTextStyle.black(
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<AuthCubit>().logout();
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                tooltip: 'Đăng xuất',
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Welcome Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF064E3B), Color(0xFF043F30)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.emerald,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: AppTextStyle.extraBold(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTextStyle.extraBold(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: AppTextStyle.regular(
                                      fontSize: 12,
                                      color: AppColors.textLightMint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: AppColors.emeraldLight,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tài khoản đã xác thực Email',
                                style: AppTextStyle.bold(
                                  fontSize: 11,
                                  color: AppColors.emeraldLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Stats Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Tổng chi tiêu',
                          value: '0 đ',
                          icon: Icons.trending_up,
                          iconColor: AppColors.emeraldDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Cần thu về',
                          value: '0 đ',
                          icon: Icons.call_received,
                          iconColor: Color(0xFF204CB2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Module integration notification
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sẵn sàng tích hợp các tính năng tiếp theo',
                          style: AppTextStyle.extraBold(
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bạn đã hoàn tất toàn bộ chu trình Xác thực (Đăng ký, Xác thực OTP, Đăng nhập, Làm mới phiên & Onboarding). Các phân hệ Nhóm, Chi tiêu và Quỹ chung sẽ được kết nối tiếp theo.',
                          style: AppTextStyle.regular(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout action button
                  OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ).let(
                    (style) => OutlinedButton.icon(
                      style: style,
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        'Đăng xuất khỏi tài khoản',
                        style: AppTextStyle.bold(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyle.semiBold(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyle.extraBold(
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

extension _ObjectExt<T> on T {
  R let<R>(R Function(T it) block) => block(this);
}
