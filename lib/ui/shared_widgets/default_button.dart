import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../app/theme.dart';
import '../../core/core_constants/colors.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton(
      {super.key,
        required this.onBtnTap,
        required this.btnText,
        this.btnColor,
        this.isNull = false,
        this.borderPresent = false,
        this.isLoading = false,
        this.width,
        this.iconData,
        this.borderColor,
        this.btnTextSize,
        this.btnTextColor,
        this.height,
        this.btnFontWeight,
        this.isIconPresent = false});

  final VoidCallback onBtnTap;
  final String btnText;
  final Color? btnColor;
  final Color? btnTextColor;
  final Color? borderColor;
  final FontWeight? btnFontWeight;
  final double? width;
  final double? btnTextSize;
  final bool isNull;
  final bool isLoading;
  final double? height;
  final bool borderPresent;
  final String? iconData;
  final bool isIconPresent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isNull ? null : onBtnTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        width: width ?? 1.sw,
        // height: height ?? 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.r),
          color: isNull ? AppColors.grey : btnColor ?? AppColors.white,
          border: borderPresent ? Border.all(
            color: borderColor ?? AppColors.primaryColor, width: 1) : null
        ),
        child: Center(
          child: isLoading ? CircularProgressIndicator(strokeWidth: 0.7, color: AppColors.white,)  : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isIconPresent)
                SizedBox(height: 30.h, width: 30.h, child: SvgPicture.asset(iconData!, colorFilter: ColorFilter.mode(btnTextColor ?? AppColors.white, BlendMode.srcIn),)),
              Gap(12.w),
              Text(btnText, style: AppThemes.getCustomTextStyle(color: btnTextColor ?? AppColors.white, fontSize: btnTextSize ?? 16, weight: btnFontWeight ?? FontWeight.w500,),),
            ],
          ),
        ),
      ).animate().scale(
        delay: 200.ms,
        duration: 500.ms,
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1), // 10% size increase
        curve: Curves.easeOut,
      )
    );
  }
}