import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../core/core_constants/media.dart';


class TopScanWidget extends StatelessWidget {
  const TopScanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.8.sh,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          SizedBox(height: double.infinity, width: double.infinity, child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset(Media.landingImage, fit: BoxFit.cover))),
          Positioned(
            top: 0.5.sh,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Label.scanReview, style: AppThemes.getCustomTextStyle(fontFamily: "Zain", fontSize: 64, color: AppColors.purple,), textAlign: TextAlign.left, )
                    .animate(delay: 200.ms)
                    .slide(
                  begin: const Offset(0, -0.3), // Start from top of screen
                  end: const Offset(0, 0), // End at center
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutBack,
                ).fade(begin: 0, end: 1, duration: 500.ms, delay: 200.ms),

                Text(Label.comingSoon, style: AppThemes.getCustomTextStyle(fontFamily: "Zain", fontSize: 24, color: AppColors.primaryColor,), textAlign: TextAlign.left, )
                    .animate(delay: 200.ms)
                    .slide(
                  begin: const Offset(0, -0.3), // Start from top of screen
                  end: const Offset(0, 0), // End at center
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutBack,
                ).fade(begin: 0, end: 1, duration: 500.ms, delay: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}