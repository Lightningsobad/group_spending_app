import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/wallet_logo.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthScreen extends StatefulWidget {
  final String initialMode;

  const AuthScreen({super.key, this.initialMode = 'login'});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLoginMode;

  // Controllers for Login
  final _loginEmailController = TextEditingController();
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Controllers for Register
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
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email.')),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mật khẩu.')));
      return;
    }

    context.read<AuthCubit>().login(email: email, password: password);
  }

  void _onRegister() {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final phone = _regPhoneController.text.trim();
    final password = _regPasswordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ và tên.')));
      return;
    }
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự.')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đăng nhập Google đang được phát triển.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chức năng Quên mật khẩu đang được hỗ trợ.'),
          ),
        );
      },
      child: Text(
        'Quên mật khẩu?',
        style: AppTextStyle.semiBold(
          fontSize: 12.5,
          color: AppColors.emeraldForest,
        ),
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
          final prefs = context.read<AppPreferences>();
          if (prefs.getHasSeenOnboarding()) {
            context.go('/dashboard');
          } else {
            context.go('/onboarding');
          }
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
                children: [
                  const SizedBox(height: 10),
                  // Header Logo & App Title
                  Center(
                    child: Column(
                      children: [
                        const WalletLogo(
                          size: 56,
                          iconSize: 28,
                          outlineWidth: 4,
                          borderRadius: 20,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Quản lý & Nhắc nhở Chi tiêu\nNhóm',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.black(
                            fontSize: 28,
                            color: AppColors.textDark,
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chia tiền minh bạch, nhắc nợ tế nhị, đóng quỹ dễ dàng.',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.medium(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Segmented Switcher
                  _AuthSegmentedControl(
                    isLoginMode: _isLoginMode,
                    onChanged: (isLogin) {
                      setState(() {
                        _isLoginMode = isLogin;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  // Card Form Container
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
                        // Google Auth Button
                        OutlinedButton(
                          onPressed: _onGoogleAuth,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textDark,
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GoogleLogoSvg(),
                              const SizedBox(width: 10),
                              Text(
                                'Đăng nhập bằng Google',
                                style: AppTextStyle.semiBold(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Divider text
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.borderLight,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'HOẶC ĐĂNG NHẬP BẰNG EMAIL',
                                style: AppTextStyle.bold(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.borderLight,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Login or Register Form
                        if (_isLoginMode) ...[
                          AppTextField(
                            label: 'Địa chỉ Email',
                            controller: _loginEmailController,
                            hintText: 'minh.nguyen@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              LucideIcons.mail,
                              size: 19,
                              color: AppColors.textMuted,
                            ),
                            errorText: state.fieldErrors?['email'],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Mật khẩu',
                            labelTrailing: _buildForgotPasswordButton(),
                            controller: _loginPasswordController,
                            hintText: '••••••••',
                            isPassword: true,
                            prefixIcon: const Icon(
                              LucideIcons.lock,
                              size: 19,
                              color: AppColors.textMuted,
                            ),
                            errorText: state.fieldErrors?['password'],
                          ),
                          const SizedBox(height: 20),
                          AppPrimaryButton(
                            text: 'Đăng nhập vào ứng dụng',
                            isLoading: state.isLoading,
                            onPressed: _onLogin,
                            trailingIcon: const Icon(
                              LucideIcons.arrowRight,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ] else ...[
                          AppTextField(
                            label: 'Họ và tên',
                            controller: _regNameController,
                            hintText: 'Nguyễn Nhật Minh',
                            prefixIcon: const Icon(
                              LucideIcons.user,
                              size: 19,
                              color: AppColors.textMuted,
                            ),
                            errorText: state.fieldErrors?['fullName'],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Địa chỉ Email',
                            controller: _regEmailController,
                            hintText: 'minh.nguyen@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              LucideIcons.mail,
                              size: 19,
                              color: AppColors.textMuted,
                            ),
                            errorText: state.fieldErrors?['email'],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Số điện thoại',
                            optionalTag: '(Không bắt buộc / Tùy chọn)',
                            controller: _regPhoneController,
                            hintText: 'VD: 0912 345 678',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(
                              LucideIcons.phone,
                              size: 19,
                              color: AppColors.textMuted,
                            ),
                            errorText: state.fieldErrors?['phone'],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Mật khẩu',
                            controller: _regPasswordController,
                            hintText: '••••••••',
                            isPassword: true,
                            prefixIcon: const Icon(
                              LucideIcons.lock,
                              size: 19,
                              color: AppColors.textMuted,
                            ),
                            errorText: state.fieldErrors?['password'],
                          ),
                          const SizedBox(height: 20),
                          AppPrimaryButton(
                            text: 'Tạo tài khoản mới',
                            isLoading: state.isLoading,
                            onPressed: _onRegister,
                            trailingIcon: const Icon(
                              LucideIcons.arrowRight,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLoginMode
                            ? 'Chưa có tài khoản? '
                            : 'Đã có tài khoản? ',
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
                          _isLoginMode ? 'Đăng ký ngay' : 'Đăng nhập',
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

class _AuthSegmentedControl extends StatelessWidget {
  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  const _AuthSegmentedControl({
    required this.isLoginMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
      ),
      child: Stack(
        children: [
          // Animated sliding background pill
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            alignment: isLoginMode
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Interactive tab items
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(true),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyle.extraBold(
                        fontSize: 15,
                        color: isLoginMode
                            ? AppColors.emeraldForest
                            : AppColors.textSecondary,
                      ),
                      child: const Text('Đăng nhập'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(false),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyle.extraBold(
                        fontSize: 15,
                        color: !isLoginMode
                            ? AppColors.emeraldForest
                            : AppColors.textSecondary,
                      ),
                      child: const Text('Đăng ký'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoogleLogoSvg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/auth/google.svg', width: 20, height: 20);
  }
}
