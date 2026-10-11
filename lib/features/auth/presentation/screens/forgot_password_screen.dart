import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';
import '../widgets/forgot_password_email_view.dart';
import '../widgets/forgot_password_new_password_view.dart';
import '../widgets/forgot_password_otp_view.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final PasswordResetCubit? cubit;

  const ForgotPasswordScreen({
    super.key,
    this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<PasswordResetCubit>.value(
        value: cubit!,
        child: const _ForgotPasswordContent(),
      );
    }

    return BlocProvider<PasswordResetCubit>(
      create: (context) => PasswordResetCubit(context.read<AuthRepository>()),
      child: const _ForgotPasswordContent(),
    );
  }
}

class _ForgotPasswordContent extends StatelessWidget {
  const _ForgotPasswordContent();

  void _onBack(BuildContext context) {
    final cubit = context.read<PasswordResetCubit>();
    if (cubit.state.isOtpStep || cubit.state.isNewPasswordStep) {
      cubit.backToEmailStep();
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/auth?mode=login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onBack(context);
        }
      },
      child: BlocListener<PasswordResetCubit, PasswordResetState>(
        listenWhen: (prev, curr) =>
            prev.step != curr.step ||
            (prev.errorMessage != curr.errorMessage && curr.errorMessage != null),
        listener: (context, state) {
          if (state.isSuccessStep) {
            AppSnackBar.showSuccess(
              context,
              tr.resetPasswordSuccessMessage,
              duration: const Duration(seconds: 4),
            );
            context.go('/auth?mode=login');
          } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            AppSnackBar.showError(context, state.errorMessage!);
          }
        },
        child: Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => _onBack(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 19),
                      color: colors.iconPrimary,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colors.cardBorder),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<PasswordResetCubit, PasswordResetState>(
                    buildWhen: (prev, curr) => prev.step != curr.step,
                    builder: (context, state) {
                      switch (state.step) {
                        case PasswordResetStep.email:
                          return ForgotPasswordEmailView(
                            onBackToLogin: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/auth?mode=login');
                              }
                            },
                          );
                        case PasswordResetStep.otp:
                          return const ForgotPasswordOtpView();
                        case PasswordResetStep.newPassword:
                          return const ForgotPasswordNewPasswordView();
                        case PasswordResetStep.success:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
