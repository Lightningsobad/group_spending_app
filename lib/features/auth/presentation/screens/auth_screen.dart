import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_mode_switcher.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/social_auth_buttons.dart';

class AuthScreen extends StatefulWidget {
  final String initialMode;

  const AuthScreen({super.key, this.initialMode = 'login'});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLoginMode;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.initialMode != 'register';
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final tr = context.l10n;
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty) {
      AppSnackBar.showWarning(context, tr.enterEmailPrompt);
      return;
    }
    if (password.isEmpty) {
      AppSnackBar.showWarning(context, tr.enterPasswordPrompt);
      return;
    }

    context.read<AuthCubit>().login(email: email, password: password);
  }

  void _onRegister() {
    final tr = context.l10n;
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final phone = _regPhoneController.text.trim();
    final password = _regPasswordController.text;

    if (name.isEmpty) {
      AppSnackBar.showWarning(context, tr.enterFullNamePrompt);
      return;
    }
    if (email.isEmpty) {
      AppSnackBar.showWarning(context, tr.enterEmailPrompt);
      return;
    }
    if (password.length < 6) {
      AppSnackBar.showWarning(context, tr.passwordMinLengthPrompt);
      return;
    }

    context.read<AuthCubit>().register(
      email: email,
      password: password,
      fullName: name,
      phone: phone.isNotEmpty ? phone : null,
    );
  }

  void _onGoogleAuth() {
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _onForgotPassword() {
    context.push('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            (previous.errorMessage != current.errorMessage &&
                current.errorMessage != null);
      },
      listener: (context, state) {
        if (state.needsVerification) {
          final email =
              state.pendingEmail ??
              (_isLoginMode
                  ? _loginEmailController.text.trim()
                  : _regEmailController.text.trim());
          context.push('/verify-otp?email=${Uri.encodeComponent(email)}');
        } else if (state.isAuthenticated) {
          context.go('/dashboard');
        } else if (state.hasError && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const AuthHeader(),
                  const SizedBox(height: 24),
                  AuthModeSwitcher(
                    isLoginMode: _isLoginMode,
                    onChanged: (isLogin) {
                      setState(() {
                        _isLoginMode = isLogin;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: colors.cardBorder,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.cardShadowColor,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SocialAuthButtons(
                          onGoogleAuth: _onGoogleAuth,
                          isLoading: state.isLoading,
                        ),
                        const SizedBox(height: 18),
                        if (_isLoginMode)
                          LoginForm(
                            emailController: _loginEmailController,
                            passwordController: _loginPasswordController,
                            onLogin: _onLogin,
                            onForgotPassword: _onForgotPassword,
                            isLoading: state.isLoading,
                            fieldErrors: state.fieldErrors,
                          )
                        else
                          RegisterForm(
                            nameController: _regNameController,
                            emailController: _regEmailController,
                            phoneController: _regPhoneController,
                            passwordController: _regPasswordController,
                            onRegister: _onRegister,
                            isLoading: state.isLoading,
                            fieldErrors: state.fieldErrors,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLoginMode
                            ? context.l10n.noAccountPrompt
                            : context.l10n.hasAccountPrompt,
                        style: AppTextStyle.medium(
                          fontSize: AppFontSize.secondary,
                          color: colors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Text(
                            _isLoginMode
                                ? context.l10n.registerNow
                                : context.l10n.loginNow,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.secondary,
                              color: AppColors.emeraldForest,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
