import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/media.dart';
import '../../../../core/utility.dart';
import '../../../../data/models/ride_model.dart';

class HistoryWidget extends StatelessWidget {
  final RideModel? ride;
  const HistoryWidget({super.key, this.ride});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 80, width: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppColors.backgroundColor), child: Center(child: SvgPicture.asset(Media.car))),
            Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ride?.dropOff?.name ?? "Kasoa", style: AppThemes.getCustomTextStyle(fontFamily: "Outfit", fontSize: 20, weight: FontWeight.w700, color: AppColors.black), maxLines: 3),
                  Gap(10),
                  Text(Utils.formatDateTime(ride?.departureTime ?? DateTime.now()), style: AppThemes.getCustomTextStyle(fontFamily: "Outfit", fontSize: 16, weight: FontWeight.w500, color: AppColors.black)),
                  Gap(10),
                  Text("ADA ${ride?.pricePerSeat ?? 0.0}", style: AppThemes.getCustomTextStyle(fontSize: 16, fontFamily: "Outfit", color: AppColors.black, weight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}