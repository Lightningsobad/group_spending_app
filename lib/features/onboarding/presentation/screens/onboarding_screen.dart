import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
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
    final colors = context.colors;
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
      backgroundColor: colors.onboardingCanvasBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Action Row (Skip button aligned right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
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
                      color: colors.onboardingSkipText,
                    ),
                  ),
                ),
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
                            // Ambient glow matching theme
                            Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.onboardingGlow,
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
            OrganicWavyDivider(
              height: 52,
              fillColor: colors.onboardingBottomBg,
            ),

            // Lower Section: Rich Theme-matched Background
            Container(
              width: double.infinity,
              color: colors.onboardingBottomBg,
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
                      color: colors.onboardingPillBg,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      item.pill.toUpperCase(),
                      style: AppTextStyle.extraBold(
                        fontSize: 11,
                        color: colors.onboardingPillText,
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
                      color: colors.onboardingTitleText,
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
                      color: colors.onboardingDescText,
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
                              ? colors.onboardingDotActive
                              : colors.onboardingDotInactive,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: colors.cardShadowColor,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Circular Next Button with Directional Arrow
                  GestureDetector(
                    onTap: () => _onNext(items.length),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colors.onboardingNextBtnBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.onboardingNextBtnBorder,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.cardShadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: colors.onboardingNextBtnFg,
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
