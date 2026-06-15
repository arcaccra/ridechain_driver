import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../data/locator.dart';
import '../../../../services/dialog_service.dart';
import 'choose_image_picker.dart';


class GetUserImage extends StatelessWidget {
  const GetUserImage({super.key, this.imageFile, this.onCameraTap, this.onGalleryTap});
  final File? imageFile;
  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        locator<DialogService>().showCustomModal(context: context, customModal: CustomPictureModal(
            cameraBtnPressed: onCameraTap,
            galleryBtnPressed: onGalleryTap
        ));
      },
      child: Align(
        alignment: Alignment.center,
        child: CircleAvatar(
            backgroundColor: AppColors.borderColor,
            radius: 70,
            child: imageFile == null? const Center(
              child: Icon(Icons.person_2_outlined, size: 48, color: AppColors.primaryColor,),
            ) : CircleAvatar(
              radius: 70,
              foregroundImage: FileImage(File(imageFile!.path,),),)
        ),
      ),
    );
  }
}
