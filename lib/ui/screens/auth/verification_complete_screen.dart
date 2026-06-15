import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../navigation/app_navigation_screen.dart';

class VerificationCompleteScreen extends StatelessWidget {
  const VerificationCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5500BF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Outer ring -> inner ring -> green check circle
                Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00D26A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 40.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(36.h),
                Text(
                  "You're all set!",
                  style: TextStyle(
                    fontFamily: 'BeauSans',
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Gap(12.h),
                Text(
                  "Your documents are under review. You can start creating rides right away.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(40.h),
                SizedBox(
                  width: 240.w,
                  height: 56.h,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.offAll(() => const AppNavigationScreen()),
                    icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
                    label: Text(
                      'Go to dashboard',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D26A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
