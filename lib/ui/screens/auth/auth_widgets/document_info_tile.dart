import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/media.dart';


class DocumentInfoTile extends StatelessWidget {
  final String name;
  final String desc;
  final bool isUploaded;
  const DocumentInfoTile({super.key, required this.name, required this.desc, required this.isUploaded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: AppThemes.getCustomTextStyle(weight: FontWeight.w700, fontSize: 16, color: AppColors.primaryColor),),
              Gap(4.h),
              Text(desc, style: AppThemes.getCustomTextStyle(weight: FontWeight.w400, fontSize: 14, color: AppColors.greyAd),),
            ],
          ),
          Container(
            height: 32,
            width: 32,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor
            ),
            child: SvgPicture.asset(isUploaded ? Media.check : Media.upload, height: 16, width: 16,),
          )
        ],
      ),
    );
  }
}
