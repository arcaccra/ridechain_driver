import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/core_constants/colors.dart';
import '../../../data/locator.dart';
import '../../../services/dialog_service.dart';
import '../../../services/location_service.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../trip_history/trip_history.dart';
import '../create_ride/create_new_ride.dart';

class AppNavigationScreen extends StatefulWidget {
  const AppNavigationScreen({super.key});

  @override
  State<AppNavigationScreen> createState() => _AppNavigationScreenState();
}

class _AppNavigationScreenState extends State<AppNavigationScreen>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  final location = locator<LocationService>();
  bool _hasInitializedLocation = false;

  final List<Widget> _screens = const [
    HomePage(),
    TripHistory(),
    ProfileScreen(),
  ];

  void changeTheCurrentIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  /// Initialize location services once
  Future<void> _initializeLocation() async {
    if (_hasInitializedLocation) return;

    try {
      await startListeningToUserPosition();
      _hasInitializedLocation = true;
    } catch (e) {
      log('Location initialization error: $e');
    }
  }

  Future<void> startListeningToUserPosition() async {
    if (!mounted) return;

    try {
      bool isLocationGranted =
          await location.checkLocationPermission(context);

      if (isLocationGranted && mounted) {
        location.startListeningToPosition();
      }
    } catch (e) {
      log('Error starting location listener: $e');
      if (mounted) {
        locator<DialogService>().showSnackBar(
          "Location Error",
          "Failed to start location services: ${e.toString()}",
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      location.clearPermissionCache();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    location.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: _screens[currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64.h,
            child: Row(
              children: [
                // Home
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    isActive: currentIndex == 0,
                    onTap: () => setState(() => currentIndex = 0),
                  ),
                ),
                // History
                Expanded(
                  child: _NavItem(
                    icon: Icons.history,
                    label: 'History',
                    isActive: currentIndex == 1,
                    onTap: () => setState(() => currentIndex = 1),
                  ),
                ),
                // Center FAB
                SizedBox(
                  width: 80.w,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Get.to(() => const CreateNewRide()),
                      child: Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 28.w),
                      ),
                    ),
                  ),
                ),
                // Profile
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    isActive: currentIndex == 2,
                    onTap: () => setState(() => currentIndex = 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? (activeIcon ?? icon) : icon,
            color: isActive ? AppColors.purple : Colors.grey[400],
            size: 24.w,
          ),
          Gap(4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isActive ? AppColors.purple : Colors.grey[400],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
