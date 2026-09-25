import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../shared/widgets/wallet_logo.dart';
import '../cubit/auth_cubit.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Cubic(0.4, 0.0, 0.2, 1.0),
      ),
    );

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final startTime = DateTime.now();

    // Check auth status
    final authCubit = context.read<AuthCubit>();
    await authCubit.checkAuthStatus();

    // Ensure splash and loading animation complete (minimum 1500ms)
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < const Duration(milliseconds: 1500)) {
      await Future.delayed(const Duration(milliseconds: 1500) - elapsed);
    }

    if (!mounted) return;

    final state = authCubit.state;
    final prefs = context.read<AppPreferences>();

    if (state.isAuthenticated) {
      if (prefs.getHasSeenOnboarding()) {
        context.go('/dashboard');
      } else {
        context.go('/onboarding');
      }
    } else {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.luxuryGradient,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Radial Glow
            Positioned(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.emeraldLight.withValues(alpha: 0.35),
                      const Color(0xFF064E3B).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // Center Branding Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const WalletLogo(
                    size: 96,
                    iconSize: 48,
                    outlineWidth: 8,
                    borderRadius: 28,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'FairShare',
                    style: AppTextStyle.style(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      shadows: const [
                        Shadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chia tiền minh bạch & nhắc nợ thông minh',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLightMint,
                      height: 1.5,
                      shadows: const [
                        Shadow(
                          color: Color(0x33000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Loading Progress Bar
            Positioned(
              bottom: 48,
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.emeraldLight.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnim.value.clamp(0.0, 1.0),
                          heightFactor: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9999),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF34D399),
                                  Color(0xFF5EEAD4),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF34D399)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
