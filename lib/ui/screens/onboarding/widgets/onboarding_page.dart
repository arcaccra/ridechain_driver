import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../app/theme.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key, required this.title,required this.stack});

  final String title;
  final Widget stack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 0.4.sh,
          width: 1.sw,
          child: stack,
        ),
        Gap(26.h),
        SizedBox(
          width: 237.w,
          child: Text(
            title,
            style: AppThemes.getCustomTextStyle(
              fontSize: 28.5,
              fontFamily: "Outfit",
              weight: FontWeight.w700,
              color: AppColors.primaryColor
            ),
            textAlign: TextAlign.center,
          ),
        ).animate(delay: 100.ms)
            .slide(
          begin: const Offset(0, 0.2), // Start from top of screen
          end: const Offset(0, 0), // End at center
          duration: 500.ms,
          curve: Curves.easeOutBack,
        )
            .fade(begin: 0, end: 1, duration: 500.ms),

      ],
    );
  }
}