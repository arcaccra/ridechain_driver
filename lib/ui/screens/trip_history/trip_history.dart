import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/core_constants/colors.dart';
import '../../../data/models/ride_model.dart';
import '../../../providers/rides_provider.dart';


class TripHistory extends StatefulWidget {
  const TripHistory({super.key});

  @override
  State<TripHistory> createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  List<RideModel> completedRides = [];
  late RideProvider rideVm;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    rideVm = context.read<RideProvider>();
    completedRides = rideVm.rides
        .where((ride) =>
            ride.status != null &&
            (ride.status?.toLowerCase() == 'completed' ||
                ride.status?.toLowerCase() == 'cancelled'))
        .toList();
  }

  List<RideModel> get _filteredRides {
    if (_filter == 'completed') {
      return completedRides
          .where((r) => r.status?.toLowerCase() == 'completed')
          .toList();
    }
    if (_filter == 'cancelled') {
      return completedRides
          .where((r) => r.status?.toLowerCase() == 'cancelled')
          .toList();
    }
    return completedRides;
  }

  @override
  Widget build(BuildContext context) {
    rideVm = context.watch<RideProvider>();
    final filtered = _filteredRides;
    final completedCount = completedRides
        .where((r) => r.status?.toLowerCase() == 'completed')
        .length;
    final totalEarned = completedRides
        .where((r) => r.status?.toLowerCase() == 'completed')
        .fold(0.0, (sum, r) {
      final price = double.tryParse(r.pricePerSeat ?? '0') ?? 0.0;
      final passengerCount = r.passengers?.length ?? 1;
      return sum + (price * passengerCount);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip history',
                    style: TextStyle(
                      fontFamily: 'BeauSans',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    '${completedRides.length} trips · all time',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                  ),
                  Gap(16.h),
                  // Stats row
                  Row(
                    children: [
                      // Total earned - purple card
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.purple,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '⊛ ',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                  Text(
                                    'Total earned',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ),
                              Gap(4.h),
                              Text(
                                totalEarned.toStringAsFixed(1),
                                style: TextStyle(
                                  fontFamily: 'BeauSans',
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(12.w),
                      // Completed - white card
                      Expanded(
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
                              Row(
                                children: [
                                  Icon(Icons.check,
                                      color: Colors.green, size: 14.w),
                                  Gap(4.w),
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.green),
                                  ),
                                ],
                              ),
                              Gap(4.h),
                              Text(
                                '$completedCount',
                                style: TextStyle(
                                  fontFamily: 'BeauSans',
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(16.h),
                  // Filter chips
                  Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      Gap(8.w),
                      _FilterChip(
                        label: 'Completed',
                        isSelected: _filter == 'completed',
                        onTap: () => setState(() => _filter = 'completed'),
                      ),
                      Gap(8.w),
                      _FilterChip(
                        label: 'Cancelled',
                        isSelected: _filter == 'cancelled',
                        onTap: () => setState(() => _filter = 'cancelled'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(12.h),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history,
                              size: 64.w, color: Colors.grey[300]),
                          Gap(16.h),
                          Text(
                            'No trips yet',
                            style: TextStyle(
                                fontSize: 16.sp, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Gap(10.h),
                      itemBuilder: (context, index) {
                        final ride = filtered[index];
                        final isCompleted =
                            ride.status?.toLowerCase() == 'completed';
                        final price =
                            double.tryParse(ride.pricePerSeat ?? '0') ?? 0.0;
                        final passengerCount = ride.passengers?.length ?? 0;
                        final pickUpName = ride.pickUp is DropOff
                            ? (ride.pickUp as DropOff).name ?? ''
                            : '';
                        final dropOffName = ride.dropOff is DropOff
                            ? (ride.dropOff as DropOff).name ?? ''
                            : '';
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: date + status badge
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 14.w, color: Colors.grey[400]),
                                  Gap(6.w),
                                  Text(
                                    ride.departureTime != null
                                        ? '${_monthName(ride.departureTime!.month)} ${ride.departureTime!.day} · ${_formatTime(ride.departureTime!)}'
                                        : 'Date unknown',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500]),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.red.withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      isCompleted ? 'Completed' : 'Cancelled',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: isCompleted
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Gap(12.h),
                              // Route: pickup → dropoff
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
                                          height: 28.h,
                                          color: Colors.grey[300]),
                                      Icon(Icons.location_on,
                                          color: AppColors.purple, size: 10.w),
                                    ],
                                  ),
                                  Gap(10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PICKUP',
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.grey[400],
                                              letterSpacing: 0.5),
                                        ),
                                        Text(
                                          pickUpName,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Gap(14.h),
                                        Text(
                                          'DROP-OFF',
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.grey[400],
                                              letterSpacing: 0.5),
                                        ),
                                        Text(
                                          dropOffName,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Gap(12.h),
                              Divider(height: 1, color: Colors.grey[100]),
                              Gap(10.h),
                              Row(
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 14.w, color: Colors.grey[400]),
                                  Gap(6.w),
                                  Text(
                                    '$passengerCount passenger${passengerCount == 1 ? '' : 's'}',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600]),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '⊛ ',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.purple),
                                  ),
                                  Text(
                                    (price * passengerCount)
                                        .toStringAsFixed(1),
                                    style: TextStyle(
                                      fontFamily: 'BeauSans',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
