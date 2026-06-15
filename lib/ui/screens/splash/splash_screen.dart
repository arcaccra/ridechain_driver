import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/cache_helper.dart';
import '../../../core/core_constants/media.dart';
import '../../../data/locator.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/login_service.dart';
import '../auth/login_screen.dart';
import '../navigation/app_navigation_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  AuthVm? authVm;

  @override
  void initState() {
    authVm = context.read<AuthVm>();
    super.initState();
    _handleLogin();
  }

  _handleLogin() async {
    _timer = Timer(const Duration(seconds: 2), () async {
      if (CacheHelper.instance.isFirstTimer == true) {
        bool isSuccess = await locator<LoginService>().isUserSignedIn();
        if (isSuccess) {
          await authVm?.fetchUserInfo();
          Get.offAll(() => const AppNavigationScreen());
        } else {
          Get.offAll(() => const LoginScreen());
        }
      } else {
        Get.offAll(() => const OnboardingScreen());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5500BF),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Outer circle ring
                  Container(
                    width: 220.w,
                    height: 220.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1.5),
                    ),
                    child: Center(
                      // Inner circle ring
                      child: Container(
                        width: 160.w,
                        height: 160.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5),
                        ),
                        child: Center(
                          // White rounded square with logo
                          child: Container(
                            width: 90.w,
                            height: 90.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                            child: Center(
                              child: Image.asset(Media.logo,
                                  width: 56.w, height: 56.w),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(24.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Ride',
                            style: TextStyle(
                                fontFamily: 'BeauSans',
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        TextSpan(
                            text: 'Chain',
                            style: TextStyle(
                                fontFamily: 'BeauSans',
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                  Gap(6.h),
                  Text(
                    'DRIVER',
                    style: TextStyle(
                        fontFamily: 'BeauSans',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 3.5),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24.h,
              left: 0,
              right: 0,
              child: Text(
                '⊛  Powered by Cardano',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
