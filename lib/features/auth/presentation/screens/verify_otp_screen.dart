import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/resend_otp_section.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AuthCubit>();
      if (cubit.state.resendCountdown == 0) {
        cubit.startResendCountdown(60);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onBack() {
    context.read<AuthCubit>().resetAuthStatus();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/auth');
    }
  }

  void _onVerify() {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 6 chữ số mã xác thực OTP.'),
        ),
      );
      return;
    }

    context.read<AuthCubit>().verifyOtp(email: widget.email, otp: otp);
  }

  void _onResend() {
    context.read<AuthCubit>().resendOtp(email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<AuthCubit>().resetAuthStatus();
        }
      },
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) {
          return previous.status != current.status ||
              (previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null);
        },
        listener: (context, state) {
          if (state.isAuthenticated) {
            context.go('/onboarding');
          } else if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _onBack,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      color: AppColors.textSlate800,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: const LinearGradient(
                                  colors: AppColors.logoGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.emerald.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mail_outline,
                                size: 34,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shield,
                                  size: 16,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Xác thực địa chỉ Email',
                          style: AppTextStyle.black(
                            fontSize: 22,
                            color: AppColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mã OTP 6 số bảo mật đã được gửi đến hòm thư của bạn',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.medium(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.email,
                                style: AppTextStyle.bold(
                                  fontSize: 12,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _onBack,
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: AppColors.emeraldDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Mã xác thực OTP',
                          style: AppTextStyle.bold(
                            fontSize: 12,
                            color: AppColors.textSlate800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '6 chữ số bảo mật',
                        style: AppTextStyle.medium(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OtpInputField(
                    controller: _otpController,
                    focusNode: _focusNode,
                    onChanged: () => setState(() {}),
                    onCompleted: (_) => _onVerify(),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) =>
                        previous.isLoading != current.isLoading,
                    builder: (context, state) {
                      return AppPrimaryButton(
                        text: 'Xác thực & Kích hoạt',
                        isLoading: state.isLoading,
                        onPressed: _onVerify,
                        trailingIcon: const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(child: ResendOtpSection(onResend: _onResend)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
