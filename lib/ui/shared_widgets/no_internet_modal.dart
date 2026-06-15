import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../app/theme.dart';
import '../../core/core_constants/colors.dart';
import '../../core/core_constants/label.dart';
import '../../core/core_constants/media.dart';


class NoInternetModal extends StatelessWidget {
  const NoInternetModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 0.5.sh,
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
              colors: AppColors.gradientColors
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 150, width: 0.4.sw, child: Image.asset(Media.noInternetImg)),
            Text(Label.noInternetTitle, style: AppThemes.getCustomTextStyle(
              fontFamily: "Outfit",
              fontSize: 18,
              weight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),),
            Gap(10),
            Text(Label.noInternetMessage, style: AppThemes.getCustomTextStyle(
              fontFamily: "Outfit",
              fontSize: 16,
              weight: FontWeight.w500,
              color: AppColors.primaryColor,))
          ],
        ),
      ),
    );
  }
}
