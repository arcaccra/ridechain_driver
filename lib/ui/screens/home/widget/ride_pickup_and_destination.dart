import 'package:dotted_line_flutter/dotted_line_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';


class RidePickupAndDestination extends StatelessWidget {
  const RidePickupAndDestination({super.key, this.pickupLocation, this.destinationLocation});

  final String? pickupLocation;
  final String? destinationLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: AppColors.purple, size: 8),
              Gap(20.w),
              Text(Label.pickup, style: AppThemes.getCustomTextStyle(color: AppColors.greyAd, fontSize: 12, weight: FontWeight.w700, fontFamily: "Outfit")),
              const Spacer(),
              Text(pickupLocation ?? Label.pickup, style: AppThemes.getCustomTextStyle(color: AppColors.black, fontSize: 13, weight: FontWeight.w400, fontFamily: "Outfit")),
            ],
          ),
          Gap(20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 0.75.sw,
                child: DottedLine(
                  axis: Axis.horizontal,
                  lineThickness: 1,
                  dashGap: 4,
                  height: 1,
                  dashWidth: 6,
                  shadowBlurRadius: 0,
                  shadowColor: Colors.transparent,
                  colors: [AppColors.textFieldBorderColor],
                ),
              ),
            ],
          ),
          Gap(20.h),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.purple, size: 8),
              Gap(20.w),
              Text(Label.destination, style: AppThemes.getCustomTextStyle(color: AppColors.greyAd, fontSize: 12, weight: FontWeight.w700, fontFamily: "Outfit")),
              const Spacer(),
              Text(destinationLocation ?? Label.destination, style: AppThemes.getCustomTextStyle(color: AppColors.black, fontSize: 13, weight: FontWeight.w400, fontFamily: "Outfit")),
            ],
          ),
        ],
      ),
    );
  }
}