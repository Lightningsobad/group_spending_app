import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.email,
  });

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

    // Ensure countdown timer is active if not already started
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

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            // Flow requirement: after register + verify email successfully, navigate to Onboarding!
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
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Back Button
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

                    // Animated Shield & Header Info
                    Center(
                      child: Column(
                        children: [
                          // Shield Icon Badge
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
                                      color: AppColors.emerald.withValues(alpha: 0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.mail_outline_rounded,
                                  size: 34,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x26000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
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

                          // Email Pill
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

                    // Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mã xác thực OTP',
                          style: AppTextStyle.bold(
                            fontSize: 12,
                            color: AppColors.textSlate800,
                          ),
                        ),
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

                    // 6 OTP Input Boxes layered with reliable input handler
                    Stack(
                      children: [
                        // Invisible TextField capturing input, backspace, and paste
                        Opacity(
                          opacity: 0.0,
                          child: SizedBox(
                            height: 54,
                            child: TextField(
                              controller: _otpController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              onChanged: (val) {
                                setState(() {});
                                if (val.length == 6) {
                                  _onVerify();
                                }
                              },
                            ),
                          ),
                        ),

                        // Visual 6-box row
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _focusNode.requestFocus();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final text = _otpController.text;
                              final isFilled = index < text.length;
                              final isFocused =
                                  _focusNode.hasFocus && index == text.length;
                              final digit = isFilled ? text[index] : '';

                              return Container(
                                width: 48,
                                height: 54,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isFilled
                                      ? AppColors.successBg
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isFilled || isFocused
                                        ? AppColors.emerald
                                        : const Color(0xFFCBD5E1),
                                    width: isFocused ? 2.0 : 1.5,
                                  ),
                                  boxShadow: isFocused
                                      ? [
                                          BoxShadow(
                                            color: AppColors.emerald
                                                .withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  digit,
                                  style: AppTextStyle.extraBold(
                                    fontSize: 22,
                                    color: isFilled
                                        ? const Color(0xFF065F46)
                                        : AppColors.textDark,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Submit CTA Button
                    AppPrimaryButton(
                      text: 'Xác thực & Kích hoạt',
                      isLoading: state.isLoading,
                      onPressed: _onVerify,
                      trailingIcon: const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Countdown / Resend Section
                    Center(
                      child: state.resendCountdown > 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Gửi lại mã sau: ',
                                  style: AppTextStyle.medium(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _formatCountdown(state.resendCountdown),
                                    style: AppTextStyle.bold(
                                      fontSize: 12,
                                      color: AppColors.emeraldDark,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : TextButton(
                              onPressed: _onResend,
                              child: Text(
                                'Gửi lại mã xác thực OTP',
                                style: AppTextStyle.bold(
                                  fontSize: 13,
                                  color: AppColors.emeraldDark,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 36),

                    // Footer Security Notice
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppColors.emerald,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Bảo mật 2 lớp qua OTP • Tự động kích hoạt tài khoản',
                          style: AppTextStyle.semiBold(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
