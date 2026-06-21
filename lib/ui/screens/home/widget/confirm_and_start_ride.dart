import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/data/locator.dart';
import 'package:ridechain_driiver/data/models/ride_model.dart';
import 'package:ridechain_driiver/providers/auth_provider.dart';
import 'package:ridechain_driiver/services/trip_firebase_service.dart';
import 'package:ridechain_driiver/ui/screens/home/widget/passenger_card.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../providers/rides_provider.dart';

class ConfirmAndStartRide extends StatefulWidget {
  final RideModel? ride;
  final VoidCallback? onAccept;
  const ConfirmAndStartRide({super.key, this.ride, this.onAccept});

  @override
  State<ConfirmAndStartRide> createState() => _ConfirmAndStartRideState();
}

class _ConfirmAndStartRideState extends State<ConfirmAndStartRide> {
  List<int> rideIds = [];

  addRideId(int id) {
    setState(() {
      rideIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideVm = Provider.of<RideProvider>(context);
    final authVm = Provider.of<AuthVm>(context);
    final ride = widget.ride;

    return Container(
      height: 0.95.sh,
      width: 1.sw,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(12.h),
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Gap(16.h),
          // Header row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Text(
                  'Trip details',
                  style: TextStyle(
                    fontFamily: 'BeauSans',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16.w, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          Gap(16.h),
          // Route card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 28.h,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                      Gap(12.w),
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
                            Gap(2.h),
                            Text(
                              ride?.pickUp?.name ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(4.h),
                  // Dropoff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: AppColors.purple, size: 10.w),
                      Gap(8.w),
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
                            Gap(2.h),
                            Text(
                              ride?.dropOff?.name ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Gap(12.h),
          // Info chips row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.access_time,
                  label: ride?.departureTime != null
                      ? '${ride!.departureTime!.hour.toString().padLeft(2, '0')}:${ride.departureTime!.minute.toString().padLeft(2, '0')}'
                      : '--:--',
                  sublabel: 'Departs',
                ),
                Gap(8.w),
                _InfoChip(
                  icon: Icons.people_outline,
                  label: '${ride?.passengers?.length ?? 0}',
                  sublabel: 'Riders',
                ),
                Gap(8.w),
                _InfoChip(
                  icon: Icons.airline_seat_recline_normal,
                  label: '${ride?.seatsAvailable ?? 0}',
                  sublabel: 'Seats avail',
                ),
              ],
            ),
          ),
          Gap(12.h),
          // Earnings highlight
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You'll earn",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                      ),
                      Text(
                        '${ride?.passengers?.length ?? 0} × ₳${ride?.pricePerSeat ?? 0}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '⊛ ',
                        style: TextStyle(fontSize: 16.sp, color: AppColors.purple),
                      ),
                      Text(
                        ((ride?.passengers?.length ?? 0) * (num.parse(ride?.pricePerSeat ?? "0"))).toStringAsFixed(1),
                        style: TextStyle(
                          fontFamily: 'BeauSans',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Gap(16.h),
          // Passengers section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Label.pickupQueue,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${ride?.passengers?.length ?? 0}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Gap(4.w),
                    Text(
                      Label.total,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(8.h),
          // Passengers list
          Expanded(
            child: ride!.passengers!.isEmpty
                ? Center(
                    child: DottedBorder(
                      options: RectDottedBorderOptions(
                        padding: const EdgeInsets.all(10),
                        dashPattern: [2, 2],
                        color: Colors.grey,
                      ),
                      child: Text(
                        Label.noAvailablePassengers,
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: ride.passengers!.length,
                    separatorBuilder: (_, __) => Gap(8.h),
                    itemBuilder: (context, index) {
                      final passenger = ride.passengers![index];
                      return PassengerCard(
                        passenger: passenger,
                        showPassengerActionWidget: !rideIds.contains(passenger.id),
                        onPassengerAccept: () async {
                          addRideId(passenger.id!);
                          await locator<TripFirebaseService>().respondToTripRequest(
                            driver: authVm.currentAuth!,
                            tripId: ride.uuid!,
                            requestId: passenger.id.toString(),
                            accept: true,
                          );
                        },
                        onPassengerReject: () async {
                          addRideId(passenger.id!);
                          await locator<TripFirebaseService>().respondToTripRequest(
                            driver: authVm.currentAuth!,
                            tripId: ride.uuid!,
                            requestId: passenger.id.toString(),
                            accept: false,
                          );
                        },
                      );
                    },
                  ),
          ),
          Gap(16.h),
          // Confirm & Start Ride button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: (ride.passengers!.isEmpty || rideIds.length != ride.passengers!.length)
                    ? null
                    : widget.onAccept,
                icon: const Icon(Icons.bolt, color: Colors.white, size: 20),
                label: Text(
                  'Confirm & Start Ride',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          Gap(kBottomNavigationBarHeight),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14.w, color: AppColors.purple),
            Gap(4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
