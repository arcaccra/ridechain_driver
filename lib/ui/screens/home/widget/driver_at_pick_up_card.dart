import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/data/locator.dart';
import 'package:ridechain_driiver/providers/auth_provider.dart';
import 'package:ridechain_driiver/services/dialog_service.dart';
import 'package:ridechain_driiver/services/trip_firebase_service.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../data/models/ride_model.dart';

class DriverAtPickUpCard extends StatefulWidget {
  final Function onCancel;
  final VoidCallback? onEndTrip;
  final List<Passenger> passengers;
  final VoidCallback? onStartTrip;
  const DriverAtPickUpCard({
    super.key,
    this.onEndTrip,
    required this.onCancel,
    required this.passengers,
    this.onStartTrip,
  });

  @override
  State<DriverAtPickUpCard> createState() => _DriverAtPickUpCardState();
}

class _DriverAtPickUpCardState extends State<DriverAtPickUpCard> {
  Timer? _timer;
  late Duration _remainingTime;
  bool _isDialogShowing = false;

  List<Passenger> stateList = [];
  Set<int> boardedIds = {};

  @override
  void initState() {
    super.initState();
    _remainingTime = const Duration(minutes: 10);
    _startTimer();
    stateList = List.from(widget.passengers);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Starts the countdown timer
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        _showTimeoutDialog();
      } else {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      }
    });
  }

  /// Restarts the timer from the beginning
  void _restartTimer() {
    setState(() {
      _remainingTime = const Duration(minutes: 10);
    });
    _startTimer();
  }

  /// Shows the modal dialog when timer reaches zero
  void _showTimeoutDialog() {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    locator<DialogService>().showAlertDialog(
      context: context,
      showTitle: true,
      title: Label.waitTimeExpired,
      message: Label.waitTimeExpiredMsg,
      showCancelBtn: true,
      cancelText: Label.cancelMsg,
      okayText: Label.okMsg,
      onCancelBtnTap: () {
        Navigator.of(context).pop();
        _isDialogShowing = false;
        widget.onCancel();
      },
      onOkayBtnTap: () {
        Navigator.of(context).pop();
        _isDialogShowing = false;
        _restartTimer();
      },
      type: AlertDialogType.error,
    );
  }

  /// Formats the remaining time as MM:SS
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  removeFromStateList(int index) {
    setState(() {
      stateList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on, color: Colors.green, size: 20.w),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You've arrived",
                    style: TextStyle(
                      fontFamily: 'BeauSans',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'At pickup location',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${boardedIds.length} / ${widget.passengers.length} boarded',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Gap(8.h),
        // Timer row
        Row(
          children: [
            Icon(Icons.timer_outlined, size: 14.w, color: Colors.grey[400]),
            Gap(4.w),
            Text(
              '${Label.waitTime}: ${_formatTime(_remainingTime)}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
        Gap(16.h),
        Text(
          'Check in passengers',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Gap(8.h),
        Expanded(
          child: ListView.separated(
            itemCount: stateList.length,
            separatorBuilder: (_, __) => Gap(8.h),
            itemBuilder: (context, index) {
              final passenger = stateList[index];
              final initials = (passenger.fullName ?? 'P')
                  .split(' ')
                  .take(2)
                  .map((w) => w.isNotEmpty ? w[0] : '')
                  .join()
                  .toUpperCase();
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
                    // Check in / Boarded button
                    GestureDetector(
                      onTap: boardedIds.contains(passenger.id)
                          ? null
                          : () {
                              if (passenger.id != null) {
                                setState(() => boardedIds.add(passenger.id!));
                              }
                            },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: boardedIds.contains(passenger.id)
                              ? Colors.green.withValues(alpha: 0.1)
                              : AppColors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              boardedIds.contains(passenger.id)
                                  ? Icons.check_circle_outline
                                  : Icons.person_add_outlined,
                              size: 13.w,
                              color: boardedIds.contains(passenger.id)
                                  ? Colors.green
                                  : AppColors.purple,
                            ),
                            Gap(4.w),
                            Text(
                              boardedIds.contains(passenger.id) ? 'Boarded' : 'Check in',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: boardedIds.contains(passenger.id)
                                    ? Colors.green
                                    : AppColors.purple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Gap(16.h),
        // Start Trip button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: widget.onStartTrip,
            icon: const Icon(Icons.bolt, color: Colors.white),
            label: Text(
              'Start Trip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.r),
              ),
              elevation: 0,
            ),
          ),
        ),
        Gap(12.h),
        // Cancel/End Trip button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: OutlinedButton(
            onPressed: widget.onEndTrip,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            child: Text(
              Label.cancelTrip,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
