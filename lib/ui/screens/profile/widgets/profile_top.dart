import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/app/theme.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../data/models/user_model.dart';
import '../../../../providers/auth_provider.dart';

class ProfileTop extends StatelessWidget {
  final UserModel? user;
  final String? adaBalance;
  final String? address;
  const ProfileTop({super.key, this.user, this.adaBalance, this.address});

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    return Container(
      padding: EdgeInsets.only(top: 24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          //top widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24,),
            child: Row(
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: Stack(
                    children: [
                      CircleAvatar(radius: 36, backgroundColor: AppColors.greyAd, foregroundColor: AppColors.primaryColor, foregroundImage: NetworkImage(user?.avatar ?? "")),
                      Positioned(
                        bottom: 16,
                        right: 14,
                        child: Container(
                          height: 23,
                          width: 23,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.green,
                            border: Border.all(color: AppColors.white, width: 2.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? "Anon",
                      style: AppThemes.getCustomTextStyle(fontSize: 20, color: AppColors.black, weight: FontWeight.w700),
                    ),
                    Gap(4),
                    Text(
                      "Driver ID: ${user?.id ?? "RYD-4758"}",
                      style: AppThemes.getCustomTextStyle(fontSize: 16, color: AppColors.greyAd, weight: FontWeight.w500),
                    ),
                    Gap(4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.lightGreen),
                      child: Text(
                        "Verified",
                        style: AppThemes.getCustomTextStyle(fontSize: 14, color: AppColors.darkGreen, weight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(20.h),
          //bottom ada rating and trips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(25)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //total earning
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "ADA ${adaBalance ?? 0.0}",
                      style: AppThemes.getCustomTextStyle(fontSize: 20, color: AppColors.white, weight: FontWeight.w700),
                    ),
                    Gap(3.h),
                    Text(
                      Label.totalEarning,
                      style: AppThemes.sora(fontSize: 14, color: AppColors.lightPurpleFF, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(
                  height: 32.h,
                  width: 2,
                  child: VerticalDivider(
                    width: 2,
                    indent: 0,
                    endIndent: 0,
                    color: AppColors.lightPurpleFF,
                  ),
                ),
                //rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: AppColors.yellow),
                        Gap(6),
                        Text(
                          "4.5",
                          style: AppThemes.getCustomTextStyle(fontSize: 20, color: AppColors.white, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Gap(3.h),
                    Text(
                      Label.rating,
                      style: AppThemes.sora(fontSize: 14, color: AppColors.lightPurpleFF, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(
                  height: 32.h,
                  width: 2,
                  child: VerticalDivider(
                    width: 2,
                    indent: 0,
                    endIndent: 0,
                    color: AppColors.lightPurpleFF,
                  ),
                ),
                //trips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "5",
                      style: AppThemes.getCustomTextStyle(fontSize: 20, color: AppColors.white, weight: FontWeight.w700),
                    ),
                    Gap(3.h),
                    Text(
                      Label.trips,
                      style: AppThemes.sora(fontSize: 14, color: AppColors.lightPurpleFF, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
