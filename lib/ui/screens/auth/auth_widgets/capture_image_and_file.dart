import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../core/core_constants/media.dart';
import '../../../shared_widgets/default_button.dart';


class CaptureImageAndFile extends StatelessWidget {
  final VoidCallback onTakePhoto;
  const CaptureImageAndFile({super.key, required this.onTakePhoto});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20)
        ),
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(radius: Radius.circular(14), color:AppColors.textFieldBorderColor ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightPurpleEF
                  ),
                  child: Center(child: SvgPicture.asset(Media.upload, height: 32, width: 32,)),
                ),
                Gap(20.h),
                Text(
                  Label.uploadDocument,
                  style: AppThemes.getCustomTextStyle(fontSize: 18, weight: FontWeight.w700, color: AppColors.black),
                ),
                Gap(8.h),
                Text(
                  Label.takeOrSelectPhoto,
                  style: AppThemes.getCustomTextStyle(fontSize: 14, weight: FontWeight.w400, color: AppColors.greyAd),
                ),
                Gap(20.h),
                //button
                DefaultButton(onBtnTap: onTakePhoto, btnText: Label.captureDocument, isIconPresent: true, btnColor: AppColors.purple, btnTextColor: AppColors.white, iconData: Media.camera,),
              ],
            ),
          ),
        )
      ),
    );
  }
}
