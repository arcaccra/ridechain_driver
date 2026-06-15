import 'package:dotted_line_flutter/dotted_line_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../app/theme.dart';
import '../../core/core_constants/colors.dart';
import '../../core/core_constants/label.dart';
import '../../core/core_constants/media.dart';
import '../../data/models/ride_model.dart';
import 'default_back_button.dart';

class DriverCarDetailWidget extends StatelessWidget {
  final RideModel? ride;
  const DriverCarDetailWidget({super.key, this.ride});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //main text
        Text(Label.notifyDriver, style: AppThemes.getCustomTextStyle(fontSize: 20.2, color: AppColors.primaryColor, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis,),
        Gap(10.h),
        //sub text
        Text(Label.notifyDriverMessage, style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.greyAd, weight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis,),
        Gap(30.h),
        SizedBox(
          width: 0.7.sw,
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
        Gap(30.h),
        CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(
            ride?.driver?.user?.avatar ?? "",
          ),
        ),
        Gap(12),
        Text(ride?.driver?.user?.fullName ?? "", style: AppThemes.getCustomTextStyle(fontFamily: "Outfit", fontSize: 18, weight: FontWeight.w700, color: AppColors.black)),
        Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(Media.steering, height: 12, width: 12,colorFilter: ColorFilter.mode(AppColors.purple, BlendMode.srcIn),),
            Gap(4),
            Text(ride?.driver?.vehicleType ?? "", style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.black, weight: FontWeight.w400),),
          ],
        ),
        Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(Media.blackCar, height: 12, width: 12, colorFilter: ColorFilter.mode(AppColors.purple, BlendMode.srcIn)),
            Gap(4),
            Text(ride?.driver?.vehiclePlateNumber ?? "", style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.black, weight: FontWeight.w700),),
            Gap(16),
            Icon(Icons.star, size:12, color: AppColors.orange,),
            Gap(4),
            Text("4.7/5 Rating", style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.black, weight: FontWeight.w700),),
          ],
        ),
        Gap(24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultBackButton(
              onBackTap: () {},
              iconColor: AppColors.purple,
              btnColor: AppColors.lightPurple,
              icon: CupertinoIcons.location,
            ),
            Gap(50.w),
            DefaultBackButton(
              onBackTap: () {},
              iconColor: AppColors.purple,
              btnColor: AppColors.lightPurple,
              icon: CupertinoIcons.phone,
            ),
          ],
        ),

      ],
    );
  }
}
