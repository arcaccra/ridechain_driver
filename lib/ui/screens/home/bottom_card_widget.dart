import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../core/core_constants/colors.dart';

class BottomCardWidget extends StatelessWidget {
  const BottomCardWidget({super.key, required this.onBtnTap, this.onCreateRide});

  final VoidCallback onBtnTap;
  final VoidCallback? onCreateRide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Gap(16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to ride',
                      style: TextStyle(
                        fontFamily: 'BeauSans',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      "You're online and accepting trips",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '⊛ ',
                        style: TextStyle(fontSize: 14.sp, color: AppColors.purple),
                      ),
                      Text(
                        '86.5',
                        style: TextStyle(
                          fontFamily: 'BeauSans',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "today's earnings",
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          Gap(20.h),
          // Let's Ride button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: onBtnTap,
              icon: const Icon(Icons.bolt, color: Colors.white, size: 20),
              label: Text(
                "Let's Ride — find trips",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
                elevation: 0,
              ),
            ),
          ),
          Gap(10.h),
          // Create ride listing button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: onCreateRide,
              icon: const Icon(Icons.add, color: Colors.black87, size: 18),
              label: Text(
                'Create a ride listing',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
