import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/core_constants/colors.dart';
import '../../../core/core_constants/media.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Purple header section
          Container(
            width: double.infinity,
            height: 0.55.sh,
            decoration: const BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Car icon
                  Container(
                    width: 96.w,
                    height: 96.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Media.car,
                        width: 52.w,
                        height: 52.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Gap(24.h),
                  Text(
                    'Ridechain',
                    style: TextStyle(
                      fontFamily: 'BeauSans',
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    'Drive. Earn. Repeat.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bottom action section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome, driver',
                  style: TextStyle(
                    fontFamily: 'BeauSans',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(6.h),
                Text(
                  'Sign in to your account or create a new one\nto start earning on the blockchain.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(32.h),
                // Sign in button
                SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const LoginScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Gap(12.h),
                // Create account button
                SizedBox(
                  height: 54.h,
                  child: OutlinedButton(
                    onPressed: () => Get.to(() => const RegisterScreen()),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.purple, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27.r),
                      ),
                    ),
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        color: AppColors.purple,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
