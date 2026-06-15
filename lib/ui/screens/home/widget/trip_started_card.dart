import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/data/locator.dart';
import 'package:ridechain_driiver/services/dialog_service.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../data/models/ride_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/trip_firebase_service.dart';

class TripStartedCard extends StatefulWidget {
  final VoidCallback? onTripComplete;
  final List<Passenger>? passengers;
  const TripStartedCard({super.key, this.onTripComplete, this.passengers});

  @override
  State<TripStartedCard> createState() => _TripStartedCardState();
}

class _TripStartedCardState extends State<TripStartedCard> {
  List<int> stateList = [];

  addToIndex(int index) {
    setState(() {
      stateList.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        // Status row
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Gap(6.w),
                  Text(
                    'Trip in progress',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              '${widget.passengers?.length ?? 0} passengers',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
            ),
          ],
        ),
        Gap(16.h),
        Text(
          'HEADING TO',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[400],
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap(4.h),
        Text(
          'Destination',
          style: TextStyle(
            fontFamily: 'BeauSans',
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        Gap(8.h),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: LinearProgressIndicator(
                  value: 0.3,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                  minHeight: 4,
                ),
              ),
            ),
            Gap(12.w),
            Text(
              '10 min',
              style: TextStyle(
                fontFamily: 'BeauSans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Gap(4.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'to arrival',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
          ),
        ),
        Gap(12.h),
        // Passengers list
        Expanded(
          child: ListView.separated(
            itemCount: widget.passengers!.length,
            separatorBuilder: (_, __) => Gap(8.h),
            itemBuilder: (context, index) {
              final passenger = widget.passengers![index];
              final initials = (passenger.fullName ?? 'P')
                  .split(' ')
                  .take(2)
                  .map((w) => w.isNotEmpty ? w[0] : '')
                  .join()
                  .toUpperCase();
              final hasExited = stateList.contains(passenger.id);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Text(
                        passenger.fullName ?? 'Passenger',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: hasExited
                          ? null
                          : () {
                              addToIndex(passenger.id!);
                              locator<TripFirebaseService>().alertPassenger(
                                driver: authVm.currentAuth!,
                                passengerId: passenger.id.toString(),
                                body: 'The passenger ${passenger.fullName} has exited the vehicle',
                              );
                              locator<DialogService>().showSnackBar(
                                "Passenger Exit",
                                "${passenger.fullName} has completed payment and exited the vehicle",
                              );
                            },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: hasExited
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: hasExited
                            ? Icon(Icons.check, color: Colors.green, size: 16.w)
                            : Text(
                                'Exit',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Gap(20.h),
        // End Trip button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: stateList.length != widget.passengers!.length
                ? null
                : widget.onTripComplete,
            icon: const Icon(Icons.flag_outlined, color: Colors.white, size: 18),
            label: Text(
              'End Trip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.r),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
