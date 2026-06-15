import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/core_constants/colors.dart';
import '../../core/core_constants/label.dart';
import '../../core/core_constants/media.dart';
import '../../app/theme.dart';


class AvailableCarCard extends StatelessWidget {
  const AvailableCarCard({super.key, this.amount, this.minutes, this.rating, this.isSelected = false});
  final bool isSelected;
  final double? amount;
  final int? minutes;
  final double? rating;


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 137.w,
      height: 139.h,
      margin: EdgeInsets.only(left: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
          color: isSelected ? AppColors.purple : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: AppColors.textFieldBorderColor)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.star, color: AppColors.orange, size: 12,),
              Text("${rating ?? 4.5}/5", style: AppThemes.getCustomTextStyle(fontSize: 12, color: isSelected ? AppColors.orange  : AppColors.greyAd, weight: FontWeight.w400),),
            ],
          ),
          Gap(10),
          SizedBox(height: 47, width: 99, child: Image.asset(Media.onboardingToyotaImg, height: 47, width: 99,)),
          Gap(16),
          Text("ADA ${amount ?? ""}", style: AppThemes.getCustomTextStyle(fontSize: 18, color: isSelected ? AppColors.white : AppColors.primaryColor, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis,),
          Gap(16),
          Text("${minutes ?? 7} min", style: AppThemes.getCustomTextStyle(fontSize: 12, color: isSelected ? AppColors.orange : AppColors.greyAd, weight: FontWeight.w400),),
        ],
      ),
    );
  }
}
