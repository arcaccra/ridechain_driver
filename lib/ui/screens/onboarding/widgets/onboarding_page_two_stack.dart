import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../core/core_constants/media.dart';
import '../../../../app/theme.dart';


class OnboardingPageTwoStack extends StatelessWidget {
  const OnboardingPageTwoStack({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240.23,
      width: 1.sw,
      child: Stack(
        children: [
          Positioned(
            bottom: 120,
            child: Text(Label.price, style: AppThemes.getCustomTextStyle(fontFamily: "Outfit", fontSize: 121, color: AppColors.greyEd))
                .animate(delay: 200.ms)
                .slide(
              begin: const Offset(0, -0.3), // Start from top of screen
              end: const Offset(0, 0), // End at center
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 500.ms, delay: 200.ms),
          ),
          Positioned(
            bottom: 80,
            right: 0,
            child: Image.asset(Media.onboardingAdaImg, height: 182, width: 385,)
                .animate(delay: 200.ms)
                .slide(
              begin: const Offset(0, -0.3), // Start from top of screen
              end: const Offset(0.25, 0), // End at center
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 500.ms, delay: 200.ms),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(Media.onboardingToyotaImg, height: 182, width: 385,)
                .animate(delay: 200.ms)
                .slide(
              begin: const Offset(0, -0.3), // Start from top of screen
              end: const Offset(0, 0), // End at center
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 500.ms, delay: 200.ms),
          ),
        ],
      ),
    );
  }
}
