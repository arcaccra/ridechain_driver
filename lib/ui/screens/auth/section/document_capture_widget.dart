import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:ridechain_driiver/app/theme.dart';
import 'package:ridechain_driiver/core/core_constants/colors.dart';
import 'package:ridechain_driiver/core/core_constants/label.dart';
import 'package:ridechain_driiver/core/core_constants/media.dart';
import 'package:ridechain_driiver/data/locator.dart';
import 'package:ridechain_driiver/ui/screens/auth/auth_widgets/capture_image_and_file.dart';
import 'package:ridechain_driiver/ui/screens/auth/auth_widgets/document_image_widget.dart';
import 'package:ridechain_driiver/ui/screens/auth/auth_widgets/document_requirement_widget.dart';
import 'package:ridechain_driiver/ui/shared_widgets/custom_app_bar.dart';

import '../../../../services/dialog_service.dart';
import '../../../shared_widgets/default_button.dart';

class DocumentCaptureSection extends StatefulWidget {
  final bool showSecondImage;
  const DocumentCaptureSection({super.key, this.showSecondImage = false});

  @override
  State<DocumentCaptureSection> createState() => _DocumentCaptureSectionState();
}

class _DocumentCaptureSectionState extends State<DocumentCaptureSection> {

  String? frontImageFile;
  String? frontImage;
  String? backImageFile;
  String? backImage;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Gap(kToolbarHeight),
            CustomLoginAppBar(),
            Gap(20.h),
            DottedBorder(
              options: RoundedRectDottedBorderOptions(radius: Radius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      Label.uploadRequirements,
                      style: AppThemes.getCustomTextStyle(fontSize: 14, weight: FontWeight.w700, color: AppColors.greyAd),
                    ),
                    Gap(8.h),
                    DocumentRequirementWidget(title: Label.reqOne),
                    DocumentRequirementWidget(title: Label.reqTwo),
                    DocumentRequirementWidget(title: Label.reqThree),
                    DocumentRequirementWidget(title: Label.reqFour),
                  ],
                ),
              ),
            ),
            Gap(16.h),
            DocumentImageWidget(
              imageFile: frontImageFile,
              imageString: frontImage,
              onCapture: (){
                locator<DialogService>().showCustomDialog(context: context, customDialog: CaptureImageAndFile( onTakePhoto: (){}));
              },
            ),
            Gap(16.h),
            if(widget.showSecondImage) DocumentImageWidget(
              imageFile: frontImageFile,
              imageString: frontImage,
              imageCaptureTitle: Label.backImageTitle,
              onCapture: (){
                locator<DialogService>().showCustomDialog(context: context, customDialog: CaptureImageAndFile( onTakePhoto: (){}));
              },
            ),
            Gap(30.h),
            DefaultButton(onBtnTap: (){}, btnText: Label.saveDocument, isIconPresent: false, btnColor: AppColors.purple, btnTextColor: AppColors.white),
          ],
        ),
      ),
    );
  }
}
