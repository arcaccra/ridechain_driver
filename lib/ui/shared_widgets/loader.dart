import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../app/theme.dart';
import '../../core/core_constants/colors.dart';

class Loader extends StatelessWidget {
  final String? loaderText;
  const Loader({super.key, this.loaderText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 1.sh,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 99.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2)),
            child: Container(
              height: 0.1.sh,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 44,
                    width: 44,
                    child: CircularProgressIndicator(
                      color: AppColors.purple,
                      strokeWidth: 2,

                    ),
                  ),
                  Gap(8.h),
                  Text(
                    loaderText ?? "Loading..",
                    style: AppThemes.getCustomTextStyle(
                    weight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.purple,
                    lineHeight: 1.2,
                    ),),
                ],
              )
            ),
          ),
        )
      )
    );
  }
}