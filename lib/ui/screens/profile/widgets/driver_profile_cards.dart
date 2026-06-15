import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ridechain_driiver/app/theme.dart';
import 'package:ridechain_driiver/core/core_constants/colors.dart';

import '../../../../core/core_constants/label.dart';


class DriverProfileCards extends StatelessWidget {
  final VoidCallback? onCardTap;
  final String? cardTitle;
  final String? cardInfo;
  final IconData? icon;
  const DriverProfileCards({super.key, this.icon, this.onCardTap, this.cardInfo, this.cardTitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.white
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon ?? Icons.trending_up_rounded, size: 16, color: AppColors.purple,),
                Gap(4),
                Text(cardInfo ?? Label.totalRides, style: AppThemes.sora(fontSize: 14, color: AppColors.greyAd, fontWeight: FontWeight.w400),)
              ],
            ),
            Gap(16),
            Text(cardTitle ?? Label.newOrders, style: AppThemes.getCustomTextStyle(fontSize: 16, color: AppColors.black, weight: FontWeight.w700),)
          ],
        ),
      ),
    );
  }
}
