import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/media.dart';
import '../../../../data/locator.dart';
import '../../../../services/dialog_service.dart';
import 'capture_image_and_file.dart';
import 'choose_image_picker.dart';


class CaptureDocumentImageOrFileCard extends StatelessWidget {
  const CaptureDocumentImageOrFileCard({super.key, this.imageFile, required this.title, this.onCameraTap, this.onGalleryTap, this.onFileTap});
  final File? imageFile;
  final String title;
  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;
  final Function? onFileTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        locator<DialogService>().showCustomDialog(context: context, customDialog: CaptureImageAndFile(
            onTakePhoto: (){
              Navigator.pop(context);
              locator<DialogService>().showCustomModal(context: context, customModal: CustomPictureModal(
                  cameraBtnPressed: onCameraTap,
                  galleryBtnPressed: onGalleryTap
              ));
            }));
      },
      child: DottedBorder(
        options: RectDottedBorderOptions(
          dashPattern: [2,2],
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: AppColors.textFieldBorderColor
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppThemes.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.black),
            ),
            Gap(8),
            SizedBox(
              height: 140.h,
              width: 0.8.sw,
              child: (imageFile == null)
                  ? Center(child: SvgPicture.asset(Media.upload, height: 32, width: 32, colorFilter: ColorFilter.mode(AppColors.black, BlendMode.srcIn),))
                  : imageFile!.path.contains('.png') || imageFile!.path.contains('.webm') || imageFile!.path.contains('.hoec') || imageFile!.path.contains('.jpg') || imageFile!.path.contains('.jpeg')
                  ? Image.file(File(imageFile!.path), height: 140.h, width: 0.8.sw)
                  : Center(
                child: Text(
                  imageFile!.path,
                  style: AppThemes.sora(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      );
  }
}
