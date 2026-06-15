import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ridechain_driiver/ui/screens/onboarding/widgets/onboarding_page_one_stack.dart';
import 'package:ridechain_driiver/ui/screens/onboarding/widgets/onboarding_page_three_stack.dart';
import 'package:ridechain_driiver/ui/screens/onboarding/widgets/onboarding_page_two_stack.dart';
import '../../../core/cache_helper.dart';
import '../../../core/core_constants/colors.dart';
import '../../../core/core_constants/media.dart';
import '../landing/landing_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
        title: 'Earn ADA on every ride',
        subtitle:
            'Get paid in Cardano cryptocurrency instantly — no banks, no middlemen, no waiting for payouts.'),
    _OnboardingData(
        title: 'Verified & trusted',
        subtitle:
            'Multi-step document verification builds passenger confidence and keeps the network safe.'),
    _OnboardingData(
        title: 'Your route, your schedule',
        subtitle:
            'Set your own pickup locations, departure times, and seat availability.'),
  ];

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _finish();
    }
  }

  void _finish() {
    CacheHelper.instance.cacheFirstTimer();
    Get.offAll(() => const LandingScreen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                        color: AppColors.purple,
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Center(
                        child: Image.asset(Media.logo,
                            width: 24.w, height: 24.w, color: Colors.white)),
                  ),
                  Gap(10.w),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: 'Ride',
                        style: TextStyle(
                            fontFamily: 'BeauSans',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    TextSpan(
                        text: 'Chain',
                        style: TextStyle(
                            fontFamily: 'BeauSans',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple)),
                  ])),
                  const Spacer(),
                  GestureDetector(
                      onTap: _finish,
                      child: Text('Skip',
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.grey[600]))),
                ],
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final stacks = [
                    OnboardingPageOneStack(),
                    OnboardingPageTwoStack(),
                    OnBoardingPageThreeStack()
                  ];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        Gap(0.05.sh),
                        SizedBox(height: 0.28.sh, child: stacks[index]),
                        Gap(0.07.sh),
                        Text(page.title,
                            style: TextStyle(
                                fontFamily: 'BeauSans',
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.black),
                            textAlign: TextAlign.center),
                        Gap(12.h),
                        Text(page.subtitle,
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                                height: 1.5),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: i == _currentPage ? 24.w : 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.purple
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      )),
            ),
            Gap(24.h),
            // Continue button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r)),
                    elevation: 0,
                  ),
                  child: Text('Continue',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            Gap(24.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String subtitle;
  const _OnboardingData({required this.title, required this.subtitle});
}
