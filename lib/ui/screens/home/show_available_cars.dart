import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/core_constants/colors.dart';
import '../../../providers/rides_provider.dart';

class ShowAvailableCarsWidget extends StatelessWidget {
  const ShowAvailableCarsWidget({
    super.key,
    required this.onRideTap,
    this.onCreateNewRide,
    this.onCancel,
  });

  final VoidCallback? onCreateNewRide;
  final VoidCallback? onCancel;
  final Function(String) onRideTap;

  @override
  Widget build(BuildContext context) {
    final ridesProvider = Provider.of<RideProvider>(context);
    return Container(
      constraints: BoxConstraints(maxHeight: 0.65.sh),
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
            children: [
              Text(
                '${ridesProvider.rides.length} trip${ridesProvider.rides.length == 1 ? '' : 's'} available',
                style: TextStyle(
                  fontFamily: 'BeauSans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
          Gap(12.h),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: ridesProvider.rides.length,
              separatorBuilder: (_, __) => Gap(10.h),
              itemBuilder: (context, index) {
                final ride = ridesProvider.rides[index];
                final departureTimeStr = ride.departureTime != null
                    ? '${ride.departureTime!.hour.toString().padLeft(2, '0')}:${ride.departureTime!.minute.toString().padLeft(2, '0')}'
                    : '';
                return GestureDetector(
                  onTap: () => onRideTap(ride.uuid!),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pickup row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 8.w,
                                        height: 8.w,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        width: 1.5,
                                        height: 24.h,
                                        color: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                  Gap(10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PICKUP',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[400],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          ride.pickUp?.name ?? '',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Gap(4.h),
                              // Dropoff row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.purple,
                                    size: 10.w,
                                  ),
                                  Gap(6.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'DROP-OFF',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[400],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          ride.dropOff?.name ?? '',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Gap(10.h),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14.w, color: Colors.grey[400]),
                                  Gap(4.w),
                                  Text(
                                    departureTimeStr,
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                  ),
                                  Gap(12.w),
                                  Icon(Icons.people_outline, size: 14.w, color: Colors.grey[400]),
                                  Gap(4.w),
                                  Text(
                                    '${ride.passengers?.length ?? 0} pax',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                  ),
                                  Gap(12.w),
                                  Icon(Icons.airline_seat_recline_normal, size: 14.w, color: Colors.grey[400]),
                                  Gap(4.w),
                                  Text(
                                    '${ride.seatsAvailable ?? 0} seats',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Gap(12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '⊛ ',
                                  style: TextStyle(fontSize: 12.sp, color: AppColors.purple),
                                ),
                                Text(
                                  '${ride.pricePerSeat ?? 0}',
                                  style: TextStyle(
                                    fontFamily: 'BeauSans',
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'per seat',
                              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                            ),
                            Gap(4.h),
                            Icon(Icons.chevron_right, color: Colors.grey[400], size: 18.w),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
