import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/core_constants/colors.dart';
import 'default_back_button.dart';

class CustomLoginAppBar extends StatelessWidget {
  const CustomLoginAppBar({super.key, this.imageString, this.onBackTap});
  final VoidCallback? onBackTap;
  final String? imageString;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      width: 1.sw,
      color: AppColors.backgroundColor,
      child: Row(
        children: [
          DefaultBackButton(
            icon: CupertinoIcons.arrow_left,
            onBackTap: onBackTap,
            iconColor: AppColors.primaryColor,
            btnColor: AppColors.backgroundColor,
          ),
          Gap(0.3.sw),
          //Image.asset(Media.appIcon, height: 60.h, width: 60.h, fit: BoxFit.cover,),
          //const Spacer(),
        ],
      ),
    );
  }
}