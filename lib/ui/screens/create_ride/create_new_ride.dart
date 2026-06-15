import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/data/locator.dart';
import 'package:ridechain_driiver/data/models/location_model.dart';
import 'package:ridechain_driiver/providers/rides_provider.dart';
import 'package:ridechain_driiver/services/dialog_service.dart';
import 'package:ridechain_driiver/ui/screens/create_ride/widgets/autocomplete_location.dart';

import '../../../core/core_constants/colors.dart';
import '../../../providers/auth_provider.dart';

class CreateNewRide extends StatefulWidget {
  const CreateNewRide({super.key});

  @override
  State<CreateNewRide> createState() => _CreateNewRideState();
}

class _CreateNewRideState extends State<CreateNewRide> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController seatsCtrl = TextEditingController(text: '1');
  TextEditingController priceCtrl = TextEditingController();
  LocationModel? pickup;
  LocationModel? destination;
  DateTime? departureTime;

  int _seats = 1;
  int? _selectedTimeIndex;
  int _selectedDateIndex = 0;

  @override
  void dispose() {
    seatsCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  String _formatLovelace(int lovelace) {
    if (lovelace >= 1000000) return '${(lovelace / 1000000).toStringAsFixed(1)}M';
    if (lovelace >= 1000) return '${(lovelace / 1000).toStringAsFixed(0)}k';
    return '$lovelace';
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    final rideVm = Provider.of<RideProvider>(context);

    final now = DateTime.now();
    final dates = List.generate(7, (i) => now.add(Duration(days: i)));
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final times = ['7:00 AM', '9:30 AM', '12:00 PM', '2:30 PM', '4:00 PM', '6:30 PM'];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _globalKey,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                              ),
                              child: const Icon(Icons.chevron_left, color: Colors.black),
                            ),
                          ),
                        ),
                        Text(
                          'Create a ride',
                          style: TextStyle(
                            fontFamily: 'BeauSans',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Route card
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                // Pickup row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 10.w,
                                      height: 10.w,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Gap(12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pickup location',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          Gap(2.h),
                                          LocationAutocomplete(
                                            locations: authVm.allLocations,
                                            hintText: 'Where are you starting?',
                                            initialValue: pickup,
                                            decoration: InputDecoration(
                                              hintText: 'Where are you starting?',
                                              hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[400],
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onLocationSelected: (loc) {
                                              setState(() => pickup = loc);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(8.h),
                                Divider(height: 1, color: Colors.grey[100]),
                                Gap(8.h),
                                // Drop-off row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 10.w,
                                      height: 10.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.purple,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Gap(12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Drop-off location',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          Gap(2.h),
                                          LocationAutocomplete(
                                            locations: authVm.allLocations,
                                            hintText: 'Where are you headed?',
                                            initialValue: destination,
                                            decoration: InputDecoration(
                                              hintText: 'Where are you headed?',
                                              hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[400],
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onLocationSelected: (loc) {
                                              setState(() => destination = loc);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Gap(20.h),
                          // Departure date label
                          Text(
                            'Departure date',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Gap(10.h),
                          // Date chips
                          SizedBox(
                            height: 72.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 7,
                              itemBuilder: (context, i) {
                                final date = dates[i];
                                final isSelected = _selectedDateIndex == i;
                                final dayName = i == 0 ? 'Today' : dayNames[(date.weekday - 1) % 7];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDateIndex = i;
                                      if (departureTime != null) {
                                        departureTime = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          departureTime!.hour,
                                          departureTime!.minute,
                                        );
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 56.w,
                                    margin: EdgeInsets.only(right: 8.w),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.purple : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          dayName,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[500],
                                          ),
                                        ),
                                        Gap(2.h),
                                        Text(
                                          '${date.day}',
                                          style: TextStyle(
                                            fontFamily: 'BeauSans',
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Gap(20.h),
                          // Departure time label
                          Text(
                            'Departure time',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Gap(10.h),
                          // Time chips grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 2.4,
                            ),
                            itemCount: times.length,
                            itemBuilder: (context, i) {
                              final isSelected = _selectedTimeIndex == i;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTimeIndex = i;
                                    // Parse time string and set departureTime
                                    final parts = times[i].split(':');
                                    int hour = int.parse(parts[0]);
                                    final minParts = parts[1].split(' ');
                                    final int minute = int.parse(minParts[0]);
                                    final bool isPM = minParts[1] == 'PM';
                                    if (isPM && hour != 12) hour += 12;
                                    if (!isPM && hour == 12) hour = 0;
                                    final baseDate = dates[_selectedDateIndex];
                                    departureTime = DateTime(
                                      baseDate.year,
                                      baseDate.month,
                                      baseDate.day,
                                      hour,
                                      minute,
                                    );
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.purple.withValues(alpha: 0.05) : Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: isSelected ? AppColors.purple : Colors.grey[200]!,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    times[i],
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: isSelected ? AppColors.purple : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Gap(20.h),
                          // Available seats
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Available seats',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'How many riders can you take?',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_seats > 1) {
                                        setState(() {
                                          _seats--;
                                          seatsCtrl.text = '$_seats';
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 32.w,
                                      height: 32.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 20.w,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Gap(16.w),
                                  Text(
                                    '$_seats',
                                    style: TextStyle(
                                      fontFamily: 'BeauSans',
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Gap(16.w),
                                  GestureDetector(
                                    onTap: () {
                                      if (_seats < 8) {
                                        setState(() {
                                          _seats++;
                                          seatsCtrl.text = '$_seats';
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 32.w,
                                      height: 32.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.purple,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 20.w,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Gap(20.h),
                          // Price per seat label
                          Text(
                            'Price per seat',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Gap(8.h),
                          // Price field card
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '\u229B',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.purple,
                                  ),
                                ),
                                Gap(8.w),
                                Expanded(
                                  child: TextFormField(
                                    controller: priceCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: TextStyle(
                                      fontFamily: 'BeauSans',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0.0',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                    validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                                    onChanged: (v) => setState(() {}),
                                  ),
                                ),
                                Text(
                                  'ADA',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(8.h),
                          Builder(
                            builder: (_) {
                              final price = double.tryParse(priceCtrl.text) ?? 0;
                              final lovelace = (price * 1000000).toInt();
                              return Text(
                                '\u2248 ${_formatLovelace(lovelace)} Lovelace \u00B7 You earn the full amount per booked seat.',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom publish button
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 24.h,
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: authVm.isLoading || rideVm.isLoading
                      ? null
                      : () async {
                          if (pickup == null) {
                            locator<DialogService>().showSnackBar("Error", "Pick up location must be selected");
                            return;
                          }
                          if (destination == null) {
                            locator<DialogService>().showSnackBar("Error", "Drop off location must be selected");
                            return;
                          }
                          if (departureTime == null) {
                            locator<DialogService>().showSnackBar("Error", "Departure time must be selected");
                            return;
                          }
                          if (_globalKey.currentState!.validate()) {
                            Map<String, dynamic> body = {
                              "pick_up": pickup?.id,
                              "drop_off": destination?.id,
                              "seats_available": _seats,
                              "price_per_seat": int.tryParse(priceCtrl.text.trim()) ?? 0,
                              "departure_time": departureTime?.toIso8601String(),
                            };
                            bool success = await rideVm.createRide(body);
                            if (success && mounted) Navigator.pop(context);
                          }
                        },
                  icon: (authVm.isLoading || rideVm.isLoading)
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check, color: Colors.white, size: 18),
                  label: Text(
                    'Publish ride',
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
            ),
          ],
        ),
      ),
    );
  }
}
