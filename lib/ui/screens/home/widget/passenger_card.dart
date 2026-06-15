import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ridechain_driiver/app/theme.dart';
import 'package:ridechain_driiver/ui/shared_widgets/default_back_button.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../data/models/ride_model.dart';


class PassengerCard extends StatelessWidget {
  final Passenger? passenger;
  final double? price;
  final VoidCallback? onPassengerReject;
  final VoidCallback? onPassengerAccept;
  final Widget? passengersActionWidget;
  final bool showPassengerActionWidget;
  const PassengerCard({super.key, this.passenger, this.price, this.showPassengerActionWidget = true, this.onPassengerAccept, this.onPassengerReject, this.passengersActionWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.lightPurple,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                foregroundImage: NetworkImage(passenger!.avatar!),
                backgroundColor: AppColors.lightPurpleFF,
              ),
              Gap(16),
              Text(passenger?.fullName ?? "Anon", style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.black, weight: FontWeight.w800),),

            ],
          ),
          // Text("ADA ${price ?? 0.0}", style: AppThemes.getCustomTextStyle(fontSize: 12, color: AppColors.black, weight: FontWeight.w800),),
          if(showPassengerActionWidget) passengersActionWidget ?? Row(
            children: [
              DefaultBackButton(btnColor: AppColors.lightPurpleFF, iconColor: AppColors.purple, icon: Icons.clear, iconSize: 12, onBackTap: onPassengerReject,),
              Gap(6),
              DefaultBackButton(btnColor: AppColors.purple, iconColor: AppColors.white, icon: Icons.check, iconSize: 12, onBackTap: onPassengerAccept,)
            ],
          ),
        ],
      ),
    );
  }
}
