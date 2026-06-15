import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/core_constants/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rides_provider.dart';
import '../auth/login_screen.dart';
import '../auth/wallet_info.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    final rideVm = Provider.of<RideProvider>(context);
    final user = authVm.currentUser;
    final initials = (user?.fullName ?? 'U')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Purple header card
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar circle with initials
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontFamily: 'BeauSans',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Gap(16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Driver',
                              style: TextStyle(
                                fontFamily: 'BeauSans',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Gap(6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.shield_outlined,
                                      size: 12.w, color: Colors.white),
                                  Gap(4.w),
                                  Text(
                                    'Verified driver',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gap(16.h),
                    // Stats bar
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          _StatItem(value: '4.92', label: 'Rating'),
                          _VertDivider(),
                          _StatItem(
                              value: '${rideVm.rides.length}',
                              label: 'Trips'),
                          _VertDivider(),
                          const _StatItem(value: '412', label: 'Hours'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 2x2 grid of quick-action cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.3,
                  children: [
                    _GridCard(
                      icon: Icons.credit_card_outlined,
                      iconColor: AppColors.purple,
                      iconBgColor: AppColors.purple.withValues(alpha: 0.1),
                      title: 'Wallet',
                      subtitle:
                          '₳ ${authVm.userWallet?.balance?.ada?.toStringAsFixed(0) ?? '0'}',
                      onTap: () => Get.to(() => const WalletInfo()),
                    ),
                    _GridCard(
                      icon: Icons.access_time_outlined,
                      iconColor: Colors.orange,
                      iconBgColor: Colors.orange.withValues(alpha: 0.1),
                      title: 'Hours online',
                      subtitle: '412 hrs',
                      onTap: () {},
                    ),
                    _GridCard(
                      icon: Icons.directions_car_outlined,
                      iconColor: Colors.green,
                      iconBgColor: Colors.green.withValues(alpha: 0.1),
                      title: 'Vehicle',
                      subtitle: user?.driver?.vehiclePlateNumber ?? 'Not set',
                      onTap: () {},
                    ),
                    _GridCard(
                      icon: Icons.help_outline,
                      iconColor: Colors.grey,
                      iconBgColor: Colors.grey.withValues(alpha: 0.1),
                      title: 'Support',
                      subtitle: 'Help center',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Gap(16.h),
              // Menu list rows
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _MenuRow(
                      icon: Icons.person_outline,
                      label: 'Personal information',
                      onTap: () {},
                    ),
                    Divider(
                        height: 1,
                        color: Colors.grey[100],
                        indent: 56.w),
                    _MenuRow(
                      icon: Icons.description_outlined,
                      label: 'Documents & verification',
                      badge: authVm.hasDriverSubmittedDocs()
                          ? 'Approved'
                          : null,
                      onTap: () =>
                          authVm.checkIfDriverHasCompleteDocumentation(false),
                    ),
                    Divider(
                        height: 1,
                        color: Colors.grey[100],
                        indent: 56.w),
                    _MenuRow(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    Divider(
                        height: 1,
                        color: Colors.grey[100],
                        indent: 56.w),
                    _MenuRow(
                      icon: Icons.shield_outlined,
                      label: 'Privacy & security',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Gap(16.h),
              // Logout button
              GestureDetector(
                onTap: () async {
                  bool success = await authVm.logout();
                  if (success) {
                    rideVm.resetRideState();
                    Get.offAll(() => const LoginScreen(),
                        transition: Transition.leftToRight);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Gap(24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'BeauSans',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30.h,
        color: Colors.white.withValues(alpha: 0.2),
      );
}

class _GridCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GridCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
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
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.w),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'BeauSans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Gap(2.h),
              Text(
                subtitle,
                style:
                    TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(icon, size: 22.w, color: Colors.grey[500]),
              Gap(16.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (badge != null) Gap(8.w),
              Icon(Icons.chevron_right,
                  size: 18.w, color: Colors.grey[400]),
            ],
          ),
        ),
      );
}
