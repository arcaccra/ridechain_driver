import 'package:dotted_line_flutter/dotted_line_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../app/theme.dart';
import '../../core/core_constants/colors.dart';
import '../../core/core_constants/label.dart';
import '../../core/core_constants/media.dart';
import '../../data/models/ride_model.dart';

class AcceptedTripDetailWidget extends StatelessWidget {
  final RideModel? ride;
  const AcceptedTripDetailWidget({super.key, this.ride});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(ride?.driver?.user?.avatar ?? 'https://i.pravatar.cc/150?img=3')),
            Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ride?.driver?.user?.fullName ?? "John Doe", style: AppThemes.getCustomTextStyle(fontFamily: "Outfit", fontSize: 18, weight: FontWeight.w700, color: AppColors.black)),
                  Gap(10),
                  Row(children: [SvgPicture.asset(Media.steering, height: 12, width: 12), Gap(4), Text(ride?.driver?.vehicleType ?? "Hyundai Elantra (Silver)", style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.black, weight: FontWeight.w400))]),
                  Gap(10),
                  Row(children: [SvgPicture.asset(Media.blackCar, height: 12, width: 12), Gap(4), Text(ride?.driver?.vehiclePlateNumber ?? "MNO-7890", style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.black, weight: FontWeight.w400))]),
                ],
              ),
            ),
            Column(children: [Text("ADA ${ride?.pricePerSeat ?? 0.0}", style: AppThemes.getCustomTextStyle(fontSize: 18, fontFamily: "Outfit", color: AppColors.black, weight: FontWeight.w700)), Gap(8)]),
          ],
        ),
        //ride information
        Gap(16),
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, color: AppColors.purple, size: 8),
                Gap(20.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Label.pickup, style: AppThemes.getCustomTextStyle(color: AppColors.greyAd, fontSize: 14, weight: FontWeight.w500, fontFamily: "Outfit")),
                    Gap(6),
                    Text(ride?.pickUp?.name ?? "Adjringano", style: AppThemes.getCustomTextStyle(color: AppColors.black, fontSize: 14, weight: FontWeight.w600, fontFamily: "Outfit")),
                  ],
                ),
                // const Spacer(),
                // Text("11:14 AM" ?? Label.pickup, style: AppThemes.getCustomTextStyle(color: AppColors.greyAd, fontSize: 14, weight: FontWeight.w400, fontFamily: "Outfit")),
              ],
            ),
            Gap(20.h),
            SizedBox(width: 0.6.sw, child: DottedLine(axis: Axis.horizontal, lineThickness: 1, dashGap: 4, height: 1, dashWidth: 6, shadowBlurRadius: 0, shadowColor: Colors.transparent, colors: [AppColors.textFieldBorderColor])),
            Gap(16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.purple, size: 8),
                Gap(20.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Label.destination, style: AppThemes.getCustomTextStyle(color: AppColors.greyAd, fontSize: 14, weight: FontWeight.w500, fontFamily: "Outfit")),
                    Gap(6),
                    Text(ride?.dropOff?.name ?? "Kasoa", style: AppThemes.getCustomTextStyle(color: AppColors.black, fontSize: 14, weight: FontWeight.w600, fontFamily: "Outfit")),
                  ],
                ),
                const Spacer(),
                Text("", style: AppThemes.getCustomTextStyle(color: AppColors.greyAd, fontSize: 12, weight: FontWeight.w400, fontFamily: "Outfit")),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
