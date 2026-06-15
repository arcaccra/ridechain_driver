import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../core/core_constants/media.dart';
import '../../../shared_widgets/default_button.dart';

class DocumentImageWidget extends StatelessWidget {
  final String? imageCaptureTitle;
  final String? imageFile;
  final String? imageString;
  final VoidCallback? onCapture;
  const DocumentImageWidget({super.key, this.imageString, this.imageFile, this.onCapture, this.imageCaptureTitle});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(radius: Radius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              imageCaptureTitle ?? Label.frontImageTitle,
              style: AppThemes.getCustomTextStyle(fontSize: 14, weight: FontWeight.w500, color: AppColors.greyAd),
            ),
            Gap(8.h),
            SizedBox(
              height: 140.h,
              width: 0.8.sw,
              child: (imageFile == null && imageString == null)
                  ? Center(child: SvgPicture.asset(Media.upload, height: 32, width: 32))
                  : imageString != null
                  ? Image.file(File(imageString!), height: 140.h, width: 0.8.sw)
                  : Center(
                      child: Text(
                        imageFile!,
                        style: AppThemes.sora(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.black),
                      ),
                    ),
            ),
            //button
            DefaultButton(onBtnTap: onCapture!, btnText: Label.captureDocument, isIconPresent: false, btnColor: AppColors.purple, btnTextColor: AppColors.white),
          ],
        ),
      ),
    );
  }
}
