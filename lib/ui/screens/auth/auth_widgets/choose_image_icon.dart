import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../app/theme.dart';

class ChooseImageIcon extends StatelessWidget {
  const ChooseImageIcon({super.key, required this.title, required this.iconData});

  final IconData iconData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withValues(alpha: 0.1)
          ),
          child:  Center(
            child: Icon(
              iconData,
              color: AppColors.primaryColor,
              size: 18,
            ),
          ),
        ),
        Gap(6.h),
        Text(
            title!,
            style: AppThemes.getCustomTextStyle(
              fontFamily: "BeauSans",
              weight: FontWeight.w400,
              color: AppColors.primaryColor,
              fontSize: 16,
              lineHeight: 1.33,
            )
        )
      ],
    );
  }
}
