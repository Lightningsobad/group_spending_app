import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/organic_wavy_divider.dart';

class _OnboardingSlide {
  final String pill;
  final String title;
  final String description;
  final String svgAsset;

  const _OnboardingSlide({
    required this.pill,
    required this.title,
    required this.description,
    required this.svgAsset,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = context.read<AppPreferences>();
    await prefs.setHasSeenOnboarding(true);
    if (!mounted) return;
    context.go('/dashboard');
  }

  void _onNext(int total) {
    if (_currentIndex < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final items = [
      _OnboardingSlide(
        pill: tr.onboardingSlide1Pill,
        title: tr.onboardingSlide1Title,
        description: tr.onboardingSlide1Desc,
        svgAsset: 'assets/onbroading/onboarding_1_group_management.svg',
      ),
      _OnboardingSlide(
        pill: tr.onboardingSlide2Pill,
        title: tr.onboardingSlide2Title,
        description: tr.onboardingSlide2Desc,
        svgAsset: 'assets/onbroading/onboarding_2_expense_management.svg',
      ),
      _OnboardingSlide(
        pill: tr.onboardingSlide3Pill,
        title: tr.onboardingSlide3Title,
        description: tr.onboardingSlide3Desc,
        svgAsset: 'assets/onbroading/onboarding_3_fund_management.svg',
      ),
      _OnboardingSlide(
        pill: tr.onboardingSlide4Pill,
        title: tr.onboardingSlide4Title,
        description: tr.onboardingSlide4Desc,
        svgAsset: 'assets/onbroading/onboarding_4_reminder_feature.svg',
      ),
    ];
    final item = items[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Action Row (Step indicator & Skip button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Step indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr.onboardingStep(_currentIndex + 1, items.length),
                        style: AppTextStyle.bold(
                          fontSize: 12,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: Text(
                      tr.skip,
                      style: AppTextStyle.extraBold(
                        fontSize: 13,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Upper Section: PageView Illustrations
            Expanded(
              flex: 11,
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final currentItem = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient warm gold glow matching HTML design
                            Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFEE685,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 36,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            SvgPicture.asset(
                              currentItem.svgAsset,
                              width: 270,
                              height: 270,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Signature Organic Wavy Divider
            const OrganicWavyDivider(
              height: 52,
              fillColor: AppColors.primaryGreen,
            ),

            // Lower Section: Rich Green Background
            Container(
              width: double.infinity,
              color: AppColors.primaryGreen,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Feature Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      item.pill.toUpperCase(),
                      style: AppTextStyle.extraBold(
                        fontSize: 11,
                        color: const Color(0xFFD1FAE5),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Slide Title
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.black(
                      fontSize: 19,
                      color: Colors.white,
                      letterSpacing: 0.4,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Slide Description
                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.regular(
                      fontSize: 13,
                      color: const Color(0xEBEEFDF4),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(items.length, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: isActive
                              ? [
                                  const BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Circular White Next Button with Green Arrow
                  GestureDetector(
                    onTap: () => _onNext(items.length),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.95),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4D000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primaryGreen,
                          size: 26,
                        ),
                      ),
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
