import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import 'choose_image_icon.dart';

class CustomPictureModal extends StatelessWidget {
  final VoidCallback?  cameraBtnPressed;
  final VoidCallback?  galleryBtnPressed;
  const CustomPictureModal({Key? key, this.cameraBtnPressed, this.galleryBtnPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(18),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 16,
                offset: const Offset(0, 3),
              ),
            ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Choose Profile photo",
                style: AppThemes.getCustomTextStyle(
                  fontFamily: "BeauSans",
                  weight: FontWeight.w700,
                  color: AppColors.primaryColor,
                  fontSize: 18,
                  lineHeight: 1.33,
                )
            ),
            Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: cameraBtnPressed,
                  child: ChooseImageIcon(
                    title: "Camera",
                    iconData: Icons.camera_alt_rounded,
                  ),
                ),
                GestureDetector(
                  onTap: galleryBtnPressed,
                  child: ChooseImageIcon(
                    title: "Gallery",
                    iconData: Icons.image,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}