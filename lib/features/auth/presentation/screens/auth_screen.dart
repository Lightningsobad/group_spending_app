import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.enterEmailPrompt)),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.enterPasswordPrompt)),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.enterFullNamePrompt)),
      );
      return;
    }
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.enterEmailPrompt)),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.passwordMinLengthPrompt)),
      );
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
    final tr = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr.googleAuthNotice),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onForgotPassword() {
    final tr = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr.forgotPasswordNotice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SocialAuthButtons(onGoogleAuth: _onGoogleAuth),
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
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                          });
                        },
                        child: Text(
                          _isLoginMode
                              ? context.l10n.registerNow
                              : context.l10n.loginNow,
                          style: AppTextStyle.bold(
                            fontSize: 13,
                            color: AppColors.emeraldForest,
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
