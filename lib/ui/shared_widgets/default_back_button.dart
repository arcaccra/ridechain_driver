import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../core/core_constants/colors.dart';

class DefaultBackButton extends StatelessWidget {
  const DefaultBackButton({super.key,this.size, this.iconSize, this.onBackTap, this.iconColor, this.btnColor, this.icon, this.asset});

  final VoidCallback? onBackTap;
  final IconData? icon;
  final Color? btnColor;
  final Color? iconColor;
  final String? asset;
  final double? size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onBackTap ?? (){
        Get.back();
      },
      child: Container(
        height: size ?? 50.h,
        width: size ?? 50.h,
        decoration: BoxDecoration(
            color: btnColor ?? AppColors.backgroundColor,
            shape: BoxShape.circle
        ),
        child: Center(
          child: asset == null ? Icon(
            icon ?? CupertinoIcons.arrow_left,
            color: iconColor ?? AppColors.white,
            size: iconSize ?? 24.sp,
          ) : SvgPicture.asset(asset!, colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn), height: 24.sp, width: 24.sp,),
        ),
      ),
    );
  }
}